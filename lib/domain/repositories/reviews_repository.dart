import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<List<Review>> getProductReviews(String productId);
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  });
  Future<bool> hasUserReviewed(String productId, String userId);
}
