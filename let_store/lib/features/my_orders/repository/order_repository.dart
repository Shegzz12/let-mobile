import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/order.dart'; // Import your MODIFIED Order model

class OrderRepository {
  final String baseUrl = 'https://let-commerce.onrender.com';

  // Now returns a list of your MODIFIED Order objects
  Future<List<Order>> fetchOrders(String bearerToken) async {
    final url = Uri.parse('$baseUrl/api/orders/my-orders');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('orders from backend: $data');
      // Directly parse into List<Order> using the new factory constructor
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }
}
