import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _orders => _db.collection('orders');

  Future<String> placeOrder({
    required String uid,
    required List<CartItem> cartItems,
    required String recipientName,
    required String phone,
    required String address,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cannot place an order with an empty cart.');
    }

    final items = cartItems
        .map((c) => OrderItem(
              productId: c.productId,
              title: c.title,
              price: c.price,
              imageUrl: c.imageUrl,
              quantity: c.quantity,
            ))
        .toList();

    final total = cartItems.fold<double>(0, (sum, c) => sum + c.subtotal);

    final order = AppOrder(
      id: '',
      buyerId: uid,
      items: items,
      total: total,
      status: 'placed',
      recipientName: recipientName.trim(),
      phone: phone.trim(),
      address: address.trim(),
    );

    final docRef = await _orders.add(order.toMap());
    return docRef.id;
  }

  // where + client-side sort avoids needing a composite index for this
  // single-field-filtered query.
  Stream<List<AppOrder>> streamMyOrders(String uid) {
    return _orders.where('buyerId', isEqualTo: uid).snapshots().map((snap) {
      final orders = snap.docs.map((d) => AppOrder.fromFirestore(d)).toList();
      orders.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return orders;
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orders.doc(orderId).update({'status': status});
  }

  Stream<List<AppOrder>> streamAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppOrder.fromFirestore(d)).toList());
  }
}