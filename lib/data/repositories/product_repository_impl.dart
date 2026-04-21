import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../datasources/product_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<List<Product>> getProducts() {
    return datasource.getProducts();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) {
    return datasource.getProductsByCategory(categoryId);
  }

  @override
  Future<Product> getProduct(String id) {
    return datasource.getProduct(id);
  }

  @override
  Future<List<Category>> getCategories() {
    return datasource.getCategories();
  }
}
