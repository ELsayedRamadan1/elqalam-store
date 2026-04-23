import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetCartItemsEvent extends CartEvent {
  final String userId;
  GetCartItemsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddToCartEvent extends CartEvent {
  final String userId;
  final String productId;
  final int quantity;
  AddToCartEvent(this.userId, this.productId, this.quantity);
  @override
  List<Object?> get props => [userId, productId, quantity];
}

class UpdateCartItemEvent extends CartEvent {
  final String cartItemId;
  final String userId; // needed to refresh cart after update
  final int quantity;
  UpdateCartItemEvent(this.cartItemId, this.userId, this.quantity);
  @override
  List<Object?> get props => [cartItemId, userId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;
  final String userId; // needed to refresh cart after removal
  RemoveFromCartEvent(this.cartItemId, this.userId);
  @override
  List<Object?> get props => [cartItemId, userId];
}

class ClearCartEvent extends CartEvent {
  final String userId;
  ClearCartEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}
