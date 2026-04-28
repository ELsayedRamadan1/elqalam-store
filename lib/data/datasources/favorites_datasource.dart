import 'package:shared_preferences/shared_preferences.dart';

class FavoritesDatasource {
  static const _key = 'favorites';

  // Get all favorite product IDs for a user (stored as userId_favorites)
  Future<Set<String>> getFavoriteIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('${userId}_$_key') ?? [];
    return list.toSet();
  }

  Future<void> addFavorite(String userId, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${userId}_$_key';
    final list = prefs.getStringList(key) ?? [];
    if (!list.contains(productId)) {
      list.add(productId);
      await prefs.setStringList(key, list);
    }
  }

  Future<void> removeFavorite(String userId, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${userId}_$_key';
    final list = prefs.getStringList(key) ?? [];
    list.remove(productId);
    await prefs.setStringList(key, list);
  }

  Future<bool> isFavorite(String userId, String productId) async {
    final ids = await getFavoriteIds(userId);
    return ids.contains(productId);
  }
}
