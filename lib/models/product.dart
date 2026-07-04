import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String condition; // e.g. "New", "Used - Good", "Used - Fair"
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final double avgRating;
  final int ratingCount;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      condition: data['condition'] ?? 'Used',
      imageUrl: data['imageUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? 'Unknown',
      avgRating: (data['avgRating'] ?? 0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0) as int,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'avgRating': avgRating,
      'ratingCount': ratingCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}