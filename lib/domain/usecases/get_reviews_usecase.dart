import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

class GetReviewsUseCase {
  final ReviewsRepository repository;
  GetReviewsUseCase(this.repository);
  Future<List<Review>> call(String productId) =>
      repository.getProductReviews(productId);
}
