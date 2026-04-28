import 'package:supabase_flutter/supabase_flutter.dart';

// Datasources
import '../data/datasources/auth_datasource.dart';
import '../data/datasources/product_datasource.dart';
import '../data/datasources/cart_datasource.dart';
import '../data/datasources/order_datasource.dart';
import '../data/datasources/favorites_datasource.dart';

// Repositories
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/favorites_repository_impl.dart';

// Repository interfaces
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/repositories/favorites_repository.dart';

// Usecases — Auth
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';
import '../domain/usecases/upload_avatar_usecase.dart';

// Usecases — Product
import '../domain/usecases/get_products_usecase.dart';
import '../domain/usecases/get_product_usecase.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../domain/usecases/get_products_by_category_usecase.dart';

// Usecases — Cart
import '../domain/usecases/get_cart_items_usecase.dart';
import '../domain/usecases/add_to_cart_usecase.dart';
import '../domain/usecases/update_cart_item_usecase.dart';
import '../domain/usecases/remove_from_cart_usecase.dart';
import '../domain/usecases/clear_cart_usecase.dart';

// Usecases — Order
import '../domain/usecases/get_orders_usecase.dart';
import '../domain/usecases/create_order_usecase.dart';
import '../domain/usecases/get_order_usecase.dart';

// Usecases — Favorites
import '../domain/usecases/get_favorites_usecase.dart';
import '../domain/usecases/add_favorite_usecase.dart';
import '../domain/usecases/remove_favorite_usecase.dart';

// Usecases — Reviews

// Blocs
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/product/product_bloc.dart';
import '../presentation/blocs/cart/cart_bloc.dart';
import '../presentation/blocs/order/order_bloc.dart';
import '../presentation/blocs/favorites/favorites_bloc.dart';
import '../presentation/blocs/theme/theme_bloc.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late AuthBloc authBloc;
  late ProductBloc productBloc;
  late CartBloc cartBloc;
  late OrderBloc orderBloc;
  late FavoritesBloc favoritesBloc;
  late ThemeBloc themeBloc;

  Future<void> setup(SupabaseClient client) async {
    // ── Datasources ──────────────────────────────────────
    final authDs      = AuthDatasource(client);
    final productDs   = ProductDatasource(client);
    final cartDs      = CartDatasource(client);
    final orderDs     = OrderDatasource(client);
    final favDs       = FavoritesDatasource();

    // ── Repositories ─────────────────────────────────────
    final AuthRepository      authRepo      = AuthRepositoryImpl(authDs);
    final ProductRepository   productRepo   = ProductRepositoryImpl(productDs);
    final CartRepository      cartRepo      = CartRepositoryImpl(cartDs);
    final OrderRepository     orderRepo     = OrderRepositoryImpl(orderDs);
    final FavoritesRepository favRepo       = FavoritesRepositoryImpl(favDs);

    // ── Usecases ─────────────────────────────────────────
    // Auth
    final loginUC          = LoginUseCase(authRepo);
    final registerUC       = RegisterUseCase(authRepo);
    final logoutUC         = LogoutUseCase(authRepo);
    final getCurrentUserUC = GetCurrentUserUseCase(authRepo);
    final updateProfileUC  = UpdateProfileUseCase(authRepo);
    final uploadAvatarUC   = UploadAvatarUseCase(authRepo);

    // Product
    final getProductsUC         = GetProductsUseCase(productRepo);
    final getProductUC          = GetProductUseCase(productRepo);
    final getCategoriesUC       = GetCategoriesUseCase(productRepo);
    final getProductsByCategoryUC = GetProductsByCategoryUseCase(productRepo);

    // Cart
    final getCartItemsUC   = GetCartItemsUseCase(cartRepo);
    final addToCartUC      = AddToCartUseCase(cartRepo);
    final updateCartItemUC = UpdateCartItemUseCase(cartRepo);
    final removeFromCartUC = RemoveFromCartUseCase(cartRepo);
    final clearCartUC      = ClearCartUseCase(cartRepo);

    // Order
    final getOrdersUC  = GetOrdersUseCase(orderRepo);
    final createOrderUC = CreateOrderUseCase(orderRepo);
    final getOrderUC   = GetOrderUseCase(orderRepo);

    // Favorites
    final getFavoritesUC   = GetFavoritesUseCase(favRepo);
    final addFavoriteUC    = AddFavoriteUseCase(favRepo);
    final removeFavoriteUC = RemoveFavoriteUseCase(favRepo);


    // ── Blocs ────────────────────────────────────────────
    authBloc = AuthBloc(
      loginUseCase: loginUC,
      registerUseCase: registerUC,
      logoutUseCase: logoutUC,
      getCurrentUserUseCase: getCurrentUserUC,
      updateProfileUseCase: updateProfileUC,
      uploadAvatarUseCase: uploadAvatarUC,
    );

    productBloc = ProductBloc(
      getProductsUseCase: getProductsUC,
      getProductUseCase: getProductUC,
      getCategoriesUseCase: getCategoriesUC,
      getProductsByCategoryUseCase: getProductsByCategoryUC,
    );

    cartBloc = CartBloc(
      getCartItemsUseCase: getCartItemsUC,
      addToCartUseCase: addToCartUC,
      updateCartItemUseCase: updateCartItemUC,
      removeFromCartUseCase: removeFromCartUC,
      clearCartUseCase: clearCartUC,
    );

    orderBloc = OrderBloc(
      getOrdersUseCase: getOrdersUC,
      createOrderUseCase: createOrderUC,
      getOrderUseCase: getOrderUC,
    );

    favoritesBloc = FavoritesBloc(
      getFavoritesUseCase: getFavoritesUC,
      addFavoriteUseCase: addFavoriteUC,
      removeFavoriteUseCase: removeFavoriteUC,
    );

    themeBloc = ThemeBloc();
  }
}
