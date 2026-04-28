import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  final String userId;
  LoadFavoritesEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String userId;
  final String productId;
  ToggleFavoriteEvent(this.userId, this.productId);
  @override
  List<Object?> get props => [userId, productId];
}
