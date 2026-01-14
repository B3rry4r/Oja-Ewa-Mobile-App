// edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ojaewa/app/widgets/app_header.dart';
import 'package:ojaewa/core/widgets/image_placeholder.dart';
import 'package:ojaewa/features/account/presentation/controllers/profile_controller.dart';

import '_error_state.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final actions = ref.watch(profileActionsProvider);

    ref.listen(userProfileProvider, (prev, next) {
      next.whenData((u) {
        // Populate once; avoid overwriting user edits.
        if (_nameController.text.isEmpty) _nameController.text = u.fullName;
        if (_emailController.text.isEmpty) _emailController.text = u.email;
        if (_phoneController.text.isEmpty)
          _phoneController.text = u.phone ?? '';
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background image
            Positioned(
              right: -30,
              bottom: -100,
              child: Opacity(
                opacity: 0.03,
                child: Container(
                  child: const AppImagePlaceholder(
                    width: 234,
                    height: 347,
                    borderRadius: 0,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                const AppHeader(
                  backgroundColor: Color(0xFFFFF8F1),
                  iconColor: Color(0xFF241508),
                  title: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF241508),
                    ),
                  ),
                ),
                Expanded(
                  child: profile.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => ErrorStateView(
                      title: 'Could not load your profile',
                      message: 'Please check your connection and try again.',
                      details: e,
                      onRetry: () => ref.invalidate(userProfileProvider),
                    ),
                    data: (_) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildTextField(
                              label: 'Full Name',
                              controller: _nameController,
                            ),
                            const SizedBox(height: 19),
                            _buildTextField(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 19),
                            _buildTextField(
                              label: 'Phone Number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 60),
                            _buildSaveButton(context, actions),
                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Campton',
            fontWeight: FontWeight.w400,
            color: Color(0xFF777F84),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 49,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w400,
              color: Color(0xFF241508),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, AsyncValue<void> actions) {
    return Container(
      height: 57,
      decoration: BoxDecoration(
        color: const Color(0xFFFDAF40),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDAF40).withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: actions.isLoading
              ? null
              : () async {
                  await ref
                      .read(profileActionsProvider.notifier)
                      .updateProfile(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim().isEmpty
                            ? null
                            : _phoneController.text.trim(),
                      );
                  if (!mounted) return;
                  if (ref.read(profileActionsProvider).hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ref.read(profileActionsProvider).error.toString(),
                        ),
                        backgroundColor: const Color(0xFFFDAF40),
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                },
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: actions.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFFBF5),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Campton',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFBF5),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
