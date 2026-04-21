import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart_item.dart';

class GetCartItemsUseCase {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  Future<List<CartItem>> call(String userId) {
    return repository.getCartItems(userId);
  }
}
