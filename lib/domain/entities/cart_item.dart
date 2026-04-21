class CartItem {
  final String id;
  final String productId;
  final String userId;
  final int quantity;
  final String productName;
  final double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.productName,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      quantity: json['quantity'],
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'quantity': quantity,
      'product_name': productName,
      'price': price,
    };
  }
}
