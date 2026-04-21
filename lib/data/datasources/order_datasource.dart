import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';

class OrderDatasource {
  final SupabaseClient client;

  OrderDatasource(this.client);

  Future<List<Order>> getOrders(String userId) async {
    final response = await client.from('orders').select().eq('user_id', userId);
    return response.map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> createOrder(String userId, List<CartItem> items) async {
    // Calculate total
    double total = 0;
    List<Map<String, dynamic>> orderItems = [];
    for (var item in items) {
      // Fetch product to get name and price
      final product = await client.from('products').select().eq('id', item.productId).single();
      total += product['price'] * item.quantity;
      orderItems.add({
        'product_id': item.productId,
        'product_name': product['name'],
        'quantity': item.quantity,
        'price': product['price'],
      });
    }
    final orderData = {
      'user_id': userId,
      'items': orderItems,
      'total': total,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };
    final response = await client.from('orders').insert(orderData).select().single();
    return Order.fromJson(response);
  }

  Future<Order> getOrder(String orderId) async {
    final response = await client.from('orders').select().eq('id', orderId).single();
    return Order.fromJson(response);
  }
}
