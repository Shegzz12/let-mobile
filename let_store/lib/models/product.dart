import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final String bearerToken;
  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  bool isFavorite;
  // ignore: prefer_typing_uninitialized_variables
  final stock;
  final String description;

  Product({
    required this.stock,
    required this.bearerToken,
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.oldPrice,
    this.isFavorite = false,
  });

  @override
  String toString() {
    return '''Product(stock: $stock,  id: $id,  name: $name,  category: $category,  price: $price,  oldPrice: $oldPrice,  imageUrl: $imageUrl,  isFavorite: $isFavorite,  description: $description,)''';
  }

  // Added for better debugging if needed
  Map<String, dynamic> toJson() {
    return {
      'stock': stock,
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'description': description,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json, String bearerToken) {
    final double price = (json['price'] as num?)?.toDouble() ?? 0.0;
    double? calculatedOldPrice;

    // Calculate oldPrice based on discount if available and oldPrice is not explicitly provided
    if (json['discount'] != null && (json['discount'] as num).toDouble() > 0) {
      final double discountPercentage =
          (json['discount'] as num).toDouble() / 100.0;
      if (discountPercentage < 1.0) {
        // Ensure valid discount percentage
        calculatedOldPrice = price / (1.0 - discountPercentage);
      }
    }

    return Product(
      stock: json['stock'] ?? '',
      bearerToken: bearerToken,
      id: json['product_id'] ?? json['id'] ?? '', // Use product_id or id
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: price,
      oldPrice:
          json['oldPrice'] !=
              null // Prioritize explicit oldPrice from JSON
          ? (json['oldPrice'] as num).toDouble()
          : calculatedOldPrice, // Otherwise, use the calculated one
      imageUrl: (json['image_urls'] != null && json['image_urls'].isNotEmpty)
          ? json['image_urls'][0]
          : 'assets/images/segun.jpg', // Fallback image
      isFavorite: json['isFavorite'] ?? json['is_in_wishlist'] ?? false,
      description: json['description'] ?? '',
    );
  }
}

final List<Product> hardcodedProducts = [
  Product(
    stock: '',
    bearerToken: 'kshdkd',
    id: 'dkghe9e',
    isFavorite: true,
    name: 'Shoes',
    category: 'Footwear',
    price: 50.00,
    oldPrice: 107.00,
    imageUrl: 'assets/images/shoe.jpg',
    description: 'This is a description of the product 1',
  ),
  Product(
    stock: '',
    bearerToken: 'kshdkd',
    id: 'kdhtie',
    name: 'Laptop',
    category: 'Electronic',
    isFavorite: true,
    price: 69.00,
    oldPrice: 189.00,
    imageUrl: 'assets/images/laptop.jpg',
    description: 'This is a description of the product 2',
  ),
  Product(
    stock: '',
    bearerToken: 'kshdkd',
    id: 'dkhgncd',
    name: 'Jordan Shoes',
    category: 'Fontwear',
    price: 69.00,
    oldPrice: 189.00,
    imageUrl: 'assets/images/shoe2.jpg',
    description: 'This is a description of the product 3',
  ),
  Product(
    stock: '',
    bearerToken: 'kshdkd',
    id: 'kdhgebe',
    name: 'Puma',
    category: 'Footwear',
    price: 20.00,
    oldPrice: 100.00,
    imageUrl: 'assets/images/shoes2.jpg',
    description: 'This is a description of the product 4',
  ),
];

/// Fetch products from API and merge with hardcoded ones
Future<List<Product>> fetchAndMergeProducts(String bearerToken) async {
  final url = Uri.parse('https://let-commerce.onrender.com/api/products/all');
  final token = bearerToken;
  print('Attempting to fetch products from: $url');
  print('Using bearer token: $token'); // Be careful with sensitive info in logs

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // // print('fetched products: Response status code: ${response.statusCode}');
    // print(
    //   'Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
    // ); // Print first 500 chars

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('Fetched products: $data');

      // Corrected: Check if the response is directly a List
      if (data is List && data.isNotEmpty) {
        final List<Product> backendProducts = data
            .map((item) => Product.fromJson(item, bearerToken))
            .toList();

        // print('Fetched ${backendProducts.length} products from backend.');
        if (backendProducts.isNotEmpty) {
          // print(
          //   'First fetched product raw data: ${jsonEncode(backendProducts.first.toJson())}',
          // );
        }

        // print('Number of hardcoded products: ${hardcodedProducts.length}');
        // final combinedProducts = [...hardcodedProducts, ...backendProducts];
        // print('Total combined products: ${combinedProducts.length}');
        return backendProducts;
      } else {
        // print('Backend response is empty or not a list of products.');
        return hardcodedProducts; // Return hardcoded products if backend response is not a valid list
      }
    } else {
      // print('Failed to fetch products. Status code: ${response.statusCode}');
      return hardcodedProducts; // Return hardcoded products on API error
    }
  } catch (e) {
    // print('Error fetching products: $e');
    return hardcodedProducts; // Return hardcoded products on network/parsing error
  }
}
