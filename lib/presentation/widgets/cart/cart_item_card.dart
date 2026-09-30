import 'package:e_commerce/domain/entities/cart_item_entity.dart';
import 'package:e_commerce/presentation/widgets/cart/quantity_selector.dart';
import 'package:flutter/material.dart';

/// Layout tokens for the cart screen.
abstract final class CartLayout {
  static const double horizontalPadding = 20;
  static const double cardRadius = 20;
  static const double itemImageSize = 88;
  static const double promoFieldHeight = 56;
  static const double checkoutButtonHeight = 56;
}

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback? onDelete;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const CartItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(CartLayout.cardRadius),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              item.productImageUrl,
              width: CartLayout.itemImageSize,
              height: CartLayout.itemImageSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: CartLayout.itemImageSize,
                height: CartLayout.itemImageSize,
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'TZS ${item.productPrice.toStringAsFixed(0)} each',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'TZS ${item.totalPrice.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    QuantitySelector(
                      quantity: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}