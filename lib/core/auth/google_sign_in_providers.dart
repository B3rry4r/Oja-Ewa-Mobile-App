import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_service.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // Using default configuration. On iOS you must set REVERSED_CLIENT_ID in Info.plist,
  // and on Android ensure SHA-1 is configured in Firebase/Google console.
  return GoogleSignIn(
    scopes: const [
      'email',
      'profile',
    ],
  );
});

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService(ref.watch(googleSignInProvider));
});
