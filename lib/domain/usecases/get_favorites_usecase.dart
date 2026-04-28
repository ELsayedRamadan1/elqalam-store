import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;
  GetFavoritesUseCase(this.repository);
  Future<Set<String>> call(String userId) => repository.getFavoriteIds(userId);
}
