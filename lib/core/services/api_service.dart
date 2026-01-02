import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finsight/core/models/product_model.dart';
import 'package:finsight/core/models/transaction_model.dart';
import 'package:finsight/core/models/category_model.dart';
import 'package:finsight/core/models/notification_model.dart';
import 'package:finsight/core/models/user_model.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http
            .post(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            )
            .timeout(_timeout);
      } catch (e) {
        // Ignore error on logout
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            body: {'email': email, 'password': password},
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return null; // Success
      }

      if (response.statusCode == 401) {
        return 'Email atau password salah.';
      }

      return 'Error ${response.statusCode}: Gagal masuk ke akun.';
    } on TimeoutException {
      return 'Koneksi lemot. Silakan coba lagi.';
    } on SocketException {
      return 'Tidak ada koneksi internet / Server offline.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<List<Product>> getProducts() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/products'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat produk. Status: ${response.statusCode}');
  }

  Future<List<Category>> getCategories() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/categories'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat kategori.');
  }

  Future<Product> addProduct(Map<String, dynamic> productData) async {
    final token = await getToken();
    var uri = Uri.parse('$baseUrl/products');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = productData['name'];
    if (productData['category_id'] != null) {
      request.fields['category_id'] = productData['category_id'].toString();
    }
    request.fields['price'] = productData['price'].toString();
    request.fields['purchase_price'] = productData['purchase_price'].toString();
    request.fields['stock'] = productData['stock'].toString();
    if (productData['description'] != null) {
      request.fields['description'] = productData['description'];
    }

    if (productData['image'] != null &&
        productData['image'].toString().isNotEmpty &&
        !productData['image'].toString().startsWith('http')) {
      request.files.add(
        await http.MultipartFile.fromPath('image', productData['image']),
      );
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal tambah produk: ${response.statusCode}');
  }

  Future<TransactionModel> createTransaction({
    required double totalAmount,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await getToken();
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/transactions'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'total_amount': totalAmount,
              'payment_method': paymentMethod,
              'items': items,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        return TransactionModel.fromJson(jsonDecode(response.body));
      }

      // Handle error response with message from server
      String errorMessage = 'Server merespon ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          errorMessage = errorBody['message'];
        }
      } catch (_) {}

      throw Exception(errorMessage);
    } on TimeoutException {
      throw Exception('Waktu habis. Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/transactions'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];
      return list.map((e) => TransactionModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/dashboard/stats'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    final token = await getToken();
    var uri = Uri.parse('$baseUrl/products/$id');

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT';

    request.fields['name'] = productData['name'];
    if (productData['category_id'] != null) {
      request.fields['category_id'] = productData['category_id'].toString();
    }
    request.fields['price'] = productData['price'].toString();
    request.fields['purchase_price'] = productData['purchase_price'].toString();
    request.fields['stock'] = productData['stock'].toString();
    if (productData['description'] != null) {
      request.fields['description'] = productData['description'];
    }

    if (productData['image'] != null &&
        productData['image'].toString().isNotEmpty &&
        !productData['image'].toString().startsWith('http')) {
      request.files.add(
        await http.MultipartFile.fromPath('image', productData['image']),
      );
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal ubah produk.');
  }

  Future<void> deleteProduct(String id) async {
    final token = await getToken();
    await http
        .delete(
          Uri.parse('$baseUrl/products/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);
  }

  Future<Product> updateProductStock(String id, int newStock) async {
    final token = await getToken();
    final response = await http
        .put(
          Uri.parse('$baseUrl/products/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'stock': newStock}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal update stok.');
  }

  Future<List<Map<String, dynamic>>> getSalesChart() async {
    final token = await getToken();
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/dashboard/chart'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<List<NotificationModel>> getNotifications() async {
    final token = await getToken();
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notifications'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<UserModel>> getStaff() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/users'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<UserModel> addStaff(Map<String, dynamic> staffData) async {
    final token = await getToken();
    final response = await http
        .post(
          Uri.parse('$baseUrl/users'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(staffData),
        )
        .timeout(_timeout);

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal tambah staff.');
  }

  Future<UserModel> updateStaff(
    String id,
    Map<String, dynamic> staffData,
  ) async {
    final token = await getToken();
    final response = await http
        .put(
          Uri.parse('$baseUrl/users/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(staffData),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal update staff.');
  }

  Future<void> deleteStaff(String id) async {
    final token = await getToken();
    await http
        .delete(
          Uri.parse('$baseUrl/users/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);
  }

  Future<Map<String, dynamic>> exportData() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/settings/export'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal ekspor data.');
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http
        .post(
          Uri.parse('$baseUrl/settings/import'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'data': data}),
        )
        .timeout(_timeout);

    return response.statusCode == 200;
  }

  // Restock History
  Future<List<Map<String, dynamic>>> getRestockHistory() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/restock-history'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<bool> addRestockHistory(Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http
        .post(
          Uri.parse('$baseUrl/restock-history'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        )
        .timeout(_timeout);

    return response.statusCode == 201;
  }

  // App Settings (Sync)
  Future<Map<String, dynamic>> getAppSettings() async {
    final token = await getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/settings'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  Future<bool> updateAppSettings(Map<String, dynamic> settings) async {
    final token = await getToken();
    final response = await http
        .post(
          Uri.parse('$baseUrl/settings'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'settings': settings}),
        )
        .timeout(_timeout);

    return response.statusCode == 200;
  }
}
