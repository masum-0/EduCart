import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order.dart';
import '../services/order_service.dart';
import 'app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  Stream<List<AppOrder>>? _ordersStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _ordersStream = _orderService.streamMyOrders(uid);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || _ordersStream == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Order History', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        margin: const EdgeInsets.only(top: 10),
        child: StreamBuilder<List<AppOrder>>(
          stream: _ordersStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load your orders:\n${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snapshot.data!;
            if (orders.isEmpty) {
              return const Center(child: Text('No orders yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 6)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(order.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(order.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (order.createdAt != null)
                        Text(
                          '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      const Divider(height: 20),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${item.title} x${item.quantity}'),
                              ),
                              Text('৳ ${(item.price * item.quantity).toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '৳ ${order.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: primaryBlue),
                          ),
                        ],
                      ),
                      if (order.address.isNotEmpty) ...[
                        const Divider(height: 20),
                        const Text('Delivery Details',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(order.recipientName, style: const TextStyle(fontSize: 13)),
                        Text(order.phone, style: const TextStyle(fontSize: 13)),
                        Text(order.address, style: const TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}