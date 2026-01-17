import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_service.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // serverClientId is the Web Client ID from Firebase/Google Cloud Console.
  // This is required to get an idToken for backend authentication.
  // On iOS you must also set REVERSED_CLIENT_ID in Info.plist.
  // On Android ensure SHA-1 is configured in Firebase console.
  return GoogleSignIn(
    scopes: const [
      'email',
      'profile',
    ],
    serverClientId: '443526782067-duvbgc0grl97ebpcjnqovov88aj0sfgn.apps.googleusercontent.com',
  );
});

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService(ref.watch(googleSignInProvider));
});
