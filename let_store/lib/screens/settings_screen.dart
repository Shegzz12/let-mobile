import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../features/privacy_policy/views/privacy_policy_screen.dart';
import '../features/terms_of_service/views/terms_of_service_screen.dart';
import '../utils/app_textstyles.dart';

// These should ideally be managed by a state management solution (like GetX controller)
// or passed down as parameters if they are user-specific settings.
// For demonstration, keeping them as global for now, but be aware of best practices.
bool _pushNotifications = true;
bool _emailNotifications = false;

// Define a class to represent a settings category for better organization
class SettingsCategory {
  final String title;
  final IconData icon;
  final List<Widget> Function(
    BuildContext context,
    Function(VoidCallback fn) setStateCallback,
  )
  buildContent;

  SettingsCategory({
    required this.title,
    required this.icon,
    required this.buildContent,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State to manage the currently selected category for desktop view
  int _selectedIndex = 0;

  late List<SettingsCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _buildCategories();
  }

  // Helper to build the list of categories dynamically
  List<SettingsCategory> _buildCategories() {
    return [
      SettingsCategory(
        title: 'Appearance',
        icon: Icons.palette_outlined,
        buildContent: (context, setStateCallback) => [
          _buildThemeToggle(context),
        ],
      ),
      SettingsCategory(
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        buildContent: (context, setStateCallback) => [
          _buildSwitchTile(
            context,
            'Push Notifications',
            'Receive push notifications about orders and promotions',
            _pushNotifications,
            (val) => setStateCallback(() => _pushNotifications = val),
          ),
          _buildSwitchTile(
            context,
            'Email Notifications',
            'Receive email updates about your orders',
            _emailNotifications,
            (val) => setStateCallback(() => _emailNotifications = val),
          ),
        ],
      ),
      SettingsCategory(
        title: 'Privacy',
        icon: Icons.privacy_tip_outlined,
        buildContent: (context, setStateCallback) => [
          _buildNavigationTile(
            context,
            'Privacy Policy',
            'View our privacy policy',
            Icons.privacy_tip_outlined,
            onTap: () => Get.to(() => PrivacyPolicyScreen()),
          ),
          _buildNavigationTile(
            context,
            'Terms of Service',
            'Read our terms of service',
            Icons.description_outlined,
            onTap: () => Get.to(() => TermsOfServiceScreen()),
          ),
        ],
      ),
      SettingsCategory(
        title: 'About',
        icon: Icons.info_outline,
        buildContent: (context, setStateCallback) => [
          _buildNavigationTile(
            context,
            'App Version',
            '1.0.0',
            Icons.info_outline,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 600; // Define desktop threshold

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Settings',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200, // Max width for the entire settings content
          ),
          child: isDesktop
              ? _buildDesktopLayout(context, isDark)
              : _buildMobileLayout(context, isDark),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Left Pane: Navigation Rail for categories
        Container(
          width: 250, // Adjust width as needed for navigation
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ListTile(
                leading: Icon(
                  category.icon,
                  color: _selectedIndex == index
                      ? Theme.of(context).primaryColor
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                title: Text(
                  category.title,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    _selectedIndex == index
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedTileColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
              );
            },
          ),
        ),
        // Right Pane: Content of the selected category
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Padding for the content area
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the title of the selected category
                Text(
                  _categories[_selectedIndex].title,
                  style: AppTextStyle.withColor(
                    AppTextStyle.h2,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 16),
                // Build content using the category's buildContent function
                ..._categories[_selectedIndex].buildContent(context, setState),
                const SizedBox(height: 24), // Add some bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Iterate through all categories and build their sections
          ..._categories.expand((category) {
            return [
              _buildSection(
                context,
                category.title,
                category.buildContent(context, setState),
              ),
            ];
            // ignore: unnecessary_to_list_in_spreads
          }).toList(),
          const SizedBox(height: 24), // Add some bottom padding
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            title,
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<ThemeController>(
      builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
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
        child: ListTile(
          leading: Icon(
            controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            'Dark Mode',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isDarkMode,
            onChanged: (value) => controller.toggleTheme(),
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onChanged(!value), // Allow tapping the tile to toggle
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
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
        child: ListTile(
          title: Text(
            title,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
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
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(
            title,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyle.withColor(
              AppTextStyle.bodySmall,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
