import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/product.dart';
import '../../presentation/blocs/reviews/reviews_bloc.dart';
import '../../presentation/blocs/reviews/reviews_event.dart';
import '../../presentation/blocs/reviews/reviews_state.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart' as app_auth;

class ReviewsSection extends StatefulWidget {
  final Product product;
  const ReviewsSection({super.key, required this.product});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewsBloc>().add(LoadReviewsEvent(widget.product.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: AppColors.success,
          ));
        }
        // Only show error snackbar for non-setup errors (ignore table-not-found)
        if (state.error != null && !_isSetupError(state.error!)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('خطأ في التقييمات'),
            backgroundColor: AppColors.error,
          ));
        }
      },
      builder: (context, state) {
        // If reviews table doesn't exist yet, show a soft placeholder
        if (state.error != null && _isSetupError(state.error!)) {
          return _ReviewsComingSoon();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFFF8F00).withAlpha(46)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8F00).withAlpha(31),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: Color(0xFFFF8F00), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('التقييمات والمراجعات',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100))),
                        Text('${state.reviews.length} تقييم',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (state.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              ))
            else ...[
              // ── Rating Summary ──
              if (state.reviews.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _RatingSummary(state: state),
                ),

              // ── Add Review Button ──
              BlocBuilder<AuthBloc, app_auth.AuthState>(
                builder: (context, authState) {
                  if (authState.user == null) return const SizedBox.shrink();
                  if (state.hasUserReviewed ||
                      state.reviews.any((r) => r.userId == authState.user!.id)) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.success.withAlpha(76)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.success, size: 16),
                            SizedBox(width: 8),
                            Text('لقد قيّمت هذا المنتج',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddReviewSheet(
                            context,
                            authState.user!.id,
                            authState.user!.email.split('@').first),
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('أضف تقييمك'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF8F00),
                          side: const BorderSide(color: Color(0xFFFF8F00)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── Reviews List ──
              if (state.reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 48, color: AppColors.primaryLight),
                        SizedBox(height: 8),
                        Text('لا توجد تقييمات بعد',
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text('كن أول من يقيّم هذا المنتج!',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: state.reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReviewCard(review: state.reviews[i]),
                ),
            ],
          ],
        );
      },
    );
  }

  void _showAddReviewSheet(
      BuildContext context, String userId, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(
        value: context.read<ReviewsBloc>(),
        child: _AddReviewSheet(
          productId: widget.product.id,
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Helper: detect Supabase table-not-found errors
// ─────────────────────────────────────────────────────
bool _isSetupError(String error) {
  return error.toLowerCase().contains('pgrst205') ||
      error.toLowerCase().contains('schema cache') ||
      error.toLowerCase().contains('not find the table') ||
      error.toLowerCase().contains('does not exist');
}

// ─────────────────────────────────────────────────────
// Soft placeholder when reviews table not set up yet
// ─────────────────────────────────────────────────────
class _ReviewsComingSoon extends StatelessWidget {
  const _ReviewsComingSoon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFB300).withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_outline_rounded,
                  color: Color(0xFFFF8F00), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('التقييمات قريباً',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFE65100))),
                  SizedBox(height: 3),
                  Text('ميزة التقييمات ستكون متاحة قريباً',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Rating Summary Widget
// ─────────────────────────────────────────────────────
class _RatingSummary extends StatelessWidget {
  final ReviewsState state;
  const _RatingSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final dist = state.ratingDistribution;
    final total = state.reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Big average number
          Column(
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1),
              ),
              _StarRow(rating: state.averageRating, size: 16),
              const SizedBox(height: 4),
              Text('$total تقييم',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(width: 16),
          // Bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                final pct = total > 0 ? count / total : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star,
                          size: 11, color: Color(0xFFFFB300)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 7,
                            backgroundColor: AppColors.divider,
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 20,
                        child: Text('$count',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Single Review Card
// ─────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final dynamic review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'ar');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withAlpha(38),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'م',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                    Text(dateFormat.format(review.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _StarRow(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Star Row Widget
// ─────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        final half = !full && i < rating;
        return Icon(
          full
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: const Color(0xFFFFB300),
          size: size,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────
// Add Review Bottom Sheet
// ─────────────────────────────────────────────────────
class _AddReviewSheet extends StatefulWidget {
  final String productId;
  final String userId;
  final String userName;

  const _AddReviewSheet({
    required this.productId,
    required this.userId,
    required this.userName,
  });

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  double _selectedRating = 0;
  final _commentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, state) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const Text(
                    'أضف تقييمك',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'شاركنا رأيك في هذا المنتج',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Star selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starVal = (i + 1).toDouble();
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedRating = starVal),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _selectedRating >= starVal
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _selectedRating >= starVal
                                ? const Color(0xFFFFB300)
                                : Colors.grey[400],
                            size: _selectedRating >= starVal ? 40 : 34,
                          ),
                        ),
                      );
                    }),
                  ),

                  if (_selectedRating > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        _ratingLabel(_selectedRating),
                        style: TextStyle(
                          color: const Color(0xFFFF8F00),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Comment field
                  TextFormField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      hintText: 'اكتب تعليقك هنا (اختياري)...',
                      hintStyle:
                          TextStyle(color: AppColors.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedRating == 0 || state.isSubmitting)
                          ? null
                          : _submit,
                      icon: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                          state.isSubmitting ? 'جارٍ الإرسال...' : 'إرسال التقييم'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  String _ratingLabel(double r) {
    if (r >= 5) return 'ممتاز! ⭐';
    if (r >= 4) return 'جيد جداً';
    if (r >= 3) return 'جيد';
    if (r >= 2) return 'مقبول';
    return 'سيئ';
  }

  void _submit() {
    context.read<ReviewsBloc>().add(AddReviewEvent(
          productId: widget.productId,
          userId: widget.userId,
          userName: widget.userName,
          rating: _selectedRating,
          comment: _commentCtrl.text.trim(),
        ));
    Navigator.pop(context);
  }
}
