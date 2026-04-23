import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_cart_items_usecase.dart';
import '../../../domain/usecases/add_to_cart_usecase.dart';
import '../../../domain/usecases/update_cart_item_usecase.dart';
import '../../../domain/usecases/remove_from_cart_usecase.dart';
import '../../../domain/usecases/clear_cart_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItemsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartItemUseCase updateCartItemUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.updateCartItemUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(const CartState()) {
    on<GetCartItemsEvent>(_onGetCartItems);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
  }

  /// Fetches cart items and computes total from CartItem.price — no N+1.
  Future<void> _refreshCart(String userId, Emitter<CartState> emit) async {
    final cartItems = await getCartItemsUseCase(userId);
    final double total =
        cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
    emit(state.copyWith(cartItems: cartItems, total: total, isLoading: false));
  }

  void _onGetCartItems(GetCartItemsEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _refreshCart(event.userId, emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addToCartUseCase(event.userId, event.productId, event.quantity);
      await _refreshCart(event.userId, emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onUpdateCartItem(
      UpdateCartItemEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updateCartItemUseCase(event.cartItemId, event.quantity);
      // Refresh so total and list stay in sync after quantity change
      await _refreshCart(event.userId, emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onRemoveFromCart(
      RemoveFromCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await removeFromCartUseCase(event.cartItemId);
      await _refreshCart(event.userId, emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await clearCartUseCase(event.userId);
      emit(state.copyWith(cartItems: [], total: 0.0, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
