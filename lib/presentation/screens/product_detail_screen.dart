import 'package:e_commerce/domain/entities/product_entity.dart';
import 'package:e_commerce/domain/entities/review_entity.dart';
import 'package:e_commerce/domain/repositories/review_repository.dart';
import 'package:e_commerce/domain/usecases/check_can_review.dart';
import 'package:e_commerce/domain/usecases/create_review.dart';
import 'package:e_commerce/domain/usecases/get_reviews.dart';
import 'package:e_commerce/main.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_event.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_state.dart';
import 'package:e_commerce/presentation/bloc/reviews/reviews_bloc.dart';
import 'package:e_commerce/presentation/bloc/reviews/reviews_event.dart';
import 'package:e_commerce/presentation/bloc/reviews/reviews_state.dart';
import 'package:e_commerce/presentation/data/home_mock_data.dart';
import 'package:e_commerce/presentation/data/product_detail_mock_data.dart';
import 'package:e_commerce/presentation/screens/store_products_screen.dart';
import 'package:e_commerce/presentation/widgets/home/product_card.dart';
import 'package:e_commerce/presentation/widgets/product_detail/product_detail_image_header.dart';
import 'package:e_commerce/presentation/widgets/product_detail/product_detail_meta_row.dart';
import 'package:e_commerce/presentation/widgets/product_detail/product_detail_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Each instance owns its ReviewsBloc, so stacked detail screens (product A,
/// then a related product B, then back) never show each other's reviews.
/// The bloc is created lazily, so reviews load when the Ratings tab is
/// first opened rather than on every detail screen.
class ProductDetailScreen extends StatelessWidget {
  final ProductEntity? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = context.read<ReviewRepository>();
        final bloc = ReviewsBloc(
          GetReviews(repository),
          CheckCanReview(repository),
          CreateReview(repository),
        );
        final current = product;
        if (current != null) bloc.add(LoadReviews(current.id));
        return bloc;
      },
      child: _ProductDetailView(product: product),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final ProductEntity? product;

  const _ProductDetailView({required this.product});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
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

    // The user may have left the screen while this was loading.
    if (!mounted) return;

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

  void _openWriteReviewSheet(BuildContext context, int productId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        // The sheet is pushed as its own route, outside this screen's
        // BlocProvider, so the bloc is handed in explicitly.
        return BlocProvider.value(
          value: context.read<ReviewsBloc>(),
          child: _WriteReviewSheet(productId: productId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final product = widget.product;

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
                        rating: product?.averageRating,
                        reviewCount: product?.reviewCount ?? 0,
                        vendor: product?.storeName,
                        onVendorTap: (product?.storeId == null ||
                                product?.storeName == null)
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StoreProductsScreen(
                                      storeId: product!.storeId!,
                                      storeName: product.storeName!,
                                    ),
                                  ),
                                ),
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
                      if (_selectedTab == 2 && product != null)
                        _RatingsTab(
                          productId: product.id,
                          onWriteReview: () =>
                              _openWriteReviewSheet(context, product.id),
                        )
                      else
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
      default:
        return _description;
    }
  }
}

/// Ratings tab content: a "Write a Review" button (shown only when the user
/// is actually eligible) and the review list.
class _RatingsTab extends StatelessWidget {
  final int productId;
  final VoidCallback onWriteReview;

  const _RatingsTab({required this.productId, required this.onWriteReview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        if (state is ReviewsLoading || state is ReviewsInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ReviewsError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              state.message,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          );
        }

        final loaded = state as ReviewsLoaded;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loaded.canReview.canReview)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onWriteReview,
                  icon: const Icon(Icons.star_border_rounded, size: 18),
                  label: const Text('Write a Review'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(color: scheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            else if (loaded.canReview.hasPurchased &&
                loaded.canReview.alreadyReviewed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'You\'ve already reviewed this product.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              )
            else if (!loaded.canReview.hasPurchased)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Only customers who have received this product can leave a review.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 16),
            if (loaded.reviews.isEmpty)
              Text(
                'No reviews yet.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              )
            else
              ...loaded.reviews.map((review) => _ReviewTile(review: review)),
          ],
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewEntity review;
  const _ReviewTile({required this.review});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: const Color(0xFFFFB800),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(review.createdAt),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurface, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final int productId;
  const _WriteReviewSheet({required this.productId});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }
    context.read<ReviewsBloc>().add(SubmitReview(
          productId: widget.productId,
          rating: _rating,
          comment: _comment.text.trim(),
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Write a Review',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starValue = i + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = starValue),
                icon: Icon(
                  starValue <= _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 32,
                  color: const Color(0xFFFFB800),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              filled: true,
              fillColor: scheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}