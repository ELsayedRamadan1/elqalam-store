import 'package:equatable/equatable.dart';

abstract class ReviewsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadReviewsEvent extends ReviewsEvent {
  final String productId;
  LoadReviewsEvent(this.productId);
  @override
  List<Object?> get props => [productId];
}

class AddReviewEvent extends ReviewsEvent {
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;

  AddReviewEvent({
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [productId, userId, rating, comment];
}

class CheckUserReviewedEvent extends ReviewsEvent {
  final String productId;
  final String userId;
  CheckUserReviewedEvent(this.productId, this.userId);
  @override
  List<Object?> get props => [productId, userId];
}
