import urllib.request, os

screens = {
    'landing': '595e8fc900a3404898204bd61a7aa106',
    'katalog': '7e080a5032d441039c08579b76fcb77b',
    'detail':  '47ea44dbcce74cacb80d08b426fc466d',
}

for name, sid in screens.items():
    url = f'https://app-companion-430619.appspot.com/render/{sid}'
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120'})
        with urllib.request.urlopen(req, timeout=30) as r:
            html = r.read().decode('utf-8', errors='replace')
            fname = f'screen_{name}.html'
            with open(fname, 'w', encoding='utf-8') as f:
                f.write(html)
            print(f'Saved {fname} ({len(html)} bytes)')
    except Exception as e:
        print(f'ERROR {name}: {e}')

# Also try the screens/preview endpoint
for name, sid in screens.items():
    url = f'https://app-companion-430619.appspot.com/screens/{sid}/preview'
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120'})
        with urllib.request.urlopen(req, timeout=30) as r:
            html = r.read().decode('utf-8', errors='replace')
            fname = f'screen_{name}_preview.html'
            with open(fname, 'w', encoding='utf-8') as f:
                f.write(html)
            print(f'Saved {fname} ({len(html)} bytes)')
    except Exception as e:
        print(f'ERROR {name} preview: {e}')
