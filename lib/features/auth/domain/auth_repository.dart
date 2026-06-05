abstract interface class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String country,
    String? referralCode,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String identifier});

  Future<void> resetPassword({
    required String identifier,
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  /// Backend supports `POST /api/auth/google`.
  ///
  /// Note: the app still needs to obtain `idToken` (Google sign-in SDK).
  Future<void> googleSignIn({
    required String idToken,
    String? referralCode,
  });

  /// Apply referral code after OAuth sign-up (authenticated endpoint)
  Future<void> setReferralCode({required String referralCode});

  /// Permanently delete the authenticated user's account and sign out locally.
  Future<void> deleteAccount();
}
