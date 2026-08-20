<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\EkrafController;

/*
|--------------------------------------------------------------------------
| Platform Ekraf HAKI — Public Website Routes
|--------------------------------------------------------------------------
*/

// Landing Page — Beranda + New Arrivals
Route::get('/', [EkrafController::class, 'index'])->name('home');

// Katalog Karya — filterable grid
Route::get('/katalog', [EkrafController::class, 'katalog'])->name('katalog');

// Detail Produk — single product page (supports both /detail/{id} and /produk/{id})
Route::get('/detail/{id}', [EkrafController::class, 'show'])->name('detail.show');
Route::get('/produk/{id}', [EkrafController::class, 'show'])->name('produk.show');

// Navigation Aliases for Editorial Navbar links
Route::get('/artists', [EkrafController::class, 'katalog']);
Route::get('/exhibitions', [EkrafController::class, 'katalog']);
Route::get('/collect', [EkrafController::class, 'katalog']);
