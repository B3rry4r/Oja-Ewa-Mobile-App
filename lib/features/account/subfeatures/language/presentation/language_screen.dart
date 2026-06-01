import 'package:flutter/material.dart';

import 'package:ojaewa/app/widgets/app_page_scaffold.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/i18n/locale_controller.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';

/// Language picker. Switching updates [LocaleController], which rebuilds the
/// whole app (incl. RTL for Arabic) and persists the choice.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected =
      LocaleController.instance.locale.value?.languageCode ?? 'en';

  static const _languages = [
    (id: 'en', label: 'English', sub: 'Default'),
    (id: 'fr', label: 'French', sub: 'Français'),
    (id: 'ee', label: 'Ewe', sub: 'Eʋegbe'),
    (id: 'tw', label: 'Twi', sub: 'Akan'),
    (id: 'rw', label: 'Kinyarwanda', sub: 'Ikinyarwanda'),
    (id: 'ar', label: 'Arabic', sub: 'العربية'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.l10n.languageTitle,
      showActions: false,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.languageSubtitle,
            style: WBTypography.body.copyWith(
              color: WBColors.fgSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: WBSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: WBColors.surfaceCard,
              borderRadius: BorderRadius.circular(WBRadius.card),
              boxShadow: WBShadows.card,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _languages.length; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      LocaleController.instance.setLocale(_languages[i].id);
                      setState(() => _selected = _languages[i].id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: i == _languages.length - 1
                            ? null
                            : const Border(
                                bottom: BorderSide(color: WBColors.bgDivider),
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _languages[i].label,
                                  style: WBTypography.body.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _languages[i].sub,
                                  style: WBTypography.caption.copyWith(
                                    color: WBColors.fgSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _Radio(selected: _selected == _languages[i].id),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? WBColors.surfaceDark : WBColors.borderFilled,
          width: selected ? 6 : 1.5,
        ),
      ),
    );
  }
}
