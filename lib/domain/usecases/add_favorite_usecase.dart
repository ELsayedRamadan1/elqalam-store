import '../repositories/favorites_repository.dart';

class AddFavoriteUseCase {
  final FavoritesRepository repository;
  AddFavoriteUseCase(this.repository);
  Future<void> call(String userId, String productId) =>
      repository.addFavorite(userId, productId);
}
