import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/review_service.dart';
import '../services/wishlist_service.dart';
import 'app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  final ReviewService _reviewService = ReviewService();
  final WishlistService _wishlistService = WishlistService();
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 5;
  bool _addingToCart = false;

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _addingToCart = true);
    try {
      await _cartService.addToCart(user.uid, widget.product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add to cart: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment.')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? user.email ?? 'Student';

      await _reviewService.addReview(
        productId: widget.product.id,
        userId: user.uid,
        userName: userName,
        rating: _selectedRating,
        comment: _reviewController.text.trim(),
      );

      _reviewController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit review: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: primaryBlue,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text('Details', style: TextStyle(color: Colors.white)),
              actions: [
                if (FirebaseAuth.instance.currentUser != null)
                  StreamBuilder<Set<String>>(
                    stream: _wishlistService.streamWishlistIds(
                        FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      final isWishlisted =
                          snapshot.data?.contains(product.id) ?? false;
                      return IconButton(
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () => _wishlistService.toggleWishlist(
                          FirebaseAuth.instance.currentUser!.uid,
                          product,
                        ),
                      );
                    },
                  ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(product.imageUrl, fit: BoxFit.cover)
                              : Container(color: accentBlue.withOpacity(0.3)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        product.title,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${product.avgRating.toStringAsFixed(1)} (${product.ratingCount})',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            product.condition,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '৳ ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Sold by ${product.sellerName}',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 16),
                      Text(product.description),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _addingToCart ? null : _addToCart,
                          icon: const Icon(Icons.add_shopping_cart,
                              color: Colors.white),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        'Reviews',
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Leave a review
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) {
                                final starValue = i + 1;
                                return IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => setState(
                                      () => _selectedRating = starValue.toDouble()),
                                  icon: Icon(
                                    starValue <= _selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  ),
                                );
                              }),
                            ),
                            TextField(
                              controller: _reviewController,
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                border: InputBorder.none,
                              ),
                              maxLines: 2,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _submitReview,
                                child: const Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<List<Review>>(
                        stream: _reviewService.streamReviews(product.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final reviews = snapshot.data!;
                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('No reviews yet. Be the first!'),
                            );
                          }
                          return Column(
                            children: reviews.map((r) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          r.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (i) => Icon(
                                              i < r.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(r.comment),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
