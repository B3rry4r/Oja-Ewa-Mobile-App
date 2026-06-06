import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'legal_content.dart';

/// In-app legal document screen (Terms / Privacy) — renders the content
/// directly in the UI rather than a PDF or external link.
class LegalDocScreen extends StatelessWidget {
  const LegalDocScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            _LegalHeader(title: title),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              intro,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            for (final s in sections) ...[
              Text(
                s.heading,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.body,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

/// In-app FAQ screen — grouped question/answer content rendered in the UI.
class LegalFaqScreen extends StatelessWidget {
  const LegalFaqScreen({super.key, this.title = 'FAQ', this.groups = kFaqGroups});

  final String title;
  final List<FaqGroup> groups;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            _LegalHeader(title: title),
            const SizedBox(height: 20),
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            for (final g in groups) ...[
              Text(
                g.category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: 12),
              for (final e in g.entries) ...[
                Text(
                  e.question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  e.answer,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        HeaderIconButton(
          asset: AppIcons.back,
          iconColor: colors.textPrimary,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
