<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Create Admin User (if not exists)
        if (!User::where('email', 'admin@finsight.com')->exists()) {
             User::create([
                'name' => 'Admin FinSight Cell',
                'email' => 'admin@finsight.com',
                'password' => Hash::make('password'),
                'role' => 'owner',
            ]);
        }

        // Create Categories
        $catHp = Category::create(['name' => 'Handphone', 'slug' => 'handphone']);
        $catAksesoris = Category::create(['name' => 'Aksesoris', 'slug' => 'akesoris']);
        $catPulsa = Category::create(['name' => 'Pulsa & Data', 'slug' => 'pulsa-data']);
        $catService = Category::create(['name' => 'Service', 'slug' => 'service']);

        // Create Products - Handphone
        Product::create([
            'category_id' => $catHp->id,
            'name' => 'iPhone 15 Pro 128GB - Blue Titanium',
            'description' => 'Garansi Resmi iBox 1 Tahun',
            'price' => 19999000,
            'stock' => 5,
        ]);

        Product::create([
            'category_id' => $catHp->id,
            'name' => 'Samsung Galaxy S24 Ultra 256GB',
            'description' => 'AI Phone, Titanium Grey',
            'price' => 21999000,
            'stock' => 3,
        ]);

        Product::create([
            'category_id' => $catHp->id,
            'name' => 'Xiaomi Redmi Note 13 8/256GB',
            'description' => 'Layar AMOLED 120Hz',
            'price' => 2799000,
            'stock' => 10,
        ]);

        Product::create([
            'category_id' => $catHp->id,
            'name' => 'Infinix Hot 40 Pro',
            'description' => 'Gaming 120Hz Free Fire Edition',
            'price' => 2100000,
            'stock' => 15,
        ]);

        // Create Products - Aksesoris
        Product::create([
            'category_id' => $catAksesoris->id,
            'name' => 'Adapter Charger 20W USB-C',
            'description' => 'Fast Charging support iPhone/Android',
            'price' => 150000,
            'stock' => 50,
        ]);

        Product::create([
            'category_id' => $catAksesoris->id,
            'name' => 'Kabel Data Type-C to Type-C',
            'description' => 'Support 65W, Braided 1M',
            'price' => 65000,
            'stock' => 100,
        ]);

        Product::create([
            'category_id' => $catAksesoris->id,
            'name' => 'Tempered Glass Full Cover',
            'description' => 'Anti Gores Kaca 9H',
            'price' => 35000,
            'stock' => 200,
        ]);

        // Create Products - Pulsa & Data (Digital Goods)
        Product::create([
            'category_id' => $catPulsa->id,
            'name' => 'Voucher Telkomsel 10GB / 30 Hari',
            'description' => 'Kuota Nasional + Lokal',
            'price' => 35000,
            'stock' => 999,
        ]);

        Product::create([
            'category_id' => $catPulsa->id,
            'name' => 'Voucher Indosat Freedom 25GB',
            'description' => 'Full 24 Jam 30 Hari',
            'price' => 65000,
            'stock' => 999,
        ]);

         Product::create([
            'category_id' => $catService->id,
            'name' => 'Ganti LCD iPhone X/XS/11',
            'description' => 'Warna Natural + True Tone',
            'price' => 450000,
            'stock' => 10, // Sparepart stock
        ]);
    }
}
