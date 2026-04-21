import '../../domain/repositories/cart_repository.dart';

class UpdateCartItemUseCase {
  final CartRepository repository;

  UpdateCartItemUseCase(this.repository);

  Future<void> call(String cartItemId, int quantity) {
    return repository.updateCartItem(cartItemId, quantity);
  }
}
