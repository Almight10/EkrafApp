import urllib.request, re, json, os

base = 'https://app-companion-430619.appspot.com'

# Fetch main JS to find the screen data
main_js_url = f'{base}/assets/index-BzYXZde0.js'

try:
    req = urllib.request.Request(main_js_url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=30) as r:
        content = r.read().decode('utf-8', errors='replace')
        print(f'Got main JS: {len(content)} bytes')
        
        # Look for screen ID or color data
        screen_ids = [
            '47ea44dbcce74cacb80d08b426fc466d',
            '595e8fc900a3404898204bd61a7aa106',
            '7e080a5032d441039c08579b76fcb77b',
        ]
        for sid in screen_ids:
            if sid in content:
                idx = content.find(sid)
                print(f'Found {sid[:12]} at idx {idx}:')
                print(content[max(0,idx-100):idx+300])
                print('---')
                
        # Look for Tailwind config or color config
        color_matches = re.findall(r'primary["\s]*:["\s]*[#\w]+', content[:50000])
        print('\nColor matches:', color_matches[:20])

        # Look for component definitions
        with open('main_bundle.js', 'w', encoding='utf-8') as f:
            f.write(content[:500000])  # first 500kb
        print('Saved first 500kb of main bundle')
        
except Exception as e:
    print(f'Error: {e}')

# Also try the API endpoint for the screen JSON
for sid in ['595e8fc900a3404898204bd61a7aa106']:
    api_url = f'{base}/api/screens/{sid}'
    try:
        req = urllib.request.Request(api_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=15) as r:
            data = r.read().decode('utf-8', errors='replace')
            print(f'\nAPI response ({len(data)} bytes): {data[:500]}')
    except Exception as e:
        print(f'API error: {e}')
