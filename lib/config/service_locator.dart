import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/auth_datasource.dart';
import '../data/datasources/product_datasource.dart';
import '../data/datasources/cart_datasource.dart';
import '../data/datasources/order_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/get_products_usecase.dart';
import '../domain/usecases/get_product_usecase.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../domain/usecases/get_products_by_category_usecase.dart';
import '../domain/usecases/get_cart_items_usecase.dart';
import '../domain/usecases/add_to_cart_usecase.dart';
import '../domain/usecases/update_cart_item_usecase.dart';
import '../domain/usecases/remove_from_cart_usecase.dart';
import '../domain/usecases/clear_cart_usecase.dart';
import '../domain/usecases/get_orders_usecase.dart';
import '../domain/usecases/create_order_usecase.dart';
import '../domain/usecases/get_order_usecase.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/product/product_bloc.dart';
import '../presentation/blocs/cart/cart_bloc.dart';
import '../presentation/blocs/order/order_bloc.dart';

/// Service Locator for dependency injection
/// This class handles the initialization and management of all dependencies
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  late AuthBloc authBloc;
  late ProductBloc productBloc;
  late CartBloc cartBloc;
  late OrderBloc orderBloc;

  Future<void> setup(SupabaseClient supabaseClient) async {
    // Datasources
    final authDatasource = AuthDatasource(supabaseClient);
    final productDatasource = ProductDatasource(supabaseClient);
    final cartDatasource = CartDatasource(supabaseClient);
    final orderDatasource = OrderDatasource(supabaseClient);

    // Repositories
    final AuthRepository authRepository = AuthRepositoryImpl(authDatasource);
    final ProductRepository productRepository = ProductRepositoryImpl(productDatasource);
    final CartRepository cartRepository = CartRepositoryImpl(cartDatasource);
    final OrderRepository orderRepository = OrderRepositoryImpl(orderDatasource);

    // Auth Usecases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

    // Product Usecases
    final getProductsUseCase = GetProductsUseCase(productRepository);
    final getProductUseCase = GetProductUseCase(productRepository);
    final getCategoriesUseCase = GetCategoriesUseCase(productRepository);
    final getProductsByCategoryUseCase = GetProductsByCategoryUseCase(productRepository);

    // Cart Usecases
    final getCartItemsUseCase = GetCartItemsUseCase(cartRepository);
    final addToCartUseCase = AddToCartUseCase(cartRepository);
    final updateCartItemUseCase = UpdateCartItemUseCase(cartRepository);
    final removeFromCartUseCase = RemoveFromCartUseCase(cartRepository);
    final clearCartUseCase = ClearCartUseCase(cartRepository);

    // Order Usecases
    final getOrdersUseCase = GetOrdersUseCase(orderRepository);
    final createOrderUseCase = CreateOrderUseCase(orderRepository);
    final getOrderUseCase = GetOrderUseCase(orderRepository);

    // Initialize Blocs
    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
    );

    productBloc = ProductBloc(
      getProductsUseCase: getProductsUseCase,
      getProductUseCase: getProductUseCase,
      getCategoriesUseCase: getCategoriesUseCase,
      getProductsByCategoryUseCase: getProductsByCategoryUseCase,
    );

    cartBloc = CartBloc(
      getCartItemsUseCase: getCartItemsUseCase,
      addToCartUseCase: addToCartUseCase,
      updateCartItemUseCase: updateCartItemUseCase,
      removeFromCartUseCase: removeFromCartUseCase,
      clearCartUseCase: clearCartUseCase,
      getProductUseCase: getProductUseCase,
    );

    orderBloc = OrderBloc(
      getOrdersUseCase: getOrdersUseCase,
      createOrderUseCase: createOrderUseCase,
      getOrderUseCase: getOrderUseCase,
    );
  }
}
