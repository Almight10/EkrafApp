<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\EkrafController;
use Inertia\Inertia;

/*
|--------------------------------------------------------------------------
| Platform Ekraf HAKI — Public Website Routes
|--------------------------------------------------------------------------
*/

// Landing Page — Beranda + New Arrivals
Route::get('/', [EkrafController::class, 'index'])->name('home');

// Katalog Karya — filterable grid
Route::get('/katalog', [EkrafController::class, 'katalog'])->name('katalog');

// Dashboard Data Sektor — dedicated analytics page
Route::get('/dashboard', [EkrafController::class, 'dashboard'])->name('dashboard');

// Detail Produk — single product page (supports both /detail/{id} and /produk/{id})
Route::get('/detail/{id}', [EkrafController::class, 'show'])->name('detail.show');
Route::get('/produk/{id}', [EkrafController::class, 'show'])->name('produk.show');

// Navigation Aliases for Editorial Navbar links
Route::get('/artists', [EkrafController::class, 'katalog']);
Route::get('/exhibitions', [EkrafController::class, 'katalog']);
Route::get('/collect', [EkrafController::class, 'katalog']);

// Automatic Dynamic APK Download Route
Route::get('/download-apk', [EkrafController::class, 'downloadApk'])->name('download.apk');

// Fallback Route for custom 404 error page (e.g., /katal -> Error.vue)
Route::fallback(function () {
    return Inertia::render('Error', [
        'status' => 404,
        'path' => request()->path(),
    ])->toResponse(request())->setStatusCode(404);
});


