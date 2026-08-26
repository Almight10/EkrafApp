<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class EkrafController extends Controller
{
    /**
     * Landing page — Beranda dengan welcome & new arrivals
     */
    public function index(): Response
    {
        return Inertia::render('LandingPage');
    }

    /**
     * Katalog Karya — grid dengan filter real-time (Vue handles Firestore query)
     */
    public function katalog(Request $request): Response
    {
        return Inertia::render('KatalogKarya', [
            'initialSektor' => $request->query('sektor', ''),
        ]);
    }

    /**
     * Dashboard Data Sektor — pemetaan & statistik 17 sub-sektor
     */
    public function dashboard(): Response
    {
        return Inertia::render('DashboardSektor');
    }

    /**
     * Detail Produk — halaman detail satu karya berdasarkan Firestore document ID
     */
    public function show(string $id): Response
    {
        return Inertia::render('DetailProduk', [
            'id' => $id,
        ]);
    }
}
