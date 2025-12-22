#!/bin/bash

# Quick Link Test - Focus on critical links
echo "🔗 Quick Link Test"
echo "=================="

# Test the PDF link that was fixed
echo "Testing PDF link..."
pdf_response=$(curl -L -s -o /dev/null -w "%{http_code}" "https://graphwiz.ai/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf")

if [ "$pdf_response" = "200" ]; then
    echo "✅ PDF link working: https://graphwiz.ai/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"
else
    echo "❌ PDF link broken: HTTP $pdf_response"
fi

# Test imprint pages
echo -e "\nTesting imprint pages..."
imprint_response=$(curl -L -s -o /dev/null -w "%{http_code}" "https://graphwiz.ai/imprint/")
tobias_imprint_response=$(curl -L -s -o /dev/null -w "%{http_code}" "https://tobias-weiss.org/imprint/")

if [ "$imprint_response" = "200" ]; then
    echo "✅ graphwiz.ai imprint working"
else
    echo "❌ graphwiz.ai imprint broken: HTTP $imprint_response"
fi

if [ "$tobias_imprint_response" = "200" ]; then
    echo "✅ tobias-weiss.org imprint working"
else
    echo "❌ tobias-weiss.org imprint broken: HTTP $tobias_imprint_response"
fi

# Test main pages
echo -e "\nTesting main pages..."
graphwiz_main=$(curl -L -s -o /dev/null -w "%{http_code}" "https://graphwiz.ai/")
tobias_main=$(curl -L -s -o /dev/null -w "%{http_code}" "https://tobias-weiss.org/")

echo "graphwiz.ai: $graphwiz_main"
echo "tobias-weiss.org: $tobias_main"

echo -e "\n✨ Quick test completed!"