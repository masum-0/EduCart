import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import 'app_theme.dart';
import 'product_detail_screen.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final ProductService _productService = ProductService();
  Stream<List<Product>>? _listingsStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _listingsStream = _productService.streamMyListings(uid);
    }
  }

  Future<void> _confirmDelete(String productId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove listing?'),
        content: Text('This will permanently remove "$title".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      await _productService.deleteProduct(productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || _listingsStream == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your listings.')),
      );
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('My Listings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        margin: const EdgeInsets.only(top: 10),
        child: StreamBuilder<List<Product>>(
          stream: _listingsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load your listings:\n${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!;
            if (products.isEmpty) {
              return const Center(
                child: Text("You haven't listed anything yet."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: p),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: p.imageUrl.isNotEmpty
                              ? Image.network(p.imageUrl,
                                  width: 60, height: 60, fit: BoxFit.cover)
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: accentBlue.withOpacity(0.3),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('৳ ${p.price.toStringAsFixed(0)}',
                                style: const TextStyle(color: primaryBlue)),
                            if (p.ratingCount > 0)
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${p.avgRating.toStringAsFixed(1)} (${p.ratingCount})',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: primaryBlue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditListingScreen(product: p),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(p.id, p.title),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}