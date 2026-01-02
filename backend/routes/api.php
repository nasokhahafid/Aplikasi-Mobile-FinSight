<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\RestockHistoryController;
use App\Http\Controllers\Api\SettingController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'getProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/categories', [App\Http\Controllers\Api\CategoryController::class, 'index']);
    Route::apiResource('products', ProductController::class);
    Route::apiResource('transactions', TransactionController::class);

    Route::apiResource('users', UserController::class);

    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
    Route::get('/dashboard/chart', [DashboardController::class, 'chart']);

    Route::get('/settings/export', [SettingsController::class, 'exportData']);
    Route::post('/settings/import', [SettingsController::class, 'importData']);

    Route::apiResource('restock-history', RestockHistoryController::class);
    Route::get('/settings', [SettingController::class, 'index']);
    Route::post('/settings', [SettingController::class, 'update']);
});
