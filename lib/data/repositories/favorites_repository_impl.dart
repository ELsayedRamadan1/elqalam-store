import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDatasource datasource;
  FavoritesRepositoryImpl(this.datasource);

  @override
  Future<Set<String>> getFavoriteIds(String userId) =>
      datasource.getFavoriteIds(userId);

  @override
  Future<void> addFavorite(String userId, String productId) =>
      datasource.addFavorite(userId, productId);

  @override
  Future<void> removeFavorite(String userId, String productId) =>
      datasource.removeFavorite(userId, productId);

  @override
  Future<bool> isFavorite(String userId, String productId) =>
      datasource.isFavorite(userId, productId);
}
