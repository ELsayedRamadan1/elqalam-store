import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductDatasource {
  final SupabaseClient client;

  ProductDatasource(this.client);

  Future<List<Product>> getProducts() async {
    final response = await client.from('products').select();
    return response.map<Product>((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final response = await client
        .from('products')
        .select()
        .eq('category_id', categoryId);
    return response.map<Product>((e) => ProductModel.fromJson(e)).toList();
  }

  Future<Product> getProduct(String id) async {
    final response =
        await client.from('products').select().eq('id', id).single();
    return ProductModel.fromJson(response);
  }

  Future<List<Category>> getCategories() async {
    final response = await client.from('categories').select();
    return response.map<Category>((e) => CategoryModel.fromJson(e)).toList();
  }
}
