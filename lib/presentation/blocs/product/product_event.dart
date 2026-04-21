import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends ProductEvent {}

class GetProductEvent extends ProductEvent {
  final String id;

  GetProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetCategoriesEvent extends ProductEvent {}

class GetProductsByCategoryEvent extends ProductEvent {
  final String categoryId;

  GetProductsByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
