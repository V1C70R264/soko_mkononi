// lib/domain/entities/store_entity.dart
import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final int productCount;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.productCount,
  });

  @override
  List<Object?> get props => [id, name, description, logoUrl, productCount];
}