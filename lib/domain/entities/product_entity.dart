// lib/domain/entities/product_entity.dart
class ProductEntity {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final int categoryId;
  final String imageUrl;
  final bool isFavorited;
  final double? averageRating;
  final int reviewCount;
  final int? storeId;
  final String? storeName;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.imageUrl,
    required this.isFavorited,
    this.averageRating,
    this.reviewCount = 0,
    this.storeId,
    this.storeName,
  });
}