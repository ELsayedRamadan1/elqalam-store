import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';

class ProductDatasource {
  final SupabaseClient client;

  ProductDatasource(this.client);

  Future<List<Product>> getProducts() async {
    final response = await client.from('products').select();
    return response.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final response = await client.from('products').select().eq('category_id', categoryId);
    return response.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await client.from('products').select().eq('id', id).single();
    return Product.fromJson(response);
  }

  Future<List<Category>> getCategories() async {
    final response = await client.from('categories').select();
    return response.map((e) => Category.fromJson(e)).toList();
  }
}
