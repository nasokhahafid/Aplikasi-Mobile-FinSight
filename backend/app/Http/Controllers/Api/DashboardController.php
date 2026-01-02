<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Product;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function stats()
    {
        $today = now()->startOfDay();

        $revenueToday = Transaction::where('date', '>=', $today)->sum('total_amount');
        $txnToday = Transaction::where('date', '>=', $today)->count();
        $totalProducts = Product::where('is_active', true)->count();
        $lowStock = Product::where('stock', '<', 10)->where('is_active', true)->count();

        return response()->json([
            'revenue_today' => $revenueToday,
            'transaction_count_today' => $txnToday,
            'total_products' => $totalProducts,
            'low_stock_count' => $lowStock,
            'profit_today' => $this->calculateProfit($today),
            'profit_month' => $this->calculateProfit(now()->startOfMonth()),
            'profit_year' => $this->calculateProfit(now()->startOfYear()),
        ]);
    }

    public function chart()
    {
        $data = [];
        // Get last 7 days
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i)->format('Y-m-d');
            $revenue = Transaction::whereDate('date', '=', $date)->sum('total_amount');

            $data[] = [
                'date' => $date,
                'day' => now()->subDays($i)->locale('id')->dayName, // Requires Carbon locale set or handle in Flutter
                'revenue' => $revenue
            ];
        }

        return response()->json($data);
    }
    private function calculateProfit($date)
    {
        // Opsi 1: Hitung Real Profit dari Database (Per Item)
        // Profit = Total (Harga Jual per item - Harga Beli per item) * Quantity

        // Menggunakan query Builder untuk performa & akurasi
        $realProfit = \Illuminate\Support\Facades\DB::table('transaction_items')
            ->join('transactions', 'transaction_items.transaction_id', '=', 'transactions.id')
            ->where('transactions.date', '>=', $date)
            ->sum(\Illuminate\Support\Facades\DB::raw('(transaction_items.price - transaction_items.buy_price) * transaction_items.quantity'));

        return $realProfit;
    }
}
