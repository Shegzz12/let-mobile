import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:let_store/screens/cart_screen.dart';

import '../features/widgets/cart_badge.dart';
import '../models/cart_item.dart';
import '/utils/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../features/widgets/size_selector.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String bearerToken; // Store the bearerToken

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.bearerToken, // Initialize bearerToken
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoadingCart = true;

  // share product
  Future<void> _shareProduct(
    BuildContext context,
    String productName,
    String description,
  ) async {
    // get the render box for share position origin (required for iPad)
    final box = context.findRenderObject() as RenderBox?;
    const String shopLink =
        'https://yourshop.com/product/cotton-tshirt'; // Placeholder link
    final String shareMessage = '$description\n\nShop now at $shopLink';
    try {
      final ShareResult result = await Share.share(
        shareMessage,
        subject: productName,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      if (result.status == ShareResultStatus.success) {
        debugPrint('Thank you for sharing!');
      }
    } catch (e) {
      debugPrint('Error Sharing: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCartItems(widget.bearerToken);
  }

  @override
  Widget build(BuildContext context) {
    const double kBottomButtonHeight = 56;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isTabletOrDesktop =
        screenWidth >= 768; // Define breakpoint for tablet/desktop
    const double maxContentWidth = 1000; // Define the max width for consistency

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Details',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // share button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Get.to(() => CartScreen(bearerToken: widget.bearerToken));
              },
              child: _isLoadingCart
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : cartIconWithBadge(
                      itemCount: totalItemCount,
                    ), // Replace 3 with your cart count variable
            ),
          ),
          IconButton(
            onPressed: () => _shareProduct(
              context,
              widget.product.name,
              widget.product.description,
            ),
            icon: Icon(
              Icons.share,
              size: 35,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        // Make the body fill available space
        child: Center(
          // Center the content on larger screens
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: maxContentWidth,
            ), // Use defined max width
            child: isTabletOrDesktop
                ? _buildTabletDesktopLayout(context, isDark)
                : _buildMobileLayout(context, isDark),
          ),
        ),
      ),

      // Add near the top of your State class (or as a file-level const)

      // ...
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTabletOrDesktop && screenWidth > maxContentWidth
                ? (screenWidth - maxContentWidth) / 2 + 24
                : 24,
            vertical: 16,
          ),
          child: Row(
            children: [
              // Left: Add to Cart (Outlined)
              Expanded(
                child: SizedBox(
                  height: kBottomButtonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      _addToCart(context, widget.product);
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.zero, // Let SizedBox control the height
                      minimumSize: Size.fromHeight(kBottomButtonHeight),
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add To Cart',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Right: Go to Cart (Elevated) with badge
              Expanded(
                child: SizedBox(
                  height: kBottomButtonHeight, // Match the outlined button
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(
                              () => CartScreen(bearerToken: widget.bearerToken),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets
                                .zero, // Let SizedBox control the height
                            minimumSize: Size.fromHeight(kBottomButtonHeight),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Go to Cart',
                            style: AppTextStyle.withColor(
                              AppTextStyle.buttonMedium,
                              Colors.white,
                            ),
                          ),
                        ),
                      ),

                      if (totalItemCount > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IgnorePointer(
                            ignoring: true,
                            child: CartBadge(count: totalItemCount),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageUrl = widget.product.imageUrl.isNotEmpty
        ? widget.product.imageUrl
        : 'https://via.placeholder.com/150?text=No+Image';
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 12,
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
              // favorite button
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    _toggleFavorite();
                    // Handle favorite toggle
                  },
                  icon: Icon(
                    widget.product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.product.isFavorite
                        ? Theme.of(context).primaryColor
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          ),
          // product details
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.name,
                        style: AppTextStyle.withColor(
                          AppTextStyle.h2,
                          Theme.of(context).textTheme.headlineMedium!.color!,
                        ),
                      ),
                    ),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h2,
                        Theme.of(context).textTheme.headlineMedium!.color!,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.product.category,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Select Size',
                  style: AppTextStyle.withColor(
                    AppTextStyle.labelMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // size selector
                const SizeSelector(),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Description',
                  style: AppTextStyle.withColor(
                    AppTextStyle.labelMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                Text(
                  widget.product.description,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletDesktopLayout(BuildContext context, bool isDark) {
    final imageUrl = widget.product.imageUrl.isNotEmpty
        ? widget.product.imageUrl
        : 'https://via.placeholder.com/150?text=No+Image';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align content to the top
      children: [
        Expanded(
          flex: 1, // Image takes 1 part of the space
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1, // Square aspect ratio for better fit in a row
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    _toggleFavorite();
                    // Handle favorite toggle
                  },
                  icon: Icon(
                    widget.product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.product.isFavorite
                        ? Theme.of(context).primaryColor
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1, // Details take 1 part of the space
          child: SingleChildScrollView(
            // Allow details to scroll independently
            padding: const EdgeInsets.all(24), // Consistent padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.name,
                        style: AppTextStyle.withColor(
                          AppTextStyle.h2,
                          Theme.of(context).textTheme.headlineMedium!.color!,
                        ),
                      ),
                    ),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h2,
                        Theme.of(context).textTheme.headlineMedium!.color!,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.product.category,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Size',
                  style: AppTextStyle.withColor(
                    AppTextStyle.labelMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                const SizeSelector(),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: AppTextStyle.withColor(
                    AppTextStyle.labelMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                Text(
                  widget.product.description,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart(BuildContext context, Product product) async {
    final success = await _addProductToCart(product.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to cart'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<bool> _addProductToCart(String productId) async {
    const String url = 'https://let-commerce.onrender.com/api/cart/add';
    final token = widget.bearerToken;
    final body = jsonEncode({"product_id": productId, "quantity": 1});
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Action methods (unchanged from previous versions)
  Future<void> _toggleFavorite() async {
    final productId = widget.product.id;
    final isFavorite = widget.product.isFavorite;
    final action = isFavorite ? 'remove' : 'add';
    final success = await _updateWishlist(productId, action);
    if (success) {
      setState(() {
        widget.product.isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Removed from wishlist' : 'Added to wishlist',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _updateWishlist(String productId, String action) async {
    final baseUrl = 'https://let-commerce.onrender.com/api/products/wishlist/';
    final url = Uri.parse('$baseUrl$action/$productId');
    final token = widget.bearerToken;
    try {
      http.Response response;
      if (action == 'add') {
        response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } else {
        response = await http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updating wishlist: $e');
      return false;
    }
  }

  Widget cartIconWithBadge({required int itemCount}) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        const Icon(Icons.shopping_cart, size: 35),

        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _fetchCartItems(bearerToken) async {
    final url = Uri.parse(
      'https://cors-anywhere.herokuapp.com/https://let-commerce.onrender.com/api/cart/get-cart',
    );
    print('Sending get request now');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          // 'Origin': 'http://localhost:58792',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ Cart items: Response body: $decoded');

        final List<dynamic> items = decoded['items'];

        setState(() {
          _cartItems = items
              .map((item) => CartItem.fromJson(item, bearerToken))
              .toList();
        });
      } else {
        print('Failed to fetch cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    } finally {
      // ✅ Always stop the loading indicator
      if (mounted) {
        setState(() {
          _isLoadingCart = false;
        });
      }
    }
  }

  int get totalItemCount => _cartItems.length;
}
