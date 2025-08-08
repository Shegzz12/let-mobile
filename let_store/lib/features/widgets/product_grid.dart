import '/models/product.dart'; // Ensure this path is correct
import 'package:flutter/material.dart';
import '../../screens/product_details_screen.dart'; // Ensure this path is correct
import 'product_card.dart'; // Ensure this path is correct

class ProductGrid extends StatelessWidget {
  final List<Product> allProducts;
  final String bearerToken;

  const ProductGrid({
    super.key,
    required this.allProducts,
    required this.bearerToken,
  });

  @override
  Widget build(BuildContext context) {
    if (allProducts.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No products found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final gridProperties = _getGridProperties(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Prevents GridView from scrolling independently
      padding: EdgeInsets.symmetric(
        horizontal: gridProperties.horizontalPadding,
        vertical: gridProperties.verticalPadding,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridProperties.crossAxisCount,
        childAspectRatio: gridProperties
            .childAspectRatio, // CRITICAL for controlling card height
        crossAxisSpacing: gridProperties.crossAxisSpacing,
        mainAxisSpacing: gridProperties.mainAxisSpacing,
      ),
      itemCount: allProducts.length,
      itemBuilder: (context, index) {
        final product = allProducts[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                bearerToken: bearerToken,
                product: product,
              ),
            ),
          ),
          child: ProductCard(
            product: product,
            bearerToken: bearerToken,
            // Pass isCompact based on the number of columns.
            // Cards with 4 or more columns will use a more condensed layout.
            isCompact: gridProperties.crossAxisCount >= 4,
          ),
        );
      },
    );
  }

  // Helper method to determine grid properties based on screen width
  GridProperties _getGridProperties(double screenWidth) {
    if (screenWidth < 600) {
      // Mobile phones (e.g., iPhone SE, small Androids)
      return GridProperties(
        crossAxisCount: 2,
        childAspectRatio: 0.72, // Taller cards for mobile to fit content
        crossAxisSpacing: 10,
        mainAxisSpacing: 8,
        horizontalPadding: 0,
        verticalPadding: 8,
      );
    } else if (screenWidth < 900) {
      // Small tablets (e.g., iPad Mini, larger phones in landscape)
      return GridProperties(
        crossAxisCount: 3,
        childAspectRatio: 0.63, // Adjusted for 3 columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        horizontalPadding: 12,
        verticalPadding: 12,
      );
    } else if (screenWidth < 1200) {
      // Large tablets / Small desktop (e.g., iPad Pro, small laptops)
      return GridProperties(
        crossAxisCount: 3,
        childAspectRatio: 0.87, // Adjusted for 4 columns, giving more height
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        horizontalPadding: 15,
        verticalPadding: 15,
      );
    } else if (screenWidth < 1600) {
      // Medium desktop (e.g., standard laptops)
      return GridProperties(
        crossAxisCount: 4,
        childAspectRatio: 0.87, // Adjusted for 5 columns, giving more height
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        horizontalPadding: 32,
        verticalPadding: 20,
      );
    } else {
      // Large desktop (e.g., large monitors)
      return GridProperties(
        crossAxisCount: 4,
        childAspectRatio: 0.70, // Adjusted for 6 columns, giving more height
        crossAxisSpacing: 28,
        mainAxisSpacing: 28,
        horizontalPadding: 40,
        verticalPadding: 24,
      );
    }
  }
}

// Helper class to store grid properties for different screen sizes
class GridProperties {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double horizontalPadding;
  final double verticalPadding;

  GridProperties({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.horizontalPadding,
    required this.verticalPadding,
  });
}
// import '/models/product.dart';
// import 'package:flutter/material.dart';
// import '../../screens/product_details_screen.dart';
// import 'product_card.dart';

// class ProductGrid extends StatelessWidget {
//   final List<Product> allProducts;
//   final String bearerToken;

//   const ProductGrid({
//     super.key,
//     required this.allProducts,
//     required this.bearerToken,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (allProducts.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.all(24),
//         child: Center(
//           child: Text(
//             'No products found',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ),
//       );
//     }

//     // Get screen width for responsive design
//     final screenWidth = MediaQuery.of(context).size.width;
//     final responsiveProps = _getResponsiveProperties(screenWidth);

//     List<Product> products = allProducts;

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(
//         horizontal: responsiveProps.padding,
//         vertical: responsiveProps.padding * 0.5,
//       ),
//       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: responsiveProps.maxItemWidth,
//         childAspectRatio: responsiveProps.aspectRatio,
//         crossAxisSpacing: responsiveProps.spacing,
//         mainAxisSpacing: responsiveProps.spacing,
//       ),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         final product = products[index];
//         return GestureDetector(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProductDetailsScreen(
//                 bearerToken: bearerToken,
//                 product: product,
//               ),
//             ),
//           ),
//           child: ProductCard(product: product, bearerToken: bearerToken),
//         );
//       },
//     );
//   }

//   ResponsiveProperties _getResponsiveProperties(double screenWidth) {
//     if (screenWidth < 600) {
//       // Mobile: ~2 columns
//       return ResponsiveProperties(
//         maxItemWidth: 200,
//         aspectRatio: 0.75,
//         spacing: 12,
//         padding: 16,
//       );
//     } else if (screenWidth < 900) {
//       // Tablet: ~3 columns
//       return ResponsiveProperties(
//         maxItemWidth: 250,
//         aspectRatio: 0.8,
//         spacing: 16,
//         padding: 20,
//       );
//     } else if (screenWidth < 1200) {
//       // Small Desktop: ~4 columns
//       return ResponsiveProperties(
//         maxItemWidth: 280,
//         aspectRatio: 0.85,
//         spacing: 20,
//         padding: 24,
//       );
//     } else if (screenWidth < 1600) {
//       // Medium Desktop: ~5 columns
//       return ResponsiveProperties(
//         maxItemWidth: 300,
//         aspectRatio: 0.9,
//         spacing: 24,
//         padding: 32,
//       );
//     } else {
//       // Large Desktop: ~6+ columns
//       return ResponsiveProperties(
//         maxItemWidth: 320,
//         aspectRatio: 0.95,
//         spacing: 28,
//         padding: 40,
//       );
//     }
//   }
// }

// class ResponsiveProperties {
//   final double maxItemWidth;
//   final double aspectRatio;
//   final double spacing;
//   final double padding;

//   ResponsiveProperties({
//     required this.maxItemWidth,
//     required this.aspectRatio,
//     required this.spacing,
//     required this.padding,
//   });
// }

// import '/models/product.dart';
// import 'package:flutter/material.dart';
// import '../../screens/product_details_screen.dart';
// import 'product_card.dart';

// class ProductGrid extends StatelessWidget {
//   final List<Product> allProducts;
//   final String bearerToken;

//   const ProductGrid({
//     super.key,
//     required this.allProducts,
//     required this.bearerToken,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (allProducts.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.all(24),
//         child: Center(
//           child: Text(
//             'No products found',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ),
//       );
//     }
//     // List<Product> products = extraProducts
//     //     .map((e) => Product.fromJson(e))
//     //     .toList();
//     List<Product> products = allProducts;
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.75,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         final product = products[index];
//         return GestureDetector(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProductDetailsScreen(
//                 bearerToken: bearerToken,
//                 product: product,
//               ),
//             ),
//           ),
//           child: ProductCard(product: product, bearerToken: bearerToken),
//         );
//       },
//     );
//   }
// }
