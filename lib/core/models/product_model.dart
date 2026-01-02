class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double purchasePrice; // Harga Beli
  int stock;
  final String? imageUrl;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.purchasePrice,
    required this.stock,
    this.imageUrl,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      category: json['category'] != null ? json['category']['name'] : 'Umum',
      price: double.parse((json['price'] ?? 0).toString()),
      purchasePrice: double.parse((json['purchase_price'] ?? 0).toString()),
      stock: int.parse((json['stock'] ?? 0).toString()),
      imageUrl: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'purchase_price': purchasePrice,
      'stock': stock,
      'description': description,
    };
  }

  double get profit => price - purchasePrice;
  double get marginPercentage =>
      purchasePrice > 0 ? (profit / purchasePrice) * 100 : 0;
}
