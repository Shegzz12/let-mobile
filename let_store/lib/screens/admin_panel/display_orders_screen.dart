import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_app/models/order.dart'; // NO LONGER NEEDED FOR DISPLAY IN THIS SCREEN
// import 'package:flutter_app/models/api_order.dart'; // The new ApiOrder model
// import 'package:flutter_app/services/order_service.dart';

import 'api_order.dart';
import 'update_order_status.dart'; // Import your OrderService

class DisplayOrdersScreen extends StatefulWidget {
  final String bearerToken;
  const DisplayOrdersScreen({super.key, required this.bearerToken});

  @override
  State<DisplayOrdersScreen> createState() => _DisplayOrdersScreenState();
}

class _DisplayOrdersScreenState extends State<DisplayOrdersScreen> {
  List<ApiOrder> _orders =
      []; // Now directly stores ApiOrder objects for display
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminUserOrders();
  }

  Future<void> _fetchAdminUserOrders() async {
    // Note: Using .onrender.com for fetching as per your original code
    const url = 'https://let-commerce.onrender.com/api/orders/admin/all';
    print('fetching the orders now');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.bearerToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Orders gotten: $data');
        setState(() {
          _orders = data.map((json) => ApiOrder.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch orders. Status code: ${response.statusCode}');
        print(response.body);
        setState(() => isLoading = false);
        _showSnackBar(
          'Failed to fetch orders: ${response.statusCode}',
          Colors.red,
        );
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => isLoading = false);
      _showSnackBar('Error fetching orders: $e', Colors.red);
    }
  }

  Future<void> _updateOrderStatus(
    String apiOrderId,
    OrderStatus newStatus,
  ) async {
    setState(() {
      // You could add a specific loading indicator for the order being updated here
    });

    try {
      final updatedApiOrder = await OrderService.updateOrderStatus(
        apiOrderId,
        newStatus,
        widget.bearerToken, // Pass the bearer token from the widget
      );

      setState(() {
        // Find the updated ApiOrder in the local list and replace it
        final index = _orders.indexWhere(
          (order) => order.id == updatedApiOrder.id,
        );
        // if (index != -1) {
        _orders[index] = updatedApiOrder;
        // Replace with the fully updated ApiOrder object
        // }
        _showSnackBar(
          'Order ${updatedApiOrder.id} status updated to ${newStatus.toShortString().toUpperCase()}',
          Colors.green,
        );
      });
    } catch (e) {
      print('Error updating order status: $e');
      _showSnackBar(
        'Failed to update order status: ${e.toString()}',
        Colors.red,
      );
    } finally {
      setState(() {
        // Hide any specific loading indicators if they were used
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSideContainers =
        screenWidth >= 600; // Show on tablet and desktop

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Orders')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              if (showSideContainers)
                Container(
                  height: double.infinity,
                  width: 200,
                  color: Colors.grey[200],
                ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _orders.isEmpty
                    ? const Center(child: Text('No orders found.'))
                    : ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final apiOrder =
                              _orders[index]; // Now directly an ApiOrder object
                          final status = apiOrder.status
                              .toShortString()
                              .toUpperCase();

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: ExpansionTile(
                              // Use ExpansionTile for expand/collapse
                              title: Text(
                                'Order ID: ${apiOrder.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('User: ${apiOrder.user.email}'),
                                  Text('Status: $status'),
                                  Text('Date: ${apiOrder.createdAt}'),
                                  Text('Total: ₦${apiOrder.totalAmount}'),
                                ],
                              ),
                              trailing: PopupMenuButton<OrderStatus>(
                                onSelected: (OrderStatus newStatus) {
                                  _updateOrderStatus(apiOrder.id, newStatus);
                                },
                                itemBuilder: (BuildContext context) {
                                  return OrderStatus.values.map((statusOption) {
                                    return PopupMenuItem<OrderStatus>(
                                      value: statusOption,
                                      child: Text(
                                        statusOption
                                            .toShortString()
                                            .toUpperCase(),
                                      ),
                                    );
                                  }).toList();
                                },
                                icon: const Icon(Icons.edit),
                                tooltip: 'Change Status',
                              ),
                              children: [
                                // Content shown when expanded
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Products:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (apiOrder.items.isEmpty)
                                        const Text('No items in this order.')
                                      else
                                        ...apiOrder.items
                                            .map(
                                              (item) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 4.0,
                                                ),
                                                child: Text(
                                                  '- ${item.productName} (x${item.quantity})',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                            // ignore: unnecessary_to_list_in_spreads
                                            .toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (showSideContainers)
                Container(
                  height: double.infinity,
                  width: 200,
                  color: Colors.grey[200],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
