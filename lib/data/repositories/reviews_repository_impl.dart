import '../../domain/entities/review.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_datasource.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsDatasource datasource;
  ReviewsRepositoryImpl(this.datasource);

  @override
  Future<List<Review>> getProductReviews(String productId) =>
      datasource.getProductReviews(productId);

  @override
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) =>
      datasource.addReview(
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
      );

  @override
  Future<bool> hasUserReviewed(String productId, String userId) =>
      datasource.hasUserReviewed(productId, userId);
}
