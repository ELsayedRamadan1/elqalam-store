import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:elqalam/domain/entities/cart_item.dart';
import 'package:elqalam/domain/usecases/get_cart_items_usecase.dart';
import 'package:elqalam/domain/usecases/add_to_cart_usecase.dart';
import 'package:elqalam/domain/usecases/update_cart_item_usecase.dart';
import 'package:elqalam/domain/usecases/remove_from_cart_usecase.dart';
import 'package:elqalam/domain/usecases/clear_cart_usecase.dart';
import 'package:elqalam/presentation/blocs/cart/cart_bloc.dart';
import 'package:elqalam/presentation/blocs/cart/cart_event.dart';
import 'package:elqalam/presentation/blocs/cart/cart_state.dart';

class MockGetCartItemsUseCase extends Mock implements GetCartItemsUseCase {}
class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}
class MockUpdateCartItemUseCase extends Mock implements UpdateCartItemUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}
class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockGetCartItemsUseCase getCartItemsUseCase;
  late MockAddToCartUseCase addToCartUseCase;
  late MockUpdateCartItemUseCase updateCartItemUseCase;
  late MockRemoveFromCartUseCase removeFromCartUseCase;
  late MockClearCartUseCase clearCartUseCase;

  const testItem = CartItem(
    id: 'ci1',
    productId: 'p1',
    userId: 'u1',
    quantity: 2,
    productName: 'كتاب',
    price: 50.0,
  );

  setUp(() {
    getCartItemsUseCase = MockGetCartItemsUseCase();
    addToCartUseCase = MockAddToCartUseCase();
    updateCartItemUseCase = MockUpdateCartItemUseCase();
    removeFromCartUseCase = MockRemoveFromCartUseCase();
    clearCartUseCase = MockClearCartUseCase();
  });

  CartBloc buildBloc() => CartBloc(
        getCartItemsUseCase: getCartItemsUseCase,
        addToCartUseCase: addToCartUseCase,
        updateCartItemUseCase: updateCartItemUseCase,
        removeFromCartUseCase: removeFromCartUseCase,
        clearCartUseCase: clearCartUseCase,
      );

  group('CartBloc', () {
    test('initial state is empty', () {
      expect(buildBloc().state, const CartState());
    });

    blocTest<CartBloc, CartState>(
      'GetCartItemsEvent — computes total without N+1',
      build: buildBloc,
      setUp: () {
        when(() => getCartItemsUseCase('u1'))
            .thenAnswer((_) async => [testItem]);
      },
      act: (bloc) => bloc.add(GetCartItemsEvent('u1')),
      expect: () => [
        const CartState(isLoading: true),
        const CartState(cartItems: [testItem], total: 100.0), // 2 × 50.0
      ],
    );

    blocTest<CartBloc, CartState>(
      'ClearCartEvent — resets cart',
      build: buildBloc,
      seed: () =>
          const CartState(cartItems: [testItem], total: 100.0),
      setUp: () {
        when(() => clearCartUseCase('u1')).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(ClearCartEvent('u1')),
      expect: () => [
        const CartState(
            isLoading: true, cartItems: [testItem], total: 100.0),
        const CartState(cartItems: [], total: 0.0),
      ],
    );
  });
}
