/// Navigation arguments for password reset flow.
class PasswordResetArgs {
  const PasswordResetArgs({required this.email});

  final String email;
}

class NewPasswordArgs {
  const NewPasswordArgs({required this.email, required this.token});

  final String email;
  final String token;
}
