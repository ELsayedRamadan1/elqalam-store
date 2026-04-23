import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.quantity,
    required super.productName,
    required super.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>?;
    return CartItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      quantity: json['quantity'] as int,
      productName: product?['name'] as String? ?? json['product_name'] as String? ?? '',
      price: (product?['price'] ?? json['price'] ?? 0 as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'user_id': userId,
        'quantity': quantity,
        'product_name': productName,
        'price': price,
      };
}
