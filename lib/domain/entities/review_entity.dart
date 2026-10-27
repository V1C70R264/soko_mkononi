// lib/domain/entities/review_entity.dart
import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int userId;
  final String userName;
  final int productId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, userName, productId, rating, comment, createdAt];
}