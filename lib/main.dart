import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'config/service_locator.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/orders_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/favorites_page.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart' as app_auth;
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_state.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/favorites/favorites_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppConstants.validate();
  await initializeDateFormatting('ar');

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  final serviceLocator = ServiceLocator();
  await serviceLocator.setup(Supabase.instance.client);

  serviceLocator.authBloc.add(GetCurrentUserEvent());

  runApp(MyApp(serviceLocator: serviceLocator));
}

String? _authGuard(BuildContext context, GoRouterState state) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return '/login';
  return null;
}

final GoRouter _router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const Scaffold(body: FavoritesView()),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/cart',
            redirect: _authGuard,
            builder: (_, __) => const CartPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/orders',
            redirect: _authGuard,
            builder: (_, __) => const OrdersPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ]),
      ],
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
  ],
);

class MyApp extends StatelessWidget {
  final ServiceLocator serviceLocator;
  const MyApp({super.key, required this.serviceLocator});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator.authBloc),
        BlocProvider(create: (_) => serviceLocator.productBloc),
        BlocProvider(create: (_) => serviceLocator.cartBloc),
        BlocProvider(create: (_) => serviceLocator.orderBloc),
        BlocProvider(create: (_) => serviceLocator.favoritesBloc),
        BlocProvider(create: (_) => serviceLocator.themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'القلم',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithBottomNavBar'));

  final StatefulNavigationShell navigationShell;

  // Load favorites whenever user lands on the tab
  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(index);
    if (index == 1) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        context
            .read<FavoritesBloc>()
            .add(LoadFavoritesEvent(user.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['الرئيسية', 'المفضلة', 'السلة', 'طلباتي', 'حسابي'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[navigationShell.currentIndex]),
        actions: [
          if (navigationShell.currentIndex != 2)
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final count = cartState.cartItems.length;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () => _onTap(context, 2),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          BlocBuilder<AuthBloc, app_auth.AuthState>(
            builder: (context, authState) {
              if (authState.user != null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'تسجيل الدخول',
                onPressed: () => context.go('/login'),
              );
            },
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

//flutter run --dart-define=SUPABASE_URL=https://kjsovaohtawvaivaplkg.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_0Q3iN9W6TLJ9vJH64gAjsA_IvuOTDWx
