import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../models/order_model.dart';

class OrderDatasource {
  final SupabaseClient client;

  OrderDatasource(this.client);

  Future<List<Order>> getOrders(String userId) async {
    final response = await client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map<Order>((e) => OrderModel.fromJson(e)).toList();
  }

  /// Creates an order — fixes the N+1 problem by computing total
  /// directly from CartItem.price (already fetched with product join).
  Future<Order> createOrder(String userId, List<CartItem> items) async {
    // Total is calculated from CartItem.price — no extra DB queries needed.
    final double total = items.fold(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );

    final List<Map<String, dynamic>> orderItems = items
        .map((item) => {
              'product_id': item.productId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'price': item.price,
            })
        .toList();

    final orderData = {
      'user_id': userId,
      'items': orderItems,
      'total': total,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };

    final response =
        await client.from('orders').insert(orderData).select().single();
    return OrderModel.fromJson(response);
  }

  Future<Order> getOrder(String orderId) async {
    final response =
        await client.from('orders').select().eq('id', orderId).single();
    return OrderModel.fromJson(response);
  }
}
