import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';

class OrderState extends Equatable {
  final List<Order> orders;
  final Order? order;
  final bool isLoading;
  final String? error;
  final bool orderCreated; // flag for one-shot success notification

  const OrderState({
    this.orders = const [],
    this.order,
    this.isLoading = false,
    this.error,
    this.orderCreated = false,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? order,
    bool? isLoading,
    String? error,
    bool? orderCreated,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      orderCreated: orderCreated ?? false, // always resets unless explicitly set
    );
  }

  @override
  List<Object?> get props => [orders, order, isLoading, error, orderCreated];
}
