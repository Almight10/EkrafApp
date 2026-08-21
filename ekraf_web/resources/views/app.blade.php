<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title inertia>Platform Ekraf HAKI</title>
        <meta name="description" content="Katalog Karya Ekonomi Kreatif Daerah Berbasis HAKI">


        <!-- Image CDN Preconnects for Fast LCP -->
        <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
        <link rel="preconnect" href="https://fuiruqmhcbyajuovkxci.supabase.co" crossorigin>

        <!-- Google Fonts (Optimized Non-Blocking Load) -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@600;700&family=Playfair+Display:ital,wght@0,700;0,800;1,700&family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap">
        <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@600;700&family=Playfair+Display:ital,wght@0,700;0,800;1,700&family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet" media="print" onload="this.media='all'">
        <noscript>
            <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@600;700&family=Playfair+Display:ital,wght@0,700;0,800;1,700&family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
        </noscript>

        <!-- Supabase config injected from env / services config -->
        <script>
            window.supabaseConfig = {
                url: "{{ config('services.supabase.url') ?: env('SUPABASE_URL', 'https://fuiruqmhcbyajuovkxci.supabase.co') }}",
                key: "{{ config('services.supabase.key') ?: env('SUPABASE_ANON_KEY', '') }}"
            };
        </script>

        @vite(['resources/css/app.css', 'resources/js/app.js'])
        @inertiaHead
    </head>
    <body class="antialiased bg-neutral-50">
        @inertia
    </body>
</html>
