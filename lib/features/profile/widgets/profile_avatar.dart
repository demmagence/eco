import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/core/constants/app_strings.dart';
import 'package:shimmer/shimmer.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool isSaving;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.isSaving,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Avatar display
          Hero(
            tag: 'profile_avatar',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: isSaving
                    ? _loadingState()
                    : photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: photoUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _loadingState(),
                            errorWidget: (context, url, error) => _defaultAvatar(),
                          )
                        : _defaultAvatar(),
              ),
            ),
          ),

          // Floating Edit / Change button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isSaving ? null : () => _showPickerOptions(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundPrimary,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.backgroundPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.primaryEmerald.withValues(alpha: 0.3),
      highlightColor: AppColors.secondaryEmerald.withValues(alpha: 0.5),
      child: Container(
        width: 120,
        height: 120,
        color: AppColors.primaryEmerald,
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.primaryEmerald,
      child: const Icon(
        Icons.person,
        color: AppColors.accent,
        size: 60,
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.accent),
                  title: const Text(
                    AppStrings.pickFromGallery,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage();
                  },
                ),
                if (photoUrl != null) ...[
                  const Divider(color: AppColors.surface),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text(
                      AppStrings.removeAvatar,
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onRemoveImage();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
