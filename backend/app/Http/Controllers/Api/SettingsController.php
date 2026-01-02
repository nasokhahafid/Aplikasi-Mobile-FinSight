<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SettingsController extends Controller
{
    public function exportData()
    {
        $data = [
            'users' => User::all(),
            'categories' => Category::all(),
            'products' => Product::all(),
            'transactions' => Transaction::with('items.product')->get(),
        ];

        return response()->json([
            'version' => '1.0',
            'timestamp' => now()->toDateTimeString(),
            'data' => $data
        ]);
    }

    public function importData(Request $request)
    {
        $request->validate([
            'data' => 'required|array',
        ]);

        $data = $request->input('data');

        try {
            DB::beginTransaction();

            // Clear existing data (Be careful! This is a complete restore)
            // Or we can just upsert/merge. For full restore, we clear first.

            if (isset($data['categories'])) {
                Category::truncate();
                foreach ($data['categories'] as $cat) {
                    Category::create($cat);
                }
            }

            if (isset($data['products'])) {
                Product::truncate();
                foreach ($data['products'] as $prod) {
                    Product::create($prod);
                }
            }

            // Note: Transactions and users are more sensitive.
            // Usually we don't truncate users during restore to avoid logout of current user.

            DB::commit();
            return response()->json(['message' => 'Data imported successfully']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Import failed: ' . $e->getMessage()], 500);
        }
    }
}
