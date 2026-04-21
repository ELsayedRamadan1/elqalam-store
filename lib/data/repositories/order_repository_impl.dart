import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../datasources/order_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderDatasource datasource;

  OrderRepositoryImpl(this.datasource);

  @override
  Future<List<Order>> getOrders(String userId) {
    return datasource.getOrders(userId);
  }

  @override
  Future<Order> createOrder(String userId, List<CartItem> items) {
    return datasource.createOrder(userId, items);
  }

  @override
  Future<Order> getOrder(String orderId) {
    return datasource.getOrder(orderId);
  }
}
