import 'package:flutter/foundation.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class PrinterService {
  BlueThermalPrinter? bluetooth = kIsWeb ? null : BlueThermalPrinter.instance;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<List<BluetoothDevice>> getDevices() async {
    if (kIsWeb || bluetooth == null) return [];
    return await bluetooth!.getBondedDevices();
  }

  Future<bool?> connect(BluetoothDevice device) async {
    if (kIsWeb || bluetooth == null) return false;
    return await bluetooth!.connect(device);
  }

  Future<void> disconnect() async {
    if (kIsWeb || bluetooth == null) return;
    await bluetooth!.disconnect();
  }

  Future<void> printReceipt(TransactionModel transaction) async {
    if (kIsWeb || bluetooth == null) return;
    bool? isConnected = await bluetooth!.isConnected;
    if (isConnected != true) return;

    // Header
    bluetooth!.printCustom("FINSIGHT POS", 3, 1);
    bluetooth!.printCustom("Solusi Keuangan UMKM", 1, 1);
    bluetooth!.printCustom("--------------------------------", 1, 1);

    // Info Transaksi
    bluetooth!.printLeftRight("ID:", transaction.id.substring(0, 8), 1);
    bluetooth!.printLeftRight(
      "Tgl:",
      DateFormat('dd/MM/yy HH:mm').format(transaction.date),
      1,
    );
    bluetooth!.printLeftRight("Metode:", transaction.paymentMethod, 1);
    bluetooth!.printCustom("--------------------------------", 1, 1);

    // Items
    for (var item in transaction.items) {
      bluetooth!.printCustom(item.product.name, 1, 0);
      bluetooth!.printLeftRight(
        "${item.quantity} x ${_currencyFormat.format(item.product.price)}",
        _currencyFormat.format(item.quantity * item.product.price),
        1,
      );
    }

    bluetooth!.printCustom("--------------------------------", 1, 1);

    // Total
    bluetooth!.printLeftRight(
      "TOTAL",
      _currencyFormat.format(transaction.totalAmount),
      2,
    );

    bluetooth!.printCustom("--------------------------------", 1, 1);
    bluetooth!.printCustom("Terima Kasih", 2, 1);
    bluetooth!.printCustom("Sudah Berbelanja!", 1, 1);
    bluetooth!.printNewLine();
    bluetooth!.printNewLine();
    bluetooth!.paperCut();
  }
}
