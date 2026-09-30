// lib/presentation/bloc/favorites/favorites_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/domain/usecases/get_favorites.dart';
import 'package:e_commerce/domain/usecases/toggle_favorite.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  FavoritesBloc(this.getFavorites, this.toggleFavorite)
      : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoad);
    on<ToggleFavoriteEvent>(_onToggle);
  }

  Future<void> _onLoad(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    // Only show a full spinner the first time. On refreshes we keep the
    // current list on screen, so hearts don't flicker after every tap.
    if (state is! FavoritesLoaded) emit(FavoritesLoading());

    final result = await getFavorites();

    result.fold(
      (favorites) => emit(FavoritesLoaded(favorites)),
      (message) => emit(FavoritesError(message)),
    );
  }

  Future<void> _onToggle(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final current = state;
    final result = await toggleFavorite(event.productId);

    result.fold(
      (_) => add(LoadFavorites()),
      (message) {
        if (current is FavoritesLoaded) {
          emit(FavoritesToggleFailed(current.favorites, message));
        } else {
          emit(FavoritesError(message));
        }
      },
    );
  }
}