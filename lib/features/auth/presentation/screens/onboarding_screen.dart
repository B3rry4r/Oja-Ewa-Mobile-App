import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ojaewa/app/theme/app_theme_colors.dart';
import 'package:ojaewa/core/resources/app_assets.dart';
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
                child: _controller.value.isInitialized
                    ? FittedBox(fit: BoxFit.cover, child: SizedBox(width: _controller.value.size.width, height: _controller.value.size.height, child: VideoPlayer(_controller)))
                    : Center(child: CircularProgressIndicator(color: colors.accent)),
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
      decoration: BoxDecoration(color: colors.surface, border: Border(top: BorderSide(color: colors.border))),
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
    final colors = context.appColors;
    return Text(
      'The Pan-African\nBeauty Market',
      style: TextStyle(fontSize: 22.5, fontWeight: FontWeight.w700, fontFamily: 'Campton', color: colors.textPrimary, height: 1.2),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.createAccount),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDAF40), foregroundColor: colors.onAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('Create Account'),
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    final colors = context.appColors;
    return Center(child: Text('By continuing, you agree to our terms.', style: TextStyle(color: colors.textSecondary, fontSize: 12)));
  }
}
