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
                                IntrinsicHeight(
                                  child: Row(
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                              _buildInfoCardWithWatermark(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      children: [
                                        _buildSettingTile(
                                          icon: Icons.notifications_outlined,
                                          title: 'Notifikasi',
                                          subtitle: 'Kelola preferensi pemberitahuan',
                                          onTap: () => _showNotificationSettings(context),
                                        ),
                                        const Divider(height: 1, color: AppColors.lightBorder),
                                        _buildSettingTile(
                                          icon: Icons.security_outlined,
                                          title: 'Privasi',
                                          subtitle: 'Keamanan akun dan data',
                                          onTap: () => _showPrivacySettings(context),
                                        ),
                                        const Divider(height: 1, color: AppColors.lightBorder),
                                        _buildSettingTile(
                                          icon: Icons.help_outline,
                                          title: 'Pusat Bantuan',
                                          subtitle: 'FAQ dan dukungan pelanggan',
                                          onTap: () => _showHelpCenter(context),
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
    return Container(
      color: AppColors.lightBackground,
    );
  }


  Widget _buildInfoCardWithWatermark({required Widget child, EdgeInsets padding = const EdgeInsets.all(24)}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
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
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
      onTap: onTap,
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

  void _showNotificationSettings(BuildContext context) {
    bool airQuality = true;
    bool dailyTips = true;
    bool activityReminder = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightTextMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pengaturan Notifikasi',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Kelola bagaimana dan kapan VibEco mengirimkan pemberitahuan ke perangkat Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text(
                      'Kualitas Udara Buruk',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Dapatkan peringatan instan saat kualitas udara di lokasi Anda memburuk.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: airQuality,
                    activeThumbColor: AppColors.lightPrimaryEmerald,
                    activeTrackColor: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setModalState(() => airQuality = val);
                    },
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24, color: AppColors.lightBorder),
                  SwitchListTile(
                    title: const Text(
                      'Tips Harian',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Terima tips ramah lingkungan harian untuk mendukung gaya hidup hijau.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: dailyTips,
                    activeThumbColor: AppColors.lightPrimaryEmerald,
                    activeTrackColor: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setModalState(() => dailyTips = val);
                    },
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24, color: AppColors.lightBorder),
                  SwitchListTile(
                    title: const Text(
                      'Pengingat Aktivitas',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Pengingat rutin untuk memindai lingkungan sekitar Anda.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: activityReminder,
                    activeThumbColor: AppColors.lightPrimaryEmerald,
                    activeTrackColor: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setModalState(() => activityReminder = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengaturan notifikasi disimpan'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimaryEmerald,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacySettings(BuildContext context) {
    bool shareData = true;
    bool preciseLocation = true;
    bool publicHistory = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightTextMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pengaturan Privasi',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Kontrol bagaimana data Anda digunakan untuk meningkatkan pengalaman VibEco.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text(
                      'Bagikan Data Lingkungan',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Bantu memetakan kondisi lingkungan secara anonim bersama komunitas.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: shareData,
                    activeThumbColor: AppColors.lightPrimaryEmerald,
                    activeTrackColor: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setModalState(() => shareData = val);
                    },
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24, color: AppColors.lightBorder),
                  SwitchListTile(
                    title: const Text(
                      'Lokasi Presisi',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Gunakan GPS presisi untuk mendapatkan data AQI dan cuaca yang sangat akurat.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: preciseLocation,
                    activeThumbColor: AppColors.lightPrimaryEmerald,
                    activeTrackColor: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setModalState(() => preciseLocation = val);
                    },
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24, color: AppColors.lightBorder),
                  SwitchListTile(
                    title: const Text(
                      'Riwayat Deteksi Publik',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Izinkan pengguna lain melihat kontribusi dan riwayat scan lingkungan Anda.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: publicHistory,
                    activeThumbColor: AppColors.lightPrimaryEmerald,
                    activeTrackColor: AppColors.lightPrimaryEmerald.withValues(alpha: 0.2),
                    onChanged: (val) {
                      setModalState(() => publicHistory = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined, color: AppColors.lightDanger),
                    title: const Text(
                      'Hapus Seluruh Riwayat',
                      style: TextStyle(
                        color: AppColors.lightDanger,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Tindakan ini permanen dan akan menghapus seluruh data scan Anda.',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      _showDeleteHistoryConfirmation(context);
                    },
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengaturan privasi disimpan'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimaryEmerald,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteHistoryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.lightCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Hapus Seluruh Riwayat?',
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus seluruh riwayat scan? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: AppColors.lightTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh riwayat berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: AppColors.lightDanger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightTextMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pusat Bantuan',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: const [
                        Text(
                          'Pertanyaan Sering Diajukan (FAQ)',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12),
                        ExpansionTile(
                          title: Text(
                            'Bagaimana cara kerja deteksi AI?',
                            style: TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'VibEco menggunakan kamera dan teknologi AI canggih untuk menganalisis jenis sampah atau kondisi lingkungan di sekitar Anda, memberikan saran daur ulang secara instan.',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text(
                            'Mengapa data kualitas air tidak muncul?',
                            style: TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Pastikan izin lokasi presisi Anda telah diaktifkan dan perangkat Anda terhubung ke internet.',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text(
                            'Apakah aplikasi ini gratis?',
                            style: TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Ya, seluruh fitur utama VibEco seperti deteksi sampah, pemantauan kualitas udara, dan asisten AI gratis digunakan untuk mendukung gaya hidup ramah lingkungan.',
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Menghubungi Dukungan VibEco via Email...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.mail_outline),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimaryEmerald,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        label: const Text(
                          'Hubungi Dukungan Pelanggan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
