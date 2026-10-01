// lib/presentation/widgets/home/home_banner.dart
import 'package:e_commerce/presentation/data/home_mock_data.dart';
import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageUrl;
  final Color backgroundColor;
  final VoidCallback? onShopTap;

  const HomeBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageUrl,
    required this.backgroundColor,
    this.onShopTap,
  });

  /// Parses a hex string like "#F5E6C8" into a Color, falling back to a
  /// neutral tone if the backend ever sends something malformed.
  static Color colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : const Color(0xFFF5E6C8);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: HomeLayout.bannerHeight,
      decoration: BoxDecoration(
        // The whole card takes the promotion's own background color, so
        // the image's backdrop blends into the card with no visible seam
        // — this is set per-promotion in Django, not hardcoded here.
        color: backgroundColor,
        borderRadius: BorderRadius.circular(HomeLayout.bannerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: onShopTap,
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        child: Text(
                          ctaLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Image.network(
              imageUrl,
              // BoxFit.contain (not cover) so the image's own edges —
              // which carry its matching backdrop color — stay visible
              // rather than being cropped, keeping the seamless look
              // even if the uploaded photo's aspect ratio varies.
              fit: BoxFit.contain,
              height: HomeLayout.bannerHeight,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}