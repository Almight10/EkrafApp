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

    /**
     * Redirects automatically to the latest APK release asset on GitHub
     */
    public function downloadApk()
    {
        $apkUrl = \Illuminate\Support\Facades\Cache::remember('latest_github_apk_url', 300, function () {
            try {
                $response = \Illuminate\Support\Facades\Http::withHeaders([
                    'User-Agent' => 'EkrafApp-Web',
                ])->get('https://api.github.com/repos/Gerryrag/ekrafApp/releases');

                if ($response->successful()) {
                    $releases = $response->json();
                    if (is_array($releases)) {
                        foreach ($releases as $release) {
                            if (!empty($release['assets']) && is_array($release['assets'])) {
                                foreach ($release['assets'] as $asset) {
                                    if (isset($asset['name']) && str_ends_with(strtolower($asset['name']), '.apk')) {
                                        return $asset['browser_download_url'];
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (\Throwable $e) {
                // Fallback to latest known URL if network error
            }
            return 'https://github.com/Gerryrag/ekrafApp/releases/download/ekraf/Kreasi-Ekraf.apk';
        });

        return redirect()->away($apkUrl);
    }
}
