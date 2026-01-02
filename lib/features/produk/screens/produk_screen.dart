import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/models/product_model.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/custom_search_bar.dart';
import '../../../shared/widgets/product_card.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(productId: product.id),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProductFormDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<DashboardProvider>(context);

    final categories = ['Semua', ...service.categories.map((c) => c.name)];
    if (categories.length == 1 && service.categories.isNotEmpty) {
      // Logic handled in spread above
    } else if (categories.length == 1) {
      // Add defaults if empty
      categories.addAll(['Handphone', 'Aksesoris']);
    }

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
        title: const Text('Manajemen Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () {
              // Sort placeholder
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                CustomSearchBar(
                  hintText: 'Cari produk...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSpacing.md),

                // Categories
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
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Belum ada produk',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      80, // Space for FAB
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70, // Slightly taller for info
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _showProductDetail(product),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final String productId;

  const _ProductDetailSheet({required this.productId});

  void _handleDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirm dialog

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menghapus produk...')),
              );

              final service = Provider.of<DashboardProvider>(
                context,
                listen: false,
              );
              final success = await service.deleteProduct(product.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (success) {
                  Navigator.pop(context); // Close detail sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus produk'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _handleEdit(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DashboardProvider>();
    Product? product;
    try {
      product = service.products.firstWhere((p) => p.id == productId);
    } catch (_) {
      product = null;
    }

    if (product == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipOval(
                        child:
                            product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: AppColors.textTertiary,
                                    ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl2),
                const Divider(),
                const SizedBox(height: AppSpacing.xl2),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _DetailStatItem(
                        label: 'Harga Jual',
                        value: CurrencyFormatter.format(product.price),
                        icon: Icons.sell_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _DetailStatItem(
                        label: 'Harga Beli',
                        value: CurrencyFormatter.format(product.purchasePrice),
                        icon: Icons.shopping_bag_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _DetailStatItem(
                        label: 'Stok Tersedia',
                        value: '${product.stock} Unit',
                        icon: Icons.inventory_2_rounded,
                        color: product.stock < 10
                            ? AppColors.error
                            : AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _DetailStatItem(
                        label: 'Profit / Margin',
                        value:
                            '${CurrencyFormatter.format(product.profit)} (${product.marginPercentage.toStringAsFixed(1)}%)',
                        icon: Icons.trending_up_rounded,
                        color: product.profit >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl3),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleEdit(context, product!),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Update Stock Logic handled in StokScreen
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add_box_rounded),
                        label: const Text('Update Stok'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _handleDelete(context, product!),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Hapus Produk'),
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

class _DetailStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController purchasePriceController; // Harga Beli
  late TextEditingController stockController;
  late TextEditingController descController;
  int? selectedCategoryId;
  String? selectedImagePath;
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameController = TextEditingController(text: p?.name);

    // Format prices: remove trailing .0 for cleaner display
    String formatPrice(double? price) {
      if (price == null) return '';
      if (price == price.toInt()) return price.toInt().toString();
      return price.toString();
    }

    priceController = TextEditingController(text: formatPrice(p?.price));
    purchasePriceController = TextEditingController(
      text: formatPrice(p?.purchasePrice),
    );
    stockController = TextEditingController(text: p?.stock.toString());
    descController = TextEditingController(text: p?.description);

    if (p?.imageUrl != null && p!.imageUrl!.isNotEmpty) {
      if (!p.imageUrl!.startsWith('http')) {
        selectedImagePath = p.imageUrl;
      }
    }

    // Initialize category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final service = Provider.of<DashboardProvider>(context, listen: false);
        if (p != null &&
            service.categories.isNotEmpty &&
            selectedCategoryId == null) {
          try {
            final cat = service.categories.firstWhere(
              (c) => c.name == p.category,
              orElse: () => service.categories.first,
            );
            setState(() {
              selectedCategoryId = cat.id;
            });
          } catch (_) {}
        }
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    purchasePriceController.dispose();
    stockController.dispose();
    descController.dispose();
    super.dispose();
  }

  double _parsePrice(String text) {
    // Remove thousand separators (Indonesia often uses dots)
    final sanitized = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(sanitized) ?? 0.0;
  }

  // ... (keeping _pickImage and _showImagePickerOptions same)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<DashboardProvider>(context);
    final isEdit = widget.product != null;

    // Profit calculation for preview
    double salePrice = _parsePrice(priceController.text);
    double buyPrice = _parsePrice(purchasePriceController.text);
    double profit = salePrice - buyPrice;
    double margin = buyPrice > 0 ? (profit / buyPrice) * 100 : 0;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Picker Section
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    image: selectedImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(selectedImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : (widget.product?.imageUrl != null &&
                                  widget.product!.imageUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    widget.product!.imageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                )
                              : null),
                  ),
                  child:
                      (selectedImagePath == null &&
                          (widget.product?.imageUrl == null ||
                              widget.product!.imageUrl!.isEmpty))
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pilih Foto Produk',
                              style: TextStyle(color: AppColors.textTertiary),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Kategori'),
                value: selectedCategoryId,
                items: service.categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedCategoryId = value),
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: purchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Beli (Modal)',
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Jual',
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Profit Preview
              if (buyPrice > 0 && salePrice > 0)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: (profit >= 0 ? AppColors.success : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimasi Profit:',
                        style: TextStyle(
                          fontSize: 12,
                          color: profit >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.format(profit)} (${margin.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: profit >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (formKey.currentState!.validate()) {
                    setState(() => isLoading = true);

                    try {
                      bool success = false;
                      final data = {
                        'name': nameController.text,
                        'category_id': selectedCategoryId,
                        'price': _parsePrice(priceController.text),
                        'purchase_price': _parsePrice(
                          purchasePriceController.text,
                        ),
                        'stock': int.tryParse(stockController.text) ?? 0,
                        'description': descController.text,
                        'image': selectedImagePath,
                      };

                      if (isEdit) {
                        success = await service.updateProduct(
                          widget.product!.id,
                          data,
                        );
                      } else {
                        success = await service.addProduct(data);
                      }

                      if (mounted) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Produk berhasil diupdate'
                                    : 'Produk berhasil ditambahkan',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Gagal update produk'
                                    : 'Gagal tambah produk',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Error saving product: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Terjadi kesalahan: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => isLoading = false);
                      }
                    }
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }
}
