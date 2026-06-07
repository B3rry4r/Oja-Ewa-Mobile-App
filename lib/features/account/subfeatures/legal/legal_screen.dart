import 'package:flutter/material.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/app/widgets/header_icon_button.dart';
import 'package:ojaewa/core/resources/app_assets.dart';

import 'legal_content.dart';

/// Horizontal safe-area padding shared by every legal document, mirroring the
/// 20px reading column used across the polished WAWUBasket legal screens.
const double _kScreenPadding = 20;

/// Centred, comfortable reading column width on wide screens.
const double _kMaxContentWidth = 720;

/// In-app legal document screen (Terms / Privacy) — renders the content
/// directly in the UI rather than a PDF or external link.
class LegalDocScreen extends StatelessWidget {
  const LegalDocScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
    this.lastUpdated = kLegalEffectiveDate,
  });

  final String title;
  final String intro;
  final List<LegalSection> sections;
  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surfaceSecondary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                _kScreenPadding,
                12,
                _kScreenPadding,
                40,
              ),
              children: [
                _LegalHeader(title: title),
                const SizedBox(height: 24),
                _DocumentTitle(title),
                const SizedBox(height: 8),
                _LastUpdated(lastUpdated),
                const SizedBox(height: 8),
                _Body(intro),
                const SizedBox(height: 16),
                for (final s in sections) _Section(s.heading, s.body),
              ],
            ),
          ),
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
      backgroundColor: colors.surfaceSecondary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                _kScreenPadding,
                12,
                _kScreenPadding,
                40,
              ),
              children: [
                _LegalHeader(title: title),
                const SizedBox(height: 24),
                const _DocumentTitle('Frequently Asked Questions'),
                const SizedBox(height: 16),
                for (final g in groups) ...[
                  Text(
                    g.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final e in g.entries) _Section(e.question, e.answer),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header row: circular back button + page title, matching the WAWUBasket
/// screen-header rhythm.
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
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.36,
              height: 1.2,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Large document heading shown beneath the header row.
class _DocumentTitle extends StatelessWidget {
  const _DocumentTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: context.appColors.textPrimary,
      ),
    );
  }
}

/// "Effective Date" line under the document title.
class _LastUpdated extends StatelessWidget {
  const _LastUpdated(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: context.appColors.textTertiary,
      ),
    );
  }
}

/// Intro / lead paragraph typography.
class _Body extends StatelessWidget {
  const _Body(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: context.appColors.textSecondary,
      ),
    );
  }
}

/// A titled section: heading + body, with consistent bottom spacing rhythm.
class _Section extends StatelessWidget {
  const _Section(this.heading, this.body);
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
