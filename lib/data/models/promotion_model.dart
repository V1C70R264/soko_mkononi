// lib/data/models/promotion_model.dart
import 'package:e_commerce/domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.ctaLabel,
    required super.imageUrl,
    required super.backgroundColorHex,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      ctaLabel: json['cta_label'] as String,
      imageUrl: json['image'] as String,
      backgroundColorHex: json['background_color'] as String,
    );
  }
}