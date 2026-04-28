import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart' as app_auth;
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/cart/cart_event.dart';
import '../../presentation/blocs/favorites/favorites_bloc.dart';
import '../../presentation/blocs/favorites/favorites_event.dart';
import '../../presentation/blocs/favorites/favorites_state.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/product/product_state.dart';
import '../../presentation/pages/product_detail_page.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null) {
        context
            .read<FavoritesBloc>()
            .add(LoadFavoritesEvent(authState.user!.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, app_auth.AuthState>(
      builder: (context, authState) {
        if (authState.user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 72, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('سجّل دخولك لحفظ مفضلتك',
                    style:
                        TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favState) {
            return BlocBuilder<ProductBloc, ProductState>(
              builder: (context, productState) {
                final favProducts = productState.products
                    .where((p) => favState.isFavorite(p.id))
                    .toList();

                if (favState.isLoading && favProducts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }

                if (favProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('لا توجد منتجات في المفضلة',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        const Text('اضغط على ❤ في أي منتج لإضافته هنا',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<FavoritesBloc>().add(
                        LoadFavoritesEvent(authState.user!.id));
                  },
                  color: AppColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المفضلة (${favProducts.length})',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error, size: 18),
                                label: const Text('مسح الكل',
                                    style:
                                        TextStyle(color: AppColors.error)),
                                onPressed: () => _confirmClearAll(
                                    context,
                                    authState.user!.id,
                                    favProducts.map((p) => p.id).toList()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, i) {
                              final product = favProducts[i];
                              final isFav = favState.isFavorite(product.id);
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailPage(
                                        product: product),
                                  ),
                                ),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: product.imageUrl
                                                      .isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          product.imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (_, __,
                                                              ___) =>
                                                          _placeholder(),
                                                    )
                                                  : _placeholder(),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      product.name,
                                                      maxLines: 2,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .textPrimary),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${product.price.toStringAsFixed(2)} ر.س',
                                                        style: const TextStyle(
                                                            color: AppColors
                                                                .success,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 13),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                  CartBloc>()
                                                              .add(
                                                                  AddToCartEvent(
                                                                      authState
                                                                          .user!
                                                                          .id,
                                                                      product
                                                                          .id,
                                                                      1));
                                                          ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'تم إضافة ${product.name}'),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .success,
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .primary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: const Icon(
                                                              Icons.add,
                                                              color: Colors
                                                                  .white,
                                                              size: 14),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Heart toggle
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            context
                                                .read<FavoritesBloc>()
                                                .add(ToggleFavoriteEvent(
                                                    authState.user!.id,
                                                    product.id));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withAlpha(230),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isFav
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFav
                                                  ? Colors.red
                                                  : Colors.grey,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: favProducts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined,
              size: 50, color: AppColors.primaryLight),
        ),
      );

  void _confirmClearAll(
      BuildContext context, String userId, List<String> productIds) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('مسح المفضلة', textAlign: TextAlign.center),
        content: const Text(
            'هل تريد إزالة جميع المنتجات من المفضلة؟',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              for (final id in productIds) {
                context
                    .read<FavoritesBloc>()
                    .add(ToggleFavoriteEvent(userId, id));
              }
            },
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }
}
