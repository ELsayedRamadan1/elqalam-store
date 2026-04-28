import '../../domain/entities/product.dart';

/// Data-layer model: handles JSON parsing/serialization.
/// The Domain [Product] entity stays pure Dart with no external dependencies.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.categoryId,
    required super.stock,
    required super.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category_id': categoryId,
        'stock': stock,
        'is_available': isAvailable,
      };
}
