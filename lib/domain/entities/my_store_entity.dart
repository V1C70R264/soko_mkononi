// lib/domain/entities/my_store_entity.dart
import 'package:equatable/equatable.dart';

enum StoreApplicationStatus { pending, approved, rejected }

class MyStoreEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final StoreApplicationStatus status;
  final String rejectionReason;

  const MyStoreEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.status,
    required this.rejectionReason,
  });

  @override
  List<Object?> get props =>
      [id, name, description, logoUrl, status, rejectionReason];
}