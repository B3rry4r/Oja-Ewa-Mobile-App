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
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AppException('Google sign-in cancelled');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AppException(
          'Google sign-in succeeded but no idToken was returned. Check Google configuration (reversed client id on iOS / SHA-1 on Android).',
        );
      }

      return idToken;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Google sign-in failed', cause: e);
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
