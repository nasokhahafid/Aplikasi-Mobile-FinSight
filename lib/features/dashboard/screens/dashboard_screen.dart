import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finsight/core/constants/app_design_system.dart';
import 'package:finsight/core/providers/dashboard_provider.dart';
import 'package:finsight/core/utils/currency_formatter.dart';
import 'package:finsight/shared/widgets/dashboard_widgets.dart';
import 'package:finsight/core/services/notification_service.dart';
import 'package:finsight/features/kasir/screens/kasir_screen.dart';
import 'package:finsight/features/produk/screens/produk_screen.dart';
import 'package:finsight/features/stok/screens/stok_screen.dart';
import 'package:finsight/features/laporan/screens/laporan_screen.dart';
import 'package:finsight/features/staff/screens/staff_screen.dart';
import 'package:finsight/features/pengaturan/screens/pengaturan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _ownerName = 'Owner';
  String _storeName = 'Toko FinSight';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _scheduleDailyReport();
  }

  void _scheduleDailyReport() {
    NotificationService.scheduleDailyReportNotification(
      hour: 21,
      minute: 0,
      title: 'Laporan Penjualan Hari Ini',
      body: 'Waktunya cek omzet hari ini! Klik untuk melihat performa tokomu.',
    );
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _ownerName = prefs.getString('ownerName') ?? 'Owner';
        _storeName = prefs.getString('storeName') ?? 'Toko FinSight';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<DashboardProvider>(context);
    final now = DateTime.now();
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl2),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.xl3),
                      bottomRight: Radius.circular(AppRadius.xl3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo & Title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Saldo Usaha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                      service.totalRevenueToday,
                                    ), // Or total balance if available
                                    style: const TextStyle(
                                      fontSize:
                                          16, // Smaller than title but visible
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Notification Icon
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Show notifications
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      _NotificationSheet(service: service),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                                child: Badge(
                                  isLabelVisible:
                                      service.unreadNotificationCount > 0,
                                  label: Text(
                                    '${service.unreadNotificationCount}',
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl2),

                      // Greeting
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _storeName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Date
                      Text(
                        _formatDate(now),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Summary Section
                    const Text(
                      'Ringkasan Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Summary Cards - Redesigned
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl2),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppShadow.sm,
                      ),
                      child: Column(
                        children: [
                          // Total Penjualan - with Switcher
                          SummaryItem(
                            icon: Icons.trending_up_rounded,
                            iconColor: AppColors.secondary,
                            iconBgColor: AppColors.secondary.withOpacity(0.1),
                            title: service.selectedRevenuePeriod == 0
                                ? 'Total Penjualan Hari Ini'
                                : service.selectedRevenuePeriod == 1
                                ? 'Total Penjualan Bulan Ini'
                                : 'Total Penjualan Tahun Ini',
                            value: CurrencyFormatter.format(
                              service.selectedRevenue,
                            ),
                            subtitle: service.selectedRevenuePeriod == 0
                                ? '+12.5%'
                                : null, // Could hide or change comparison
                            subtitleColor: AppColors.success,
                            trailing: PopupMenuButton<int>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              onSelected: service.setRevenuePeriod,
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 0,
                                  child: Text('Hari Ini'),
                                ),
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('Bulan Ini'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Tahun Ini'),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: AppSpacing.xl),

                          // Profit Item
                          SummaryItem(
                            icon: Icons.monetization_on_rounded,
                            iconColor: AppColors.success,
                            iconBgColor: AppColors.success.withOpacity(0.1),
                            title: service.selectedRevenuePeriod == 0
                                ? 'Keuntungan (Hari Ini)'
                                : service.selectedRevenuePeriod == 1
                                ? 'Keuntungan (Bulan Ini)'
                                : 'Keuntungan (Tahun Ini)',
                            value: CurrencyFormatter.format(
                              service.selectedProfit,
                            ),
                            subtitle: service.selectedRevenuePeriod == 0
                                ? 'Margin bersih dari transaksi hari ini'
                                : service.selectedRevenuePeriod == 1
                                ? 'Margin bersih bulan ini'
                                : 'Margin bersih tahun ini',
                            subtitleColor: AppColors.textSecondary,
                          ),
                          const Divider(height: AppSpacing.xl),

                          // Row for Transaksi and Produk
                          Row(
                            children: [
                              Expanded(
                                child: SummaryItem(
                                  icon: Icons.receipt_long_rounded,
                                  iconColor: AppColors.accent,
                                  iconBgColor: AppColors.accent.withOpacity(
                                    0.1,
                                  ),
                                  title: 'Transaksi',
                                  value: service.transactions
                                      .where(
                                        (t) =>
                                            t.date.day == now.day &&
                                            t.date.month == now.month,
                                      )
                                      .length
                                      .toString(),
                                  isCompact: true,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 60,
                                color: AppColors.borderLight,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                              ),
                              Expanded(
                                child: SummaryItem(
                                  icon: Icons.inventory_2_rounded,
                                  iconColor: AppColors.warning,
                                  iconBgColor: AppColors.warning.withOpacity(
                                    0.1,
                                  ),
                                  title: 'Total Produk',
                                  value: service.products.length.toString(),
                                  subtitle:
                                      '${service.products.where((p) => p.stock < 10).length} stok menipis',
                                  subtitleColor: AppColors.error,
                                  isCompact: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SalesChartWidget(
                      data: service.chartData,
                      title: service.selectedRevenuePeriod == 0
                          ? 'Tren Penjualan (Hari Ini)'
                          : service.selectedRevenuePeriod == 1
                          ? 'Tren Penjualan (Bulan Ini)'
                          : 'Tren Penjualan (Tahun Ini)',
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    // Menu Section
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Menu Grid - 4 Columns Circular
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.85,
                      children: [
                        CircularMenuCard(
                          title: 'Kasir',
                          icon: Icons.point_of_sale_rounded,
                          gradient: AppColors.secondaryGradient,
                          onTap: () =>
                              _navigateTo(context, const KasirScreen()),
                        ),
                        CircularMenuCard(
                          title: 'Produk',
                          icon: Icons.inventory_2_rounded,
                          gradient: AppColors.accentGradient,
                          onTap: () =>
                              _navigateTo(context, const ProdukScreen()),
                        ),
                        CircularMenuCard(
                          title: 'Stok',
                          icon: Icons.warehouse_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          onTap: () => _navigateTo(context, const StokScreen()),
                        ),
                        CircularMenuCard(
                          title: 'Laporan',
                          icon: Icons.analytics_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          ),
                          onTap: () =>
                              _navigateTo(context, const LaporanScreen()),
                        ),
                        CircularMenuCard(
                          title: 'Staff',
                          icon: Icons.people_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                          ),
                          onTap: () =>
                              _navigateTo(context, const StaffScreen()),
                        ),
                        CircularMenuCard(
                          title: 'Pengaturan',
                          icon: Icons.settings_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF64748B), Color(0xFF475569)],
                          ),
                          onTap: () =>
                              _navigateTo(context, const PengaturanScreen()),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl2),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting = '';
    if (hour < 12) {
      timeGreeting = 'Selamat Pagi';
    } else if (hour < 15) {
      timeGreeting = 'Selamat Siang';
    } else if (hour < 18) {
      timeGreeting = 'Selamat Sore';
    } else {
      timeGreeting = 'Selamat Malam';
    }
    return '$timeGreeting, $_ownerName';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _NotificationSheet extends StatelessWidget {
  final DashboardProvider service;

  const _NotificationSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: service.notifications.isEmpty
                ? const Center(child: Text('Tidak ada notifikasi'))
                : ListView.builder(
                    itemCount: service.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = service.notifications[index];
                      // Use a safe color or default if type is unknown
                      IconData icon;
                      Color color;
                      switch (notif.type) {
                        case 'transaction':
                          icon = Icons.receipt;
                          color = Colors.green;
                          break;
                        case 'stock':
                          icon = Icons.inventory;
                          color = Colors.orange;
                          break;
                        default:
                          icon = Icons.info;
                          color = Colors.blue;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notif.isRead
                              ? Colors.grey[300]
                              : color.withOpacity(0.2),
                          child: Icon(
                            icon,
                            color: notif.isRead ? Colors.grey : color,
                          ),
                        ),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notif.message),
                        trailing: Text(
                          _timeAgo(notif.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }
}
