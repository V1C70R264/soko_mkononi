// lib/domain/entities/promotion_entity.dart
import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageUrl;
  final String backgroundColorHex;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageUrl,
    required this.backgroundColorHex,
  });

  @override
  List<Object?> get props =>
      [id, title, subtitle, ctaLabel, imageUrl, backgroundColorHex];
}