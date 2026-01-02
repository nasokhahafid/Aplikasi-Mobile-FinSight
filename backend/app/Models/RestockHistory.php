<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RestockHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'quantity',
        'purchase_price',
        'notes',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
