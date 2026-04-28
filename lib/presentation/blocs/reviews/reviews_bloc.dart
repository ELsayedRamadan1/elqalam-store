import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_reviews_usecase.dart';
import '../../../domain/usecases/add_review_usecase.dart';
import 'reviews_event.dart';
import 'reviews_state.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final GetReviewsUseCase getReviewsUseCase;
  final AddReviewUseCase addReviewUseCase;

  ReviewsBloc({
    required this.getReviewsUseCase,
    required this.addReviewUseCase,
  }) : super(const ReviewsState()) {
    on<LoadReviewsEvent>(_onLoad);
    on<AddReviewEvent>(_onAdd);
    on<CheckUserReviewedEvent>(_onCheck);
  }

  Future<void> _onLoad(
      LoadReviewsEvent event, Emitter<ReviewsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final reviews = await getReviewsUseCase(event.productId);
      emit(state.copyWith(reviews: reviews, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAdd(
      AddReviewEvent event, Emitter<ReviewsState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await addReviewUseCase(
        productId: event.productId,
        userId: event.userId,
        userName: event.userName,
        rating: event.rating,
        comment: event.comment,
      );
      // Reload reviews after adding
      final reviews = await getReviewsUseCase(event.productId);
      emit(state.copyWith(
        reviews: reviews,
        isSubmitting: false,
        hasUserReviewed: true,
        successMessage: 'تم إضافة تقييمك بنجاح!',
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> _onCheck(
      CheckUserReviewedEvent event, Emitter<ReviewsState> emit) async {
    final already = state.reviews.any((r) => r.userId == event.userId);
    emit(state.copyWith(hasUserReviewed: already));
  }
}
