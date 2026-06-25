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
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.primary,
                  width: 4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: isSaving
                        ? _loadingState()
                        : photoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: photoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _loadingState(),
                                errorWidget: (context, url, error) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                  ),
                ),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
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
      baseColor: AppColors.divider,
      highlightColor: AppColors.surface,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.mintGreen.withValues(alpha: 0.3),
      child: const Icon(
        Icons.person,
        color: AppColors.primary,
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
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.primary),
                  ),
                  title: const Text(
                    AppStrings.pickFromGallery,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage();
                  },
                ),
                if (photoUrl != null) ...[
                  const Divider(color: AppColors.divider, height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.danger),
                    ),
                    title: const Text(
                      AppStrings.removeAvatar,
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
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
