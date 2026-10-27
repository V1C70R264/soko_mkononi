// lib/presentation/bloc/stores/store_products_event.dart
abstract class StoreProductsEvent {}

class LoadStoreProducts extends StoreProductsEvent {
  final int storeId;
  LoadStoreProducts(this.storeId);
}

class LoadMoreStoreProducts extends StoreProductsEvent {}