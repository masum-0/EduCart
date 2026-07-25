import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;

  WishlistItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  factory WishlistItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WishlistItem(
      productId: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
