import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// `context.l10n.someKey` — concise access to the generated localizations.
extension AppL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
