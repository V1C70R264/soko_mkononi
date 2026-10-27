// lib/data/models/store_page_model.dart
import 'package:e_commerce/domain/entities/store_page_entity.dart';
import 'store_model.dart';

class StorePageModel extends StorePageEntity {
  const StorePageModel({
    required super.stores,
    required super.hasMore,
    required super.nextCursor,
  });

  factory StorePageModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List;
    final next = json['next'] as String?;
    return StorePageModel(
      stores: results
          .map((item) => StoreModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      hasMore: next != null,
      nextCursor: next,
    );
  }
}