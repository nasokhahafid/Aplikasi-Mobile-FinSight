import 'package:flutter/material.dart';
import 'package:finsight/core/constants/app_design_system.dart';
import 'package:finsight/core/models/product_model.dart';
import 'package:finsight/core/utils/currency_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showStock;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showStock = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock < 10;
    final isOutOfStock = product.stock <= 0;

    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: isOutOfStock ? 0.5 : 1.0,
        child: InkWell(
          onTap: isOutOfStock ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isOutOfStock
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.borderLight,
                width: isOutOfStock ? 2 : 1,
              ),
              boxShadow: isOutOfStock ? [] : AppShadow.sm,
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image/Icon
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withValues(alpha: 0.1),
                              AppColors.accent.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.xl),
                          ),
                        ),
                        child:
                            product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppRadius.xl),
                                ),
                                child: Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          size: 56,
                                          color: AppColors.secondary.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  _getCategoryIcon(product.category),
                                  size: 56,
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Price
                          Text(
                            CurrencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: -0.5,
                            ),
                          ),

                          if (showStock) ...[
                            const SizedBox(height: AppSpacing.sm),

                            // Stock Indicator
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? AppColors.error
                                        : isLowStock
                                        ? AppColors.warning
                                        : AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isOutOfStock
                                      ? 'HABIS'
                                      : 'Stok: ${product.stock}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOutOfStock
                                        ? AppColors.error
                                        : isLowStock
                                        ? AppColors.warning
                                        : AppColors.textSecondary,
                                    fontWeight: isOutOfStock || isLowStock
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Profit Badge
                if (product.profit > 0)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: AppShadow.sm,
                      ),
                      child: Text(
                        '+${product.marginPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Out of Stock Overlay
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text(
                            'STOK HABIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant_rounded;
      case 'minuman':
        return Icons.local_cafe_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }
}
