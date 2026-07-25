import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: (map['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}

class AppOrder {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  final double total;
  final String status; // "placed", "completed", "cancelled"
  final String recipientName;
  final String phone;
  final String address;
  final DateTime? createdAt;

  AppOrder({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.total,
    required this.status,
    this.recipientName = '',
    this.phone = '',
    this.address = '',
    this.createdAt,
  });

  factory AppOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawItems = (data['items'] as List<dynamic>? ?? []);
    return AppOrder(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      items: rawItems
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'placed',
      // ?? '' keeps this safe for any orders placed before these fields existed
      recipientName: data['recipientName'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,
      'recipientName': recipientName,
      'phone': phone,
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}