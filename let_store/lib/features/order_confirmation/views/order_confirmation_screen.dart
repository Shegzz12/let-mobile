// import '../../../screens/main_screen.dart';
// import 'package:let_store/screens/cart_screen.dart';
import 'package:let_store/screens/main_screen.dart';

import '/features/my_orders/view/screens/my_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// import '../../../screens/main_screen.dart';
import '../../../utils/app_textstyles.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  final String bearerToken;

  const OrderConfirmationScreen({
    required this.bearerToken,
    super.key,
    required this.orderNumber,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/order_success.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              SizedBox(height: 32),
              Text(
                'Order Confirmed!',
                textAlign: TextAlign.center,
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your order #$orderNumber has been successfully placed.',
                textAlign: TextAlign.center,
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => MyOrderScreen(bearerToken: bearerToken));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Track Order',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  //
                  Get.offAll(
                    () => MainScreen(
                      bearerToken: bearerToken,
                      avatar: '',
                      name: '',
                    ),
                  );
                },
                child: Text(
                  'Continue Shopping',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
