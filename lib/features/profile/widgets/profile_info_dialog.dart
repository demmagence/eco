import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';

class ProfileInfoDialog extends StatelessWidget {
  const ProfileInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: AlertDialog(
        backgroundColor: AppColors.backgroundSecondary.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: AppColors.accent),
            SizedBox(width: 8),
            Text(
              AppStrings.profileInfoTitle,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _InfoRow(
              icon: Icons.alternate_email,
              text: 'Username tidak dapat diubah setelah registrasi.',
            ),
            SizedBox(height: 12),
            _InfoRow(
              icon: Icons.edit_outlined,
              text: 'Nama tampilan dapat disesuaikan sesuka Anda.',
            ),
            SizedBox(height: 12),
            _InfoRow(
              icon: Icons.logout,
              text: 'Keluar akan menghapus sesi login aktif Anda.',
            ),
            SizedBox(height: 12),
            _InfoRow(
              icon: Icons.login,
              text: 'Anda dapat masuk kembali kapan saja dengan akun Google.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.accent.withValues(alpha: 0.7),
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
