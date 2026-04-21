import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';

class GetOrderUseCase {
  final OrderRepository repository;

  GetOrderUseCase(this.repository);

  Future<Order> call(String orderId) {
    return repository.getOrder(orderId);
  }
}
