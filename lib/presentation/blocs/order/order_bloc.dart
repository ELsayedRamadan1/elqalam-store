import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_orders_usecase.dart';
import '../../../domain/usecases/create_order_usecase.dart';
import '../../../domain/usecases/get_order_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final GetOrderUseCase getOrderUseCase;

  OrderBloc({
    required this.getOrdersUseCase,
    required this.createOrderUseCase,
    required this.getOrderUseCase,
  }) : super(const OrderState()) {
    on<GetOrdersEvent>(_onGetOrders);
    on<CreateOrderEvent>(_onCreateOrder);
    on<GetOrderEvent>(_onGetOrder);
  }

  void _onGetOrders(GetOrdersEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final orders = await getOrdersUseCase(event.userId);
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final order = await createOrderUseCase(event.userId, event.items);
      // Refresh the orders list and signal success with orderCreated = true
      final orders = await getOrdersUseCase(event.userId);
      emit(state.copyWith(
        order: order,
        orders: orders,
        isLoading: false,
        orderCreated: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onGetOrder(GetOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final order = await getOrderUseCase(event.orderId);
      emit(state.copyWith(order: order, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
