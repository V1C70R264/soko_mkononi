import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_state.dart';
import 'package:e_commerce/presentation/screens/checkout_screen.dart';
import 'package:e_commerce/presentation/widgets/cart/cart_header.dart';
import 'package:e_commerce/presentation/widgets/cart/cart_item_card.dart';
import 'package:e_commerce/presentation/widgets/cart/cart_price_summary.dart';
import 'package:e_commerce/presentation/widgets/cart/promo_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatefulWidget {
  /// When `true`, hides the back button (e.g. embedded in bottom nav).
  final bool embedded;

  const CartScreen({super.key, this.embedded = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  bool get _showBack => !widget.embedded && (Navigator.canPop(context));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            CartHeader(showBackButton: _showBack),
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartLoading || state is CartInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CartError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is CartItemAdded) {
                    // A LoadCart is dispatched right after AddToCartEvent
                    // succeeds (see CartBloc), so this state is transient —
                    // show a spinner until CartLoaded arrives.
                    return const Center(child: CircularProgressIndicator());
                  }

                  final loaded = state as CartLoaded;
                  final items = loaded.cart.items;

                  if (items.isEmpty) {
                    return const Center(child: Text('Your cart is empty'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CartLayout.horizontalPadding,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CartItemCard(
                        item: item,
                        onDelete: () {
                          context.read<CartBloc>().add(
                                RemoveCartItemEvent(item.id),
                              );
                        },
                        onDecrement: item.quantity > 1
                            ? () {
                                context.read<CartBloc>().add(
                                      UpdateCartItemQuantityEvent(
                                        cartItemId: item.id,
                                        quantity: item.quantity - 1,
                                      ),
                                    );
                              }
                            : null,
                        onIncrement: () {
                          context.read<CartBloc>().add(
                                UpdateCartItemQuantityEvent(
                                  cartItemId: item.id,
                                  quantity: item.quantity + 1,
                                ),
                              );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                final cart = state is CartLoaded ? state.cart : null;
                final total = cart?.totalPrice ?? 0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    CartLayout.horizontalPadding,
                    16,
                    CartLayout.horizontalPadding,
                    20,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PromoCodeField(
                          controller: _promoController,
                          onApply: () {},
                        ),
                        const SizedBox(height: 20),
                        CartPriceSummary(
                          subtotal: total,
                          shippingFee: 0,
                          total: total,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: CartLayout.checkoutButtonHeight,
                          child: FilledButton(
                            onPressed: (cart == null || cart.items.isEmpty)
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CheckoutScreen(),
                                      ),
                                    );
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              disabledBackgroundColor:
                                  scheme.onSurfaceVariant.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Proceed To Payment',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}