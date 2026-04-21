import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Order> call(String userId, List<CartItem> items) {
    return repository.createOrder(userId, items);
  }
}
