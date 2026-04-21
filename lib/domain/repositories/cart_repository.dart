import '../../domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems(String userId);
  Future<void> addToCart(String userId, String productId, int quantity);
  Future<void> updateCartItem(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart(String userId);
}
