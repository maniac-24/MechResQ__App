import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/review_service.dart';
import '../utils/snackbar_helper.dart';
import '../l10n/app_localizations.dart';

class ReviewsListScreen extends StatefulWidget {
  final String mechanicId;
  final String mechanicName;

  const ReviewsListScreen({
    super.key,
    required this.mechanicId,
    required this.mechanicName,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  final _reviewService = ReviewService();
  String _sortBy = 'recent';
  Map<int, int>? _ratingDistribution;

  @override
  void initState() {
    super.initState();
    _loadRatingDistribution();
  }

  Future<void> _loadRatingDistribution() async {
    final distribution =
        await _reviewService.getRatingDistribution(widget.mechanicId);
    if (mounted) {
      setState(() => _ratingDistribution = distribution);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviewsAndRatings),
        actions: [
          // Sort menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Text(l10n.sortMostRecent),
              ),
              PopupMenuItem(
                value: 'highest',
                child: Text(l10n.sortHighestRated),
              ),
              PopupMenuItem(
                value: 'lowest',
                child: Text(l10n.sortLowestRated),
              ),
              PopupMenuItem(
                value: 'helpful',
                child: Text(l10n.sortMostHelpful),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Rating distribution card
          if (_ratingDistribution != null)
            _buildRatingDistribution(scheme),

          // Reviews list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _reviewService.getMechanicReviewsStream(
                mechanicId: widget.mechanicId,
                sortBy: _sortBy,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      l10n.errorLoadingReviews,
                      style: TextStyle(color: scheme.error),
                    ),
                  );
                }

                final reviews = snapshot.data ?? [];

                if (reviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: scheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noReviewsYet,
                          style: TextStyle(
                            fontSize: 18,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.beTheFirstToReview,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _ReviewCard(
                      review: reviews[index],
                      reviewService: _reviewService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(ColorScheme scheme) {
    final total = _ratingDistribution!.values.fold<int>(0, (sum, count) => sum + count);
    
    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.ratingDistribution,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(5, (index) {
            final stars = 5 - index;
            final count = _ratingDistribution![stars] ?? 0;
            final percentage = total > 0 ? (count / total) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$stars',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation(
                          stars >= 4 ? Colors.green : (stars >= 3 ? Colors.orange : Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;
  final ReviewService reviewService;

  const _ReviewCard({
    required this.review,
    required this.reviewService,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool? _userVote;

  @override
  void initState() {
    super.initState();
    _loadUserVote();
  }

  Future<void> _loadUserVote() async {
    final vote = await widget.reviewService.getUserVoteOnReview(
      widget.review['reviewId'],
    );
    if (mounted) {
      setState(() => _userVote = vote);
    }
  }

  Future<void> _handleVote(bool isHelpful) async {
    try {
      await widget.reviewService.markReviewHelpful(
        reviewId: widget.review['reviewId'],
        isHelpful: isHelpful,
      );
      await _loadUserVote();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.failedToRecordVote,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final rating = widget.review['rating'] ?? 0.0;
    final createdAt = widget.review['createdAt'] as DateTime?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: scheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review['userName'] ?? l10n.anonymous,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (createdAt != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              // Star rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRatingColor(rating).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: _getRatingColor(rating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(rating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review text
          Text(
            widget.review['reviewText'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.9),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Helpful buttons
          Row(
            children: [
              Text(
                l10n.wasThisHelpful,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 12),
              _VoteButton(
                icon: Icons.thumb_up,
                count: widget.review['helpfulCount'] ?? 0,
                isSelected: _userVote == true,
                onTap: () => _handleVote(true),
              ),
              const SizedBox(width: 8),
              _VoteButton(
                icon: Icons.thumb_down,
                count: widget.review['notHelpfulCount'] ?? 0,
                isSelected: _userVote == false,
                onTap: () => _handleVote(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? scheme.primary
                  : scheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? scheme.primary
                    : scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
