import 'package:dio/dio.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/network/dio_error_mapper.dart';
import 'logout_endpoints.dart';

/// Low-level API client for auth endpoints.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// Authenticate against WAWU ID, with organic migration of existing Beauty
  /// users on first login.
  ///
  /// Flow:
  /// 1. Try WAWU ID. If the user already exists there, we're done.
  /// 2. If WAWU ID doesn't know the user yet (404 / USER_NOT_IN_WAWUID),
  ///    verify the credentials against the old Beauty auth.
  /// 3. If Beauty accepts them, silently provision the user on WAWU ID so all
  ///    future logins go straight through the new system.
  /// 4. If that provisioning fails, fall back to the Beauty token so the user
  ///    still gets in; migration is retried on the next login.
  ///
  /// WAWU ID returns: {"data": {"accessToken": "...", "refreshToken": "...",
  /// "user": {...}}}. Returns both tokens keyed as 'accessToken'/'refreshToken'.
  Future<Map<String, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Try WAWU ID first.
      final res = await _dio.post(
        '${AppUrls.wawuIdBaseUrl}/auth/login',
        data: {'identifier': email, 'password': password},
      );
      final wawuToken = _extractToken(res.data);
      if (wawuToken == null || wawuToken.isEmpty) {
        throw const FormatException('Token missing in response');
      }
      // WAWU ID tokens don't authenticate the Beauty (Laravel) API — swap for a
      // Beauty session so the rest of the app works and we aren't bounced to
      // login after landing on home.
      return await _exchangeWawuIdForBeautySession(wawuToken);
    } catch (e) {
      // Only fall back when WAWU ID simply doesn't have this user yet. Any
      // other failure (wrong password, network, 5xx) is a real error.
      if (!_isUserNotInWawuId(e)) throw mapDioError(e);

      // Verify credentials against the old Beauty auth — this mints a Beauty
      // (Sanctum) session directly, which is the session we keep.
      final Response oldRes;
      try {
        oldRes = await _dio.post(
          '/api/login',
          data: {'email': email, 'password': password},
        );
      } catch (beautyError) {
        throw mapDioError(beautyError);
      }
      final sanctum = _extractToken(oldRes.data) ?? '';

      // Best-effort: mirror the account into WAWU ID for next time. Do NOT
      // switch the session to the WAWU ID token — the Beauty session above is
      // what the Laravel API authenticates. Next login takes the primary path.
      try {
        final userData = oldRes.data['data']['user'];
        await _dio.post(
          '${AppUrls.wawuIdBaseUrl}/auth/register',
          data: {
            'identifier': email,
            'email': email,
            'password': password,
            'phone': userData['phone'] ?? '',
            'fullName':
                '${userData['firstname'] ?? ''} ${userData['lastname'] ?? ''}'
                    .trim(),
            'country': 'Nigeria',
          },
        );
      } catch (_) {
        // Mirror failed / needs OTP — retries on next login.
      }

      return {'accessToken': sanctum, 'refreshToken': ''};
    }
  }

  /// Swap a WAWU ID access token for a Beauty (Sanctum) session token. Uses a
  /// bare Dio carrying the WAWU ID bearer so the app's auth interceptor (which
  /// would attach/overwrite with the stored token) can't interfere.
  Future<Map<String, String>> _exchangeWawuIdForBeautySession(
      String wawuAccessToken) async {
    final bare = Dio(BaseOptions(
      baseUrl: AppUrls.laravelBaseUrl,
      headers: {'Authorization': 'Bearer $wawuAccessToken'},
    ));
    final res = await bare.post('/api/auth/wawu/exchange');
    return _extractTokens(res.data); // { data: { token } } → Sanctum session
  }

  /// True when a WAWU ID error means the account hasn't been migrated yet
  /// (so we should try the old Beauty auth), rather than a genuine failure.
  bool _isUserNotInWawuId(Object e) {
    if (e is DioException && e.response?.statusCode == 404) return true;
    final msg = e.toString();
    return msg.contains('USER_NOT_IN_WAWUID') || msg.contains('404');
  }

  Future<Map<String, String>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String country,
    String? referralCode,
    String? gender,
  }) async {
    try {
      // WAWU ID's RegisterDto requires a phone (min 7 chars) and a country.
      final data = {
        'fullName': '$firstname $lastname'.trim(),
        'email': email,
        'password': password,
        'phone': phone,
        'country': country,
      };

      // Optional canonical identity gender (lowercase 'male'|'female').
      if (gender != null && gender.isNotEmpty) {
        data['gender'] = gender;
      }

      // Add referral_code if provided
      if (referralCode != null && referralCode.isNotEmpty) {
        data['referral_code'] = referralCode;
      }

      final res = await _dio.post(
        '${AppUrls.wawuIdBaseUrl}/auth/register',
        data: data,
      );

      final wawuToken = _extractToken(res.data);
      if (wawuToken == null || wawuToken.isEmpty) {
        throw const FormatException('Token missing in response');
      }
      // Record privacy-policy consent on WAWU ID (the sign-up screen gates on
      // accepting the terms) before swapping for a Beauty session.
      await _recordPrivacyConsent(wawuToken);
      // Swap the WAWU ID token for a Beauty (Sanctum) session.
      return await _exchangeWawuIdForBeautySession(wawuToken);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Records the user's consent to the current privacy-policy version on WAWU ID
  /// (the shared ecosystem consent ledger). Uses the WAWU ID access token
  /// directly. Best-effort — a consent-logging failure must never block sign-up.
  Future<void> _recordPrivacyConsent(String wawuToken) async {
    try {
      await _dio.post(
        '${AppUrls.wawuIdBaseUrl}/policies/privacy/accept',
        data: {'source': 'wawubeauty'},
        options: Options(headers: {'Authorization': 'Bearer $wawuToken'}),
      );
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Best-effort server logout.
  ///
  /// Because the API docs do not currently document user logout, we try a small
  /// set of common endpoints. Any failure should NOT block local sign-out.
  Future<void> logout() async {
    // Backend contract: POST /api/logout
    await _dio.post(userLogoutPath);
  }

  Future<void> forgotPassword({required String identifier}) async {
    try {
      await _dio.post(
        '${AppUrls.wawuIdBaseUrl}/auth/forgot-password',
        // WAWU ID's ForgotPasswordDto keys on `identifier` (email OR phone);
        // method defaults to 'sms', so a Termii code goes to the phone.
        data: {'identifier': identifier},
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> resetPassword({
    required String identifier,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      // WAWU ID's SMS-code reset path expects { identifier, code, newPassword }.
      // The recovery flow delivers a Termii SMS code (forgot-password), and the
      // verification screen forwards it here as [token].
      await _dio.post(
        '${AppUrls.wawuIdBaseUrl}/auth/reset-password',
        data: {
          'identifier': identifier,
          'code': token,
          'newPassword': password,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<String> googleSignIn({
    required String idToken,
    String? referralCode,
  }) async {
    try {
      final data = {
        'idToken': idToken,
      };
      
      // Add referral_code if provided
      if (referralCode != null && referralCode.isNotEmpty) {
        data['referral_code'] = referralCode;
      }

      final res = await _dio.post(
        '/api/oauth/google',
        data: data,
      );

      final token = _extractToken(res.data);
      if (token == null || token.isEmpty) {
        throw const FormatException('Token missing in response');
      }
      return token;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Permanently delete the authenticated user's account.
  ///
  /// Backend contract: DELETE /api/account
  /// Requires: Authorization: Bearer <token>
  /// Expected response: 200 OK with {"message": "Account deleted successfully"}
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/api/account');
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Apply referral code after OAuth sign-up (authenticated endpoint)
  Future<void> setReferralCode({required String referralCode}) async {
    try {
      await _dio.post(
        '/api/set-referral-code',
        data: {
          'referral_code': referralCode,
        },
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

/// Pulls both tokens out of a WAWU ID response and validates the access token.
Map<String, String> _extractTokens(dynamic data) {
  final accessToken = _extractToken(data);
  if (accessToken == null || accessToken.isEmpty) {
    throw const FormatException('Token missing in response');
  }
  return {
    'accessToken': accessToken,
    'refreshToken': _extractRefreshToken(data) ?? '',
  };
}

String? _extractToken(dynamic data) {
  if (data is Map<String, dynamic>) {
    // WAWU ID shape: {"data": {"accessToken": "..."}}
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final access = nested['accessToken'];
      if (access is String) return access;

      // Old Sanctum nested shape: {"data": {"token": "..."}}
      final t = nested['token'];
      if (t is String) return t;
    }

    // Old Sanctum flat shape: {"token": "..."}
    final direct = data['token'];
    if (direct is String) return direct;
  }
  return null;
}

String? _extractRefreshToken(dynamic data) {
  if (data is Map<String, dynamic>) {
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      final r = nested['refreshToken'];
      if (r is String) return r;
    }

    final direct = data['refreshToken'];
    if (direct is String) return direct;
  }
  return null;
}
