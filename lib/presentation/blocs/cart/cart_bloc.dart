import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_cart_items_usecase.dart';
import '../../../domain/usecases/add_to_cart_usecase.dart';
import '../../../domain/usecases/update_cart_item_usecase.dart';
import '../../../domain/usecases/remove_from_cart_usecase.dart';
import '../../../domain/usecases/clear_cart_usecase.dart';
import '../../../domain/usecases/get_product_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItemsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartItemUseCase updateCartItemUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;
  final GetProductUseCase getProductUseCase;

  CartBloc({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.updateCartItemUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
    required this.getProductUseCase,
  }) : super(const CartState()) {
    on<GetCartItemsEvent>(_onGetCartItems);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
  }

  void _onGetCartItems(GetCartItemsEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final cartItems = await getCartItemsUseCase(event.userId);
      double total = 0.0;
      for (var item in cartItems) {
        final product = await getProductUseCase(item.productId);
        total += product.price * item.quantity;
      }
      emit(state.copyWith(cartItems: cartItems, total: total, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addToCartUseCase(event.userId, event.productId, event.quantity);
      final cartItems = await getCartItemsUseCase(event.userId);
      double total = 0.0;
      for (var item in cartItems) {
        final product = await getProductUseCase(item.productId);
        total += product.price * item.quantity;
      }
      emit(state.copyWith(cartItems: cartItems, total: total, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onUpdateCartItem(UpdateCartItemEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updateCartItemUseCase(event.cartItemId, event.quantity);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await removeFromCartUseCase(event.cartItemId);
      emit(state.copyWith(isLoading: false));
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
