<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RestockHistory;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RestockHistoryController extends Controller
{
    public function index()
    {
        $history = RestockHistory::with('product')->orderBy('created_at', 'desc')->get();
        return response()->json($history);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'purchase_price' => 'required|numeric',
            'notes' => 'nullable|string',
        ]);

        try {
            DB::beginTransaction();

            // Create Restock History
            $history = RestockHistory::create($validated);

            // Update Product Stock
            $product = Product::findOrFail($validated['product_id']);
            $product->increment('stock', $validated['quantity']);

            // Update Purchase Price if it changes (Optional policy)
            $product->update(['purchase_price' => $validated['purchase_price']]);

            DB::commit();

            return response()->json($history->load('product'), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Restock gagal: ' . $e->getMessage()], 500);
        }
    }
}
