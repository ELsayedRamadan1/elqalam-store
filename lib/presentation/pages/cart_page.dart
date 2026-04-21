import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/cart/cart_event.dart';
import '../../presentation/blocs/cart/cart_state.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/blocs/order/order_bloc.dart';
import '../../presentation/blocs/order/order_event.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      context.read<CartBloc>().add(GetCartItemsEvent(authState.user!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.user == null) {
          return const Center(
            child: Text('يرجى تسجيل الدخول لعرض السلة'),
          );
        }

        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (cartState.error != null) {
              return Center(child: Text('خطأ: ${cartState.error}'));
            }

            if (cartState.cartItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('السلة فارغة', style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartState.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartState.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Product Image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory, size: 30),
                              ),
                              const SizedBox(width: 16),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${item.price} ريال',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: item.quantity > 1
                                        ? () => context.read<CartBloc>().add(
                                              UpdateCartItemEvent(
                                                item.id,
                                                item.quantity - 1,
                                              ),
                                            )
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: () => context.read<CartBloc>().add(
                                          UpdateCartItemEvent(
                                            item.id,
                                            item.quantity + 1,
                                          ),
                                        ),
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                              // Remove Button
                              IconButton(
                                onPressed: () => context.read<CartBloc>().add(
                                      RemoveFromCartEvent(item.id),
                                    ),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Total and Checkout
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المجموع الكلي:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${cartState.total} ريال',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Create order
                              context.read<OrderBloc>().add(
                                    CreateOrderEvent(
                                      state.user!.id,
                                      cartState.cartItems,
                                    ),
                                  );
                              // Clear cart
                              context.read<CartBloc>().add(ClearCartEvent(state.user!.id));
                              // Navigate to orders
                              // You might want to show a success message or navigate
                            },
                            child: const Text('إتمام الطلب'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
