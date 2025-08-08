import '../features/edit_profile/views/edit_profile_screen.dart';
import '../features/help_center/views/help_center_screen.dart';
import '../features/my_orders/view/screens/my_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_textstyles.dart';
import 'settings_screen.dart';
import '../features/shipping_address/views/shipping_address_screen.dart';
import 'signin_screen.dart';

class AccountScreen extends StatelessWidget {
  final String bearerToken;
  const AccountScreen({super.key, required this.bearerToken});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSideContainers =
        screenWidth >= 600; // Show on tablet and desktop

    // final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Account',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsScreen()),
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
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
                  width: 200, // Fixed width for the side container
                  color: Colors.grey[200], // Example color, adjust as needed
                  // You can add content here if desired, e.g., a secondary navigation
                ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileSection(context),
                      SizedBox(height: 24),
                      _buildMenuSection(context),
                    ],
                  ),
                ),
              ),
              if (showSideContainers)
                Container(
                  height: double.infinity,
                  width: 200, // Fixed width for the side container
                  color: Colors.grey[200], // Example color, adjust as needed
                  // You can add content here if desired
                ),
            ],
          ),
        ),
      ),
      // Right side container (only visible on tablet/desktop)
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/segun.jpg'),
          ),
          SizedBox(height: 16),
          Text(
            'Samson Adeniyi',
            style: AppTextStyle.withColor(
              AppTextStyle.h2,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'adeniyisamson590@gmail.com',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Get.to(() => EditProfileScreen()),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: BorderSide(color: isDark ? Colors.white70 : Colors.black12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Edit Profile',
              style: AppTextStyle.withColor(
                AppTextStyle.buttonMedium,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuItems = [
      {'icon': Icons.shopping_bag_outlined, 'title': 'My Orders'},
      {'icon': Icons.location_on_outlined, 'title': 'Shipping Address'},
      {'icon': Icons.help_outline, 'title': 'Help Center'},
      {'icon': Icons.logout_outlined, 'title': 'Logout'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                item['title'] as String,
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onTap: () {
                if (item['title'] == 'Logout') {
                  _showLogoutDialog(context);
                } else if (item['title'] == 'My Orders') {
                  Get.to(() => MyOrderScreen(bearerToken: bearerToken));
                } else if (item['title'] == 'Shipping Address') {
                  Get.to(() => ShippingAddressScreen());
                } else if (item['title'] == 'Help Center') {
                  Get.to(() => HelpCenterScreen());
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Are you sure you want to logout?',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final AuthController authController =
                          Get.find<AuthController>();
                      authController.logout();
                      Get.offAll(() => SigninScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
