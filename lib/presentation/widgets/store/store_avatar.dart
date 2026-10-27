// lib/presentation/widgets/store/store_avatar.dart
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StoreAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final double size;

  const StoreAvatar({
    super.key,
    required this.name,
    required this.logoUrl,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
      ),
      child: logoUrl == null
          ? fallback
          : Image.network(
              logoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}