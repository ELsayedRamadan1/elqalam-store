import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/review.dart';
import '../models/review_model.dart';

class ReviewsDatasource {
  final SupabaseClient client;
  ReviewsDatasource(this.client);

  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final response = await client
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return response.map<Review>((e) => ReviewModel.fromJson(e)).toList();
    } catch (e) {
      if (_isSetupError(e.toString())) {
        // Table not created yet — throw a recognizable error for the BLoC
        throw Exception('PGRST205: reviews table not set up yet');
      }
      rethrow;
    }
  }

  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    try {
      await client.from('reviews').insert({
        'product_id': productId,
        'user_id': userId,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (_isSetupError(e.toString())) return;
      rethrow;
    }
  }

  Future<bool> hasUserReviewed(String productId, String userId) async {
    try {
      final response = await client
          .from('reviews')
          .select('id')
          .eq('product_id', productId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      if (_isSetupError(e.toString())) return false;
      rethrow;
    }
  }

  bool _isSetupError(String error) {
    final e = error.toLowerCase();
    return e.contains('pgrst205') ||
        e.contains('schema cache') ||
        e.contains('not find the table') ||
        e.contains('does not exist');
  }
}
