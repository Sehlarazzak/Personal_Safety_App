import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The circular "shield" brand mark shown on Splash, Login, and
/// Registration. Kept as one widget so the brand mark can't drift out of
/// sync across the auth flow.
class AppShieldLogo extends StatelessWidget {
  final double size;
  final IconData icon;

  const AppShieldLogo({
    super.key,
    this.size = 64,
    this.icon = Icons.shield,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: AppColors.onPrimaryContainer,
      ),
    );
  }
}
