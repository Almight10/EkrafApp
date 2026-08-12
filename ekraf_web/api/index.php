<?php

// 1. Prepare writable storage directories in /tmp for Vercel Serverless environment
$storageFolders = [
    '/tmp/storage',
    '/tmp/storage/app',
    '/tmp/storage/app/public',
    '/tmp/storage/framework',
    '/tmp/storage/framework/cache',
    '/tmp/storage/framework/cache/data',
    '/tmp/storage/framework/sessions',
    '/tmp/storage/framework/views',
    '/tmp/storage/logs',
];

foreach ($storageFolders as $folder) {
    if (!file_exists($folder)) {
        mkdir($folder, 0755, true);
    }
}

// 2. Prepare SQLite database file in /tmp
if (!file_exists('/tmp/database.sqlite')) {
    touch('/tmp/database.sqlite');
}

// 3. Set environment variables into getenv, $_ENV, and $_SERVER
$envVars = [
    'APP_NAME' => 'Platform Ekraf HAKI',
    'APP_ENV' => 'production',
    'APP_KEY' => 'base64:QX55OMumXIx8Di73dZAraVpgMlbMT08eyEOF18Wluk4=',
    'APP_DEBUG' => 'true',
    'APP_URL' => 'https://ekraf-app.vercel.app',
    'APP_STORAGE_PATH' => '/tmp/storage',
    'VIEW_COMPILED_PATH' => '/tmp/storage/framework/views',
    'APP_CONFIG_CACHE' => '/tmp/config.php',
    'APP_SERVICES_CACHE' => '/tmp/services.php',
    'APP_PACKAGES_CACHE' => '/tmp/packages.php',
    'APP_ROUTES_CACHE' => '/tmp/routes.php',
    'DB_CONNECTION' => 'sqlite',
    'DB_DATABASE' => '/tmp/database.sqlite',
    'SESSION_DRIVER' => 'cookie',
    'CACHE_STORE' => 'array',
    'LOG_CHANNEL' => 'stderr',
    'SUPABASE_URL' => 'https://fuiruqmhcbyajuovkxci.supabase.co',
    'SUPABASE_ANON_KEY' => 'sb_publishable_IpDQmNCzzWC5Li8HXRcnzA_YX3R8Jbe',
    'VITE_SUPABASE_URL' => 'https://fuiruqmhcbyajuovkxci.supabase.co',
    'VITE_SUPABASE_ANON_KEY' => 'sb_publishable_IpDQmNCzzWC5Li8HXRcnzA_YX3R8Jbe',
    'VITE_SUPABASE_PUBLISHABLE_KEY' => 'sb_publishable_IpDQmNCzzWC5Li8HXRcnzA_YX3R8Jbe',
];

foreach ($envVars as $key => $value) {
    if (!getenv($key)) {
        putenv("{$key}={$value}");
    }
    if (!isset($_ENV[$key])) {
        $_ENV[$key] = $value;
    }
    if (!isset($_SERVER[$key])) {
        $_SERVER[$key] = $value;
    }
}

$_SERVER['HTTPS'] = 'on';
$_SERVER['HTTP_X_FORWARDED_PROTO'] = 'https';
$_SERVER['HTTP_X_FORWARDED_PORT'] = 443;
putenv('HTTPS=on');

// Forward Vercel requests to Laravel public index
require __DIR__ . '/../public/index.php';
