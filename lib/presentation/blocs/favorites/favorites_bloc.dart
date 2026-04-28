import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_favorites_usecase.dart';
import '../../../domain/usecases/add_favorite_usecase.dart';
import '../../../domain/usecases/remove_favorite_usecase.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(const FavoritesState()) {
    on<LoadFavoritesEvent>(_onLoad);
    on<ToggleFavoriteEvent>(_onToggle);
  }

  Future<void> _onLoad(
      LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final ids = await getFavoritesUseCase(event.userId);
      emit(state.copyWith(favoriteProductIds: ids, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onToggle(
      ToggleFavoriteEvent event, Emitter<FavoritesState> emit) async {
    final current = Set<String>.from(state.favoriteProductIds);
    final isCurrentlyFav = current.contains(event.productId);

    // Instant optimistic update — no rollback needed (local storage never fails)
    if (isCurrentlyFav) {
      current.remove(event.productId);
    } else {
      current.add(event.productId);
    }
    emit(state.copyWith(favoriteProductIds: current));

    // Persist to SharedPreferences
    if (isCurrentlyFav) {
      await removeFavoriteUseCase(event.userId, event.productId);
    } else {
      await addFavoriteUseCase(event.userId, event.productId);
    }
  }
}
