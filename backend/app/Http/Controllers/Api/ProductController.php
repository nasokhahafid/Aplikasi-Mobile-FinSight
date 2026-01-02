<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::with('category')->where('is_active', true)->get();
        return response()->json($products);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'category_id' => 'nullable|exists:categories,id',
            'price' => 'required|numeric',
            'purchase_price' => 'nullable|numeric',
            'stock' => 'required|integer',
            'description' => 'nullable|string',
            'barcode' => 'nullable|string|unique:products,barcode',
            'image' => 'nullable|file|image|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('products', 'public');
            // Full URL: http://127.0.0.1:8000/storage/products/filename.jpg
            $validated['image'] = asset('storage/' . $path);
        }

        $product = Product::create($validated);
        return response()->json($product, 201);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|string',
            'category_id' => 'sometimes|nullable|exists:categories,id',
            'price' => 'sometimes|numeric',
            'purchase_price' => 'sometimes|numeric',
            'stock' => 'sometimes|integer',
            'barcode' => 'sometimes|nullable|string|unique:products,barcode,' . $id,
            'description' => 'sometimes|nullable|string',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('products', 'public');
            $validated['image'] = asset('storage/' . $path);
        }

        $product->update($validated);
        return response()->json($product);
    }

    public function destroy($id)
    {
        $product = Product::findOrFail($id);
        $product->update(['is_active' => false]); // Soft delete logic for products
        return response()->json(['message' => 'Product deleted']);
    }
}
