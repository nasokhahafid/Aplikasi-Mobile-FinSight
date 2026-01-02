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
}
