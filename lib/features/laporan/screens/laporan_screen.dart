import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/providers/report_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/event_model.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportProvider(),
      child: const _LaporanScreenContent(),
    );
  }
}

class _LaporanScreenContent extends StatefulWidget {
  const _LaporanScreenContent();

  @override
  State<_LaporanScreenContent> createState() => _LaporanScreenContentState();
}

class _LaporanScreenContentState extends State<_LaporanScreenContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboard = Provider.of<DashboardProvider>(context, listen: false);
      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).setTransactions(dashboard.transactions);
    });
  }

  void _showAddEventDialog(DateTime date) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Agenda - ${DateFormat('dd MMM').format(date)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Nama Agenda'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newEvent = EventModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descController.text,
                  date: date,
                );
                Provider.of<ReportProvider>(
                  context,
                  listen: false,
                ).addEvent(newEvent);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = Provider.of<ReportProvider>(context);

    // Dynamic title for summary
    String summaryTitle = 'Total Pendapatan';
    String filterInfo = 'Semua Periode';

    if (report.rangeStart != null && report.rangeEnd != null) {
      summaryTitle = 'Pendapatan Periode';
      filterInfo =
          '${DateFormat('dd MMM').format(report.rangeStart!)} - ${DateFormat('dd MMM yyyy').format(report.rangeEnd!)}';
    } else if (report.selectedDay != null) {
      summaryTitle =
          'Pendapatan ${DateFormat('dd MMM').format(report.selectedDay!)}';
      filterInfo = DateFormat('dd MMMM yyyy').format(report.selectedDay!);
    } else if (report.rangeStart != null) {
      summaryTitle =
          'Pendapatan ${DateFormat('dd MMM').format(report.rangeStart!)}';
      filterInfo = DateFormat('dd MMMM yyyy').format(report.rangeStart!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan & Kalender'),
        actions: [
          if (report.selectedDay != null || report.rangeStart != null)
            IconButton(
              tooltip: 'Hapus Filter',
              icon: const Icon(Icons.filter_alt_off_rounded),
              onPressed: () {
                report.clearFilter();
              },
            ),
          IconButton(
            tooltip: 'Tutup Buku Bulan Ini',
            icon: const Icon(
              Icons.assignment_turned_in_rounded,
              color: AppColors.secondary,
            ),
            onPressed: () {
              _showClosingReportDialog(context, report);
            },
          ),
          IconButton(
            tooltip: 'Export Excel',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              report.exportToExcel();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengexport laporan...')),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calendar Section (Filter Primary)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadow.sm,
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: report.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(report.selectedDay, day),
                rangeStartDay: report.rangeStart,
                rangeEndDay: report.rangeEnd,
                rangeSelectionMode: report.rangeSelectionMode,
                onDaySelected: report.onDaySelected,
                onRangeSelected: report.onRangeSelected,
                onPageChanged: (focusedDay) {
                  report.setFocusedDay(focusedDay);
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor: AppColors.primary.withValues(alpha: 0.1),
                  rangeStartDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  withinRangeTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  rangeStartTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  rangeEndTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                eventLoader: (day) => report.getEventsForDay(day),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Combined Summary Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadow.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        summaryTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          filterInfo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CurrencyFormatter.format(
                      report.transactions.fold(
                        0.0,
                        (sum, item) => sum + item.totalAmount,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _SummaryStat(
                        icon: Icons.receipt_long_rounded,
                        label: 'Transaksi',
                        value: '${report.transactions.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl2),

            if (report.selectedDay != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal & Agenda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddEventDialog(report.selectedDay!),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Agenda'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (report.getEventsForDay(report.selectedDay!).isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Text(
                      'Tidak ada agenda khusus',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                )
              else
                ...report
                    .getEventsForDay(report.selectedDay!)
                    .map(
                      (event) => Card(
                        elevation: 0,
                        color: AppColors.surface,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.accent.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.event_note_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(event.description),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => report.removeEvent(event.id),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: AppSpacing.xl),
            ],

            Text(
              report.selectedDay != null
                  ? 'Transaksi Hari Ini'
                  : 'Riwayat Transaksi',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            report.transactions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Tidak ada transaksi untuk periode ini'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: report.transactions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final transaction = report.transactions[index];
                      return InkWell(
                        onTap: () {
                          _showTransactionDetail(context, transaction);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.xs,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              transaction.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'dd MMM, HH:mm',
                              ).format(transaction.date),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(
                                    transaction.totalAmount,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                Text(
                                  transaction.paymentMethod,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: AppSpacing.xl6),
          ],
        ),
      ),
    );
  }

  void _showClosingReportDialog(BuildContext context, ReportProvider report) {
    final stats = report.getMonthlyClosingStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            const Icon(Icons.analytics_rounded, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('Tutup Buku ${stats['month']}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildClosingRow('Total Transaksi', '${stats['transactionCount']}'),
            _buildClosingRow('Produk Terjual', '${stats['itemsCount']} item'),
            const Divider(height: 24),
            _buildClosingRow(
              'Total Omzet',
              CurrencyFormatter.format(stats['revenue']),
              isBold: true,
            ),
            _buildClosingRow(
              'Total Modal',
              CurrencyFormatter.format(stats['capital']),
              color: AppColors.error,
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: _buildClosingRow(
                'Keuntungan Bersih',
                CurrencyFormatter.format(stats['profit']),
                isBold: true,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              report.exportToExcel();
              Navigator.pop(context);
            },
            child: const Text('Simpan & Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
              fontSize: isBold ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionModel trx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl2),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Printing... (Simulated)'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              Text('ID: ${trx.id}'),
              Text(
                'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(trx.date)}',
              ),
              Text('Metode: ${trx.paymentMethod}'),
              const SizedBox(height: 10),
              const Text(
                'Item:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...trx.items.map(
                (item) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.product.name} x${item.quantity}'),
                    Text(
                      CurrencyFormatter.format(
                        item.product.price * item.quantity,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    CurrencyFormatter.format(trx.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
