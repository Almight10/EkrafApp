<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title inertia>Platform Ekraf HAKI</title>
        <meta name="description" content="Katalog Karya Ekonomi Kreatif Daerah Berbasis HAKI">


        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

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
