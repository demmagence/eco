import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/data/models/user_model.dart';

/// Custom AppBar for the Dashboard — Light Mode
/// Left = greeting + city, Right = avatar + name + @username.
class DashboardAppBar extends StatelessWidget {
  final String cityName;
  final String userName;
  final UserModel? user;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    super.key,
    required this.cityName,
    this.userName = 'User',
    this.user,
    this.onLocationTap,
    this.onProfileTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName.split(' ').first
        : userName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left: Greeting + Location ──
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onLocationTap?.call();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $displayName!',
                    style: const TextStyle(
                      color: AppColors.lightDarkEmerald,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.lightAccentEmerald,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cityName.isNotEmpty ? cityName : 'Lokasi',
                          style: const TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ── Right: Profile Section ──
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onProfileTap?.call();
            },
            child: Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user?.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user!.photoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => _defaultAvatar(),
                        )
                      : _defaultAvatar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.lightAccentEmerald.withValues(alpha: 0.1),
      child: const Icon(
        Icons.person,
        color: AppColors.lightPrimaryEmerald,
        size: 26,
      ),
    );
  }
}
