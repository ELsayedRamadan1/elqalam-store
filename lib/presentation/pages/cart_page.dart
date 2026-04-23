import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/cart/cart_event.dart';
import '../../presentation/blocs/cart/cart_state.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart' as app_auth;
import '../../presentation/blocs/order/order_bloc.dart';
import '../../presentation/blocs/order/order_event.dart';
import '../../presentation/blocs/order/order_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Track items removed optimistically so the Dismissible is immediately removed
  // from the UI while the bloc processes the removal.
  final Set<String> _removedItemIds = {};

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      context.read<CartBloc>().add(GetCartItemsEvent(authState.user!.id));
    }
  }

  void _confirmOrder(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد الطلب', textAlign: TextAlign.center),
        content: const Text('هل أنت متأكد من إتمام الطلب؟',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final cartItems = context.read<CartBloc>().state.cartItems;
              context
                  .read<OrderBloc>()
                  .add(CreateOrderEvent(userId, cartItems));
              context.read<CartBloc>().add(ClearCartEvent(userId));
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, orderState) {
        if (orderState.orderCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('تم تسجيل طلبك بنجاح! 🎉'),
              ]),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          context.go('/orders');
        }
        if (orderState.error != null && !orderState.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${orderState.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, app_auth.AuthState>(
        builder: (context, authState) {
          if (authState.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('يرجى تسجيل الدخول لعرض السلة',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            );
          }

          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.isLoading && cartState.cartItems.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (cartState.error != null && cartState.cartItems.isEmpty) {
                return Center(child: Text('خطأ: ${cartState.error}'));
              }

              if (cartState.cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('السلة فارغة',
                          style: TextStyle(
                              fontSize: 20, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      const Text('أضف منتجات لتبدأ التسوق',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.store),
                        label: const Text('تصفح المنتجات'),
                      ),
                    ],
                  ),
                );
              }

              // Build a filtered list that excludes items that were optimistically
              // removed by the user (so the Dismissible gets removed from the
              // tree synchronously and Flutter doesn't assert).
              final visibleItems = cartState.cartItems
                  .where((i) => !_removedItemIds.contains(i.id))
                  .toList();

              // Clean up any ids that are no longer present in the backend list
              // (e.g. after a refresh) so the set doesn't grow indefinitely.
              _removedItemIds.removeWhere(
                  (id) => !cartState.cartItems.any((element) => element.id == id));

              return Column(
                children: [
                  // Items List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibleItems.length,
                      itemBuilder: (context, index) {
                        final item = visibleItems[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            // Optimistically remove from UI so the Dismissible
                            // is no longer part of the tree immediately.
                            setState(() => _removedItemIds.add(item.id));
                            // Then dispatch the removal to the bloc.
                            context.read<CartBloc>().add(
                                  RemoveFromCartEvent(
                                      item.id, authState.user!.id),
                                );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.price.toStringAsFixed(2)} ر.س / قطعة',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'الإجمالي: ${(item.price * item.quantity).toStringAsFixed(2)} ر.س',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quantity controls
                                  Column(
                                    children: [
                                      _SmallButton(
                                        icon: Icons.add,
                                        onTap: () =>
                                            context.read<CartBloc>().add(
                                                  UpdateCartItemEvent(
                                                    item.id,
                                                    authState.user!.id,
                                                    item.quantity + 1,
                                                  ),
                                                ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      _SmallButton(
                                        icon: Icons.remove,
                                        onTap: item.quantity > 1
                                            ? () =>
                                                context.read<CartBloc>().add(
                                                      UpdateCartItemEvent(
                                                        item.id,
                                                        authState.user!.id,
                                                        item.quantity - 1,
                                                      ),
                                                    )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Checkout Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cartState.cartItems.length} منتج',
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              '${cartState.total.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Checkout Button
                        BlocBuilder<OrderBloc, OrderState>(
                          builder: (context, orderState) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: orderState.isLoading
                                    ? null
                                    : () => _confirmOrder(
                                        context, authState.user!.id),
                                icon: orderState.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.check_circle_outline),
                                label: const Text('إتمام الطلب',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
