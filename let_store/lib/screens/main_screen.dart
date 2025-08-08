import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../models/product.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
// import 'shopping_screen.dart';
import '../features/widgets/custom_bottom_nav_bar.dart';
import 'wish_list_screen.dart';

class MainScreen extends StatelessWidget {
  final String? avatar;
  final String bearerToken;
  // final String? id;
  // final String? email;
  final String? name;
  const MainScreen({
    super.key,
    required this.bearerToken,
    required this.avatar,
    // required this.id,
    // required this.email,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put(
      NavigationController(),
    );
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Obx(
            () => IndexedStack(
              key: ValueKey(navigationController.currentIndex.value),
              index: navigationController.currentIndex.value,
              children: [
                HomeScreen(
                  bearerToken: bearerToken,
                  avatar: avatar,
                  // id: id,
                  // email: email,
                  name: name,
                ),
                WishListScreen(bearerToken: bearerToken),
                CartScreen(bearerToken: bearerToken),
                AccountScreen(bearerToken: bearerToken),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}
