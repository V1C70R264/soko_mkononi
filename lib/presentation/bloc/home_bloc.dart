// presentation/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products_by_category.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategories getCategories;
  final GetProductsByCategory getProductsByCategory;

  HomeBloc(this.getCategories, this.getProductsByCategory) : super(HomeInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final categoriesResult = await getCategories();

    await categoriesResult.fold(
      (categories) async {
        if (categories.isEmpty) {
          emit(HomeError('No categories available'));
          return;
        }

        final firstCategoryId = categories.first.id;
        final productsResult = await getProductsByCategory(firstCategoryId);

        productsResult.fold(
          (products) {
            emit(HomeLoaded(
              categories: categories,
              selectedCategoryId: firstCategoryId,
              products: products,
            ));
          },
          (errorMessage) {
            emit(HomeError('Failed to load products: $errorMessage'));
          },
        );
      },
      (errorMessage) async {
        emit(HomeError('Failed to load categories: $errorMessage'));
      },
    );
}


 Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;

    if (currentState is! HomeLoaded) return;

    emit(
      currentState.copyWith(
        selectedCategoryId: event.categoryId,
        productsLoading: true,
      ),
    );

    final productsResult = await getProductsByCategory(
      event.categoryId,
    );

    productsResult.fold(
      (products) {
        emit(
          currentState.copyWith(
            selectedCategoryId: event.categoryId,
            products: products,
            productsLoading: false,
          ),
        );
      },
      (errorMessage) {
        emit(
          HomeError(
            'Failed to load products: $errorMessage',
          ),
        );
      },
    );
}
}