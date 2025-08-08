// import 'dart:convert';

// Merged OrderStatus enum with all statuses (from your original and previous response)
enum OrderStatus { pending, active, shipped, delivered, cancelled }

// Extension to convert enum to string and vice versa
extension OrderStatusExtension on OrderStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'active':
        return OrderStatus.active;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      default:
        // Default to cancelled if status is null or unknown
        return OrderStatus.cancelled;
    }
  }
}

// OrderItem: Based on your original, but with toJson for API consistency
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
    };
  }
}

// User model: Part of the backend API response structure
class User {
  final String email;
  final String id;

  User({required this.email, required this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json['email'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'id': id};
  }
}

// ApiOrder: Represents the full order structure from the backend API
// This is what you fetch and what you send back for patching
class ApiOrder {
  final String createdAt;
  final String id; // This is the unique order ID from the backend
  final List<OrderItem> items;
  OrderStatus status; // Made mutable for local updates after patch
  final int totalAmount;
  final User user;

  ApiOrder({
    required this.createdAt,
    required this.id,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.user,
  });

  factory ApiOrder.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? []; // Handle null items list
    List<OrderItem> items = itemsList
        .map((i) => OrderItem.fromJson(i))
        .toList();

    return ApiOrder(
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
      items: items,
      status: OrderStatusExtension.fromString(json['status']),
      totalAmount:
          (json['total_amount'] as num?)?.toInt() ??
          0, // Handle null and convert to int
      user: User.fromJson(json['user'] ?? {}), // Handle null user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'status': status.toShortString(),
      'total_amount': totalAmount,
      'user': user.toJson(),
    };
  }
}
