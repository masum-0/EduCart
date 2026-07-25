import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _orders => _db.collection('orders');

  /// Places an order from the current cart contents. Does NOT clear the
  /// cart itself — caller (checkout screen) does that after success so a
  /// failed order doesn't silently wipe the cart.
  Future<String> placeOrder(String uid, List<CartItem> cartItems) async {
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
    );

    final docRef = await _orders.add(order.toMap());
    return docRef.id;
  }

  Stream<List<AppOrder>> streamMyOrders(String uid) {
    return _orders
        .where('buyerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppOrder.fromFirestore(d)).toList());
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
