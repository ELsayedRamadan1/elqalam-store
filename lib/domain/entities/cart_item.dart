/// Pure domain entity.
class CartItem {
  final String id;
  final String productId;
  final String userId;
  final int quantity;
  final String productName;
  final double price;

  const CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.productName,
    required this.price,
  });
}
