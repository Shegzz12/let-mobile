import 'dart:convert';
// import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:let_store/screens/cart_screen.dart';
// import '/utils/app_textstyles.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import '../../models/product.dart'; // Ensure this path is correct

class ProductCard extends StatefulWidget {
  final Product product;
  final String bearerToken;
  final bool?
  isCompact; // Passed from ProductGrid to indicate a more condensed layout
  const ProductCard({
    super.key,
    required this.product,
    required this.bearerToken,
    this.isCompact = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late Product product;
  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Determine if we're in compact mode based on screen width or explicit setting from ProductGrid
    final isCompact = widget.isCompact ?? screenWidth > 1200;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // Remove default margin from Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section - takes 3/5 of the card height
          Expanded(flex: 3, child: _buildImageSection(screenWidth, isDark)),
          // Content section - takes 2/5 of the card height
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(_getContentPadding(screenWidth)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Pushes content to top and buttons to bottom
                children: [
                  // Product info (name, category, price)
                  Column(
                    // Group name, category, price
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min, // Column takes minimum vertical space
                    children: [
                      SizedBox(height: 4),
                      // Product name
                      FittedBox(
                        // Ensures text fits by scaling down if necessary
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: _getTitleFontSize(screenWidth),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            height:
                                1.2, // Adjust line height for better spacing
                          ),
                          maxLines: isCompact
                              ? 1
                              : 2, // 1 line for compact, 2 for others
                          overflow: TextOverflow
                              .ellipsis, // Fallback to ellipsis if FittedBox can't prevent overflow
                        ),
                      ),
                      // Category - only show if not in compact mode
                      if (!isCompact) ...[
                        SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.product.category,
                            style: TextStyle(
                              fontSize: _getCategoryFontSize(screenWidth),
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      SizedBox(height: 6),
                      // Price
                      _buildPriceRow(screenWidth, isDark),
                    ],
                  ),
                  // Buttons - pushed to bottom by mainAxisAlignment.spaceBetween
                  _buildButtonSection(screenWidth, isDark, isCompact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(double screenWidth, bool isDark) {
    return Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_getBorderRadius(screenWidth)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _buildProductImage(widget.product.imageUrl, screenWidth),
          ),
        ),
        // Discount badge - always show if there's a discount
        if (widget.product.oldPrice != null &&
            widget.product.oldPrice! > widget.product.price)
          Positioned(
            left: 10,
            top: 15,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _getBadgePadding(screenWidth),
                vertical: _getBadgePadding(screenWidth) * 0.5,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '-${(((widget.product.oldPrice! - widget.product.price) / widget.product.oldPrice!) * 100).round()}%',
                  style: TextStyle(
                    fontSize: _getBadgeFontSize(
                      screenWidth,
                    ), // Adjusted font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        // Favorite button
        Positioned(
          right: 2,
          top: 2,
          child: IconButton(
            iconSize: _getIconSize(screenWidth) + 5,
            padding: EdgeInsets.all(2),
            constraints: BoxConstraints(
              minWidth: _getIconSize(screenWidth) + 7,
              minHeight: _getIconSize(screenWidth) + 7,
            ),
            icon: Icon(
              widget.product.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.product.isFavorite
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(double screenWidth, bool isDark) {
    return Row(
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: _getPriceFontSize(screenWidth),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              overflow: TextOverflow
                  .ellipsis, // Fallback to ellipsis if FittedBox can't scale enough
            ),
          ),
        ),
        if (widget.product.oldPrice != null &&
            widget.product.oldPrice! > widget.product.price) ...[
          SizedBox(width: 7),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '\$${widget.product.oldPrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: _getOldPriceFontSize(screenWidth),
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButtonSection(double screenWidth, bool isDark, bool isCompact) {
    final buttonHeight = _getButtonHeight(screenWidth);
    final buttonFontSize = _getButtonFontSize(screenWidth);

    // If in compact mode or very small screen, return an empty SizedBox (no buttons)
    if (isCompact || screenWidth < 400) {
      return SizedBox();
    } else {
      // Otherwise (full mode), show only the "Buy" button
      return Row(
        children: [
          // Commented out "Add" button as per user request
          // Expanded(
          //   child: SizedBox(
          //     height: buttonHeight,
          //     child: OutlinedButton(
          //       onPressed: () => _addToCart(),
          //       style: OutlinedButton.styleFrom(
          //         side: BorderSide(
          //           color: Theme.of(context).primaryColor,
          //           width: 1,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(6),
          //         ),
          //         padding: EdgeInsets.symmetric(horizontal: 2),
          //         minimumSize: Size.fromHeight(buttonHeight),
          //       ),
          //       child: FittedBox(
          //         fit: BoxFit.scaleDown,
          //         child: Text(
          //           'Add',
          //           style: TextStyle(
          //             fontSize: buttonFontSize,
          //             color: Theme.of(context).primaryColor,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(width: 4), // Spacing if "Add" button was present
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () => _addToCart(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 2,
                  ), // Reduced padding
                  minimumSize: Size.fromHeight(
                    buttonHeight,
                  ), // Ensure consistent height
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  // Responsive helper methods - adjusted for better fit
  double _getBorderRadius(double screenWidth) {
    if (screenWidth < 600) return 8;
    if (screenWidth < 900) return 10;
    return 12;
  }

  double _getContentPadding(double screenWidth) {
    if (screenWidth < 600) return 6; // Reduced for mobile
    if (screenWidth < 900) return 8; // Reduced for tablet
    return 10; // Reduced for desktop
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 600) return 16; // Smallest for mobile
    if (screenWidth < 900) return 18;
    return 16; // Largest for desktop
  }

  double _getCategoryFontSize(double screenWidth) {
    if (screenWidth < 600) return 13; // Smallest for mobile
    if (screenWidth < 900) return 14;
    return 15; // Largest for desktop
  }

  double _getPriceFontSize(double screenWidth) {
    if (screenWidth < 600) return 15; // Smallest for mobile
    if (screenWidth < 900) return 16;
    return 16; // Largest for desktop
  }

  double _getOldPriceFontSize(double screenWidth) {
    if (screenWidth < 600) return 12; // Smallest for mobile (was 14)
    if (screenWidth < 900) return 13; // (was 15)
    return 14; // (was 16)
  }

  double _getButtonFontSize(double screenWidth) {
    if (screenWidth < 600) return 10; // Smallest for mobile
    if (screenWidth < 900) return 11;
    return 12; // Largest for desktop
  }

  double _getButtonHeight(double screenWidth) {
    if (screenWidth < 600) return 28; // Smallest for mobile
    if (screenWidth < 900) return 32;
    return 36; // Largest for desktop
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 600) return 23; // Smallest for mobile
    if (screenWidth < 900) return 30;
    return 22; // Largest for desktop
  }

  double _getBadgePadding(double screenWidth) {
    if (screenWidth < 600) return 4; // Smallest for mobile
    if (screenWidth < 900) return 6;
    return 8; // Largest for desktop
  }

  double _getBadgeFontSize(double screenWidth) {
    if (screenWidth < 600) return 12; // Smallest for mobile
    if (screenWidth < 900) return 16;
    return 10; // Largest for desktop
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

  void _addToCart() async {
    final success = await _addProductToCart(widget.product.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to cart'),
          duration: Duration(seconds: 1),
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

  Widget _buildProductImage(String imageUrl, double screenWidth) {
    final isNetworkImage =
        imageUrl.startsWith('http') || imageUrl.startsWith('https');

    return isNetworkImage
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageError(screenWidth);
            },
          )
        : Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageError(screenWidth);
            },
          );
  }

  Widget _buildImageError(double screenWidth) {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[600],
        size: _getIconSize(screenWidth) * 1.5,
      ),
    );
  }
}
