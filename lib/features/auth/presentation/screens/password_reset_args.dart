/// Navigation arguments for password reset flow.
///
/// [identifier] is the account's phone number (E.164) entered on the reset
/// screen — WAWU ID texts the reset code there via Termii.
class PasswordResetArgs {
  const PasswordResetArgs({required this.identifier});

  final String identifier;
}

class NewPasswordArgs {
  const NewPasswordArgs({required this.identifier, required this.token});

  final String identifier;
  final String token;
}
