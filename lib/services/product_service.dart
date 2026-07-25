import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _products => _db.collection('products');

  /// Live stream of all products, most recent first.
  Stream<List<Product>> streamProducts({String? category}) {
    Query query = _products.orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => Product.fromFirestore(d)).toList(),
        );
  }

  Future<Product?> getProduct(String productId) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  Stream<List<Product>> streamMyListings(String uid) {
    return _products
        .where('sellerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Product.fromFirestore(d)).toList());
  }

  Future<String> createProduct(Product product) async {
    if (product.title.trim().isEmpty) {
      throw Exception('Title cannot be empty.');
    }
    if (product.price <= 0) {
      throw Exception('Price must be greater than 0.');
    }
    final docRef = await _products.add(product.toMap());
    return docRef.id;
  }

  Future<void> updateProduct(String productId, Product product) async {
    if (product.title.trim().isEmpty) {
      throw Exception('Title cannot be empty.');
    }
    if (product.price <= 0) {
      throw Exception('Price must be greater than 0.');
    }
    await _products.doc(productId).update({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'condition': product.condition,
      'imageUrl': product.imageUrl,
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  Future<void> updateRatingSummary(
    String productId,
    double newAvg,
    int newCount,
  ) async {
    await _products.doc(productId).update({
      'avgRating': newAvg,
      'ratingCount': newCount,
    });
  }
}
