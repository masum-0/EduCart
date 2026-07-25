import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_item.dart';
import '../models/product.dart';

class WishlistService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _wishlistRef(String uid) =>
      _db.collection('wishlists').doc(uid).collection('items');

  Stream<List<WishlistItem>> streamWishlist(String uid) {
    return _wishlistRef(uid).snapshots().map(
          (snap) => snap.docs.map((d) => WishlistItem.fromFirestore(d)).toList(),
        );
  }

  /// Stream of just the product IDs currently wishlisted, handy for showing
  /// filled/outline heart icons on grid tiles without a separate read per tile.
  Stream<Set<String>> streamWishlistIds(String uid) {
    return _wishlistRef(uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> toggleWishlist(String uid, Product product) async {
    final ref = _wishlistRef(uid).doc(product.id);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.delete();
    } else {
      final item = WishlistItem(
        productId: product.id,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      await ref.set(item.toMap());
    }
  }

  Future<void> removeFromWishlist(String uid, String productId) async {
    await _wishlistRef(uid).doc(productId).delete();
  }
}
