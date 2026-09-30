import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class ProductPageEntity extends Equatable {
  final List<ProductEntity> products;
  final bool hasMore;
  final String? nextCursor;

  const ProductPageEntity({
    required this.products,
    required this.hasMore,
    required this.nextCursor,
  });

  @override
  List<Object?> get props => [products, hasMore, nextCursor];
}