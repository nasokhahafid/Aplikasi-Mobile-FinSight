import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    hide Column, Row; // Hide to avoid conflict with Flutter widgets
import 'package:table_calendar/table_calendar.dart';
import 'package:finsight/core/models/transaction_model.dart';
import 'package:finsight/core/models/event_model.dart';

class ReportProvider extends ChangeNotifier {
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  List<EventModel> _events = [];

  // Calendar States
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  List<TransactionModel> get transactions => _filteredTransactions;
  List<EventModel> get events => _events;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;
  RangeSelectionMode get rangeSelectionMode => _rangeSelectionMode;

  DateTimeRange? get selectedDateRange {
    if (_rangeStart != null && _rangeEnd != null) {
      return DateTimeRange(start: _rangeStart!, end: _rangeEnd!);
    }
    return null;
  }

  // Initialize with transactions (e.g., from DashboardProvider)
  void setTransactions(List<TransactionModel> transactions) {
    _allTransactions = transactions;
    _applyFilter();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _rangeStart = null;
    _rangeEnd = null;
    _rangeSelectionMode = RangeSelectionMode.toggledOff;
    _applyFilter();
    notifyListeners();
  }

  void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    _selectedDay = null;
    _focusedDay = focusedDay;
    _rangeStart = start;
    _rangeEnd = end;
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    _applyFilter();
    notifyListeners();
  }

  void clearFilter() {
    _selectedDay = null;
    _rangeStart = null;
    _rangeEnd = null;
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    _applyFilter();
    notifyListeners();
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  List<EventModel> getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  void _applyFilter() {
    if (_selectedDay != null) {
      // Filter by specific day selected in calendar
      _filteredTransactions = _allTransactions.where((t) {
        return t.date.year == _selectedDay!.year &&
            t.date.month == _selectedDay!.month &&
            t.date.day == _selectedDay!.day;
      }).toList();
    } else if (_rangeStart != null && _rangeEnd != null) {
      // Filter by range
      _filteredTransactions = _allTransactions.where((t) {
        final date = t.date;
        // Start of range (00:00:00)
        final start = DateTime(
          _rangeStart!.year,
          _rangeStart!.month,
          _rangeStart!.day,
        );
        // End of range (23:59:59)
        final end = DateTime(
          _rangeEnd!.year,
          _rangeEnd!.month,
          _rangeEnd!.day,
          23,
          59,
          59,
        );

        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    } else if (_rangeStart != null) {
      // If only start is selected but not end yet, filter that single day
      _filteredTransactions = _allTransactions.where((t) {
        return t.date.year == _rangeStart!.year &&
            t.date.month == _rangeStart!.month &&
            t.date.day == _rangeStart!.day;
      }).toList();
    } else {
      // No filter, show all
      _filteredTransactions = List.from(_allTransactions);
    }
    // Sort by date desc
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalRevenue =>
      _filteredTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);

  // Closing Report Logic (Month being viewed)
  Map<String, dynamic> getMonthlyClosingStats() {
    final targetDate = _focusedDay;
    final monthTransactions = _allTransactions.where((t) {
      return t.date.year == targetDate.year && t.date.month == targetDate.month;
    }).toList();

    double revenue = 0;
    double capital = 0;
    int itemsCount = 0;

    for (var trx in monthTransactions) {
      revenue += trx.totalAmount;
      for (var item in trx.items) {
        capital += (item.buyPrice * item.quantity);
        itemsCount += item.quantity;
      }
    }

    return {
      'month': DateFormat('MMMM yyyy').format(targetDate),
      'revenue': revenue,
      'capital': capital,
      'profit': revenue - capital,
      'transactionCount': monthTransactions.length,
      'itemsCount': itemsCount,
    };
  }

  Future<void> exportToExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Headers
    sheet.getRangeByName('A1').setText('ID Transaksi');
    sheet.getRangeByName('B1').setText('Tanggal');
    sheet.getRangeByName('C1').setText('Total');
    sheet.getRangeByName('D1').setText('Modal');
    sheet.getRangeByName('E1').setText('Keuntungan');
    sheet.getRangeByName('F1').setText('Metode Pembayaran');

    // Data
    for (int i = 0; i < _filteredTransactions.length; i++) {
      final trx = _filteredTransactions[i];

      double capital = 0;
      for (var item in trx.items) {
        capital += (item.buyPrice * item.quantity);
      }
      final profit = trx.totalAmount - capital;

      sheet.getRangeByName('A${i + 2}').setText(trx.id);
      sheet
          .getRangeByName('B${i + 2}')
          .setText(DateFormat('yyyy-MM-dd HH:mm').format(trx.date));
      sheet.getRangeByName('C${i + 2}').setNumber(trx.totalAmount);
      sheet.getRangeByName('D${i + 2}').setNumber(capital);
      sheet.getRangeByName('E${i + 2}').setNumber(profit);
      sheet.getRangeByName('F${i + 2}').setText(trx.paymentMethod);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationDocumentsDirectory()).path;
    final String fileName =
        '$path/Laporan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);

    await OpenFile.open(fileName);
  }
}
