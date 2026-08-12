import re

with open('stitch_bundle.js', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

print(f'Bundle: {len(content)} bytes')

# Search for Tailwind class patterns that suggest the design
# Look for color classes
colors = re.findall(r'(?:bg|text|border)-(?:white|black|gray|slate|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d{2,3}', content)
from collections import Counter
color_counts = Counter(colors)
print('\n=== Top colors ===')
for color, count in color_counts.most_common(30):
    print(f'  {count}x {color}')

# Look for font-family references
fonts = re.findall(r'font-family["\s]*:["\s]*[\'"]?([^"\';\}]+)', content)
print('\n=== Font families ===')
for f in set(fonts[:20]):
    print(f'  {f[:80]}')

# Look for hex colors
hexes = re.findall(r'#[0-9a-fA-F]{6}', content)
hex_counts = Counter(hexes)
print('\n=== Top hex colors ===')
for hex_c, count in hex_counts.most_common(20):
    print(f'  {count}x {hex_c}')
