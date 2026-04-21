import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetOrdersEvent extends OrderEvent {
  final String userId;

  GetOrdersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateOrderEvent extends OrderEvent {
  final String userId;
  final List<CartItem> items;

  CreateOrderEvent(this.userId, this.items);

  @override
  List<Object?> get props => [userId, items];
}

class GetOrderEvent extends OrderEvent {
  final String orderId;

  GetOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
