// lib/presentation/screens/checkout_screen.dart
import 'package:e_commerce/domain/repositories/order_repository.dart';
import 'package:e_commerce/presentation/bloc/address/address_bloc.dart';
import 'package:e_commerce/presentation/bloc/address/address_event.dart';
import 'package:e_commerce/presentation/bloc/address/address_state.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_state.dart';
import 'package:e_commerce/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:e_commerce/presentation/bloc/checkout/checkout_event.dart';
import 'package:e_commerce/presentation/bloc/checkout/checkout_state.dart';
import 'package:e_commerce/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce/presentation/cubit/profile_state.dart';
import 'package:e_commerce/presentation/screens/addresses_screen.dart';
import 'package:e_commerce/presentation/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _PaymentOption { payOnDelivery, debitCard, googlePay }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PaymentOption _selectedPayment = _PaymentOption.payOnDelivery;

  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(LoadAddresses());
  }

  void _selectPayment(_PaymentOption option) {
    if (option != _PaymentOption.payOnDelivery) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This payment method is coming soon')),
      );
      return;
    }
    setState(() => _selectedPayment = option);
  }

  Future<void> _openAddresses() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressesScreen()),
    );
    // The user may have added or changed the default address there.
    if (mounted) context.read<AddressBloc>().add(LoadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: MultiBlocListener(
        listeners: [
          BlocListener<CheckoutBloc, CheckoutState>(
            listener: (context, state) {
              if (state is CheckoutSuccess) {
                context.read<CartBloc>().add(ClearCartEvent());
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order ${state.order.orderNumber} placed!'),
                  ),
                );
              } else if (state is CheckoutError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is! CartLoaded || cartState.cart.items.isEmpty) {
                return const Center(child: Text('Your cart is empty'));
              }
              final cart = cartState.cart;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            'Proceed to Buy',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      children: [
                        _SectionTitle('Shipping Address'),
                        const SizedBox(height: 10),
                        _ShippingAddressCard(onAddEditTap: _openAddresses),
                        const SizedBox(height: 24),
                        _SectionTitle('Payment Options'),
                        const SizedBox(height: 10),
                        _PaymentOptionTile(
                          icon: Icons.local_shipping_outlined,
                          label: 'Pay on Delivery',
                          selected: _selectedPayment == _PaymentOption.payOnDelivery,
                          onTap: () => _selectPayment(_PaymentOption.payOnDelivery),
                        ),
                        const SizedBox(height: 10),
                        _PaymentOptionTile(
                          icon: Icons.credit_card_outlined,
                          label: 'Debit Card',
                          selected: _selectedPayment == _PaymentOption.debitCard,
                          onTap: () => _selectPayment(_PaymentOption.debitCard),
                        ),
                        const SizedBox(height: 10),
                        _PaymentOptionTile(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google Pay',
                          selected: _selectedPayment == _PaymentOption.googlePay,
                          onTap: () => _selectPayment(_PaymentOption.googlePay),
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle('Order Summary'),
                        const SizedBox(height: 10),
                        _OrderSummaryCard(cart: cart),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: BlocBuilder<AddressBloc, AddressState>(
                        builder: (context, addrState) {
                          final defaultAddress = addrState is AddressLoaded
                              ? addrState.defaultAddress
                              : null;

                          return BlocBuilder<CheckoutBloc, CheckoutState>(
                            builder: (context, checkoutState) {
                              final placing = checkoutState is CheckoutLoading;
                              return SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed: (defaultAddress == null || placing)
                                      ? null
                                      : () {
                                          final items = cart.items
                                              .map((item) => OrderItemInput(
                                                    productId: item.productId,
                                                    quantity: item.quantity,
                                                  ))
                                              .toList();
                                          context.read<CheckoutBloc>().add(
                                                PlaceOrder(
                                                  shippingAddressId:
                                                      defaultAddress.id,
                                                  items: items,
                                                ),
                                              );
                                        },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: scheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: placing
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Place Order \u2022 TZS '
                                          '${cart.totalPrice.toStringAsFixed(0)}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: scheme.onPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ShippingAddressCard extends StatelessWidget {
  final VoidCallback onAddEditTap;
  const _ShippingAddressCard({required this.onAddEditTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, addrState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onAddEditTap,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add/Edit Address'),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              if (addrState is AddressLoading || addrState is AddressInitial)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (addrState is! AddressLoaded ||
                  addrState.defaultAddress == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No saved address yet. Tap "Add/Edit Address" to add one.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                )
              else ...[
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    final email = profileState.user?.email;
                    final address = addrState.defaultAddress!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AddressRow(
                          icon: Icons.person_outline_rounded,
                          text: address.fullName,
                        ),
                        if (email != null && email.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _AddressRow(
                            icon: Icons.email_outlined,
                            text: email,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _AddressRow(
                          icon: Icons.phone_outlined,
                          text: address.phoneNumber,
                        ),
                        const SizedBox(height: 8),
                        _AddressRow(
                          icon: Icons.location_on_outlined,
                          text: '${address.streetAddress}, '
                              '${address.district} - ${address.region}',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AddressRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: scheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final dynamic cart; // CartEntity
  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cart.items.map<Widget>(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.2),
                        child: Icon(Icons.image_not_supported_outlined,
                            color: scheme.onSurfaceVariant, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    'TZS ${item.totalPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                'TZS ${cart.totalPrice.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}