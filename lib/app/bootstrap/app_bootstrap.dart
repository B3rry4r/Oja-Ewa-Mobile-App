import 'package:flutter/material.dart';

/// Pass-through bootstrap widget.
///
/// Auth is loaded in main() before runApp() via loadFromStorage(), so by the
/// time the widget tree builds, authControllerProvider is already in a
/// definitive state (AuthAuthenticated or AuthUnauthenticated).
///
/// The SplashScreen handles the initial routing decision by reading
/// accessTokenProvider directly. No FutureProvider gating is needed here —
/// that approach caused navigator stack corruption when the FutureProvider
/// re-ran after connectivity or other rebuilds temporarily replaced the
/// entire widget tree with a loading spinner.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
