import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<Product> getProduct(String id);
  Future<List<Category>> getCategories();
}
