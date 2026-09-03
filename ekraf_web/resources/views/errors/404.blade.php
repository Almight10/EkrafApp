<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>404 — Halaman Tidak Ditemukan | Platform Ekraf HAKI</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --clr-bg: #faf6f0;
            --clr-terracotta: #c04828;
            --clr-charcoal: #1c1917;
            --clr-muted: #66605a;
        }
        body {
            margin: 0;
            padding: 0;
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--clr-bg);
            color: var(--clr-charcoal);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            text-align: center;
        }
        .error-card {
            background: #ffffff;
            border: 1px solid var(--clr-charcoal);
            box-shadow: 6px 6px 0px rgba(28, 25, 23, 0.85);
            padding: 3rem 2rem;
            max-width: 520px;
            width: 90%;
            border-radius: 4px;
        }
        .error-code {
            font-family: 'Playfair Display', serif;
            font-size: 5rem;
            font-weight: 800;
            color: var(--clr-terracotta);
            margin: 0;
            line-height: 1;
        }
        .error-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.75rem;
            margin: 1rem 0 0.5rem;
        }
        .error-desc {
            color: var(--clr-muted);
            font-size: 0.95rem;
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        .btn-home {
            display: inline-block;
            background: var(--clr-terracotta);
            color: #ffffff;
            font-weight: 700;
            padding: 0.8rem 1.5rem;
            text-decoration: none;
            border: 1px solid var(--clr-charcoal);
            box-shadow: 3px 3px 0px rgba(28, 25, 23, 0.9);
            border-radius: 2px;
        }
    </style>
</head>
<body>
    <div class="error-card">
        <div class="error-code">404</div>
        <h1 class="error-title">Halaman Tidak Ditemukan</h1>
        <p class="error-desc">Maaf, halaman yang Anda tuju tidak ditemukan atau alamat URL yang Anda masukkan kurang tepat.</p>
        <a href="/" class="btn-home">Kembali ke Beranda Utama</a>
    </div>
</body>
</html>
