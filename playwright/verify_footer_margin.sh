#!/bin/bash

echo "=============================================="
echo "Footer Margin Verification Test"
echo "=============================================="
echo ""

URL="https://graphwiz.ai"

echo "Fetching page from $URL..."
PAGE=$(curl -s "$URL")

# Check if footer-custom.css is linked
if echo "$PAGE" | grep -q "footer-custom.css"; then
    echo "✓ footer-custom.css is linked in the page"
else
    echo "❌ footer-custom.css is NOT linked in the page"
    exit 1
fi

# Get the CSS URL
CSS_URL=$(echo "$PAGE" | grep -o 'href="[^"]*footer-custom\.css[^"]*"' | sed 's/href="//;s/".*//')
if [ -z "$CSS_URL" ]; then
    CSS_URL="/css/footer-custom.css"
fi

# Make absolute URL if needed
if [[ "$CSS_URL" == /* ]]; then
    CSS_FULL_URL="https://graphwiz.ai$CSS_URL"
else
    CSS_FULL_URL="$CSS_URL"
fi

echo ""
echo "Fetching CSS from: $CSS_FULL_URL"
CSS_CONTENT=$(curl -s "$CSS_FULL_URL")

echo ""
echo "Checking CSS rules..."
echo "=============================================="

# Check for list-inline-item margin rules
FAILED=0

# Check margin-left
if echo "$CSS_CONTENT" | grep -q "margin-left.*0.*!important"; then
    echo "✓ margin-left: 0 !important found"
elif echo "$CSS_CONTENT" | grep -q "margin-left.*0"; then
    echo "✓ margin-left: 0 found"
else
    echo "❌ margin-left: 0 NOT found"
    FAILED=1
fi

# Check margin-right
if echo "$CSS_CONTENT" | grep -q "margin-right.*0.*!important"; then
    echo "✓ margin-right: 0 !important found"
elif echo "$CSS_CONTENT" | grep -q "margin-right.*0"; then
    echo "✓ margin-right: 0 found"
else
    echo "❌ margin-right: 0 NOT found"
    FAILED=1
fi

echo ""
echo "Relevant CSS section:"
echo "=============================================="
echo "$CSS_CONTENT" | grep -A 5 "\.list-inline-item" | head -20
echo "=============================================="

echo ""
if [ $FAILED -eq 0 ]; then
    echo "✓ All checks passed!"
    exit 0
else
    echo "❌ Some checks failed"
    exit 1
fi
