import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../datasources/cart_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDatasource datasource;

  CartRepositoryImpl(this.datasource);

  @override
  Future<List<CartItem>> getCartItems(String userId) {
    return datasource.getCartItems(userId);
  }

  @override
  Future<void> addToCart(String userId, String productId, int quantity) {
    return datasource.addToCart(userId, productId, quantity);
  }

  @override
  Future<void> updateCartItem(String cartItemId, int quantity) {
    return datasource.updateCartItem(cartItemId, quantity);
  }

  @override
  Future<void> removeFromCart(String cartItemId) {
    return datasource.removeFromCart(cartItemId);
  }

  @override
  Future<void> clearCart(String userId) {
    return datasource.clearCart(userId);
  }
}
