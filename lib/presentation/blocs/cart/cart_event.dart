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
  final int quantity;

  UpdateCartItemEvent(this.cartItemId, this.quantity);

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;

  RemoveFromCartEvent(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class ClearCartEvent extends CartEvent {
  final String userId;

  ClearCartEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
