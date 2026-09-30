// presentation/bloc/home_state.dart
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final int selectedCategoryId;
  final List<ProductEntity> products;
  final bool productsLoading;

  HomeLoaded({
    required this.categories,
    required this.selectedCategoryId,
    required this.products,
    this.productsLoading = false,
  });

  HomeLoaded copyWith({
    List<CategoryEntity>? categories,
    int? selectedCategoryId,
    List<ProductEntity>? products,
    bool? productsLoading,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      products: products ?? this.products,
      productsLoading: productsLoading ?? this.productsLoading,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}