import 'dart:convert';
import 'package:http/http.dart' as http;
// import '/screens/cart_screen.dart';
import '/utils/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import 'cart_service.dart';
// import '../services/cart_service.dart'; // Ensure this import is correct

class WishListScreen extends StatefulWidget {
  final String bearerToken;
  const WishListScreen({super.key, required this.bearerToken});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final List<Product> wishList = [];
  bool _isLoading = true; // Loading state for fetching wishlist
  bool _isAddingAllToCart = false; // Loading state for "Add All to Cart" button
  // New: Loading state for individual "Add to Cart" buttons
  final Map<String, bool> _itemLoadingStates = {};

  @override
  void initState() {
    super.initState();
    _fetchWishlistItems(); // Call the refactored fetch function
  }

  Future<void> _fetchWishlistItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await fetchWishlistItems(widget.bearerToken);
      if (mounted) {
        setState(() {
          wishList.clear(); // Clear existing items before adding new ones
          wishList.addAll(items);
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar('Error', 'Failed to load wishlist items: $error');
      }
    }
  }

  // Function to add all wishlist items to cart and then remove them
  Future<void> _addAllToCart() async {
    if (wishList.isEmpty) {
      Get.snackbar('Info', 'Your wishlist is empty. Nothing to add to cart.');
      return;
    }

    setState(() {
      _isAddingAllToCart = true; // Show loading on button
    });

    int successfulAdds = 0;
    List<String> failedProducts = [];
    List<Product> itemsToRemove =
        []; // Collect items to remove after successful operations

    // Iterate over a copy to avoid modifying the list while iterating
    final currentWishlistCopy = List<Product>.from(wishList);

    for (final product in currentWishlistCopy) {
      // Assuming quantity is 1 when adding from wishlist to cart
      final cartSuccess = await CartService.addToCart(
        product.id,
        1,
        widget.bearerToken,
      );

      if (cartSuccess) {
        final removeSuccess = await removeFromWishlist(product.id);
        if (removeSuccess) {
          successfulAdds++;
          itemsToRemove.add(product); // Mark for removal from local list
        } else {
          // Item added to cart but failed to remove from wishlist
          failedProducts.add(
            '${product.name} (failed to remove from wishlist)',
          );
        }
      } else {
        failedProducts.add('${product.name} (failed to add to cart)');
      }
    }

    setState(() {
      // Remove all successfully processed items from the local wishlist
      for (final product in itemsToRemove) {
        wishList.removeWhere((item) => item.id == product.id);
      }
      _isAddingAllToCart = false; // Hide loading on button
    });

    if (successfulAdds == currentWishlistCopy.length) {
      Get.snackbar(
        'Success',
        'All $successfulAdds items added to cart and removed from wishlist!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else if (successfulAdds > 0) {
      Get.snackbar(
        'Partial Success',
        '$successfulAdds items added to cart and removed from wishlist. Failed for: ${failedProducts.join(', ')}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        'Failed',
        'Failed to add any items to cart or remove from wishlist. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // New function to add a single item to cart and remove it from wishlist
  Future<void> _addSingleItemToCartAndRemove(Product product) async {
    setState(() {
      _itemLoadingStates[product.id] =
          true; // Show loading for this specific item
    });

    bool overallSuccess = false;
    String message = '';

    try {
      final cartSuccess = await CartService.addToCart(
        product.id,
        1, // Assuming quantity is 1
        widget.bearerToken,
      );

      if (cartSuccess) {
        final removeSuccess = await removeFromWishlist(product.id);
        if (removeSuccess) {
          overallSuccess = true;
          message = '${product.name} added to cart and removed from wishlist!';
        } else {
          message =
              '${product.name} added to cart, but failed to remove from wishlist.';
        }
      } else {
        message = 'Failed to add ${product.name} to cart.';
      }
    } catch (e) {
      message = 'Error processing ${product.name}: $e';
    } finally {
      setState(() {
        _itemLoadingStates[product.id] = false; // Hide loading for this item
        if (overallSuccess) {
          wishList.removeWhere(
            (item) => item.id == product.id,
          ); // Remove from local list
        }
      });
      Get.snackbar(
        overallSuccess ? 'Success' : 'Error',
        message,
        backgroundColor: overallSuccess ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
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
        title: Text(
          'Wish List Screen',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Implement search functionality
            },
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
        ), // Limits overall content width
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
            : wishList.isEmpty
            ? Center(
                child: Text(
                  'Your wishlist is empty.',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ), // Max width for the entire row/column
                  child: Row(
                    children: [
                      if (showSideContainers)
                        Container(
                          height: double.infinity,
                          width: 50, // Fixed width for the side container
                          color: Colors
                              .grey[200], // Example color, adjust as needed
                          // You can add content here if desired
                        ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            // summary section
                            SliverToBoxAdapter(
                              child: _buildSummarySection(context),
                            ),
                            // wishlist items - now directly determine the sliver based on screen width
                            _buildWishlistItemsSliver(
                              context,
                            ), // Call a helper method that returns a sliver
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteProducts = wishList.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$favoriteProducts Items',
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'in your wishlist',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _isAddingAllToCart || wishList.isEmpty
                ? null // Disable button when loading or wishlist is empty
                : _addAllToCart, // Call the new function
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isAddingAllToCart
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ) // Show loading indicator
                : Text(
                    'Add All to Cart',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // New helper method to return the correct sliver based on screen width
  Widget _buildWishlistItemsSliver(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;
    bool isGridView;
    // Define breakpoints for responsiveness
    if (screenWidth >= 1200) {
      // Desktop-like view (within the 1000px max width)
      crossAxisCount = 4;
      childAspectRatio = 0.68; // Portrait cards for grid
      isGridView = true;
    } else if (screenWidth >= 900) {
      // Desktop-like view (within the 1000px max width)
      crossAxisCount = 3;
      childAspectRatio = 0.85; // Portrait cards for grid
      isGridView = true;
    } else if (screenWidth >= 600) {
      // Tablet view
      crossAxisCount = 2;
      childAspectRatio = 0.85; // Slightly wider portrait cards for grid
      isGridView = true;
    } else {
      // Mobile view
      crossAxisCount = 1; // Effectively a list
      childAspectRatio = 3.5; // Keep original aspect ratio for list items
      isGridView = false;
    }

    if (!isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildWishlistItem(
              context,
              wishList[index],
              isGridView: false, // Explicitly false for list view
              key: ValueKey(wishList[index].id),
            ),
            childCount: wishList.length,
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
            (context, index) => _buildWishlistItem(
              context,
              wishList[index],
              isGridView: true, // Explicitly true for grid view
              key: ValueKey(wishList[index].id),
            ),
            childCount: wishList.length,
          ),
        ),
      );
    }
  }

  Widget _buildWishlistItem(
    BuildContext context,
    Product product, {
    Key? key,
    required bool isGridView,
  }) {
    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl
        : 'https://via.placeholder.com/150?text=No+Image';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Check if this specific item is currently being processed
    final bool isItemLoading = _itemLoadingStates[product.id] ?? false;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
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
      child: isGridView
          ? Column(
              // Grid View Layout
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ), // Only top corners rounded
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : Image.asset(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyLarge,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                        maxLines: 1, // Prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodySmall,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                        maxLines: 1, // Prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(), // Pushes buttons to the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: isItemLoading
                            ? null
                            : () {
                                _showDeleteConfirmation(context, product);
                              },
                        icon:
                            isItemLoading &&
                                _itemLoadingStates[product.id] == true
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                        tooltip: 'Remove from wishlist', // Accessibility
                      ),
                      IconButton(
                        onPressed: isItemLoading
                            ? null // Disable when loading
                            : () => _addSingleItemToCartAndRemove(
                                product,
                              ), // Call new function
                        icon:
                            isItemLoading &&
                                _itemLoadingStates[product.id] == true
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.shopping_cart_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                        tooltip:
                            'Add to cart and remove from wishlist', // Accessibility
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              // List View Layout (original)
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : Image.asset(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodyLarge,
                                Theme.of(context).textTheme.bodyLarge!.color!,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.category,
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodySmall,
                                isDark ? Colors.grey[400]! : Colors.grey[600]!,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: AppTextStyle.withColor(
                                    AppTextStyle.h3,
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color!,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: isItemLoading
                                  ? null
                                  : () {
                                      _showDeleteConfirmation(context, product);
                                    },
                              icon:
                                  isItemLoading &&
                                      _itemLoadingStates[product.id] == true
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                              tooltip: 'Remove from wishlist',
                            ),
                            IconButton(
                              onPressed: isItemLoading
                                  ? null // Disable when loading
                                  : () => _addSingleItemToCartAndRemove(
                                      product,
                                    ), // Call new function
                              icon:
                                  isItemLoading &&
                                      _itemLoadingStates[product.id] == true
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.blue,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              tooltip: 'Add to cart and remove from wishlist',
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

  void _showDeleteConfirmation(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Item',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete this item from your wishlist?',
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
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'cancel',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await removeFromWishlist(product.id);
                      if (success) {
                        setState(() {
                          wishList.removeWhere((item) => item.id == product.id);
                        });
                        Get.back();
                      } else {
                        Get.snackbar(
                          'Error',
                          'Failed to remove item from wishlist',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Delete',
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
        // barrierColor: Colors.black54,
      ),
    );
  }

  Future<List<Product>> fetchWishlistItems(String bearerToken) async {
    final url = Uri.parse(
      'https://let-commerce.onrender.com/api/products/wishlist',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((item) => Product.fromJson(item, widget.bearerToken))
            .toList();
      } else {
        print("❌ Failed to fetch wishlist. Status: ${response.statusCode}");
        return [];
      }
    } catch (e, stackTrace) {
      print("⚠️ Error fetching wishlist: $e");
      print(stackTrace);
      return [];
    }
  }

  Future<bool> removeFromWishlist(String productId) async {
    final url = Uri.parse(
      'https://let-commerce.onrender.com/api/products/wishlist/remove/$productId',
    );
    final token = widget.bearerToken;
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('✅ Product removed from wishlist: $productId');
        return true;
      } else {
        print('❌ Failed to remove product $productId: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error removing from wishlist $productId: $e');
      return false;
    }
  }
}
