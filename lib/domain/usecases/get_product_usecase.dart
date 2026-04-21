import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';

class GetProductUseCase {
  final ProductRepository repository;

  GetProductUseCase(this.repository);

  Future<Product> call(String id) {
    return repository.getProduct(id);
  }
}
