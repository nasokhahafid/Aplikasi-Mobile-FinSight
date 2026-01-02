<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index()
    {
        $transactions = Transaction::with(['items.product', 'user'])
            ->orderBy('date', 'desc')
            ->paginate(20);

        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'total_amount' => 'required|numeric',
            'payment_method' => 'required|string',
        ]);

        // We use DB Transaction to ensure data integrity
        try {
            DB::beginTransaction();

            $transaction = Transaction::create([
                'invoice_number' => 'TRX-' . time(),
                'user_id' => $request->user()->id ?? 1, // Fallback for testing
                'total_amount' => $request->total_amount,
                'payment_method' => $request->payment_method,
                'status' => 'completed',
                'date' => now(),
            ]);

            foreach ($request->items as $item) {
                $product = Product::lockForUpdate()->find($item['product_id']);

                if (!$product) {
                    throw new \Exception("Product ID {$item['product_id']} not found");
                }

                // Create Item
                TransactionItem::create([
                    'transaction_id' => $transaction->id,
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'price' => $product->price,
                    'buy_price' => $product->purchase_price ?? 0, // Snapshot current purchase price
                    'subtotal' => $product->price * $item['quantity'],
                ]);

                // Deduction Stock
                $product->decrement('stock', $item['quantity']);
            }

            DB::commit();

            return response()->json($transaction->load('items'), 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }
}
