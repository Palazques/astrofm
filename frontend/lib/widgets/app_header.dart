import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

/// App header with logo and navigation buttons.
class AppHeader extends StatelessWidget {
  final bool showBackButton;
  final bool showMenuButton;
  final bool showNotificationButton;
  final bool showSettingsButton;
  final String? title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSettingsPressed;
  final Widget? rightAction;

  const AppHeader({
    super.key,
    this.showBackButton = false,
    this.showMenuButton = true,
    this.showNotificationButton = true,
    this.showSettingsButton = false,
    this.title,
    this.onBackPressed,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onSettingsPressed,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left button
          _buildLeftButton(context),

          // Center: Logo or Title
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          else
            _buildLogo(),

          // Right button
          _buildRightButton(),
        ],
      ),
    );
  }

  Widget _buildLeftButton(BuildContext context) {
    if (showBackButton) {
      return _HeaderButton(
        icon: Icons.arrow_back_rounded,
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    } else if (showMenuButton) {
      return _HeaderButton(
        icon: Icons.menu_rounded,
        onPressed: onMenuPressed,
      );
    }
    return const SizedBox(width: 40);
  }

  Widget _buildRightButton() {
    if (rightAction != null) {
      return rightAction!;
    } else if (showSettingsButton) {
      return Builder(
        builder: (context) => _HeaderButton(
          icon: Icons.settings_rounded,
          onPressed: onSettingsPressed ?? () => Navigator.pushNamed(context, '/settings'),
        ),
      );
    } else if (showNotificationButton) {
      return _HeaderButton(
        icon: Icons.notifications_outlined,
        onPressed: onNotificationPressed,
        badge: true,
      );
    }
    return const SizedBox(width: 40);
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Saturn-like icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.electricYellow,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring
              Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: 44,
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.hotPink,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'ASTRO.FM',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool badge;

  const _HeaderButton({
    required this.icon,
    this.onPressed,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
        if (badge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.hotPink,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
