/// Navigation arguments for password reset flow.
///
/// [identifier] is the account email entered on the reset screen — WAWU ID
/// emails the 6-digit reset code there (WhatsApp/SMS isn't live yet).
class PasswordResetArgs {
  const PasswordResetArgs({required this.identifier});

  final String identifier;
}

class NewPasswordArgs {
  const NewPasswordArgs({required this.identifier, required this.token});

  final String identifier;
  final String token;
}
