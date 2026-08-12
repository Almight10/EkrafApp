import re, urllib.request, json, os

# Read the bundle JS
with open('stitch_bundle.js', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()
print('Bundle size:', len(content))

# Look for screen IDs and hosted image URLs
screen_ids = [
    '47ea44dbcce74cacb80d08b426fc466d',
    '595e8fc900a3404898204bd61a7aa106',
    '7e080a5032d441039c08579b76fcb77b',
    'asset-stub-assets_2085c30201444003bbdd1c41076089a4',
]

for sid in screen_ids:
    # Find 100 chars around each screen ID occurrence
    idx = content.find(sid)
    if idx >= 0:
        print(f'\n=== Found screen {sid[:12]}... ===')
        print(content[max(0,idx-200):idx+300])

# Search for appspot image URLs
appspot_urls = re.findall(r'https://app-companion[^\s"\'\\]+', content)
print(f'\n=== App-companion URLs ({len(appspot_urls)}) ===')
for u in appspot_urls[:20]:
    print(u)

# Search for hosted screen URLs (Stitch serves PNGs like /hosted/...)
hosted = re.findall(r'(?:hosted|preview|screenshot|render)[^\s"\'\\]{5,100}', content)
print(f'\n=== Hosted patterns ({len(hosted)}) ===')
for h in hosted[:20]:
    print(h)
