import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/get_product_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/usecases/get_products_by_category_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductUseCase getProductUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsByCategoryUseCase getProductsByCategoryUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductUseCase,
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
  }) : super(const ProductState()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductEvent>(_onGetProduct);
    on<GetCategoriesEvent>(_onGetCategories);
    on<GetProductsByCategoryEvent>(_onGetProductsByCategory);
  }

  void _onGetProducts(GetProductsEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final products = await getProductsUseCase();
      emit(state.copyWith(products: products, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onGetProduct(GetProductEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final product = await getProductUseCase(event.id);
      emit(state.copyWith(product: product, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onGetCategories(GetCategoriesEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final categories = await getCategoriesUseCase();
      emit(state.copyWith(categories: categories, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onGetProductsByCategory(GetProductsByCategoryEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final products = await getProductsByCategoryUseCase(event.categoryId);
      emit(state.copyWith(products: products, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
