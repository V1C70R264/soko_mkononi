import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/main.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_state.dart';
import 'package:e_commerce/presentation/data/home_mock_data.dart';
import 'package:e_commerce/presentation/data/product_detail_mock_data.dart';
import 'package:e_commerce/presentation/widgets/home/product_card.dart';
import 'package:e_commerce/presentation/widgets/product_detail/product_detail_image_header.dart';
import 'package:e_commerce/presentation/widgets/product_detail/product_detail_meta_row.dart';
import 'package:e_commerce/presentation/widgets/product_detail/product_detail_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<ProductEntity> _relatedProducts = [];
  bool _relatedLoading = true;
  String? _relatedError;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
  }

  Future<void> _loadRelatedProducts() async {
    final product = widget.product;
    if (product == null) {
      setState(() => _relatedLoading = false);
      return;
    }

    final result = await appGetProductsByCategory(product.categoryId);

    result.fold(
      (products) {
        setState(() {
          _relatedProducts =
              products.where((p) => p.id != product.id).toList();
          _relatedLoading = false;
        });
      },
      (errorMessage) {
        setState(() {
          _relatedError = errorMessage;
          _relatedLoading = false;
        });
      },
    );
  }

  String get _title =>
      widget.product?.name.isNotEmpty == true
          ? widget.product!.name
          : kDefaultProductTitle;

  String get _imageUrl =>
      widget.product?.imageUrl.isNotEmpty == true
          ? widget.product!.imageUrl
          : kDefaultProductImageUrl;

  String get _description =>
      widget.product?.description.isNotEmpty == true
          ? widget.product!.description
          : kProductDetailDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHigh,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductDetailImageHeader(imageUrl: _imageUrl),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ProductDetailLayout.horizontalPadding,
                    8,
                    ProductDetailLayout.horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ProductDetailMetaRow(
                        rating: kDefaultRating,
                        reviewCount: kDefaultReviewCount,
                        seller: kDefaultSeller,
                        vendor: kDefaultVendor,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: scheme.outlineVariant, height: 1),
                      const SizedBox(height: 16),
                      ProductDetailTabBar(
                        tabs: kProductDetailTabs,
                        selectedIndex: _selectedTab,
                        onTabSelected: (i) => setState(() => _selectedTab = i),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _tabBody,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: scheme.outlineVariant, height: 1),
                      const SizedBox(height: 20),
                      if (_relatedLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_relatedError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Could not load related products: $_relatedError',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.error,
                            ),
                          ),
                        )
                      else if (_relatedProducts.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'You Might Also Like',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
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
                        const SizedBox(height: 14),
                        BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (context, favState) {
                            final favoriteIds = favState is FavoritesLoaded
                                ? favState.favoriteIds
                                : <int>{};

                            return SizedBox(
                              height: HomeLayout.productCardHeight,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _relatedProducts.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final item = _relatedProducts[index];
                                  return SizedBox(
                                    width: HomeLayout.productCardWidth,
                                    child: ProductCard(
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
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _tabBody {
    switch (_selectedTab) {
      case 1:
        return 'Contact our support team for help with orders, delivery, and product questions. '
            'We are available 24/7 to assist you.';
      case 2:
        return 'Rated ${kDefaultRating.toStringAsFixed(1)} based on $kDefaultReviewCount reviews. '
            'Customers love the freshness and quality of this product.';
      default:
        return _description;
    }
  }
}