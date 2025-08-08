import '../models/cart_item.dart';
import '/utils/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/checkout/screen/checkout_screen.dart';

// Assuming CartItem and Product models are defined elsewhere and correctly structured.
// The Product model provided in the previous turn is sufficient.
// Ensure your CartItem model has a Product product and int quantity.

class CartScreen extends StatefulWidget {
  final String bearerToken;
  const CartScreen({super.key, required this.bearerToken});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching
    });
    try {
      final items = await fetchCartItems(widget.bearerToken);
      if (mounted) {
        setState(() {
          cartItems = items;
          _isLoading = false; // Set loading to false after data is fetched
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading to false on error
        });
        Get.snackbar('Error', 'Failed to load cart items: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSideContainers =
        screenWidth >= 600; // Show on tablet and desktop
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'My Cart',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Center(
        // Center the main content
        child: ConstrainedBox(
          // Constrain the max width of the content
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // Max width for the entire row/column
          child: Row(
            children: [
              if (showSideContainers)
                Container(
                  height: double.infinity,
                  width: 50, // Fixed width for the side container
                  color: Colors.grey[200], // Example color, adjust as needed
                  // You can add content here if desired
                ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            ) // Show loading indicator
                          : cartItems.isEmpty
                          ? Center(
                              child: Text(
                                'Your cart is empty.',
                                style: AppTextStyle.withColor(
                                  AppTextStyle.bodyLarge,
                                  isDark
                                      ? Colors.grey[400]!
                                      : Colors.grey[600]!,
                                ),
                              ),
                            )
                          : CustomScrollView(
                              // Use CustomScrollView for responsive slivers
                              slivers: [
                                _buildCartItemsSliver(
                                  context,
                                ), // Responsive cart items
                              ],
                            ),
                    ),
                    _buildCartSummary(
                      context,
                    ), // Cart summary remains at the bottom
                  ],
                ),
              ),
              if (showSideContainers)
                Container(
                  height: double.infinity,
                  width: 50, // Fixed width for the side container
                  color: Colors.grey[200], // Example color, adjust as needed
                  // You can add content here if desired
                ),
            ],
          ),
        ),
      ),
    );
  }

  // New helper method to return the correct sliver based on screen width
  Widget _buildCartItemsSliver(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;
    bool isGridView;

    // Define breakpoints for responsiveness
    if (screenWidth >= 1100) {
      crossAxisCount = 4;
      childAspectRatio = 0.73; // Adjusted for cart item content
      isGridView = true;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.79; // Adjusted for cart item content
      isGridView = true;
    } else if (screenWidth >= 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.70; // Adjusted for cart item content
      isGridView = true;
    } else {
      crossAxisCount = 1; // Effectively a list
      childAspectRatio = 3.5; // Keep original aspect ratio for list items
      isGridView = false;
    }

    if (!isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCartItem(
              context,
              cartItems[index],
              isGridView: false, // Explicitly false for list view
              key: ValueKey(
                cartItems[index].product.id,
              ), // Use product ID as key
            ),
            childCount: cartItems.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCartItem(
              context,
              cartItems[index],
              isGridView: true, // Explicitly true for grid view
              key: ValueKey(
                cartItems[index].product.id,
              ), // Use product ID as key
            ),
            childCount: cartItems.length,
          ),
        ),
      );
    }
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem cartitem, {
    Key? key,
    required bool isGridView,
  }) {
    final imageUrl = cartitem.product.imageUrl.isNotEmpty
        ? cartitem.product.imageUrl
        : 'https://via.placeholder.com/150?text=No+Image';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: key, // Apply the key here
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isGridView
          ? Column(
              // Grid View Layout
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    cartitem.product.imageUrl.isNotEmpty
                        ? cartitem.product.imageUrl
                        : 'https://via.placeholder.com/150?text=No+Image', // Fallback placeholder
                    height: 150, // Fixed height for grid image
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 80),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartitem.product.name,
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyLarge,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Qty: ${cartitem.quantity}',
                        style: AppTextStyle.withColor(
                          AppTextStyle
                              .bodyMedium, // Changed to bodyMedium for quantity
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${(cartitem.product.price * cartitem.quantity).toStringAsFixed(2)}', // Show total for item
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(), // Pushes buttons to the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (cartitem.quantity > 1) {
                                  final success = await updateCartQuantity(
                                    productId: cartitem.product.id,
                                    quantity: cartitem.quantity - 1,
                                    bearerToken: widget.bearerToken,
                                  );
                                  if (success) {
                                    setState(() {
                                      cartitem.quantity--;
                                    });
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.remove,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              tooltip: 'Decrease quantity',
                            ),
                            Text(
                              '${cartitem.quantity}',
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodyMedium,
                                Theme.of(context).textTheme.bodyLarge!.color!,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final success = await updateCartQuantity(
                                  productId: cartitem.product.id,
                                  quantity: cartitem.quantity + 1,
                                  bearerToken: widget.bearerToken,
                                );
                                if (success) {
                                  setState(() {
                                    cartitem.quantity++;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.add,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              tooltip: 'Increase quantity',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, cartitem),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                        tooltip: 'Remove item',
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              // List View Layout (original style)
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),

                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : Image.asset(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cartitem.product.name,
                                style: AppTextStyle.withColor(
                                  AppTextStyle.bodyLarge,
                                  Theme.of(context).textTheme.bodyLarge!.color!,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showDeleteConfirmationDialog(
                                context,
                                cartitem,
                              ),
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                              ),
                              tooltip: 'Remove item',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Qty: ${cartitem.quantity}',
                          style: AppTextStyle.withColor(
                            AppTextStyle
                                .bodyMedium, // Changed to bodyMedium for quantity
                            isDark ? Colors.grey[400]! : Colors.grey[600]!,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${(cartitem.product.price * cartitem.quantity)}', // Show total for item
                              style: AppTextStyle.withColor(
                                AppTextStyle.h3,
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      if (cartitem.quantity > 1) {
                                        try {
                                          final success =
                                              await updateCartQuantity(
                                                productId: cartitem.product.id,
                                                quantity: cartitem.quantity - 1,
                                                bearerToken: widget.bearerToken,
                                              );
                                          if (success) {
                                            setState(() {
                                              cartitem.quantity--;
                                            });
                                          }
                                        } catch (e) {
                                          print(
                                            "Error decreasing quantity: $e",
                                          );
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    tooltip: 'Decrease quantity',
                                  ),
                                  Text(
                                    '${cartitem.quantity}',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyMedium,
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final success = await updateCartQuantity(
                                        productId: cartitem.product.id,
                                        quantity: cartitem.quantity + 1,
                                        bearerToken: widget.bearerToken,
                                      );
                                      if (success) {
                                        setState(() {
                                          cartitem.quantity++;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    tooltip: 'Increase quantity',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, CartItem cartitem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 32,
              ), // Delete Icon
            ),
            const SizedBox(height: 24),
            Text(
              'Remove Item',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to remove this item from your cart?',
              textAlign: TextAlign.center,
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await removeCartItem(
                        widget.bearerToken,
                        cartitem.product.id,
                      );
                      Get.back(); // Close the dialog after deletion
                      setState(() {
                        cartItems.removeWhere(
                          (item) => item.product.id == cartitem.product.id,
                        );
                      });
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product removed successfully'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Remove',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // barrierColor: Colors.black54,
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    String total = _calculateTotal().toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ), // box deco
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${cartItems.length}) items)',
                style: AppTextStyle.withColor(
                  AppTextStyle.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              Text(
                '\$$total',
                style: AppTextStyle.withColor(
                  AppTextStyle.h3,
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // --- MODIFIED LOGIC HERE ---
                final userData = await validateToken(
                  widget.bearerToken,
                ); // Now returns Map<String, dynamic>?
                if (userData != null) {
                  final shippingDetails = userData['shipping_address'];

                  // Add a print statement to confirm shippingDetails
                  // print('Shipping Details: $shippingDetails');

                  if (shippingDetails == null) {
                    Get.snackbar(
                      "Error",
                      "Shipping address not found for this user. Please update your profile.",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    // Optionally navigate to a screen to add/edit shipping address
                    // Get.to(() => AddShippingAddressScreen(bearerToken: widget.bearerToken));
                  } else {
                    Get.to(
                      () => CheckoutScreen(
                        cartItems: cartItems,
                        total: total,
                        bearerToken: widget.bearerToken,
                        user: userData, // Pass the user data directly
                        shippingDetails: shippingDetails,
                      ),
                    );
                  }
                } else {
                  Get.snackbar(
                    "Error",
                    "Invalid or expired token. Please log in again.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  // Optionally navigate to login screen
                  // Get.offAll(() => LoginScreen());
                }
                // --- END MODIFIED LOGIC ---
              },
              // navigate to checkout screen
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<CartItem>> fetchCartItems(String bearerToken) async {
    final url = Uri.parse(
      'https://cors-anywhere.herokuapp.com/https://let-commerce.onrender.com/api/cart/get-cart',
    );
    // print('Sending get request now');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // 'Origin': 'http://localhost:58792',
        },
      );
      // print("Response status: ${response.statusCode}");
      print("✅ Cart items: Response body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> items = jsonResponse['items'];
        final List<CartItem> cartItems = items
            .map((item) => CartItem.fromJson(item, widget.bearerToken))
            .toList();
        return cartItems;
      } else {
        print("❌ Failed to fetch cart items. Status: ${response.statusCode}");
        print(response.body);
        return [];
      }
    } catch (e, stackTrace) {
      print("⚠️ Error fetching cart items: $e");
      print(stackTrace);
      return [];
    }
  }

  Future<void> removeCartItem(String bearerToken, String productId) async {
    final url = Uri.parse('https://let-commerce.onrender.com/api/cart/remove');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode({'product_id': productId}),
      );
      if (response.statusCode == 200) {
        print('✅ Product removed successfully');
      } else {
        print('❌ Failed to remove product. Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error during delete request: $e');
    }
  }

  double _calculateTotal() {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  Future<bool> updateCartQuantity({
    required String productId,
    required int quantity,
    required String bearerToken,
  }) async {
    final url = Uri.parse(
      'https://let-commerce.onrender.com/api/cart/update-quantity',
    );
    print('updating cart quantity');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update cart: ${response.body}');
      return false;
    }
  }

  // --- MODIFIED VALIDATE TOKEN FUNCTION ---
  Future<Map<String, dynamic>?> validateToken(String token) async {
    final url = Uri.parse(
      'https://let-commerce.onrender.com/api/auth/token-validate',
    );
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // Return the 'user' map from the response
        if (jsonResponse.containsKey('user') && jsonResponse['user'] is Map) {
          return jsonResponse['user'];
        } else {
          print('Error: User data not found in token validation response.');
          return null;
        }
      } else {
        print('Token validation failed. Status: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error validating token: $e');
      print(stackTrace);
      return null;
    }
  }

  // --- END MODIFIED VALIDATE TOKEN FUNCTION ---
}
