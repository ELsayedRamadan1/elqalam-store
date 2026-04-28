import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final Set<String> favoriteProductIds;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favoriteProductIds = const {},
    this.isLoading = false,
    this.error,
  });

  bool isFavorite(String productId) => favoriteProductIds.contains(productId);

  FavoritesState copyWith({
    Set<String>? favoriteProductIds,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [favoriteProductIds, isLoading, error];
}
