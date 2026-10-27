import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/domain/entities/store_entity.dart';
import 'package:e_commerce/domain/repositories/store_repository.dart';
import 'package:e_commerce/domain/usecases/get_store.dart';
import 'package:e_commerce/domain/usecases/get_store_products.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_state.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_state.dart';
import 'package:e_commerce/presentation/bloc/stores/store_products_bloc.dart';
import 'package:e_commerce/presentation/bloc/stores/store_products_event.dart';
import 'package:e_commerce/presentation/bloc/stores/store_products_state.dart';
import 'package:e_commerce/presentation/screens/product_detail_screen.dart';
import 'package:e_commerce/presentation/widgets/home/product_card.dart';
import 'package:e_commerce/presentation/widgets/store/store_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/presentation/widgets/common/app_back_button.dart';

/// Each instance owns its bloc, so stacked store screens (store A, then a
/// product, then store B, then back) never overwrite each other's data.
class StoreProductsScreen extends StatelessWidget {
  final int storeId;
  final String storeName;

  const StoreProductsScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = context.read<StoreRepository>();
        return StoreProductsBloc(
          GetStore(repository),
          GetStoreProducts(repository),
        )..add(LoadStoreProducts(storeId));
      },
      child: _StoreProductsView(storeId: storeId, storeName: storeName),
    );
  }
}

class _StoreProductsView extends StatefulWidget {
  final int storeId;
  final String storeName;

  const _StoreProductsView({required this.storeId, required this.storeName});

  @override
  State<_StoreProductsView> createState() => _StoreProductsViewState();
}

class _StoreProductsViewState extends State<_StoreProductsView> {
  final _scrollController = ScrollController();
  static const _loadMoreThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<StoreProductsBloc>().add(LoadMoreStoreProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CartBloc, CartState>(
          listener: (context, cartState) {
            if (cartState is CartItemAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to cart')),
              );
            } else if (cartState is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(cartState.message)),
              );
            }
          },
        ),
        BlocListener<FavoritesBloc, FavoritesState>(
          listener: (context, favState) {
            if (favState is FavoritesToggleFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(favState.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F7),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    const AppBackButton(),
                    Expanded(
                      child: Text(
                        widget.storeName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<StoreProductsBloc, StoreProductsState>(
                  builder: (context, state) {
                    if (state.status == StoreProductsStatus.initial ||
                        state.status == StoreProductsStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == StoreProductsStatus.error) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.error ?? 'Something went wrong'),
                            TextButton(
                              onPressed: () => context
                                  .read<StoreProductsBloc>()
                                  .add(LoadStoreProducts(widget.storeId)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final store = state.store!;

                    return BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favState) {
                        final favoriteIds = favState is FavoritesLoaded
                            ? favState.favoriteIds
                            : <int>{};

                        return CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 4, 20, 16),
                                child: _StoreHeaderCard(store: store),
                              ),
                            ),
                            if (state.products.isEmpty)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Text('This store has no products yet'),
                                ),
                              )
                            else
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.72,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final ProductEntity item =
                                          state.products[index];
                                      return ProductCard(
                                        imageUrl: item.imageUrl,
                                        name: item.name,
                                        price: item.price,
                                        subtitle: item.description,
                                        isFavorited:
                                            favoriteIds.contains(item.id),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailScreen(
                                                      product: item),
                                            ),
                                          );
                                        },
                                        onAddTap: () {
                                          context.read<CartBloc>().add(
                                                AddToCartEvent(
                                                  productId: item.id,
                                                  quantity: 1,
                                                ),
                                              );
                                        },
                                        onFavoriteTap: () {
                                          context.read<FavoritesBloc>().add(
                                                ToggleFavoriteEvent(item.id),
                                              );
                                        },
                                      );
                                    },
                                    childCount: state.products.length,
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: state.isLoadingMore
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox(height: 24),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHeaderCard extends StatelessWidget {
  final StoreEntity store;
  const _StoreHeaderCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoreAvatar(name: store.name, logoUrl: store.logoUrl, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  store.productCount == 1
                      ? '1 product'
                      : '${store.productCount} products',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (store.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    store.description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}