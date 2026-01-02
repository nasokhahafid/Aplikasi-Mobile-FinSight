import 'package:flutter/material.dart';
import 'package:finsight/core/models/product_model.dart';
import 'package:finsight/core/models/transaction_model.dart';
import 'package:finsight/core/models/category_model.dart';
import 'package:finsight/core/models/notification_model.dart';
import 'package:finsight/core/models/user_model.dart';
import 'package:finsight/core/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  int _selectedRevenuePeriod = 0; // 0: Today, 1: Month, 2: Year
  List<Product> _products = [];
  List<Category> _categories = [];
  List<TransactionModel> _transactions = [];
  List<Map<String, dynamic>> _chartData = [];
  List<NotificationModel> _notifications = [];
  List<UserModel> _staff = [];
  List<Map<String, dynamic>> _restockHistory = [];
  Map<String, dynamic> _appSettings = {};
  bool _isLoading = false;
  double _profitToday = 0;
  double _profitMonth = 0;
  double _profitYear = 0;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<TransactionModel> get transactions => _transactions;
  List<Map<String, dynamic>> get chartData => _chartData;
  List<NotificationModel> get notifications => _notifications;
  List<UserModel> get staff => _staff;
  List<Map<String, dynamic>> get restockHistory => _restockHistory;
  Map<String, dynamic> get appSettings => _appSettings;
  int get selectedRevenuePeriod => _selectedRevenuePeriod;
  double get profitToday => _profitToday;
  double get profitMonth => _profitMonth;
  double get profitYear => _profitYear;

  double get selectedProfit {
    switch (_selectedRevenuePeriod) {
      case 1:
        return profitMonth;
      case 2:
        return profitYear;
      case 0:
      default:
        return profitToday;
    }
  }

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  void setRevenuePeriod(int index) {
    _selectedRevenuePeriod = index;
    updateChartData();
    notifyListeners();
  }

  // Computed properties
  double get revenueToday {
    final now = DateTime.now();
    return _transactions
        .where((t) {
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
        })
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  double get revenueMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        })
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  double get revenueYear {
    final now = DateTime.now();
    return _transactions
        .where((t) {
          return t.date.year == now.year;
        })
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  double get selectedRevenue {
    switch (_selectedRevenuePeriod) {
      case 1:
        return revenueMonth;
      case 2:
        return revenueYear;
      case 0:
      default:
        return revenueToday;
    }
  }

  // Backwards compatibility
  double get totalRevenueToday => revenueToday;

  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchProducts(),
        fetchCategories(),
        fetchTransactions(), // This will now trigger updateChartData
        fetchNotifications(),
        fetchStaff(),
        fetchRestockHistory(),
        syncAppSettings(),
        fetchStats(),
      ]);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      final stats = await _api.getDashboardStats();
      if (stats.containsKey('profit_today')) {
        _profitToday = double.tryParse(stats['profit_today'].toString()) ?? 0.0;
      }
      if (stats.containsKey('profit_month')) {
        _profitMonth = double.tryParse(stats['profit_month'].toString()) ?? 0.0;
      }
      if (stats.containsKey('profit_year')) {
        _profitYear = double.tryParse(stats['profit_year'].toString()) ?? 0.0;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> fetchProducts() async {
    try {
      _products = await _api.getProducts();
      _checkLowStock();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

  void _checkLowStock() {
    for (var product in _products) {
      if (product.stock <= 5) {
        final notificationId = 'low_stock_${product.id}';
        // Check if notification already exists to avoid duplication
        if (!_notifications.any((n) => n.id == notificationId)) {
          final lowStockNotif = NotificationModel(
            id: notificationId,
            title: 'Stok Menipis!',
            message: 'Stok ${product.name} tinggal ${product.stock} unit.',
            type: 'stock',
            isRead: false,
            createdAt: DateTime.now(),
          );
          _notifications.insert(0, lowStockNotif);
        }
        debugPrint('STOK TIPIS: ${product.name}');
      }
    }
  }

  Future<void> fetchTransactions() async {
    try {
      _transactions = await _api.getTransactions();
      updateChartData(); // Call updateChartData after transactions are fetched
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  void updateChartData() {
    _chartData = _generateChartDataFromTransactions();
  }

  Future<void> fetchChartData() async {
    // We prioritize local calculation to match the selected period precisely
    updateChartData();
    notifyListeners();
  }

  List<Map<String, dynamic>> _generateChartDataFromTransactions() {
    final Map<String, double> totals = {};
    final now = DateTime.now();

    if (_selectedRevenuePeriod == 0) {
      // TODAY: Hourly (Show every 3 hours for clarity: 0, 3, 6, 9, 12, 15, 18, 21)
      for (int i = 0; i <= 21; i += 3) {
        totals[i.toString().padLeft(2, '0')] = 0;
      }
      for (var trx in _transactions) {
        if (trx.date.year == now.year &&
            trx.date.month == now.month &&
            trx.date.day == now.day) {
          final hour = (trx.date.hour ~/ 3) * 3;
          final key = hour.toString().padLeft(2, '0');
          totals[key] = (totals[key] ?? 0) + trx.totalAmount;
        }
      }
    } else if (_selectedRevenuePeriod == 1) {
      // MONTH: Daily (All days in current month)
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= lastDay; i++) {
        totals[i.toString().padLeft(2, '0')] = 0;
      }
      for (var trx in _transactions) {
        if (trx.date.year == now.year && trx.date.month == now.month) {
          final key = trx.date.day.toString().padLeft(2, '0');
          totals[key] = (totals[key] ?? 0) + trx.totalAmount;
        }
      }
    } else {
      // YEAR: Monthly (Jan - Dec)
      for (int i = 1; i <= 12; i++) {
        totals[i.toString().padLeft(2, '0')] = 0;
      }
      for (var trx in _transactions) {
        if (trx.date.year == now.year) {
          final key = trx.date.month.toString().padLeft(2, '0');
          totals[key] = (totals[key] ?? 0) + trx.totalAmount;
        }
      }
    }

    final sortedKeys = totals.keys.toList()..sort();
    return sortedKeys.map((key) {
      String label = key;
      if (_selectedRevenuePeriod == 0) label = '$key:00';
      if (_selectedRevenuePeriod == 2) {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        label = months[int.parse(key) - 1];
      }
      return {'day': label, 'total': totals[key]};
    }).toList();
  }

  Future<void> fetchNotifications() async {
    try {
      _notifications = await _api.getNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _api.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchStaff() async {
    try {
      _staff = await _api.getStaff();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching staff: $e');
    }
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    try {
      await _api.addProduct(data);
      await fetchProducts(); // Refresh list
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return false;
    }
  }

  Future<String?> addTransaction(TransactionModel trx) async {
    try {
      // Prepare items for API
      final itemsData = trx.items
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList();

      final newTrx = await _api.createTransaction(
        totalAmount: trx.totalAmount,
        paymentMethod: trx.paymentMethod,
        items: itemsData,
      );

      _transactions.insert(0, newTrx);
      updateChartData();

      // Refresh data secara paralel agar lebih cepat
      await Future.wait([fetchProducts()]);

      notifyListeners();
      return null; // Success
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return e.toString();
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _api.updateProduct(id, data);
      await fetchProducts(); // Refresh list
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _api.deleteProduct(id);
      await fetchProducts(); // Refresh list
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  Future<bool> updateProductStock(String id, int newStock) async {
    try {
      await _api.updateProductStock(id, newStock);
      await fetchProducts(); // Refresh list
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  Future<bool> addStaff(Map<String, dynamic> data) async {
    try {
      await _api.addStaff(data);
      await fetchStaff();
      return true;
    } catch (e) {
      debugPrint('Error adding staff: $e');
      return false;
    }
  }

  Future<bool> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      await _api.updateStaff(id, data);
      await fetchStaff();
      return true;
    } catch (e) {
      debugPrint('Error updating staff: $e');
      return false;
    }
  }

  Future<bool> deleteStaff(String id) async {
    try {
      await _api.deleteStaff(id);
      await fetchStaff();
      return true;
    } catch (e) {
      debugPrint('Error deleting staff: $e');
      return false;
    }
  }

  // Restock logic
  Future<void> fetchRestockHistory() async {
    try {
      _restockHistory = await _api.getRestockHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching restock history: $e');
    }
  }

  Future<bool> addRestock(Map<String, dynamic> data) async {
    try {
      final success = await _api.addRestockHistory(data);
      if (success) {
        await Future.wait([fetchProducts(), fetchRestockHistory()]);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding restock: $e');
      return false;
    }
  }

  // Settings logic
  Future<void> syncAppSettings() async {
    try {
      _appSettings = await _api.getAppSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing settings: $e');
    }
  }

  Future<bool> updateStoreSettings(Map<String, dynamic> settings) async {
    try {
      final success = await _api.updateAppSettings(settings);
      if (success) {
        await syncAppSettings();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating settings: $e');
      return false;
    }
  }
}
