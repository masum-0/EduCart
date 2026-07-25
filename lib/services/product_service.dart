import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _products => _db.collection('products');

  /// Filtered by category client-side sort avoids needing a composite
  /// index for category+createdAt — not currently wired to any screen,
  /// but kept safe in case you filter by category server-side later.
  Stream<List<Product>> streamProducts({String? category}) {
    Query query = _products;
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snap) {
      final products = snap.docs.map((d) => Product.fromFirestore(d)).toList();
      products.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return products;
    });
  }

  Stream<List<Product>> streamAllProducts() {
    return streamProducts();
  }

  Future<Product?> getProduct(String productId) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  // where + client-side sort avoids needing a composite index for this
  // single-field-filtered query.
  Stream<List<Product>> streamMyListings(String uid) {
    return _products.where('sellerId', isEqualTo: uid).snapshots().map((snap) {
      final products = snap.docs.map((d) => Product.fromFirestore(d)).toList();
      products.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
      return products;
    });
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