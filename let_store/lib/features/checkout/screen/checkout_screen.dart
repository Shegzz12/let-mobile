import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/cart_item.dart';
import '../../../utils/app_textstyles.dart';
import '../../order_confirmation/views/order_confirmation_screen.dart';
import '../widget/address_card.dart';
import '../widget/checkout_bottom_bar.dart';
import '../widget/order_summary_card.dart';
import '../widget/payment_method_card.dart';

class CheckoutScreen extends StatelessWidget {
  final String total;
  final List<CartItem> cartItems;
  final String bearerToken;
  // ignore: prefer_typing_uninitialized_variables
  final user;
  // ignore: prefer_typing_uninitialized_variables
  final shippingDetails;

  const CheckoutScreen({
    required this.shippingDetails,
    required this.user,
    required this.cartItems,
    super.key,
    required this.total,
    required this.bearerToken,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overallTotal = calculateTotal(double.parse(total));

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
          'Checkout',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Shipping Address'),
            const SizedBox(height: 16),
            AddressCard(shippingDetails: shippingDetails),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Payment Method'),
            const SizedBox(height: 16),
            PaymentMethodCard(),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Order Summary'),
            const SizedBox(height: 16),
            // --- NEW SECTION: Display Cart Items ---
            if (cartItems.isNotEmpty) ...[
              Text(
                'Items in your cart:',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              // Use a Column to display each cart item
              Column(
                children: cartItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item.product.imageUrl.isNotEmpty
                                ? item.product.imageUrl
                                : 'https://via.placeholder.com/50?text=No+Image',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 30),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: AppTextStyle.withColor(
                                  AppTextStyle.bodyMedium,
                                  Theme.of(context).textTheme.bodyLarge!.color!,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Qty: ${item.quantity} x \$${item.product.price.toStringAsFixed(2)}',
                                style: AppTextStyle.withColor(
                                  AppTextStyle.bodySmall,
                                  isDark
                                      ? Colors.grey[400]!
                                      : Colors.grey[600]!,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16), // Space before the summary card
            ],
            // --- END NEW SECTION ---
            OrderSummaryCard(total: double.parse(total)),
          ],
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        totalAmount: overallTotal,
        onPlaceOrder: () async {
          // generate a random order number (this would come from backend)
          final success = await placeOrder(
            bearerToken: bearerToken,
            cartItems: cartItems,
            shipping: calculateShipping(),
            tax: calculateTax(double.parse(total)),
            shippingAddress: shippingDetails,
            paymentMethod: 'bank transfer',
          );
          if (success) {
            // Navigate or show confirmation
            Get.to(
              () => OrderConfirmationScreen(
                bearerToken: bearerToken,
                orderNumber: 'ORD${DateTime.now().millisecondsSinceEpoch}',
                totalAmount:
                    overallTotal, // subtotal + shipping + calculateTax(double.parse(total)),
              ),
            );
          } else {
            // Show failure
            Get.snackbar(
              "Order Failed",
              "There was an issue placing your order. Please try again.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
            );
          }
          // Text('Place Order (\$$overallTotal)'); // This line was misplaced
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyle.withColor(
        AppTextStyle.h3,
        Theme.of(context).textTheme.bodyLarge!.color!,
      ),
    );
  }

  Future<bool> placeOrder({
    required String bearerToken,
    required List<CartItem> cartItems,
    required double shipping,
    required double tax,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
  }) async {
    final url = Uri.parse('https://let-commerce.onrender.com/api/orders/place');
    final items = cartItems
        .map(
          (ci) => {
            'product_id': ci.product.id,
            'quantity': ci.quantity,
            'unit_price': ci.product.price,
            'total': ci.quantity * ci.product.price,
          },
        )
        .toList();

    final subtotal = cartItems.fold<double>(
      0,
      (sum, ci) => sum + (ci.quantity * ci.product.price),
    );

    final body = {
      'items': items,
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': subtotal + shipping + tax,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
    };

    print('placing orders: $body'); // For debugging the payload

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Order placed successfully: ${response.body}');
        return true;
      } else {
        print(
          '❌ Failed to place order: ${response.statusCode}\n${response.body}',
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('⚠️ Error during place order request: $e');
      print(stackTrace);
      return false;
    }
  }

  // Helper functions (assuming these are defined elsewhere or within this file)
  double calculateShipping() {
    // Implement your shipping calculation logic here
    return 5.00; // Example fixed shipping cost
  }

  double calculateTax(double subtotal) {
    // Implement your tax calculation logic here
    return subtotal * 0.08; // Example 8% tax
  }

  double calculateTotal(double subtotal) {
    return subtotal + calculateShipping() + calculateTax(subtotal);
  }
}
