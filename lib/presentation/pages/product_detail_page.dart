import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/product.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/blocs/cart/cart_bloc.dart';
import '../../presentation/blocs/cart/cart_event.dart';
import '../../presentation/blocs/cart/cart_state.dart';
import '../../presentation/blocs/favorites/favorites_bloc.dart';
import '../../presentation/blocs/favorites/favorites_event.dart';
import '../../presentation/blocs/favorites/favorites_state.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/product/product_state.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return _ProductDetailView(product: product);
  }
}

class _ProductDetailView extends StatefulWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _quantity = 1;
  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  void _navigateToProduct(Product product) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductDetailPage(product: product),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          final similarProducts = productState.products
              .where((p) =>
                  p.id != product.id &&
                  p.categoryId == product.categoryId &&
                  p.isAvailable)
              .toList();

          final suggestedProducts = productState.products
              .where((p) =>
                  p.id != product.id &&
                  p.categoryId != product.categoryId &&
                  p.isAvailable)
              .toList()
            ..sort((a, b) => (a.price - product.price)
                .abs()
                .compareTo((b.price - product.price).abs()));
          final topSuggested = suggestedProducts.take(8).toList();

          return CustomScrollView(
            slivers: [
              // ── Hero AppBar ──
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                actions: [
                  // Heart — wired to FavoritesBloc
                  BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, favState) {
                      final authState = context.read<AuthBloc>().state;
                      final isFav = authState.user != null &&
                          favState.isFavorite(_currentProduct.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red[300] : Colors.white,
                        ),
                        onPressed: () {
                          if (authState.user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('سجّل دخولك أولاً')),
                            );
                            return;
                          }
                          context.read<FavoritesBloc>().add(
                                ToggleFavoriteEvent(authState.user!.id,
                                    _currentProduct.id),
                              );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      Share.share(
                        '🛍️ ${_currentProduct.name}\n'
                        '💰 السعر: ${_currentProduct.price.toStringAsFixed(2)} ر.س\n'
                        '📦 المخزون: ${_currentProduct.stock} قطعة\n\n'
                        'تسوق الآن من متجر القلم!',
                        subject: _currentProduct.name,
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.background,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                ),
                              ),
                              errorWidget: (_, __, ___) =>
                                  _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withAlpha(100),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: product.isAvailable
                                ? AppColors.success
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                product.isAvailable
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.isAvailable ? 'متاح' : 'غير متاح',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Product Info ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'رقم المنتج: ${product.id.length > 8 ? product.id.substring(0, 8).toUpperCase() : product.id}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),

                        // Price block
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success.withAlpha(20),
                                AppColors.success.withAlpha(5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.success.withAlpha(64)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('السعر',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.price.toStringAsFixed(2)} ر.س',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('المخزون',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.stock} قطعة',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: product.stock > 5
                                          ? AppColors.textPrimary
                                          : AppColors.error,
                                    ),
                                  ),
                                  if (product.stock >= 1 &&
                                      product.stock <= 5)
                                    const Text('كمية محدودة!',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Description
                        if (product.description.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text('وصف المنتج',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                          ),
                        ],

                        // Quantity selector
                        if (product.isAvailable && product.stock > 0) ...[
                          const SizedBox(height: 24),
                          const Text('الكمية',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
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
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.divider),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('$_quantity',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _QuantityButton(
                                icon: Icons.add,
                                onTap: _quantity < product.stock
                                    ? () => setState(() => _quantity++)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'الإجمالي: ${(product.price * _quantity).toStringAsFixed(2)} ر.س',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Similar Products ──
              if (similarProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.grid_view_rounded,
                    title: 'منتجات مشابهة',
                    subtitle: 'من نفس الفئة',
                    color: AppColors.primary,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: similarProducts.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (_, i) => _HorizontalProductCard(
                        product: similarProducts[i],
                        onTap: () =>
                            _navigateToProduct(similarProducts[i]),
                        onAddToCart: () =>
                            _addToCart(context, similarProducts[i]),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Suggested Products ──
              if (topSuggested.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.auto_awesome,
                    title: 'قد يعجبك أيضاً',
                    subtitle: 'منتجات مقترحة لك',
                    color: const Color(0xFFE65100),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _GridProductCard(
                        product: topSuggested[i],
                        onTap: () => _navigateToProduct(topSuggested[i]),
                        onAddToCart: () =>
                            _addToCart(context, topSuggested[i]),
                      ),
                      childCount: topSuggested.length,
                    ),
                  ),
                ),
              ],

const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),

      // ── Bottom Bar ──
      bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              final canAdd = product.isAvailable && product.stock > 0;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        // Wishlist button
                        BlocBuilder<FavoritesBloc, FavoritesState>(
                          builder: (context, favState) {
                            final isFav = authState.user != null &&
                                favState.isFavorite(_currentProduct.id);
                            return InkWell(
                              onTap: () {
                                if (authState.user == null) return;
                                context.read<FavoritesBloc>().add(
                                      ToggleFavoriteEvent(
                                          authState.user!.id,
                                          _currentProduct.id),
                                    );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.divider),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav
                                      ? Colors.red
                                      : AppColors.textSecondary,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed:
                                  !canAdd || cartState.isLoading
                                      ? null
                                      : () => _addToCartWithAuth(
                                          context,
                                          authState,
                                          cartState),
                              icon: cartState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(
                                      Icons.shopping_cart_outlined),
                              label: Text(
                                !canAdd
                                    ? 'غير متاح'
                                    : cartState.isLoading
                                        ? 'جارٍ الإضافة...'
                                        : 'أضف للسلة',
                                style:
                                    const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _imagePlaceholder() => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined,
              size: 80, color: AppColors.primaryLight),
        ),
      );

  void _addToCart(BuildContext context, Product p) {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى تسجيل الدخول أولاً'),
          action: SnackBarAction(
              label: 'دخول', onPressed: () => context.go('/login')),
        ),
      );
      return;
    }
    context.read<CartBloc>().add(AddToCartEvent(authState.user!.id, p.id, 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${p.name} للسلة'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'السلة',
          textColor: Colors.white,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
  }

  void _addToCartWithAuth(
      BuildContext context, AuthState authState, CartState cartState) {
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى تسجيل الدخول أولاً'),
          action: SnackBarAction(
              label: 'دخول', onPressed: () => context.go('/login')),
        ),
      );
      return;
    }
    context.read<CartBloc>().add(
          AddToCartEvent(
              authState.user!.id, _currentProduct.id, _quantity),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إضافة ${_currentProduct.name} ($_quantity قطعة) للسلة',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: Colors.white,
          onPressed: () => context.go('/cart'),
        ),
      ),
    );
    Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(38)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_back_ios, size: 14, color: color.withAlpha(128)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Horizontal Product Card (Similar)
// ─────────────────────────────────────────────────────
class _HorizontalProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _HorizontalProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 14),
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
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined,
              size: 36, color: AppColors.primaryLight),
        ),
      );
}

// ─────────────────────────────────────────────────────
// Grid Product Card (Suggested)
// ─────────────────────────────────────────────────────
class _GridProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _GridProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('مقترح',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${product.price.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success),
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 15),
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
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined,
              size: 40, color: AppColors.primaryLight),
        ),
      );
}

// ─────────────────────────────────────────────────────
// Quantity Button
// ─────────────────────────────────────────────────────
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
