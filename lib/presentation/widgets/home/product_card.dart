import 'package:e_commerce/core/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// A purely presentational product card. It knows nothing about entities,
/// BLoCs or layout width: the screen decides all of that.
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String? subtitle;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onFavoriteTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.subtitle,
    this.isFavorited = false,
    this.onTap,
    this.onAddTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported_outlined,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Heart (favorites)
                  Positioned(
                    top: 18,
                    right: 18,
                    child: Material(
                      color: scheme.surface.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onFavoriteTap,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            // The free Hugeicons set is stroke-only, so the
                            // "favorited" state uses a solid Material heart.
                            child: isFavorited
                                ? const Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: Colors.red,
                                  )
                                : HugeIcon(
                                    icon: AppIcons.favorite,
                                    size: 20,
                                    color: scheme.onSurfaceVariant,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Add to cart
                  Positioned(
                    right: 10,
                    bottom: 4,
                    child: Material(
                      color: scheme.onSurface,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onAddTap,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: HugeIcon(
                              icon: AppIcons.add,
                              size: 20,
                              color: scheme.surfaceContainerHigh,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'TZS ${price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}