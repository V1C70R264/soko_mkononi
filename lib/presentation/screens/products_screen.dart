import 'dart:async';

import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_state.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_state.dart';
import 'package:e_commerce/presentation/bloc/search/search_bloc.dart';
import 'package:e_commerce/presentation/bloc/search/search_event.dart';
import 'package:e_commerce/presentation/bloc/search/search_state.dart';
import 'package:e_commerce/presentation/screens/product_detail_screen.dart';
import 'package:e_commerce/presentation/widgets/home/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Serves two entry points from Home: the search bar (autofocus: true,
/// starts empty and fills as the user types) and "View All" (autofocus:
/// false, loads every product immediately). Both hit the same endpoint,
/// since an empty search term returns everything unfiltered.
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
  int _selectedTab = 0;

  static const _tabs = ['View All', 'Trending items', 'New seller', 'Vendor'];
  static const _loadMoreThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    // Load everything immediately, whichever entry point was used.
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
      context.read<SearchBloc>().add(SearchLoadMore());
    }
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    });
  }

  void _onTabTap(int index) {
    if (index == 0) {
      setState(() => _selectedTab = 0);
      return;
    }
    // Trending / New seller / Vendor need backend support that doesn't
    // exist yet (no trending metric, no seller-picker endpoint). Left
    // visible for the design, honestly inert for now.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_tabs[index]} coming soon')),
    );
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // balances the back button
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
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final selected = index == _selectedTab;
                    return GestureDetector(
                      onTap: () => _onTabTap(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tabs[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: selected
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
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
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading || state is SearchInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(child: Text(state.message));
                    }

                    final loaded = state as SearchLoaded;
                    final products = loaded.products;
                    if (products.isEmpty) {
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
                                    final ProductEntity item = products[index];
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
                                  childCount: products.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: loaded.isLoadingMore
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