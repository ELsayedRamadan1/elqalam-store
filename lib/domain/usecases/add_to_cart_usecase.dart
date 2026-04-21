import '../../domain/repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<void> call(String userId, String productId, int quantity) {
    return repository.addToCart(userId, productId, quantity);
  }
}
