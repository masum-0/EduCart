import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final String sellerId;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CartItem(
      productId: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      quantity: (data['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}