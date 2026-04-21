import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';

class OrderState extends Equatable {
  final List<Order> orders;
  final Order? order;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.order,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? order,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [orders, order, isLoading, error];
}
