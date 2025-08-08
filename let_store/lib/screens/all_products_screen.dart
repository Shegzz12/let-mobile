import 'package:get/get.dart';

import '../features/widgets/product_grid.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '/utils/app_textstyles.dart';
import '../features/widgets/filter_bottom_sheet.dart';

// ignore: must_be_immutable
class AllProductsScreen extends StatelessWidget {
  List<Product> allProducts = [];
  String bearerToken;
  AllProductsScreen({
    super.key,
    required this.allProducts,
    required this.bearerToken,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'All Products',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // search icon
          IconButton(
            onPressed: () {},
            color: isDark ? Colors.white : Colors.black,
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          // filter icon
          IconButton(
            onPressed: () => FilterBottomSheet.show(context),
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: ProductGrid(allProducts: allProducts, bearerToken: bearerToken),
    );
  }
}
