import 'package:flutter/material.dart';

/// Pass-through bootstrap widget.
///
/// Auth loading is kicked off from main(), but launch no longer blocks on
/// secure-storage I/O. The splash screen waits for the auth state to resolve
/// if startup work is still in flight.
///
/// No FutureProvider gating is needed here — that approach caused navigator
/// stack corruption when the FutureProvider re-ran after connectivity or other
/// rebuilds temporarily replaced the entire widget tree with a loading spinner.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
