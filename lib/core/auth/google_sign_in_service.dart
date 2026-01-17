import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/app_exception.dart';

/// Handles Google OAuth sign-in on device and returns an ID token.
///
/// The returned `idToken` is sent to the backend (`POST /api/auth/google`).
class GoogleSignInService {
  GoogleSignInService(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  Future<String> signInAndGetIdToken() async {
    try {
      debugPrint('[GoogleSignIn] Starting sign-in flow...');
      final account = await _googleSignIn.signIn();
      
      if (account == null) {
        debugPrint('[GoogleSignIn] User cancelled');
        throw const AppException('Google sign-in cancelled');
      }

      debugPrint('[GoogleSignIn] Account: ${account.email}');
      final auth = await account.authentication;
      final idToken = auth.idToken;
      
      if (idToken == null || idToken.isEmpty) {
        debugPrint('[GoogleSignIn] ERROR: idToken is null');
        throw const AppException(
          'Google sign-in succeeded but no idToken was returned. Check Google configuration (reversed client id on iOS / SHA-1 on Android).',
        );
      }

      debugPrint('[GoogleSignIn] Success - got idToken');
      return idToken;
    } on PlatformException catch (e) {
      debugPrint('[GoogleSignIn] PlatformException: ${e.code} - ${e.message}');
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        throw const AppException('Google sign-in cancelled');
      }
      throw AppException('Google sign-in failed: ${e.message}');
    } on AppException {
      rethrow;
    } catch (e, stack) {
      debugPrint('[GoogleSignIn] Error: $e');
      debugPrint('[GoogleSignIn] Stack: $stack');
      throw AppException('Google sign-in failed', cause: e);
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
