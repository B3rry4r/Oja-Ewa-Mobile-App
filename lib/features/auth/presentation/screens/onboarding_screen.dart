// onboarding_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
import 'package:ojaewa/core/i18n/l10n_ext.dart';
import 'package:ojaewa/core/theme/wb_theme_exports.dart';
import 'package:ojaewa/core/widgets/wb_widgets.dart';
import 'package:ojaewa/app/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(AppVideos.onboardingVideo)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.surfaceSecondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                child: Stack(
                  children: [
                    if (_controller.value.isInitialized)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [colors.surfaceSecondary, colors.surfaceSecondary],
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 18,
                      child: const Center(
                        child: WBWordmark(height: 30, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeadline(context),
          const SizedBox(height: 14),
          _buildActionButtons(context),
          const SizedBox(height: 10),
          _buildTermsAndPrivacy(context),
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context) {
    return Text(
      context.l10n.onboardingTitle,
      style: WBTypography.page.copyWith(fontWeight: FontWeight.w700, height: 1.2),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        WBButton(
          label: context.l10n.authCreateAccount,
          fullWidth: true,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.createAccount),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: WBButton(
                label: context.l10n.authSignIn,
                fullWidth: true,
                variant: WBButtonVariant.secondary,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: WBButton(
                label: context.l10n.authGuest,
                fullWidth: true,
                variant: WBButtonVariant.secondary,
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: WBTypography.caption.copyWith(
            color: WBColors.fgSecondary,
            height: 1.4,
          ),
          children: [
            TextSpan(text: context.l10n.onboardingTerms),
            TextSpan(
              text: context.l10n.onboardingTermsOfService,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.of(context).pushNamed(AppRoutes.termsOfService),
            ),
            TextSpan(text: context.l10n.onboardingAnd),
            TextSpan(
              text: context.l10n.onboardingPrivacy,
              style: WBTypography.caption.copyWith(
                color: WBColors.fgHeader,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}
