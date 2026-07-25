import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/order.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import 'app_theme.dart';
import 'edit_profile_screen.dart';
import 'my_listings_screen.dart';
import 'order_history_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'settings_screen.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart' hide primaryBlue, lightGrey, pinkColor;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  String name = "Loading...";
  String email = "";
  String dob = "";
  String role = "user";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    email = user.email ?? "";

    final doc = await _firestore.collection("users").doc(user.uid).get();
    final data = doc.data();

    setState(() {
      name = data?['name'] ?? "No Name";
      dob = data?['dob'] ?? "";
      role = data?['role'] ?? "user";
      _isLoading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Educart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (role == 'admin')
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
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PROFILE HEADER
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 38,
                                  backgroundColor: primaryBlue,
                                  child: Text(
                                    _initials(name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13),
                                      ),
                                      if (role == 'admin') ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryBlue.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'ADMIN',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: primaryBlue),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfileScreen(
                                          currentName: name,
                                          currentDob: dob,
                                        ),
                                      ),
                                    );
                                    if (updated == true) loadUserData();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // STATS ROW
                            if (uid != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: StreamBuilder<List<Product>>(
                                      stream:
                                          _productService.streamMyListings(uid),
                                      builder: (context, snapshot) {
                                        final count =
                                            snapshot.data?.length ?? 0;
                                        return _statCard(
                                            'Listings', count.toString());
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StreamBuilder<List<AppOrder>>(
                                      stream: _orderService.streamMyOrders(uid),
                                      builder: (context, snapshot) {
                                        final count =
                                            snapshot.data?.length ?? 0;
                                        return _statCard(
                                            'Orders', count.toString());
                                      },
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 28),

                            const Text(
                              'My Account',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),

                            _menuTile(
                              icon: Icons.storefront_outlined,
                              label: 'My Listings',
                              subtitle: 'Manage items you\'re selling',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyListingsScreen(),
                                ),
                              ),
                            ),
                            _menuTile(
                              icon: Icons.receipt_long_outlined,
                              label: 'Order History',
                              subtitle: 'Track things you\'ve bought',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrderHistoryScreen(),
                                ),
                              ),
                            ),
                            _menuTile(
                              icon: Icons.shopping_cart_outlined,
                              label: 'My Cart',
                              subtitle: 'Items ready for checkout',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              ),
                            ),
                            _menuTile(
                              icon: Icons.favorite_border,
                              label: 'My Wishlist',
                              subtitle: 'Items you\'ve saved for later',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WishlistScreen(),
                                ),
                              ),
                            ),
                            _menuTile(
                              icon: Icons.person_outline,
                              label: 'Edit Profile',
                              subtitle: 'Update your name and details',
                              onTap: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      currentName: name,
                                      currentDob: dob,
                                    ),
                                  ),
                                );
                                if (updated == true) loadUserData();
                              },
                            ),
                            if (role == 'admin')
                              _menuTile(
                                icon: Icons.admin_panel_settings_outlined,
                                label: 'Admin Dashboard',
                                subtitle: 'Manage listings, users, and orders',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminDashboardScreen(),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),

                            _menuTile(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              subtitle: 'About & account info',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              ),
                            ),

                            _menuTile(
                              icon: Icons.logout,
                              label: 'Log Out',
                              subtitle: null,
                              iconColor: Colors.red,
                              labelColor: Colors.red,
                              onTap: _confirmLogout,
                            ),

                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'UID: ${_auth.currentUser?.uid ?? ""}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    String? subtitle,
    Color iconColor = primaryBlue,
    Color labelColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }
}
