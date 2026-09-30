import 'package:e_commerce/domain/entities/order_entity.dart';
import 'package:e_commerce/presentation/bloc/orders/orders_bloc.dart';
import 'package:e_commerce/presentation/bloc/orders/orders_event.dart';
import 'package:e_commerce/presentation/bloc/orders/orders_state.dart';
import 'package:e_commerce/presentation/data/orders_mock_data.dart';
import 'package:e_commerce/presentation/screens/order_tracking_screen.dart';
import 'package:e_commerce/presentation/widgets/orders/order_card.dart';
import 'package:e_commerce/presentation/widgets/orders/orders_header.dart';
import 'package:e_commerce/presentation/widgets/orders/orders_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatefulWidget {
  /// When `true`, hides the back button (e.g. embedded in bottom nav).
  final bool embedded;

  const OrdersScreen({super.key, this.embedded = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<OrdersBloc>().add(LoadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _showBack => !widget.embedded && Navigator.canPop(context);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            OrdersHeader(showBackButton: _showBack),
            OrdersTabBar(controller: _tabController),
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading || state is OrdersInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OrdersError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message),
                          TextButton(
                            onPressed: () =>
                                context.read<OrdersBloc>().add(LoadOrders()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final loaded = state as OrdersLoaded;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderList(orders: loaded.inProgress),
                      _OrderList(orders: loaded.completed),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderEntity> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders yet',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        OrdersLayout.horizontalPadding,
        16,
        OrdersLayout.horizontalPadding,
        24,
      ),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTrack: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }
}