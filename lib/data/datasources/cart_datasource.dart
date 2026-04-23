import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/cart_item.dart';
import '../models/cart_item_model.dart';

class CartDatasource {
  final SupabaseClient client;

  CartDatasource(this.client);

  Future<List<CartItem>> getCartItems(String userId) async {
    final response = await client
        .from('cart_items')
        .select('*, products(name, price)')
        .eq('user_id', userId);

    return response
        .map<CartItem>((e) => CartItemModel.fromJson(e))
        .toList();
  }

  /// Adds item to cart with stock validation.
  /// Throws [Exception] if requested quantity exceeds available stock.
  Future<void> addToCart(
      String userId, String productId, int quantity) async {
    // Validate stock before inserting
    final product = await client
        .from('products')
        .select('stock, is_available')
        .eq('id', productId)
        .single();

    if (product['is_available'] == false) {
      throw Exception('المنتج غير متاح حالياً');
    }
    final stock = product['stock'] as int? ?? 0;
    if (quantity > stock) {
      throw Exception('الكمية المطلوبة ($quantity) تتجاوز المخزون المتاح ($stock)');
    }

    await client.from('cart_items').insert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    await client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  Future<void> removeFromCart(String cartItemId) async {
    await client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart(String userId) async {
    await client.from('cart_items').delete().eq('user_id', userId);
  }
}
