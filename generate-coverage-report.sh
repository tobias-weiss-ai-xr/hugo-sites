#!/bin/bash

# Coverage Report Generator
# Generates comprehensive reports for image accessibility and performance

set -e

REPORT_DIR="/opt/git/hugo-sites/reports"
mkdir -p "$REPORT_DIR"

report_file="$REPORT_DIR/accessibility-coverage-$(date +%Y%m%d-%H%M%S).md"

echo "# Hugo Sites Image Accessibility & Performance Coverage Report" > "$report_file"
echo "Generated on: $(date)" >> "$report_file"
echo "" >> "$report_file"

# Add test results
echo "## Test Results" >> "$report_file"
/opt/git/hugo-sites/test-image-accessibility.sh >> "$report_file" 2>&1

echo "" >> "$report_file"
echo "## Image Optimization Analysis" >> "$report_file"
/opt/git/hugo-sites/optimize-images.sh >> "$report_file" 2>&1

echo "" >> "$report_file"
echo "## Additional Metrics" >> "$report_file"
echo "- Alt Text Coverage: $(grep -c "alt=" /opt/git/hugo-sites/hugo-graphwiz-ai/myhugoapp/content/**/*.md /opt/git/hugo-sites/hugo-tobias-weiss-org/myhugoapp/content/**/*.md 2>/dev/null || echo "0") images with alt text" >> "$report_file"
echo "- Total Images: $(find /opt/git/hugo-sites/hugo-graphwiz-ai/myhugoapp/static /opt/git/hugo-sites/hugo-tobias-weiss-org/myhugoapp/static \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) 2>/dev/null | wc -l)" >> "$report_file"
echo "- Average Image Size: Calculated from optimization script" >> "$report_file"

echo "Coverage report generated: $report_file"