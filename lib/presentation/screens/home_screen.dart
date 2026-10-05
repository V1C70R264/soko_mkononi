import 'dart:async';

import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_state.dart';
import 'package:e_commerce/presentation/bloc/home_bloc.dart';
import 'package:e_commerce/presentation/bloc/home_event.dart';
import 'package:e_commerce/presentation/bloc/home_state.dart';
import 'package:e_commerce/presentation/data/home_mock_data.dart';
import 'package:e_commerce/presentation/screens/cart_screen.dart';
import 'package:e_commerce/presentation/screens/favorites_screen.dart';
import 'package:e_commerce/presentation/screens/notifications_screen.dart';
import 'package:e_commerce/presentation/screens/orders_screen.dart';
import 'package:e_commerce/presentation/screens/products_screen.dart';
import 'package:e_commerce/presentation/screens/profile_screen.dart';
import 'package:e_commerce/presentation/widgets/home/home_banner.dart';
import 'package:e_commerce/presentation/widgets/home/home_bottom_navigation.dart';
import 'package:e_commerce/presentation/widgets/home/home_header.dart';
import 'package:e_commerce/presentation/screens/product_detail_screen.dart';
import 'package:e_commerce/presentation/widgets/home/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce/presentation/cubit/profile_state.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_state.dart';
import 'package:e_commerce/presentation/bloc/promotions/promotions_bloc.dart';
import 'package:e_commerce/presentation/bloc/promotions/promotions_event.dart';
import 'package:e_commerce/presentation/bloc/promotions/promotions_state.dart';
import 'package:e_commerce/presentation/bloc/notifications/notifications_bloc.dart';
import 'package:e_commerce/presentation/bloc/notifications/notifications_event.dart';
import 'package:e_commerce/domain/entities/promotion_entity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchUserProfile();
    context.read<HomeBloc>().add(LoadCategories());
    context.read<FavoritesBloc>().add(LoadFavorites());
    context.read<PromotionsBloc>().add(LoadPromotions());
    context.read<NotificationsBloc>().add(LoadNotifications());
  }

  int _navIndex = 0;

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_navIndex) {
      1 => const FavoritesScreen(),
      2 => const CartScreen(embedded: true),
      3 => const OrdersScreen(embedded: true),
      4 => ProfileScreen(),
      _ => const _GroceryHomeBody(),
    };

    return Scaffold(
      body: body,
      floatingActionButton: HomeCartFab(
        isSelected: _navIndex == 2,
        onTap: () => _onNavTap(2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _GroceryHomeBody extends StatelessWidget {
  const _GroceryHomeBody();

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
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as HomeLoaded;

          return ColoredBox(
            color: scheme.surface,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, profileState) {
                            final user = profileState.user;
                            final userName = user?.username?.trim().isNotEmpty == true
                                ? user!.username!
                                : (user?.fullName?.trim().isNotEmpty == true
                                    ? user!.fullName!
                                    : (user?.email.isNotEmpty == true
                                        ? user!.email.split('@').first
                                        : ''));

                            final avatar = user?.profileImage ?? '';

                            return HomeHeader(
                              userName: userName,
                              avatarUrl: avatar,
                              categories: loaded.categories,
                              selectedCategoryId: loaded.selectedCategoryId,
                              onCategorySelected: (id) =>
                                  context.read<HomeBloc>().add(SelectCategory(id)),
                              onSearchTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductsScreen(
                                      autofocusSearch: true,
                                    ),
                                  ),
                                );
                              },
                              onNotificationTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        BlocBuilder<PromotionsBloc, PromotionsState>(
                          builder: (context, promoState) {
                            if (promoState is! PromotionsLoaded ||
                                promoState.promotions.isEmpty) {
                              // No active promotions — the whole section
                              // simply doesn't render.
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: HomeLayout.horizontalPadding,
                                  ),
                                  child: Text(
                                    'Special Offers',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _PromotionCarousel(
                                  promotions: promoState.promotions,
                                ),
                                const SizedBox(height: 28),
                              ],
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: HomeLayout.horizontalPadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Popular Items',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProductsScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: scheme.onSurfaceVariant,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'View All',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (loaded.productsLoading)
                          const SizedBox(
                            height: HomeLayout.productCardHeight,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, favState) {
                              final favoriteIds = favState is FavoritesLoaded
                                  ? favState.favoriteIds
                                  : <int>{};

                              return SizedBox(
                                height: HomeLayout.productCardHeight,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: HomeLayout.horizontalPadding,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: loaded.products.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final item = loaded.products[index];
                                    // Width is a layout decision, so the screen
                                    // owns it, not the card.
                                    return SizedBox(
                                      width: HomeLayout.productCardWidth,
                                      child: ProductCard(
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
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Auto-advancing banner carousel for promotions. Advances every 4
/// seconds; a manual swipe resets that timer so the banner doesn't
/// yank away right after the user interacts with it.
class _PromotionCarousel extends StatefulWidget {
  final List<PromotionEntity> promotions;

  const _PromotionCarousel({required this.promotions});

  @override
  State<_PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<_PromotionCarousel> {
  late final PageController _controller;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    if (widget.promotions.length <= 1) return; // nothing to rotate to
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % widget.promotions.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: HomeLayout.bannerHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.promotions.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              // User swiped manually — restart the timer so auto-advance
              // doesn't immediately fight the swipe they just made.
              _startAutoAdvance();
            },
            itemBuilder: (context, index) {
              final promo = widget.promotions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HomeLayout.horizontalPadding,
                ),
                child: HomeBanner(
                  title: promo.title,
                  subtitle: promo.subtitle,
                  ctaLabel: promo.ctaLabel,
                  imageUrl: promo.imageUrl,
                  backgroundColor:
                      HomeBanner.colorFromHex(promo.backgroundColorHex),
                  onShopTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductsScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (widget.promotions.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.promotions.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}