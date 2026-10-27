// lib/data/models/my_store_model.dart
import 'package:e_commerce/domain/entities/my_store_entity.dart';

class MyStoreModel extends MyStoreEntity {
  const MyStoreModel({
    required super.id,
    required super.name,
    required super.description,
    required super.logoUrl,
    required super.status,
    required super.rejectionReason,
  });

  factory MyStoreModel.fromJson(Map<String, dynamic> json) {
    return MyStoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      status: _parseStatus(json['status'] as String),
      rejectionReason: json['rejection_reason'] as String? ?? '',
    );
  }

  /// An unrecognized value falls back to pending, which shows the safe
  /// "under review" state rather than wrongly showing a live store.
  static StoreApplicationStatus _parseStatus(String value) {
    switch (value) {
      case 'approved':
        return StoreApplicationStatus.approved;
      case 'rejected':
        return StoreApplicationStatus.rejected;
      default:
        return StoreApplicationStatus.pending;
    }
  }
}