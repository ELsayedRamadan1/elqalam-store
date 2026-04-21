import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders(String userId);
  Future<Order> createOrder(String userId, List<CartItem> items);
  Future<Order> getOrder(String orderId);
}
