import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_design_system.dart';
import '../../core/utils/currency_formatter.dart';

// Circular Menu Card Widget
class CircularMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const CircularMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Summary Item Widget (for new card design)
class SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;
  final bool isCompact;
  final Widget? trailing;

  const SummaryItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.isCompact = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(icon, color: iconColor, size: isCompact ? 20 : 28),
        ),
        const SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isCompact ? 11 : 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isCompact ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitleColor ?? AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SalesChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String? title;

  const SalesChartWidget({super.key, required this.data, this.title});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(child: Text('Data penjualan belum tersedia')),
      );
    }

    // Process data for charts
    final spots = data.asMap().entries.map((entry) {
      final value = entry.value;
      double yValue = 0;
      try {
        yValue = double.parse((value['total'] ?? 0).toString());
      } catch (e) {
        debugPrint('Error parsing chart value: $e');
      }
      return FlSpot(entry.key.toDouble(), yValue);
    }).toList();

    // Ensure we have at least 2 points for a line chart to look good
    if (spots.length < 2) {
      // Add a dummy zero point if only one exists
      if (spots.length == 1) {
        spots.insert(0, const FlSpot(-1, 0));
      }
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'Tren Penjualan (7 Hari Terakhir)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: AppColors.borderLight, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= data.length)
                          return const SizedBox();

                        // Optimization: Hide some labels if there's too much data
                        if (data.length > 20 && index % 5 != 0) {
                          return const SizedBox();
                        } else if (data.length > 10 &&
                            data.length <= 20 &&
                            index % 2 != 0) {
                          return const SizedBox();
                        }
                        // Parse date from API data (usually YYYY-MM-DD or day name)
                        String dayLabel = data[index]['day'].toString();
                        if (dayLabel.length > 5) {
                          // Try to format if it's a date string
                          try {
                            final date = DateTime.parse(dayLabel);
                            dayLabel = DateFormat('dd/MM').format(date);
                          } catch (_) {}
                        }

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            dayLabel,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value >= 1000000
                                ? '${(value / 1000000).toStringAsFixed(1)}jt'
                                : value >= 1000
                                ? '${(value / 1000).toInt()}k'
                                : value.toString(),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: AppColors.primaryGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          CurrencyFormatter.format(spot.y),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
