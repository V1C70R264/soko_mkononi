import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class FavoriteEntity extends Equatable {
  final int id;
  final ProductEntity product;
  final DateTime createdAt;

  const FavoriteEntity({
    required this.id,
    required this.product,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, product, createdAt];
}