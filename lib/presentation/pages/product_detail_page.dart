import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/product.dart';
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/cart/cart_event.dart';
import '../../presentation/blocs/cart/cart_state.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with product image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.background,
                        child: const Icon(Icons.shopping_bag_outlined,
                            size: 80, color: AppColors.primaryLight),
                      ),
                    )
                  : Container(
                      color: AppColors.background,
                      child: const Icon(Icons.shopping_bag_outlined,
                          size: 80, color: AppColors.primaryLight),
                    ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & status row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product.isAvailable
                                ? AppColors.success
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.isAvailable ? 'متاح' : 'غير متاح',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success.withOpacity(0.1),
                            AppColors.success.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'السعر',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${product.price.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stock
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'المخزون: ${product.stock} قطعة',
                          style: TextStyle(
                            color: product.stock > 5
                                ? AppColors.textSecondary
                                : AppColors.error,
                            fontWeight: product.stock <= 5
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (product.stock > 0 && product.stock <= 5)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              '(كمية محدودة)',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    if (product.description.isNotEmpty) ...[
                      const Text(
                        'الوصف',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quantity Selector
                    if (product.isAvailable && product.stock > 0) ...[
                      const Text(
                        'الكمية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: _quantity < product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // Make the total flexible so it doesn't cause a horizontal
                          // overflow on narrow screens. Use ellipsis if it doesn't fit.
                          Expanded(
                            child: Text(
                              'الإجمالي: ${(product.price * _quantity).toStringAsFixed(2)} ر.س',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Add to Cart
      bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: !product.isAvailable || product.stock == 0
                          ? null
                          : cartState.isLoading
                              ? null
                              : () {
                                  if (authState.user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'يرجى تسجيل الدخول أولاً'),
                                        action: SnackBarAction(
                                          label: 'دخول',
                                          onPressed: () => context.go('/login'),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  // Dispatch AddToCart
                                  context.read<CartBloc>().add(
                                        AddToCartEvent(
                                          authState.user!.id,
                                          product.id,
                                          _quantity,
                                        ),
                                      );

                                  // Use the root navigator's context for navigation
                                  // from the SnackBar action. The root context is
                                  // not deactivated when this page is popped, so
                                  // ancestor lookups (like GoRouter.of) are safe.
                                  final rootContext =
                                      Navigator.of(context, rootNavigator: true)
                                          .context;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم إضافة ${product.name} للسلة',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      backgroundColor: AppColors.success,
                                      action: SnackBarAction(
                                        label: 'عرض السلة',
                                        textColor: Colors.white,
                                        onPressed: () =>
                                            GoRouter.of(rootContext).go('/cart'),
                                      ),
                                    ),
                                  );

                                  // Close this page after adding to cart.
                                  Navigator.pop(context);
                                },
                      icon: cartState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        !product.isAvailable || product.stock == 0
                            ? 'غير متاح'
                            : 'أضف للسلة',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
