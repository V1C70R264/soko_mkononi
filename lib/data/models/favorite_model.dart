import 'package:e_commerce/data/models/product_model.dart';
import 'package:e_commerce/domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.product,
    required super.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int,
      // Reuses ProductModel's own parsing — product_detail is now
      // shaped exactly like a /products/ response.
      product: ProductModel.fromJson(json['product_detail'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}