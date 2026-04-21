import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<List<Order>> call(String userId) {
    return repository.getOrders(userId);
  }
}
