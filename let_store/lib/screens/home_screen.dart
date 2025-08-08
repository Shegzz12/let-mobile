// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:let_store/screens/cart_screen.dart';
import '../controllers/theme_controller.dart';
import '../features/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/notifications/view/notifications_screen.dart';
// import '../features/widgets/category_chips.dart';
import '../features/widgets/product_grid.dart';
import '../features/widgets/sale_banner.dart';
import '../models/product.dart'; // fetchAndMergeProducts

class HomeScreen extends StatefulWidget {
  final String? avatar;
  final String bearerToken;
  final String? name;
  const HomeScreen({
    super.key,
    required this.bearerToken,
    required this.avatar,
    required this.name,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> backendProducts = [];
  List<Product> allProducts = [];
  List<Product> _searchResults = [];
  bool _isSearchSubmitted =
      false; // State to track if search results should be shown
  bool _isSearchBarFullyExpanded = false; // Controls header layout

  void _handleSearch(List<Product> results) {
    setState(() {
      _searchResults = results;
      _isSearchSubmitted =
          true; // A search has been submitted and results are here
    });
  }

  void _onSearchStart() {
    setState(() {
      _isSearchSubmitted = true; // Indicate that a search is in progress
    });
  }

  void _onSearchClosed() {
    setState(() {
      _searchResults = []; // Clear search results
      _isSearchSubmitted = false; // Reset search state
      _isSearchBarFullyExpanded = false; // Ensure header returns to normal
    });
  }

  // Method to handle search bar expansion state from CustomSearchBar
  void _handleSearchBarExpansion(bool expanded) {
    setState(() {
      _isSearchBarFullyExpanded = expanded;
      if (!expanded) {
        _isSearchSubmitted = false;
        _searchResults = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Initial load of all products
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dname = widget.name?.split(' ').first ?? '';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Responsive Header (constrained on desktop to avoid stretched icons)
            _buildResponsiveHeader(
              context,
              isDark,
              dname,
              isTablet,
              isDesktop,
              screenWidth,
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                child: _isSearchSubmitted
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32 : (isTablet ? 24 : 18),
                        ),
                        child: _searchResults.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text(
                                    'No products found for your search.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : ProductGrid(
                                allProducts: _searchResults,
                                bearerToken: widget.bearerToken,
                              ),
                      )
                    : _buildDefaultContent(
                        context,
                        isTablet,
                        isDesktop,
                        isDesktop ? 32.0 : (isTablet ? 24.0 : 18.0),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader(
    BuildContext context,
    bool isDark,
    String dname,
    bool isTablet,
    bool isDesktop,
    double screenWidth,
  ) {
    // Tighter desktop sizes (prevents stretched feel)
    final double symbolSize = isDesktop ? 80 : (isTablet ? 72 : 60);
    final double logoWidth = isDesktop ? 150 : (isTablet ? 140 : 115);
    final double logoHeight = isDesktop ? 36 : (isTablet ? 34 : 30);

    final double horizontalPad = isDesktop ? 24 : (isTablet ? 20 : 16);
    final double verticalPad = isDesktop ? 16 : (isTablet ? 16 : 14);

    final Widget letSymbolLogo = Image.asset(
      'assets/images/let_symbol.png',
      width: symbolSize,
      height: symbolSize,
      fit: BoxFit.contain,
    );

    final Widget letTextLogo = SizedBox(
      width: logoWidth,
      height: logoHeight,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/let_logo.png'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // keep header compact on desktop
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Always show symbol on far left
              letSymbolLogo,

              if (_isSearchBarFullyExpanded) ...[
                const SizedBox(width: 8),
                // Search bar takes the middle space when expanded
                Expanded(
                  child: CustomSearchBar(
                    onSearchResults: _handleSearch,
                    onSearchStart: _onSearchStart,
                    onSearchClosed: _onSearchClosed,
                    onExpandedChanged: _handleSearchBarExpansion,
                    bearerToken: widget.bearerToken,
                  ),
                ),
                const SizedBox(width: 12),
                // Logo on the right when expanded
                letTextLogo,
              ] else ...[
                const SizedBox(width: 8),
                // When collapsed: logo near the symbol
                letTextLogo,
                const Spacer(),
                // Action icons remain on the right and compact
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildActionButton(
                      Icons.search,
                      () => _handleSearchBarExpansion(true),
                      isDark,
                      screenWidth,
                    ),
                    SizedBox(width: isDesktop ? 12 : (isTablet ? 10 : 0)),
                    _buildActionButton(
                      Icons.notifications_outlined,
                      () => Get.to(() => NotificationsScreen()),
                      isDark,
                      screenWidth,
                    ),
                    SizedBox(width: isDesktop ? 12 : (isTablet ? 10 : 0)),
                    GetBuilder<ThemeController>(
                      builder: (controller) => _buildActionButton(
                        controller.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        () => controller.toggleTheme(),
                        isDark,
                        screenWidth,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Compact action button to avoid stretched look on desktop
  Widget _buildActionButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDark,
    double screenWidth,
  ) {
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768;
    final iconSize = isDesktop ? 22.0 : (isTablet ? 21.0 : 20.0);

    return IconButton(
      icon: Icon(
        icon,
        color: isDark ? Colors.grey[300]! : Colors.grey[800]!,
        size: iconSize,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      splashRadius: 22,
    );
  }

  Widget _buildDefaultContent(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    double horizontalPadding,
  ) {
    // Keep mobile constant; reduce top banner height on desktop
    final double bannerHeight = isDesktop ? 150 : (isTablet ? 170 : 180);

    return Column(
      children: [
        SizedBox(height: isTablet ? 4 : 2),

        // Shorter on desktop, unchanged on mobile
        SaleBanner(bannerHeight: bannerHeight),

        SizedBox(height: isTablet ? 16 : 8),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isTablet ? 12 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Products',
                style: TextStyle(
                  fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: fetchAllProducts, // Also clears search state
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Constrain grid on desktop to avoid edge-to-edge stretch
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ProductGrid(
                bearerToken: widget.bearerToken,
                allProducts: allProducts,
              ),
            ),
          ),
        ),

        SizedBox(height: isTablet ? 32 : 24),
      ],
    );
  }

  Future<void> _loadProducts() async {
    final products = await fetchAndMergeProducts(widget.bearerToken);
    setState(() {
      allProducts = products;
    });
  }

  Future<void> fetchAllProducts() async {
    final products = await fetchAndMergeProducts(widget.bearerToken);
    setState(() {
      allProducts = products;
      _searchResults = []; // Clear search results
      _isSearchSubmitted = false; // Reset search state
      _isSearchBarFullyExpanded = false; // Ensure search bar collapses
    });
  }
}
