// lib/domain/repositories/promotion_repository.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<Result<List<PromotionEntity>>> getActivePromotions();
}