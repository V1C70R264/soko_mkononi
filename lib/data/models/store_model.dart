// lib/data/models/store_model.dart
import 'package:e_commerce/domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.description,
    required super.logoUrl,
    required super.productCount,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      productCount: json['product_count'] as int? ?? 0,
    );
  }
}