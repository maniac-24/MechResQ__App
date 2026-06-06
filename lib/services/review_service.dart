import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing reviews and ratings
class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // ═══════════════════════════════════════════════════════════
  // CREATE/UPDATE REVIEW
  // ═══════════════════════════════════════════════════════════

  /// Submit a review for a mechanic
  /// Can be called after service completion
  Future<void> submitReview({
    required String mechanicId,
    required String requestId,
    required double rating,
    required String reviewText,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    // Check if user already reviewed this mechanic for this request
    final existingReview = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('mechanicId', isEqualTo: mechanicId)
        .where('requestId', isEqualTo: requestId)
        .get();

    if (existingReview.docs.isNotEmpty) {
      // Update existing review
      await _updateExistingReview(
        existingReview.docs.first.id,
        rating,
        reviewText,
        mechanicId,
      );
    } else {
      // Create new review
      await _createNewReview(
        mechanicId: mechanicId,
        requestId: requestId,
        rating: rating,
        reviewText: reviewText,
      );
    }
  }

  Future<void> _createNewReview({
    required String mechanicId,
    required String requestId,
    required double rating,
    required String reviewText,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final batch = _db.batch();

    // Create review document
    final reviewRef = _db.collection('reviews').doc();
    batch.set(reviewRef, {
      'reviewId': reviewRef.id,
      'userId': userId,
      'mechanicId': mechanicId,
      'requestId': requestId,
      'rating': rating,
      'reviewText': reviewText,
      'helpfulCount': 0,
      'notHelpfulCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update mechanic's rating stats
    await _recalculateMechanicRating(mechanicId);

    await batch.commit();
  }

  Future<void> _updateExistingReview(
    String reviewId,
    double rating,
    String reviewText,
    String mechanicId,
  ) async {
    await _db.collection('reviews').doc(reviewId).update({
      'rating': rating,
      'reviewText': reviewText,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Recalculate mechanic's rating
    await _recalculateMechanicRating(mechanicId);
  }

  // ═══════════════════════════════════════════════════════════
  // GET REVIEWS
  // ═══════════════════════════════════════════════════════════

  /// Get all reviews for a mechanic (with pagination support)
  Stream<List<Map<String, dynamic>>> getMechanicReviewsStream({
    required String mechanicId,
    String? sortBy = 'recent', // recent, highest, lowest, helpful
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('reviews')
        .where('mechanicId', isEqualTo: mechanicId);

    // Apply sorting
    switch (sortBy) {
      case 'highest':
        query = query.orderBy('rating', descending: true);
        break;
      case 'lowest':
        query = query.orderBy('rating', descending: false);
        break;
      case 'helpful':
        query = query.orderBy('helpfulCount', descending: true);
        break;
      case 'recent':
      default:
        query = query.orderBy('createdAt', descending: true);
    }

    return query.limit(limit).snapshots().asyncMap((snapshot) async {
      final reviews = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // Fetch user info for each review
        final userDoc = await _db.collection('users').doc(data['userId']).get();
        final userData = userDoc.data();

        reviews.add({
          'reviewId': data['reviewId'] ?? doc.id,
          'userId': data['userId'],
          'userName': userData?['name'] ?? 'Anonymous',
          'mechanicId': data['mechanicId'],
          'requestId': data['requestId'],
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'reviewText': data['reviewText'] ?? '',
          'helpfulCount': (data['helpfulCount'] as num?)?.toInt() ?? 0,
          'notHelpfulCount': (data['notHelpfulCount'] as num?)?.toInt() ?? 0,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        });
      }

      return reviews;
    });
  }

  /// Get user's own review for a specific mechanic request
  Future<Map<String, dynamic>?> getUserReviewForRequest({
    required String mechanicId,
    required String requestId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final snapshot = await _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .where('mechanicId', isEqualTo: mechanicId)
        .where('requestId', isEqualTo: requestId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();

    return {
      'reviewId': data['reviewId'] ?? doc.id,
      'userId': data['userId'],
      'mechanicId': data['mechanicId'],
      'requestId': data['requestId'],
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'reviewText': data['reviewText'] ?? '',
      'helpfulCount': (data['helpfulCount'] as num?)?.toInt() ?? 0,
      'notHelpfulCount': (data['notHelpfulCount'] as num?)?.toInt() ?? 0,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
    };
  }

  /// Get rating distribution for a mechanic
  Future<Map<int, int>> getRatingDistribution(String mechanicId) async {
    final reviews = await _db
        .collection('reviews')
        .where('mechanicId', isEqualTo: mechanicId)
        .get();

    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final doc in reviews.docs) {
      final rating = (doc.data()['rating'] as num?)?.round() ?? 0;
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }

    return distribution;
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE REVIEW
  // ═══════════════════════════════════════════════════════════

  /// Delete user's own review
  Future<void> deleteReview(String reviewId, String mechanicId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Verify ownership
    final doc = await _db.collection('reviews').doc(reviewId).get();
    if (!doc.exists) throw Exception('Review not found');

    final data = doc.data();
    if (data?['userId'] != userId) {
      throw Exception('You can only delete your own reviews');
    }

    await _db.collection('reviews').doc(reviewId).delete();

    // Recalculate mechanic's rating
    await _recalculateMechanicRating(mechanicId);
  }

  // ═══════════════════════════════════════════════════════════
  // HELPFUL VOTES
  // ═══════════════════════════════════════════════════════════

  /// Mark review as helpful
  Future<void> markReviewHelpful({
    required String reviewId,
    required bool isHelpful,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final voteRef = _db
        .collection('reviews')
        .doc(reviewId)
        .collection('votes')
        .doc(userId);

    final existingVote = await voteRef.get();

    if (existingVote.exists) {
      // Update existing vote
      final previousVote = existingVote.data()?['isHelpful'] as bool?;
      
      if (previousVote == isHelpful) {
        // Remove vote if clicking same button
        await voteRef.delete();
        await _updateReviewVoteCounts(reviewId, isHelpful, increment: false);
      } else {
        // Change vote
        await voteRef.update({'isHelpful': isHelpful});
        await _updateReviewVoteCounts(reviewId, !isHelpful, increment: false);
        await _updateReviewVoteCounts(reviewId, isHelpful, increment: true);
      }
    } else {
      // Create new vote
      await voteRef.set({
        'userId': userId,
        'isHelpful': isHelpful,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _updateReviewVoteCounts(reviewId, isHelpful, increment: true);
    }
  }

  Future<void> _updateReviewVoteCounts(
    String reviewId,
    bool isHelpful,
    {required bool increment},
  ) async {
    final field = isHelpful ? 'helpfulCount' : 'notHelpfulCount';
    await _db.collection('reviews').doc(reviewId).update({
      field: FieldValue.increment(increment ? 1 : -1),
    });
  }

  /// Get user's vote on a review
  Future<bool?> getUserVoteOnReview(String reviewId) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final voteDoc = await _db
        .collection('reviews')
        .doc(reviewId)
        .collection('votes')
        .doc(userId)
        .get();

    if (!voteDoc.exists) return null;
    return voteDoc.data()?['isHelpful'] as bool?;
  }

  // ═══════════════════════════════════════════════════════════
  // RATING CALCULATION
  // ═══════════════════════════════════════════════════════════

  /// Recalculate and update mechanic's overall rating
  Future<void> _recalculateMechanicRating(String mechanicId) async {
    final reviews = await _db
        .collection('reviews')
        .where('mechanicId', isEqualTo: mechanicId)
        .get();

    if (reviews.docs.isEmpty) {
      // No reviews, set to 0
      await _db.collection('mechanics').doc(mechanicId).update({
        'rating': 0.0,
        'totalReviews': 0,
      });
      return;
    }

    double totalRating = 0;
    int count = 0;

    for (final doc in reviews.docs) {
      final rating = (doc.data()['rating'] as num?)?.toDouble();
      if (rating != null) {
        totalRating += rating;
        count++;
      }
    }

    final avgRating = count > 0 ? totalRating / count : 0.0;

    await _db.collection('mechanics').doc(mechanicId).update({
      'rating': double.parse(avgRating.toStringAsFixed(1)),
      'totalReviews': count,
    });
  }

  /// Check if user can review (service must be completed)
  Future<bool> canUserReview({
    required String mechanicId,
    required String requestId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    // Check if request is completed
    final requestDoc = await _db.collection('requests').doc(requestId).get();
    if (!requestDoc.exists) return false;

    final requestData = requestDoc.data();
    if (requestData?['status'] != 'completed') return false;
    if (requestData?['userId'] != userId) return false;
    if (requestData?['mechanicId'] != mechanicId) return false;

    return true;
  }
}
