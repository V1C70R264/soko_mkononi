// lib/presentation/bloc/promotions/promotions_state.dart
import 'package:e_commerce/domain/entities/promotion_entity.dart';

abstract class PromotionsState {}

class PromotionsInitial extends PromotionsState {}

class PromotionsLoading extends PromotionsState {}

class PromotionsLoaded extends PromotionsState {
  final List<PromotionEntity> promotions;
  PromotionsLoaded(this.promotions);
}

class PromotionsError extends PromotionsState {
  final String message;
  PromotionsError(this.message);
}