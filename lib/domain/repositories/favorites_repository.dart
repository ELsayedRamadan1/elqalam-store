abstract class FavoritesRepository {
  Future<Set<String>> getFavoriteIds(String userId);
  Future<void> addFavorite(String userId, String productId);
  Future<void> removeFavorite(String userId, String productId);
  Future<bool> isFavorite(String userId, String productId);
}
