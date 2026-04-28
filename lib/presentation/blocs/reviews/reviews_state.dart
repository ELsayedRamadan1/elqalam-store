import 'package:equatable/equatable.dart';
import '../../../domain/entities/review.dart';

class ReviewsState extends Equatable {
  final List<Review> reviews;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasUserReviewed;
  final String? error;
  final String? successMessage;

  const ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasUserReviewed = false,
    this.error,
    this.successMessage,
  });

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  Map<int, int> get ratingDistribution {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final key = r.rating.round().clamp(1, 5);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  ReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasUserReviewed,
    String? error,
    String? successMessage,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasUserReviewed: hasUserReviewed ?? this.hasUserReviewed,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props =>
      [reviews, isLoading, isSubmitting, hasUserReviewed, error, successMessage];
}
