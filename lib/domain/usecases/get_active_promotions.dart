// lib/domain/usecases/get_active_promotions.dart
import 'package:e_commerce/core/utils/result.dart';
import 'package:e_commerce/domain/entities/promotion_entity.dart';
import 'package:e_commerce/domain/repositories/promotion_repository.dart';

class GetActivePromotions {
  final PromotionRepository repository;
  GetActivePromotions(this.repository);

  Future<Result<List<PromotionEntity>>> call() =>
      repository.getActivePromotions();
}