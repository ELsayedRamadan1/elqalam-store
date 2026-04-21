import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/cart_item.dart';

class CartDatasource {
  final SupabaseClient client;

  CartDatasource(this.client);

  Future<List<CartItem>> getCartItems(String userId) async {
    final response = await client
        .from('cart_items')
        .select('*, products(name, price)')
        .eq('user_id', userId);

    return response.map((e) {
      final product = e['products'] as Map<String, dynamic>;
      return CartItem.fromJson({
        ...e,
        'product_name': product['name'],
        'price': product['price'],
      });
    }).toList();
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    await client.from('cart_items').insert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    await client.from('cart_items').update({'quantity': quantity}).eq('id', cartItemId);
  }

  Future<void> removeFromCart(String cartItemId) async {
    await client.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<void> clearCart(String userId) async {
    await client.from('cart_items').delete().eq('user_id', userId);
  }
}
