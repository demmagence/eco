import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eco/core/constants/app_colors.dart';
import 'package:eco/data/models/user_model.dart';

/// Custom AppBar for the Dashboard — Light Mode
/// Left = clock + city, Right = avatar + name + @username.
class DashboardAppBar extends StatelessWidget {
  final String cityName;
  final UserModel? user;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    super.key,
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
          // ── Left: Location ──
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onLocationTap?.call();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.lightAccentEmerald,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cityName.isNotEmpty ? cityName : 'Lokasi',
                          style: const TextStyle(
                            color: AppColors.lightDarkEmerald,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
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

          const SizedBox(width: 16), // Spacer to avoid clashing when texts are long

          // ── Right: Profile Section ──
          Flexible(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onProfileTap?.call();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Name + Username
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user?.displayName.isNotEmpty == true)
                          Text(
                            user!.displayName,
                            style: const TextStyle(
                              color: AppColors.lightDarkEmerald,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (user?.formattedUsername != null)
                          Text(
                            user!.formattedUsername,
                            style: const TextStyle(
                              color: AppColors.lightTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else if (user?.displayName.isEmpty == true &&
                            user?.email.isNotEmpty == true)
                          Text(
                            user!.email,
                            style: const TextStyle(
                              color: AppColors.lightTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 44,
      height: 44,
      color: AppColors.lightAccentEmerald.withValues(alpha: 0.1),
      child: const Icon(
        Icons.person,
        color: AppColors.lightPrimaryEmerald,
        size: 24,
      ),
    );
  }
}
