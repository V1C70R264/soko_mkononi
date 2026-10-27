import 'package:flutter/material.dart';

class ProductDetailMetaRow extends StatelessWidget {
  /// Null when the product has no reviews yet.
  final double? rating;
  final int reviewCount;
  final VoidCallback? onVendorTap;

  /// The store's name, or null when the seller has no approved store.
  final String? vendor;

  const ProductDetailMetaRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.onVendorTap,
    required this.vendor,
  
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasVendor = vendor != null && vendor!.isNotEmpty;

    return Row(
      children: [
        if (rating != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: scheme.onPrimary),
                const SizedBox(width: 4),
                Text(
                  rating!.toStringAsFixed(1),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($reviewCount ${reviewCount == 1 ? 'Review' : 'Reviews'})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ] else
          Text(
            'No reviews yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
         if (hasVendor) ...[
          _VerticalDivider(color: scheme.outlineVariant),
          Expanded(
            child: InkWell(
              onTap: onVendorTap,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Vendor: $vendor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onVendorTap != null
                            ? scheme.primary
                            : scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onVendorTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: scheme.primary,
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: color,
    );
  }
}