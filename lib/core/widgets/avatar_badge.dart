import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

enum AvatarRole {
  brand,
  creator,
  neutral,
}

/// AvatarBadge
/// Standard circular avatar with role-tinted border, image cache, and fallback initials
class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48.0,
    this.role = AvatarRole.neutral,
    this.isVerified = false,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final AvatarRole role;
  final bool isVerified;
  final VoidCallback? onTap;

  String _getInitials(String input) {
    final parts = input.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Color ringColor = switch (role) {
      AvatarRole.brand => AppColors.blue400,
      AvatarRole.creator => AppColors.pink400,
      AvatarRole.neutral => AppColors.ink100,
    };

    final initials = _getInitials(name);

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2.0),
        boxShadow: const [AppColors.shadowSm],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.ink100,
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTypography.headline.copyWith(
                        fontSize: size * 0.38,
                        color: AppColors.ink700,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.ink100,
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTypography.headline.copyWith(
                        fontSize: size * 0.38,
                        color: AppColors.ink700,
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                color: switch (role) {
                  AvatarRole.brand => AppColors.blue100,
                  AvatarRole.creator => AppColors.pink100,
                  AvatarRole.neutral => AppColors.ink100,
                },
                child: Center(
                  child: Text(
                    initials,
                    style: AppTypography.headline.copyWith(
                      fontSize: size * 0.38,
                      color: switch (role) {
                        AvatarRole.brand => AppColors.blue700,
                        AvatarRole.creator => AppColors.pink700,
                        AvatarRole.neutral => AppColors.ink700,
                      },
                    ),
                  ),
                ),
              ),
      ),
    );

    if (isVerified) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsets.all(AppTokens.space1 / 2),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: const BoxDecoration(
                  color: AppColors.blue500,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: size * 0.22,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
