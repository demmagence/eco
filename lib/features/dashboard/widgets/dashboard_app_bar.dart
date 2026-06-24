import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/data/models/user_model.dart';

/// Custom AppBar for the Dashboard: left = clock + city, right = avatar + name + @username.
class DashboardAppBar extends StatelessWidget {
  final String currentTime;
  final String cityName;
  final UserModel? user;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    super.key,
    required this.currentTime,
    required this.cityName,
    this.user,
    this.onLocationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left: Clock + Location ──
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onLocationTap?.call();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTime,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cityName.isNotEmpty ? cityName : 'Lokasi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Right: Profile Section ──
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onProfileTap?.call();
            },
            child: Row(
              children: [
                // Name + Username
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (user?.displayName.isNotEmpty == true)
                      Text(
                        user!.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (user?.formattedUsername != null)
                      Text(
                        user!.formattedUsername!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    else if (user?.displayName.isEmpty == true &&
                        user?.email.isNotEmpty == true)
                      Text(
                        user!.email,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Avatar
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user?.photoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: user!.photoUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 44,
      height: 44,
      color: AppColors.primaryEmerald,
      child: const Icon(
        Icons.person,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }
}
