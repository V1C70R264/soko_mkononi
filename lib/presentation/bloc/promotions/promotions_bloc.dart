// lib/presentation/bloc/promotions/promotions_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_active_promotions.dart';
import 'promotions_event.dart';
import 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final GetActivePromotions getActivePromotions;

  PromotionsBloc(this.getActivePromotions) : super(PromotionsInitial()) {
    on<LoadPromotions>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPromotions event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());
    final result = await getActivePromotions();
    result.fold(
      (promotions) => emit(PromotionsLoaded(promotions)),
      (message) => emit(PromotionsError(message)),
    );
  }
}