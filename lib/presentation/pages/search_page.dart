import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/product/product_bloc.dart';
import '../../presentation/blocs/product/product_event.dart';
import '../../presentation/blocs/product/product_state.dart';
import '../../presentation/widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  RangeValues priceRange = const RangeValues(0, 10000);
  List<String> selectedCategoryIds = [];
  String sortBy = 'newest'; // newest, price_low, price_high, rating

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(GetProductsEvent());
    context.read<ProductBloc>().add(GetCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن المنتجات'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن المنتجات...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Filter Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.tune),
                      label: const Text('تصفية النتائج'),
                      onPressed: () => _showFilterDialog(context, theme, state),
                    ),
                  ),
                ),

                // Active Filters Display
                if (selectedCategoryIds.isNotEmpty ||
                    priceRange.start > 0 ||
                    priceRange.end < 10000 ||
                    sortBy != 'newest')
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الفلاتر النشطة:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (priceRange.start > 0 ||
                                priceRange.end < 10000)
                              Chip(
                                label: Text(
                                  '${priceRange.start.toInt()} - ${priceRange.end.toInt()} ريال',
                                ),
                                onDeleted: () => setState(() {
                                  priceRange = const RangeValues(0, 10000);
                                }),
                              ),
                            if (sortBy != 'newest')
                              Chip(
                                label: Text(_getSortLabel(sortBy)),
                                onDeleted: () =>
                                    setState(() => sortBy = 'newest'),
                              ),
                            if (selectedCategoryIds.isNotEmpty)
                              Chip(
                                label: Text(
                                  '${selectedCategoryIds.length} فئات',
                                ),
                                onDeleted: () => setState(() {
                                  selectedCategoryIds.clear();
                                }),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Products List
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildProducts(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProducts(ProductState state) {
    final filteredProducts = state.products.where((product) {
      // Search filter
      final matchesSearch = searchController.text.isEmpty ||
          product.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase());

      // Price filter
      final matchesPrice =
          product.price >= priceRange.start && product.price <= priceRange.end;

      // Category filter
      final matchesCategory = selectedCategoryIds.isEmpty ||
          selectedCategoryIds.contains(product.categoryId);

      return matchesSearch && matchesPrice && matchesCategory;
    }).toList();

    // Sort products
    switch (sortBy) {
      case 'price_low':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
      default:
        break;
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات مطابقة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النتائج: ${filteredProducts.length} منتج',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) => ProductCard(
            product: filteredProducts[index],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(
    BuildContext context,
    ThemeData theme,
    ProductState state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التصفية',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price Range
                Text(
                  'نطاق السعر',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 10000,
                  onChanged: (newRange) {
                    setState(() => priceRange = newRange);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${priceRange.start.toInt()} ريال'),
                    Text('${priceRange.end.toInt()} ريال'),
                  ],
                ),
                const SizedBox(height: 20),

                // Sorting
                Text(
                  'الترتيب',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    RadioListTile(
                      title: const Text('الأحدث'),
                      value: 'newest',
                      groupValue: sortBy,
                      onChanged: (value) =>
                          setState(() => sortBy = value ?? 'newest'),
                    ),
                    RadioListTile(
                      title: const Text('السعر: الأقل أولاً'),
                      value: 'price_low',
                      groupValue: sortBy,
                      onChanged: (value) =>
                          setState(() => sortBy = value ?? 'newest'),
                    ),
                    RadioListTile(
                      title: const Text('السعر: الأعلى أولاً'),
                      value: 'price_high',
                      groupValue: sortBy,
                      onChanged: (value) =>
                          setState(() => sortBy = value ?? 'newest'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Categories
                if (state.categories.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الفئات',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: state.categories
                            .map((category) => CheckboxListTile(
                                  title: Text(category.name),
                                  value: selectedCategoryIds
                                      .contains(category.id.toString()),
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected ?? false) {
                                        selectedCategoryIds
                                            .add(category.id.toString());
                                      } else {
                                        selectedCategoryIds
                                            .remove(category.id.toString());
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          searchController.clear();
                          priceRange = const RangeValues(0, 10000);
                          selectedCategoryIds.clear();
                          sortBy = 'newest';
                        }),
                        child: const Text('إعادة تعيين'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('تطبيق'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'price_low':
        return 'السعر: الأقل أولاً';
      case 'price_high':
        return 'السعر: الأعلى أولاً';
      case 'newest':
      default:
        return 'الأحدث';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

