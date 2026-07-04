import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/product_service.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  CollectionReference _reviewsRef(String productId) =>
      _db.collection('products').doc(productId).collection('reviews');

  Stream<List<Review>> streamReviews(String productId) {
    return _reviewsRef(productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Review.fromFirestore(d)).toList());
  }

  /// Adds a review, then recalculates and writes the product's avgRating
  /// and ratingCount. One review per user is enforced by using the user's
  /// uid as the review document id (a repeat submission overwrites theirs).
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }

    await _reviewsRef(productId).doc(userId).set(
      Review(
        id: userId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment.trim(),
      ).toMap(),
    );

    final allReviews = await _reviewsRef(productId).get();
    final ratings = allReviews.docs
        .map((d) => ((d.data() as Map<String, dynamic>)['rating'] ?? 0).toDouble())
        .toList();
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    await _productService.updateRatingSummary(productId, avg, ratings.length);
  }
}