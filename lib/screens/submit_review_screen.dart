import 'package:flutter/material.dart';
import '../services/review_service.dart';
import '../utils/snackbar_helper.dart';
import '../l10n/app_localizations.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String mechanicId;
  final String mechanicName;
  final String requestId;
  final Map<String, dynamic>? existingReview;

  const SubmitReviewScreen({
    super.key,
    required this.mechanicId,
    required this.mechanicName,
    required this.requestId,
    this.existingReview,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _reviewController = TextEditingController();
  final _reviewService = ReviewService();
  
  double _rating = 5.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill if editing existing review
    if (widget.existingReview != null) {
      _rating = widget.existingReview!['rating'] ?? 5.0;
      _reviewController.text = widget.existingReview!['reviewText'] ?? '';
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final l10n = AppLocalizations.of(context)!;
    final reviewText = _reviewController.text.trim();

    if (reviewText.isEmpty) {
      SnackBarHelper.showError(context, l10n.pleaseWriteAReview);
      return;
    }

    if (reviewText.length < 10) {
      SnackBarHelper.showError(
        context,
        l10n.reviewMinLength,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _reviewService.submitReview(
        mechanicId: widget.mechanicId,
        requestId: widget.requestId,
        rating: _rating,
        reviewText: reviewText,
      );

      if (!mounted) return;

      SnackBarHelper.showSuccess(
        context,
        widget.existingReview != null
            ? l10n.reviewUpdated
            : l10n.reviewSubmitted,
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      SnackBarHelper.showError(
        context,
        l10n.failedToSubmitReview(e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingReview != null ? l10n.editReview : l10n.writeReview,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mechanic info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: scheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.rateYourExperience,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.mechanicName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Rating Section
            Text(
              l10n.yourRating,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Star rating selector
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starValue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        _rating >= starValue
                            ? Icons.star
                            : Icons.star_border,
                        size: 48,
                        color: _rating >= starValue
                            ? Colors.amber
                            : scheme.outline,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // Rating description
            Center(
              child: Text(
                _getRatingDescription(_rating),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getRatingColor(_rating, scheme),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Review text section
            Text(
              l10n.yourReview,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Review text field
            TextField(
              controller: _reviewController,
              maxLines: 6,
              maxLength: 500,
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: l10n.shareYourExperience,
                hintStyle: TextStyle(
                  color: scheme.onSurface.withOpacity(0.4),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: scheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                counterText: '${_reviewController.text.length}/500',
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Text(
                        widget.existingReview != null
                            ? l10n.updateReview
                            : l10n.submitReview,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.tipsForReview,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.reviewTip1 + '\n' +
                    l10n.reviewTip2 + '\n' +
                    l10n.reviewTip3 + '\n' +
                    l10n.reviewTip4,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSecondaryContainer.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingDescription(double rating) {
    final l10n = AppLocalizations.of(context)!;
    if (rating >= 5) return l10n.ratingExcellent;
    if (rating >= 4) return l10n.ratingVeryGood;
    if (rating >= 3) return l10n.ratingGood;
    if (rating >= 2) return l10n.ratingFair;
    return l10n.ratingPoor;
  }

  Color _getRatingColor(double rating, ColorScheme scheme) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }
}
