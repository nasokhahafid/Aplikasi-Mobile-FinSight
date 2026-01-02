import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../../../shared/widgets/product_card.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final List<TransactionItem> _cart = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  void _addToCart(Product product) {
    // Validasi stok habis
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} stok habis!'),
          backgroundColor: AppColors.error,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      );
      return;
    }

    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        // Validasi jika quantity di cart + 1 melebihi stok
        final currentQtyInCart = _cart[index].quantity;
        if (currentQtyInCart >= product.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stok ${product.name} tidak mencukupi! (Tersedia: ${product.stock})',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          );
          return;
        }
        _cart[index].quantity++;
      } else {
        _cart.add(TransactionItem(product: product));
      }
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }

  double get _totalAmount {
    return _cart.fold(0, (sum, item) => sum + item.total);
  }

  int get _totalItems {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartBottomSheet(
        cart: _cart,
        onQuantityChanged: (item, delta) {
          setState(() {
            item.quantity += delta;
            if (item.quantity <= 0) {
              _cart.remove(item);
            }
          });
          Navigator.pop(context);
          if (_cart.isNotEmpty) {
            _showCart();
          }
        },
        onCheckout: _handleCheckout,
        totalAmount: _totalAmount,
      ),
    );
  }

  void _handleCheckout() {
    if (_cart.isEmpty) return;

    final screenContext = context;

    showDialog(
      context: screenContext,
      builder: (dialogContext) => _PaymentDialog(
        totalAmount: _totalAmount,
        onPaymentConfirmed: (method) async {
          // Tutup dialog pembayaran menggunakan context dialog itu sendiri
          Navigator.pop(dialogContext);

          // Tampilkan loading di atas screen context
          showDialog(
            context: screenContext,
            barrierDismissible: false,
            builder: (ctx) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memproses Transaksi...'),
                    ],
                  ),
                ),
              ),
            ),
          );

          try {
            final service = Provider.of<DashboardProvider>(
              screenContext,
              listen: false,
            );
            final transaction = TransactionModel(
              id: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
              date: DateTime.now(),
              items: List.from(_cart),
              totalAmount: _totalAmount,
              paymentMethod: method,
            );

            final error = await service.addTransaction(transaction);

            if (mounted) {
              // Tutup Loading Dialog
              Navigator.of(screenContext).pop();

              if (error == null) {
                // Tutup Cart Sheet (jika masih terbuka)
                if (Navigator.canPop(screenContext)) {
                  Navigator.of(screenContext).pop();
                }

                // Beri sedikit jeda agar animasi pop selesai sebelum dialog baru muncul
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    _showSuccessDialog(transaction);
                  }
                });

                setState(() => _cart.clear());
              } else {
                ScaffoldMessenger.of(screenContext).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(screenContext).pop(); // Tutup Loading
              ScaffoldMessenger.of(screenContext).showSnackBar(
                SnackBar(
                  content: Text('Koneksi Gagal: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showSuccessDialog(TransactionModel transaction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Total: ${CurrencyFormatter.format(transaction.totalAmount)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),

              // Print Options
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Simulate Printing
                        Navigator.pop(context);
                        _showReceiptPreview(transaction);
                      },
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Cetak Struk'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptPreview(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipt Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 40,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toko FinSight',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const Text(
                      'Jl. FinSight No. 1, Jakarta',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      color: Colors.black54,
                      thickness: 1.5,
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TGL: ${transaction.date.toString().substring(0, 10)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                        Text(
                          'JAM: ${transaction.date.toString().substring(11, 16)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'NO: ${transaction.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dashed Line
              CustomPaint(
                painter: _DashedLinePainter(),
                size: const Size(double.infinity, 1),
              ),

              // Items
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: transaction.items.length,
                  itemBuilder: (context, index) {
                    final item = transaction.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              item.product.name,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'x${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              CurrencyFormatter.format(
                                item.total,
                              ).replaceAll('Rp', ''),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dashed Line
              CustomPaint(
                painter: _DashedLinePainter(),
                size: const Size(double.infinity, 1),
              ),

              // Totals
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(
                            transaction.totalAmount,
                          ).replaceAll('Rp', ''),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PEMBAYARAN',
                          style: TextStyle(fontSize: 12, fontFamily: 'Courier'),
                        ),
                        Text(
                          transaction.paymentMethod,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Terima Kasih!',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _simulatePrintingProcess();
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Cetak Sekarang'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup Preview'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulatePrintingProcess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Struk berhasil dicetak ke printer thermal'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            );
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<DashboardProvider>(context);

    final categories = [
      'Semua',
      'Handphone',
      'Aksesoris',
      'Pulsa & Data',
      'Service',
    ];

    final filteredProducts = service.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kasir'),
        actions: [
          // Cart Button with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_rounded),
                onPressed: _cart.isEmpty ? null : _showCart,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$_totalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Bar
                CustomSearchBar(
                  hintText: 'Cari produk...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),

                const SizedBox(height: AppSpacing.md),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.secondary.withValues(
                            alpha: 0.15,
                          ),
                          checkmarkColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: product.stock > 0
                            ? () => _addToCart(product)
                            : null, // Disable tap jika stok habis
                      );
                    },
                  ),
          ),
        ],
      ),

      // Floating Cart Summary (when cart has items)
      floatingActionButton: _cart.isNotEmpty
          ? Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: InkWell(
                  onTap: _showCart,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl2,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            '$_totalItems',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Text(
                          'Lihat Keranjang',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          CurrencyFormatter.format(_totalAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Cart Bottom Sheet
class _CartBottomSheet extends StatelessWidget {
  final List<TransactionItem> cart;
  final Function(TransactionItem, int) onQuantityChanged;
  final VoidCallback onCheckout;
  final double totalAmount;

  const _CartBottomSheet({
    required this.cart,
    required this.onQuantityChanged,
    required this.onCheckout,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl2),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keranjang Belanja',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              CurrencyFormatter.format(item.product.price),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Controls
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                            onPressed: () => onQuantityChanged(item, -1),
                            color: AppColors.error,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            onPressed: item.quantity >= item.product.stock
                                ? null // Disable jika sudah mencapai stok maksimal
                                : () => onQuantityChanged(item, 1),
                            color: item.quantity >= item.product.stock
                                ? AppColors.textTertiary
                                : AppColors.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Total & Checkout
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: AppShadow.lg,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalAmount),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Bayar Sekarang'),
                        SizedBox(width: AppSpacing.sm),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Dialog
class _PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final Function(String) onPaymentConfirmed;

  const _PaymentDialog({
    required this.totalAmount,
    required this.onPaymentConfirmed,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  String _selectedMethod = 'Tunai';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Tunai',
      'icon': Icons.payments_rounded,
      'color': AppColors.secondary,
    },
    {'name': 'QRIS', 'icon': Icons.qr_code_rounded, 'color': AppColors.accent},
    {
      'name': 'E-Wallet',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.warning,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // Payment Methods
            ..._paymentMethods.map((method) {
              final isSelected = method['name'] == _selectedMethod;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedMethod = method['name']),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (method['color'] as Color).withValues(alpha: 0.1)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? method['color']
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: (method['color'] as Color).withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              method['icon'],
                              color: method['color'],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: method['color'],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl2),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.onPaymentConfirmed(_selectedMethod),
                child: const Text('Konfirmasi Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
