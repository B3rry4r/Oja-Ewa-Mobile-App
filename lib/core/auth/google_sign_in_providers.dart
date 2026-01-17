import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_service.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // For Google Sign-In to return an idToken for backend auth:
  // - iOS: Uses CLIENT_ID from GoogleService-Info.plist automatically
  // - Android: Uses the web client (serverClientId) to get idToken
  // 
  // The serverClientId should be the Web Client ID from Firebase Console.
  // On Android, SHA-1 fingerprint must be registered in Firebase Console.
  return GoogleSignIn(
    scopes: const [
      'email',
      'profile',
    ],
    // Web client ID for getting idToken on Android
    serverClientId: '443526782067-duvbgc0grl97ebpcjnqovov88aj0sfgn.apps.googleusercontent.com',
    // Explicitly set iOS client ID from firebase_options
    clientId: '443526782067-ga3m3iqcgh47cgflsq4us1736sv01hda.apps.googleusercontent.com',
  );
});

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService(ref.watch(googleSignInProvider));
});
