import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:finsight/core/models/transaction_model.dart';

class ExportService {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Future<void> exportToPdf({
    required List<TransactionModel> transactions,
    required String title,
    required Map<String, dynamic> stats,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title),
          pw.SizedBox(height: 20),
          _buildStats(stats),
          pw.SizedBox(height: 20),
          _buildTable(transactions),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    final bytes = await pdf.save();

    // Preview & Print Option
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Laporan_FinSight_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FinSight - Laporan Keuangan',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(title, style: const pw.TextStyle(fontSize: 16)),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildStats(Map<String, dynamic> stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          _buildStatRow(
            'Total Pendapatan',
            _currencyFormat.format(stats['revenue']),
          ),
          _buildStatRow(
            'Total Modal',
            _currencyFormat.format(stats['capital']),
          ),
          pw.Divider(color: PdfColors.grey300),
          _buildStatRow(
            'Total Laba Bersih',
            _currencyFormat.format(stats['profit']),
            isBold: true,
          ),
          _buildStatRow('Jumlah Transaksi', '${stats['transactionCount']}'),
        ],
      ),
    );
  }

  static pw.Widget _buildStatRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            value,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(List<TransactionModel> transactions) {
    final headers = ['Waktu', 'ID Transaksi', 'Metode', 'Total'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: transactions.map((t) {
        return [
          DateFormat('dd/MM HH:mm').format(t.date),
          t.id.substring(0, 8),
          t.paymentMethod,
          _currencyFormat.format(t.totalAmount),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }
}
