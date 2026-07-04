import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _cartRef(String uid) =>
      _db.collection('carts').doc(uid).collection('items');

  Stream<List<CartItem>> streamCart(String uid) {
    return _cartRef(uid).snapshots().map(
          (snap) => snap.docs.map((d) => CartItem.fromFirestore(d)).toList(),
        );
  }

  Future<void> addToCart(String uid, Product product) async {
    final ref = _cartRef(uid).doc(product.id);
    final existing = await ref.get();

    if (existing.exists) {
      final currentQty =
          (existing.data() as Map<String, dynamic>)['quantity'] ?? 1;
      await ref.update({'quantity': currentQty + 1});
    } else {
      final item = CartItem(
        productId: product.id,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        sellerId: product.sellerId,
      );
      await ref.set(item.toMap());
    }
  }

  Future<void> updateQuantity(String uid, String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(uid, productId);
      return;
    }
    await _cartRef(uid).doc(productId).update({'quantity': quantity});
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await _cartRef(uid).doc(productId).delete();
  }

  Future<void> clearCart(String uid) async {
    final items = await _cartRef(uid).get();
    final batch = _db.batch();
    for (final doc in items.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}