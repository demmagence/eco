import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/utils/date_formatter.dart';
import 'package:eco/core/widgets/glass_card.dart';
import 'package:eco/core/widgets/loading_indicator.dart';
import 'package:eco/features/auth/auth_viewmodel.dart';
import 'package:eco/features/profile/profile_viewmodel.dart';
import 'package:eco/features/profile/widgets/profile_avatar.dart';
import 'package:eco/features/profile/widgets/profile_info_dialog.dart';
import 'package:eco/features/profile/widgets/logout_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileVM = context.read<ProfileViewModel>();
      await profileVM.loadProfile();
      if (profileVM.user != null) {
        _nameController.text = profileVM.user!.displayName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        // Sync name if loaded and controller is empty
        if (_nameController.text.isEmpty && profileVM.user != null && !profileVM.isSaving) {
          _nameController.text = profileVM.user!.displayName;
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              AppStrings.profile,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.accent),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          body: profileVM.isLoading
              ? const Center(child: LoadingIndicator(message: 'Memuat profil...'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar selection/display
                      ProfileAvatar(
                        photoUrl: profileVM.user?.photoUrl,
                        isSaving: profileVM.isSaving,
                        onPickImage: () async {
                          final success = await profileVM.pickAndUploadAvatar();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto profil berhasil diperbarui'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        onRemoveImage: () async {
                          final success = await profileVM.removeAvatar();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto profil berhasil dihapus'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

                      const SizedBox(height: 32),

                      // Name TextField Container (GlassCard)
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.editProfile,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              AppStrings.name,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama Anda',
                                hintStyle: const TextStyle(color: AppColors.textMuted),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.glassBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.glassBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              AppStrings.username,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: profileVM.user?.displayLabel ?? '-',
                              ),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.01),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.5)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                suffixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: profileVM.isSaving
                                    ? null
                                    : () async {
                                        final success = await profileVM.updateDisplayName(_nameController.text.trim());
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Nama berhasil disimpan'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.backgroundPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                  elevation: 0,
                                ),
                                child: profileVM.isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(AppColors.backgroundPrimary),
                                        ),
                                      )
                                    : const Text(
                                        AppStrings.saveName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                      const SizedBox(height: 20),

                      // Stats Cards (Row using GlassCard)
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.document_scanner_outlined,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${profileVM.totalScans}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    AppStrings.totalScans,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    profileVM.user != null
                                        ? DateFormatter.formatDate(profileVM.user!.createdAt)
                                        : '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    AppStrings.memberSince,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                      const SizedBox(height: 32),

                      // Logout Button (outlined but modern)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout),
                          label: const Text(AppStrings.signOut),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProfileInfoDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => LogoutDialog(
        onLogout: () async {
          await context.read<AuthViewModel>().signOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
