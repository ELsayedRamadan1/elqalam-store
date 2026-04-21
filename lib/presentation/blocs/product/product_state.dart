import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';

class ProductState extends Equatable {
  final List<Product> products;
  final Product? product;
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.products = const [],
    this.product,
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? products,
    Product? product,
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      product: product ?? this.product,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [products, product, categories, isLoading, error];
}
