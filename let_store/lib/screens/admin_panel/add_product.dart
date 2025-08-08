import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:let_store/screens/admin_panel/display_orders_screen.dart';
import 'package:let_store/screens/signin_screen.dart';

import '../../features/widgets/custom_textfield.dart';
import '../../models/product.dart';
import '../../utils/app_textstyles.dart';

class AddProductPage extends StatefulWidget {
  final String bearerToken;

  const AddProductPage({super.key, required this.bearerToken});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final tagsController = TextEditingController(); // comma-separated tags
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final stockController = TextEditingController();
  final imageUrlsController = TextEditingController(); // comma-separated
  final videoUrlsController = TextEditingController(); // comma-separated
  final String apiUrl = 'https://let-commerce.onrender.com/api/products/add';
  List<Product> backendProducts = [];
  List<Product> allProducts = [];

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: backendProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Name",
                              nameController,
                              prefixIcon: CupertinoIcons.pencil,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: _buildTextField(
                              "Quantity",
                              stockController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.money,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildTextField(
                        "Description",
                        descriptionController,
                        prefixIcon: Icons.text_fields,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Category",
                              categoryController,
                              prefixIcon: Icons.category,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: _buildTextField(
                              "Tags (comma-separated)",
                              tagsController,
                              prefixIcon: CupertinoIcons.tag,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Price",
                              priceController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.numbers,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: _buildTextField(
                              "Discount (%)",
                              discountController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.percent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      _buildTextField(
                        "Image URLs (comma-separated)",
                        imageUrlsController,
                        prefixIcon: Icons.picture_in_picture,
                      ),
                      SizedBox(height: 8),
                      _buildTextField(
                        "Video URLs (comma-separated)",
                        videoUrlsController,
                        prefixIcon: CupertinoIcons.video_camera,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitProduct,
                        child: Text('Submit Product'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.start,
                        'Stocked Products',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyLarge,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),

                      SizedBox(
                        height: 400,
                        child: ListView.builder(
                          itemCount: backendProducts.length,
                          itemBuilder: (context, index) {
                            final product = backendProducts[index];
                            final imageUrl = product.imageUrl.isNotEmpty
                                ? product.imageUrl
                                : 'https://via.placeholder.com/150?text=No+Image';
                            return Column(
                              children: [
                                ListTile(
                                  leading: imageUrl.startsWith('http')
                                      ? Image.network(
                                          imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        )
                                      : Image.asset(
                                          imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        ),

                                  title: Text(product.name),
                                  subtitle: Text(
                                    '${product.category} • ₦${product.price}',
                                  ),
                                  trailing: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Qty: ${product.stock}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          deleteProduct(
                                            product.id,
                                            widget.bearerToken,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.blue[200],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: addProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                child: const Text('     Send     '),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => DisplayOrdersScreen(bearerToken: widget.bearerToken),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                child: const Text('Pending Orders'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => Get.to(() => SigninScreen()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                child: const Text('Back To Signin'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteProduct(String productId, String bearerToken) async {
    final url = Uri.parse(
      "https://let-commerce.onrender.com/api/products/delete/$productId",
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('🗑️ Product deleted successfully!');
        print(jsonDecode(response.body));
        fetchAllProducts(); // Refresh list
      } else {
        print('❌ Failed to delete product: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('⚠️ Error occurred while deleting product: $e');
    }
  }

  Future<void> fetchAllProducts() async {
    final url = Uri.parse('https://let-commerce.onrender.com/api/products/all');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.bearerToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched Products: $data');

        if (data is List && data.isNotEmpty) {
          final fetched = data
              .map((item) => Product.fromJson(item, widget.bearerToken))
              .toList();

          setState(() {
            allProducts =
                fetched; // or combine with hardcodedProducts if needed
            backendProducts = fetched;
          });
        } else {
          print('No products found');
        }
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> addProduct() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.bearerToken}',
        },
        body: jsonEncode(_submitProduct()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Product added successfully!');
        print(jsonDecode(response.body));
        fetchAllProducts(); // Refresh list
      } else {
        print('❌ Failed to add product: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('⚠️ Error occurred: $e');
    }
  }

  Map<String, Object> _submitProduct() {
    final productData = {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "category": categoryController.text.trim(),
      "tags": tagsController.text.split(',').map((e) => e.trim()).toList(),
      "price": double.tryParse(priceController.text) ?? 0.0,
      "discount": int.tryParse(discountController.text) ?? 0,
      "stock": int.tryParse(stockController.text) ?? 0,
      "image_urls": imageUrlsController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      "video_urls": videoUrlsController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    };

    print('Submitted Product: $productData');
    return productData;
    // You can send this map to your backend or further process it
  }

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    tagsController.dispose();
    priceController.dispose();
    discountController.dispose();
    stockController.dispose();
    imageUrlsController.dispose();
    videoUrlsController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    final TextInputType? keyboardType,
    IconData prefixIcon = CupertinoIcons.pencil,
  }) {
    return CustomTextfield(
      label: label,
      prefixIcon: prefixIcon,
      keyboardType: keyboardType ?? TextInputType.text,
      controller: controller,
    );
  }
}
