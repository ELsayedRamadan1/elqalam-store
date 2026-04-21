import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<List<Product>> call(String categoryId) {
    return repository.getProductsByCategory(categoryId);
  }
}
