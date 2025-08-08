import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:let_store/utils/app_textstyles.dart';

class SaleBanner extends StatelessWidget {
  final double bannerHeight;
  const SaleBanner({super.key, required this.bannerHeight});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: bannerHeight, // Height of the entire banner
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/kyoto_store.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // The background image is set by BoxDecoration on the parent Container.
          // Content (text and button)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(
                12.0,
              ), // Padding for the content within the banner
              child: Row(
                // Use Row to place text column and button side-by-side
                mainAxisSize: MainAxisSize
                    .min, // Make the Row take minimum horizontal space
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - Sale text with individual blurred backgrounds
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize
                        .min, // Make column take minimum vertical space
                    children: [
                      // "Get Your" text with its own blurred background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Smaller radius for individual lines
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5,
                            sigmaY: 5,
                          ), // Adjust blur strength
                          child: Container(
                            // color: Colors.black.withOpacity(0.15), // Light overlay for contrast
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            child: Text(
                              'Get Your',
                              style: AppTextStyle.withColor(
                                AppTextStyle.h3,
                                isDark
                                    ? Colors.black
                                    : Colors.white, // Text color remains sharp
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Space between lines
                      // "Special Sale" text with its own blurred background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 4,
                            sigmaY: 4,
                          ), // Different blur strength
                          child: Container(
                            // color: Colors.black.withOpacity(0.2), // Slightly darker overlay
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            child: Text(
                              'Special Sale',
                              style: AppTextStyle.withWeight(
                                AppTextStyle.withColor(
                                  AppTextStyle.h2,
                                  Colors.red, // Primary color for emphasis
                                ),
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Space between lines
                      // "Up to 40%" text with its own blurred background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 3,
                            sigmaY: 3,
                          ), // Another blur strength
                          child: Container(
                            // color: Colors.black.withOpacity(0.1), // Lighter overlay
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            child: Text(
                              'Up to 40%',
                              style: AppTextStyle.withColor(
                                AppTextStyle.h3,
                                isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20), // Space between text and button
                  // Right side - Shop Now button (no blur applied to it)
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.white, // Button background
                      foregroundColor: isDark
                          ? Colors.white
                          : Colors.black, // Button text color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text('Shop Now', style: AppTextStyle.buttonMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
