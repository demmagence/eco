import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:eco/core/utils/date_formatter.dart';
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
        if (_nameController.text.isEmpty && profileVM.user != null && !profileVM.isSaving) {
          _nameController.text = profileVM.user!.displayName;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: profileVM.isLoading
              ? const Center(child: LoadingIndicator(message: 'Memuat profil...'))
              : Stack(
                  children: [
                    // ── BACKGROUND ARTWORK SYSTEM ──
                    _buildBackgroundArtwork(),

                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // ── PREMIUM HERO HEADER ──
                        SliverAppBar(
                          expandedHeight: 280.0,
                          floating: false,
                          pinned: true,
                          backgroundColor: AppColors.lightPrimaryEmerald,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.white),
                              onPressed: () => _showInfoDialog(context),
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Emerald Background
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                  ),
                                ),
                                // Organic Shapes & Mountain Silhouettes (Layered Artwork)
                                Positioned(
                                  bottom: -20,
                                  left: -50,
                                  right: -50,
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: const BorderRadius.vertical(top: Radius.elliptical(300, 100)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -10,
                                  left: -20,
                                  right: -20,
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: const BorderRadius.vertical(top: Radius.elliptical(250, 80)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -50,
                                  right: -50,
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.06),
                                    ),
                                  ),
                                ),
                                // Subtle Leaf Decorations
                                Positioned(
                                  top: 60,
                                  right: 40,
                                  child: Icon(Icons.eco, color: Colors.white.withValues(alpha: 0.1), size: 48),
                                ),
                                Positioned(
                                  top: 120,
                                  left: 30,
                                  child: Icon(Icons.energy_savings_leaf, color: Colors.white.withValues(alpha: 0.08), size: 36),
                                ),
                                // Avatar Backdrop Glow
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          blurRadius: 40,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Avatar Section
                                Positioned(
                                  bottom: 30,
                                  left: 0,
                                  right: 0,
                                  child: ProfileAvatar(
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
                                ),
                                // Floating Particles
                                _buildFloatingParticle(left: 80, bottom: 90, size: 4),
                                _buildFloatingParticle(left: 120, bottom: 120, size: 6),
                                _buildFloatingParticle(right: 90, bottom: 70, size: 5),
                                _buildFloatingParticle(right: 140, bottom: 140, size: 8),
                              ],
                            ),
                          ),
                        ),

                        // ── BODY CONTENT ──
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.transparent, // Background handled by main Stack
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── USER INFORMATION CARD ──
                                _buildInfoCardWithWatermark(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Informasi Pribadi',
                                            style: TextStyle(
                                              color: AppColors.lightTextPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.lightSuccess.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Active',
                                              style: TextStyle(
                                                color: AppColors.lightSuccess,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      _buildEditableField(
                                        label: 'Nama Lengkap',
                                        controller: _nameController,
                                        isLoading: profileVM.isSaving,
                                        onSave: () async {
                                          FocusScope.of(context).unfocus();
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
                                      ),
                                      const SizedBox(height: 20),
                                      _buildReadOnlyField(
                                        label: 'Username',
                                        value: '@${profileVM.user?.displayLabel ?? '-'}',
                                        icon: Icons.alternate_email,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildReadOnlyField(
                                        label: 'Email',
                                        value: 'user@example.com',
                                        icon: Icons.email_outlined,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

                                const SizedBox(height: 32),

                                // ── PROFILE STATISTICS SECTION ──
                                const Text(
                                  'Aktivitas Lingkungan',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCardWithWatermark(
                                        padding: const EdgeInsets.all(20),
                                        child: _buildStatCardContent(
                                          title: 'Total Scan',
                                          value: '${profileVM.totalScans}',
                                          icon: Icons.document_scanner_outlined,
                                          color: AppColors.lightPrimaryEmerald,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInfoCardWithWatermark(
                                        padding: const EdgeInsets.all(20),
                                        child: _buildStatCardContent(
                                          title: 'Anggota Sejak',
                                          value: profileVM.user != null
                                              ? DateFormatter.formatDate(profileVM.user!.createdAt)
                                              : '-',
                                          icon: Icons.calendar_today_outlined,
                                          color: AppColors.lightAccentEmerald,
                                          isDate: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),

                                const SizedBox(height: 32),

                                // ── SETTINGS SECTION ──
                                const Text(
                                  'Pengaturan',
                                  style: TextStyle(
                                    color: AppColors.lightTextPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                                const SizedBox(height: 16),
                                _buildInfoCardWithWatermark(
                                  padding: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      _buildSettingTile(
                                        icon: Icons.notifications_outlined,
                                        title: 'Notifikasi',
                                        subtitle: 'Kelola preferensi pemberitahuan',
                                      ),
                                      const Divider(height: 1, color: AppColors.lightBorder),
                                      _buildSettingTile(
                                        icon: Icons.security_outlined,
                                        title: 'Privasi',
                                        subtitle: 'Keamanan akun dan data',
                                      ),
                                      const Divider(height: 1, color: AppColors.lightBorder),
                                      _buildSettingTile(
                                        icon: Icons.help_outline,
                                        title: 'Pusat Bantuan',
                                        subtitle: 'FAQ dan dukungan pelanggan',
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),

                                const SizedBox(height: 48),

                                // ── LOGOUT SECTION ──
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showLogoutDialog(context),
                                    icon: const Icon(Icons.logout, size: 20),
                                    label: const Text(
                                      AppStrings.signOut,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: AppColors.lightDanger,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ).copyWith(
                                      backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// Master Background System (Parallax/Depth)
  Widget _buildBackgroundArtwork() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base color
        Container(color: AppColors.lightBackground),
        // Layer 1: Soft radial emerald gradients (Opacity 5%-15%)
        Positioned(
          top: 300,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.03),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -150,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.03),
            ),
          ),
        ),
        // Layer 2: Blurred Organic Shapes
        Positioned(
          top: 400,
          left: 50,
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Positioned(
          bottom: 300,
          right: 50,
          child: Container(
            width: 150,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.lightAccentEmerald.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(150),
            ),
          ),
        ),
        // Apply Blur filter for Layer 2 & 1 integration
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
        // Layer 3: Environmental illustrations (subtle leaves/watermarks)
        Positioned(
          top: 450,
          right: 30,
          child: Icon(Icons.park, size: 120, color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.02)),
        ),
        Positioned(
          bottom: 200,
          left: 20,
          child: Icon(Icons.water, size: 180, color: AppColors.lightAccentEmerald.withValues(alpha: 0.03)),
        ),
        Positioned(
          bottom: 50,
          right: 80,
          child: Icon(Icons.eco, size: 80, color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.02)),
        ),
      ],
    );
  }

  Widget _buildFloatingParticle({double? top, double? bottom, double? left, double? right, required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 4, spreadRadius: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCardWithWatermark({required Widget child, EdgeInsets padding = const EdgeInsets.all(24)}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Leaf Watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.energy_savings_leaf,
              size: 100,
              color: AppColors.lightPrimaryEmerald.withValues(alpha: 0.03),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isLoading,
    required VoidCallback onSave,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: AppColors.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightPrimaryEmerald),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isLoading ? null : onSave,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.lightTextMuted, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardContent({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isDate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: isDate ? 16 : 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.lightAccentEmerald.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.lightPrimaryEmerald, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.lightTextMuted),
      onTap: () {},
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
