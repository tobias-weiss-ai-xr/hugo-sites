#!/usr/bin/env python3
"""
Footer Margin Verification Script
Verifies that footer navigation elements have no left/right margin
"""

import requests
from bs4 import BeautifulSoup
import re
import sys

def check_footer_css(url='https://graphwiz.ai/'):
    """Fetch and check the footer CSS"""
    print(f"Fetching {url}...")
    response = requests.get(url, timeout=10)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, 'html.parser')

    # Find the footer navigation
    footer_nav = soup.find('div', class_='footer-nav')
    if not footer_nav:
        print("❌ Footer navigation not found")
        return False

    print(f"✓ Found footer navigation")

    # Check for CSS file
    css_links = soup.find_all('link', rel='stylesheet', href=re.compile(r'footer-custom'))
    if not css_links:
        print("⚠️  Footer custom CSS not linked in HTML")
        return False

    print(f"✓ Found footer-custom.css link")

    # Fetch the CSS file
    css_url = css_links[0]['href']
    if css_url.startswith('/'):
        css_url = f"{url.rstrip('/')}{css_url}"

    print(f"Fetching CSS from {css_url}...")
    css_response = requests.get(css_url, timeout=10)
    css_response.raise_for_status()

    css_content = css_response.text

    # Check for margin rules
    issues = []

    # Look for list-inline-item margin rules
    if '.footer-nav .list-inline-item' in css_content:
        print("✓ Found .footer-nav .list-inline-item rule")

        # Check for margin-left: 0
        if 'margin-left: 0' in css_content or 'margin-left:0' in css_content:
            print("✓ margin-left: 0 found")
        else:
            issues.append("margin-left: 0 not found")

        # Check for margin-right: 0
        if 'margin-right: 0' in css_content or 'margin-right:0' in css_content:
            print("✓ margin-right: 0 found")
        else:
            issues.append("margin-right: 0 not found")

        # Check for !important
        if '!important' in css_content:
            print("✓ Using !important to override Bootstrap")
        else:
            print("⚠️  No !important found - might not override Bootstrap")
    else:
        issues.append(".footer-nav .list-inline-item rule not found")

    # Print the relevant CSS section
    print("\nRelevant CSS content:")
    print("-" * 50)
    lines = css_content.split('\n')
    in_list_inline_item = False
    for line in lines:
        if '.list-inline-item' in line:
            in_list_inline_item = True
        if in_list_inline_item:
            print(line)
            if '}' in line and in_list_inline_item:
                in_list_inline_item = False
                break
    print("-" * 50)

    return len(issues) == 0, issues

def main():
    print("=" * 60)
    print("Footer Margin Verification")
    print("=" * 60)

    try:
        success, issues = check_footer_css()

        print("\n" + "=" * 60)
        if success:
            print("✓ All checks passed! Footer margins are set to 0")
            return 0
        else:
            print("❌ Issues found:")
            for issue in issues:
                print(f"  - {issue}")
            return 1
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
