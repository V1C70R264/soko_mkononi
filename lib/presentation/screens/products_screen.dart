// lib/presentation/screens/products_screen.dart
import 'dart:async';

import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_state.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_state.dart';
import 'package:e_commerce/presentation/bloc/search/product_feed_type.dart';
import 'package:e_commerce/presentation/bloc/search/search_bloc.dart';
import 'package:e_commerce/presentation/bloc/search/search_event.dart';
import 'package:e_commerce/presentation/bloc/search/search_state.dart';
import 'package:e_commerce/presentation/screens/product_detail_screen.dart';
import 'package:e_commerce/presentation/widgets/home/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Serves three entry points from Home: the search bar (autofocus: true,
/// starts empty and fills as the user types), "View All" (autofocus:
/// false, loads every product immediately), and the Trending/New Sellers
/// tabs. All share one SearchBloc, which caches each tab's data so
/// switching back to a previously-viewed tab is instant.
class ProductsScreen extends StatefulWidget {
  final bool autofocusSearch;

  const ProductsScreen({super.key, this.autofocusSearch = false});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  static const _tabs = [
    (ProductFeedType.viewAll, 'View All'),
    (ProductFeedType.trending, 'Trending items'),
    (ProductFeedType.newSellers, 'New seller'),
  ];
  static const _loadMoreThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(SearchQueryChanged(''));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<SearchBloc>().add(LoadMoreActiveFeed());
    }
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Column(
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
                        'See All Items',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  autofocus: widget.autofocusSearch,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: scheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (prev, curr) => prev.activeFeed != curr.activeFeed,
                builder: (context, state) {
                  return SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final (feedType, label) = _tabs[index];
                        final selected = feedType == state.activeFeed;
                        return GestureDetector(
                          onTap: () {
                            context.read<SearchBloc>().add(SwitchFeed(feedType));
                            // Scroll position doesn't carry over between
                            // feeds, so reset it on tab switch.
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(0);
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selected
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(height: 6),
                                Container(
                                  width: 20,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    final feed = state.activeFeedData;

                    if (!feed.hasLoadedOnce) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (feed.errorMessage != null && feed.products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(feed.errorMessage!),
                            TextButton(
                              onPressed: () => context
                                  .read<SearchBloc>()
                                  .add(SwitchFeed(state.activeFeed)),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (feed.products.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    return BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favState) {
                        final favoriteIds = favState is FavoritesLoaded
                            ? favState.favoriteIds
                            : <int>{};

                        return CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                    final ProductEntity item = feed.products[index];
                                    return ProductCard(
                                      imageUrl: item.imageUrl,
                                      name: item.name,
                                      price: item.price,
                                      subtitle: item.description,
                                      isFavorited: favoriteIds.contains(item.id),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProductDetailScreen(product: item),
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
                                  childCount: feed.products.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: feed.isLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24),
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