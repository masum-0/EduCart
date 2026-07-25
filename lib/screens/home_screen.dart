import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../services/wishlist_service.dart';
import '../services/cart_service.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'sell_screen.dart';
import 'order_history_screen.dart';
import 'admin_dashboard_screen.dart';
import 'app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isAdmin = false;

  final List<String> _tabs = ['All', ...productCategories];

  // Streams are created exactly once here and reused for the lifetime of
  // this screen. Creating them inline inside build() instead would make
  // every rebuild (e.g. from setState) tear down and restart the Firestore
  // listener, which is what caused lists to flash and then go blank.
  late final Stream<List<Product>> _productsStream;
  Stream<Set<String>>? _wishlistIdsStream;
  Stream<Set<String>>? _cartIdsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = _productService.streamAllProducts();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _wishlistIdsStream = _wishlistService.streamWishlistIds(uid);
      _cartIdsStream = _cartService.streamCartProductIds(uid);
    }

    _checkAdmin();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await _authService.isCurrentUserAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }

  Future<void> _toggleCart(Product product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _cartService.toggleCartItem(uid, product);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update cart: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2100B8),
      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "EduCart",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isAdmin)
                        IconButton(
                          icon: const Icon(Icons.admin_panel_settings,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminDashboardScreen(),
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SEARCH BAR — icon on the right, filters the grid live
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6E8CFF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: TextField(
                              controller: _searchController,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: "Search books...",
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.search, color: Colors.white, size: 30),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // CATEGORY TABS
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final isSelected = tab == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = tab),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 28),
                            child: Column(
                              children: [
                                Text(
                                  tab,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (isSelected)
                                  Container(
                                    width: 50,
                                    height: 2,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // GRID — single stable stream, filtered client-side by category + search
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _productsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load listings:\n${snapshot.error}',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  var products = snapshot.data!;
                  if (_selectedCategory != 'All') {
                    products = products
                        .where((p) => p.category == _selectedCategory)
                        .toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    products = products
                        .where((p) =>
                            p.title.toLowerCase().contains(_searchQuery) ||
                            p.description.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No items match "${_searchController.text}"'
                              : 'No items yet. Be the first to sell something!',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5F7CFF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              // BOOK COVER
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white24,
                                    image: product.imageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(product.imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: product.imageUrl.isEmpty
                                      ? const Icon(Icons.menu_book,
                                          color: Colors.white54, size: 40)
                                      : null,
                                ),
                              ),

                              // PRICE SECTION
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "৳ ${product.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // BUTTONS — favorite toggles wishlist, cart icon toggles cart
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 12),
                                child: Row(
                                  children: [
                                    if (_wishlistIdsStream != null)
                                      StreamBuilder<Set<String>>(
                                        stream: _wishlistIdsStream,
                                        builder: (context, wSnapshot) {
                                          final isWishlisted = wSnapshot.data
                                                  ?.contains(product.id) ??
                                              false;
                                          return GestureDetector(
                                            onTap: () {
                                              final uid = FirebaseAuth
                                                  .instance.currentUser?.uid;
                                              if (uid != null) {
                                                _wishlistService
                                                    .toggleWishlist(uid, product);
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                color:
                                                    const Color(0xFFA8C8FF),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Icon(
                                                isWishlisted
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 20,
                                                color: isWishlisted
                                                    ? Colors.redAccent
                                                    : Colors.black87,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    const SizedBox(width: 10),
                                    if (_cartIdsStream != null)
                                      Expanded(
                                        child: StreamBuilder<Set<String>>(
                                          stream: _cartIdsStream,
                                          builder: (context, cSnapshot) {
                                            final inCart = cSnapshot.data
                                                    ?.contains(product.id) ??
                                                false;
                                            return GestureDetector(
                                              onTap: () => _toggleCart(product),
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: inCart
                                                      ? primaryBlue
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Icon(
                                                  inCart
                                                      ? Icons.check
                                                      : Icons
                                                          .add_shopping_cart_outlined,
                                                  size: 22,
                                                  color: inCart
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF8EB6FF),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {}, // Home — already here
              child: navItem(Icons.home_outlined),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellScreen()),
                );
              },
              child: navItem(Icons.add_box_outlined),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: navItem(Icons.shopping_cart_outlined),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderHistoryScreen(),
                  ),
                );
              },
              child: navItem(Icons.receipt_long_outlined),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: navItem(Icons.person_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon) {
    return Container(
      height: 55,
      width: 55,
      decoration: const BoxDecoration(
        color: Color(0xFF3E7DDB),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}