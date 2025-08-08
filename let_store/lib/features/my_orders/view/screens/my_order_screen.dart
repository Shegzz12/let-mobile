import '../../../../models/product.dart'; // Assuming this path is correct for your Product model
import '../../../../screens/product_details_screen.dart'; // Assuming this path is correct
import '../../repository/order_repository.dart';
// import '../widgets/order_card.dart'; // NO LONGER NEEDED
import '../widgets/order_product_item_card.dart'; // Import the NEW OrderProductItemCard
import '/utils/app_textstyles.dart';
import '../../model/order.dart'; // Import your MODIFIED Order model
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../models/api_order.dart'; // Still needed for OrderStatus enum and patching via OrderService
// import '../../services/order_service.dart'; // Still needed for patching

class MyOrderScreen extends StatefulWidget {
  final String bearerToken;
  const MyOrderScreen({super.key, required this.bearerToken});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  late Future<List<Order>> futureOrders;
  List<Order> _currentOrders = [];

  bool? get isLoading => null;

  @override
  void initState() {
    super.initState();
    _fetchAndSetOrders();
  }

  Future<void> _fetchAndSetOrders() async {
    setState(() {
      futureOrders = OrderRepository().fetchOrders(widget.bearerToken);
    });
    try {
      _currentOrders = await futureOrders;
      setState(() {});
    } catch (e) {
      print('Error fetching orders: $e');
      _showSnackBar('Error fetching orders: ${e.toString()}', Colors.red);
    }
  }

  // Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
  //   try {
  //     final updatedApiOrder = await OrderService.updateOrderStatus(
  //       orderId,
  //       newStatus,
  //       widget.bearerToken,
  //     );

  //     setState(() {
  //       final index = _currentOrders.indexWhere(
  //         (order) => order.id == updatedApiOrder.id,
  //       );
  //       if (index != -1) {
  //         _currentOrders[index].status = updatedApiOrder.status;
  //       }
  //       _showSnackBar(
  //         'Order ${updatedApiOrder.id} status updated to ${newStatus.toShortString().toUpperCase()}',
  //         Colors.green,
  //       );
  //     });
  //   } catch (e) {
  //     print('Error updating order status: $e');
  //     _showSnackBar(
  //       'Failed to update order status: ${e.toString()}',
  //       Colors.red,
  //     );
  //   }
  // }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // Helper to get product image URL (assuming a placeholder or lookup from Product model)
  String _getProductImageUrl(String productId) {
    try {
      final product = hardcodedProducts.firstWhere((p) => p.id == productId);
      return product.imageUrl;
    } catch (e) {
      return 'assets/images/segun.jpg'; // Default placeholder if product not found
    }
  }

  // Helper to build status chip (moved from OrderCard)
  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color getStatusColor() {
      switch (status) {
        case OrderStatus.active:
          return Colors.blue;
        case OrderStatus.shipped:
          return Colors.orange; // Added color for shipped
        case OrderStatus.delivered:
          return Colors.green;
        case OrderStatus.cancelled:
          return Colors.red;
        case OrderStatus.pending:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status
            .toShortString()
            .capitalizeFirst!, // Use capitalizeFirst from GetX
        style: AppTextStyle.withColor(AppTextStyle.bodySmall, getStatusColor()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSideContainers = screenWidth >= 600;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            'My Orders',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.white : Colors.black,
            ),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: isDark
                ? Colors.grey[400]!
                : Colors.grey[600]!,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Active'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
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
                  child: TabBarView(
                    children: [
                      _buildOrderList(context, OrderStatus.pending),
                      _buildOrderList(context, OrderStatus.active),
                      _buildOrderList(context, OrderStatus.shipped),
                      _buildOrderList(context, OrderStatus.delivered),
                      _buildOrderList(context, OrderStatus.cancelled),
                    ],
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
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, OrderStatus status) {
    final filteredOrders = _currentOrders
        .where((order) => order.status == status)
        .toList();

    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // } else if (filteredOrders.isEmpty) {
    //   return Center(child: Text('No ${status.toShortString()} orders found.'));
    // }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ExpansionTile(
            title: Text(
              'Order ID: ${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User: ${order.user.email}'),
                _buildStatusChip(
                  context,
                  order.status,
                ), // Use the new status chip helper
                Text('Date: ${order.createdAt}'),
                Text('Total: ₦${order.totalAmount}'),
              ],
            ),
            // trailing: PopupMenuButton<OrderStatus>(
            //   onSelected: (OrderStatus newStatus) {
            //     _updateOrderStatus(order.id, newStatus);
            //   },
            //   itemBuilder: (BuildContext context) {
            //     return OrderStatus.values.map((statusOption) {
            //       return PopupMenuItem<OrderStatus>(
            //         value: statusOption,
            //         child: Text(statusOption.toShortString().toUpperCase()),
            //       );
            //     }).toList();
            //   },
            //   icon: const Icon(Icons.edit),
            //   tooltip: 'Change Status',
            // ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (order.items.isEmpty)
                      const Text('No items in this order.')
                    else
                      ...order.items
                          .map(
                            (item) => OrderProductItemCard(
                              // Use the new widget here
                              item: item,
                              productImageUrl: _getProductImageUrl(
                                item.productId,
                              ),
                              onViewDetails: (productId) {
                                final product = hardcodedProducts.firstWhere(
                                  (p) => p.id == productId,
                                  orElse: () => Product(
                                    stock: item.quantity,
                                    bearerToken: widget.bearerToken,
                                    id: item.productId,
                                    category: '',
                                    description: '',
                                    imageUrl: _getProductImageUrl(
                                      item.productId,
                                    ),
                                    name: item.productName,
                                    price: 0,
                                    oldPrice: 0,
                                    isFavorite: false,
                                  ),
                                );
                                Get.to(
                                  () => ProductDetailsScreen(
                                    product: product,
                                    bearerToken: widget.bearerToken,
                                  ),
                                );
                              },
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
    );
  }
}
