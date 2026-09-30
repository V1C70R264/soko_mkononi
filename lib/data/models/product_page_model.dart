import 'package:e_commerce/data/models/product_model.dart';
import 'package:e_commerce/domain/entities/product_page_entity.dart';

class ProductPageModel extends ProductPageEntity {
  const ProductPageModel({
    required super.products,
    required super.hasMore,
    required super.nextCursor,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List;
    final next = json['next'] as String?;
    return ProductPageModel(
      products: results
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      hasMore: next != null,
      nextCursor: next,
    );
  }
}