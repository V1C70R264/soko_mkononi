// lib/presentation/widgets/common/app_back_button.dart
import 'package:e_commerce/core/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// The circular white back button used in screen headers.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: HugeIcon(icon: AppIcons.back, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}