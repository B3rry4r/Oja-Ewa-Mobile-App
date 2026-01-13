import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

/// Kicks off loading auth state from secure storage at app start.
///
/// This is separated so we can trigger it from a small bootstrap widget.
final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authControllerProvider.notifier).loadFromStorage();
});
