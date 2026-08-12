import re, json

# Read the print_html.py which might have what was fetched
import os
for fname in os.listdir('.'):
    if fname.endswith('.html') and fname.startswith('stitch_'):
        with open(fname, encoding='utf-8', errors='replace') as f:
            content = f.read()
        # Look for any CSS or color data embedded in the Stitch HTML
        styles = re.findall(r'<style[^>]*>(.*?)</style>', content, re.DOTALL)
        if styles:
            print(f'\n=== {fname} styles ===')
            for s in styles:
                print(s[:2000])
        
        # Look for JSON data
        scripts = re.findall(r'<script[^>]*>(.*?)</script>', content, re.DOTALL)
        for s in scripts:
            if 'color' in s.lower() or 'background' in s.lower() or 'font' in s.lower():
                print(f'\n=== Script with design data in {fname} ===')
                print(s[:1000])
