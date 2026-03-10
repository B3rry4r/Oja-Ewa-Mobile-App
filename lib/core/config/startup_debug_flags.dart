import 'dart:io';

import 'package:flutter/foundation.dart';

/// Temporary startup isolation flags for device-specific iOS launch debugging.
///
/// Toggle these to narrow down which native/plugin startup path is causing an
/// early crash before the first Flutter frame appears.
abstract final class StartupDebugFlags {
  static const bool isolateIosStartupPlugins = true;
  static const bool disableIosFcmStartup = true;
  static const bool disableIosLocalNotificationsStartup = true;
  static const bool disableIosDeepLinksStartup = true;

  static bool get isIosStartupIsolationEnabled =>
      !kIsWeb && Platform.isIOS && isolateIosStartupPlugins;

  static bool get shouldDisableFcmAtStartup =>
      isIosStartupIsolationEnabled && disableIosFcmStartup;

  static bool get shouldDisableLocalNotificationsAtStartup =>
      isIosStartupIsolationEnabled && disableIosLocalNotificationsStartup;

  static bool get shouldDisableDeepLinksAtStartup =>
      isIosStartupIsolationEnabled && disableIosDeepLinksStartup;
}
