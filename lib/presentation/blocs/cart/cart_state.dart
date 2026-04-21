import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> cartItems;
  final double total;
  final bool isLoading;
  final String? error;

  const CartState({
    this.cartItems = const [],
    this.total = 0.0,
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItem>? cartItems,
    double? total,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [cartItems, total, isLoading, error];
}
