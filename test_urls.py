import urllib.request, re

screen_ids = [
    '47ea44dbcce74cacb80d08b426fc466d',
    '595e8fc900a3404898204bd61a7aa106',
    '7e080a5032d441039c08579b76fcb77b',
]
project_id = '5596943933808868442'

base_urls = [
    'https://app-companion-430619.appspot.com/render/{sid}',
    'https://app-companion-430619.appspot.com/screens/{sid}/preview',
    'https://stitch.withgoogle.com/screens/{sid}/preview.png',
    'https://stitch.withgoogle.com/api/screens/{sid}/thumbnail',
]

for sid in screen_ids[:1]:
    for template in base_urls:
        url = template.replace('{sid}', sid)
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=5) as r:
                ct = r.headers.get('content-type', '?')
                print(f'OK {r.status} ct={ct}  url={url}')
        except urllib.error.HTTPError as e:
            print(f'HTTP {e.code}  url={url}')
        except Exception as e:
            print(f'ERR {type(e).__name__}  url={url}')
