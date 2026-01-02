import 'product_model.dart';

class TransactionItem {
  final Product product;
  int quantity;

  TransactionItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class TransactionModel {
  final String id;
  final DateTime date;
  final List<TransactionItem> items;
  final double totalAmount;
  final String paymentMethod; // Tunai, QRIS, etc

  TransactionModel({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<TransactionItem> itemsList = list.map((i) {
      // Handling if 'product' is null or just an ID
      final productData = i['product'];
      Product product;
      if (productData != null && productData is Map<String, dynamic>) {
        product = Product.fromJson(productData);
      } else {
        // Fallback for missing product detail
        product = Product(
          id: (i['product_id'] ?? 0).toString(),
          name: 'Produk Terhapus',
          price: 0,
          purchasePrice: 0,
          stock: 0,
          category: 'Unknown',
        );
      }

      return TransactionItem(product: product, quantity: i['quantity'] ?? 0);
    }).toList();

    return TransactionModel(
      id: (json['invoice_number'] ?? json['id'] ?? 'unknown').toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      items: itemsList,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'Tunai',
    );
  }
}
