import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get _baseHost {
    if (kIsWeb) return '127.0.0.1';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return '127.0.0.1';
  }

  static String get userServiceUrl => 'http://$_baseHost:8001';
  static String get productServiceUrl => 'http://$_baseHost:8002';
  static String get cartOrderServiceUrl => 'http://$_baseHost:8003';
  static String get deliveryServiceUrl => 'http://$_baseHost:8004';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> saveAuth(String token, int userId, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('user_id', userId);
    await prefs.setString('user_name', name);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String otp) async {
    final url = Uri.parse('$userServiceUrl/register');
    print('Making request to: $url');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'otp': otp,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveAuth(data['access_token'], data['user_id'], data['name']);
      return data;
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$userServiceUrl/login');
    print('Making request to: $url');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveAuth(data['access_token'], data['user_id'], data['name']);
      return data;
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$userServiceUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load profile');
  }

  static Future<List<dynamic>> getProducts({String? category}) async {
    String url = '$productServiceUrl/products';
    if (category != null) url += '?category=$category';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load products');
  }

  static Future<Map<String, dynamic>> getProduct(int productId) async {
    final response =
        await http.get(Uri.parse('$productServiceUrl/products/$productId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load product');
  }

  static Future<List<dynamic>> getCategories() async {
    final response =
        await http.get(Uri.parse('$productServiceUrl/categories'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load categories');
  }

  static Future<Map<String, dynamic>> addToCart(
      int productId, String productName, double productPrice,
      {int quantity = 1}) async {
    final userId = await getUserId();
    final response = await http.post(
      Uri.parse('$cartOrderServiceUrl/cart/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'product_id': productId,
        'product_name': productName,
        'product_price': productPrice,
        'quantity': quantity,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to add to cart');
  }

  static Future<void> removeFromCart(int productId) async {
    final userId = await getUserId();
    await http.post(
      Uri.parse('$cartOrderServiceUrl/cart/remove'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'product_id': productId}),
    );
  }

  static Future<List<dynamic>> getCart() async {
    final userId = await getUserId();
    final response =
        await http.get(Uri.parse('$cartOrderServiceUrl/cart?user_id=$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load cart');
  }

  static Future<Map<String, dynamic>> createOrder() async {
    final userId = await getUserId();
    final response = await http.post(
      Uri.parse('$cartOrderServiceUrl/order/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
        jsonDecode(response.body)['detail'] ?? 'Failed to create order');
  }

  static Future<List<dynamic>> getOrders() async {
    final userId = await getUserId();
    final response =
        await http.get(Uri.parse('$cartOrderServiceUrl/orders?user_id=$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load orders');
  }

  static Future<Map<String, dynamic>> getOrderStatus(int orderId) async {
    final response =
        await http.get(Uri.parse('$deliveryServiceUrl/order/$orderId/status'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load order status');
  }

  static Future<Map<String, dynamic>> updateOrderStatus(int orderId) async {
    final response = await http.post(
      Uri.parse('$deliveryServiceUrl/order/$orderId/update-status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update order status');
  }
}
