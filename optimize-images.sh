#!/bin/bash

# Image Optimization Script
# Optimizes images for web performance and accessibility

set -e

info() {
    echo -e "\033[0;34mℹ INFO\033[0m: $1"
}

success() {
    echo -e "\033[0;32m✓ SUCCESS\033[0m: $1"
}

warning() {
    echo -e "\033[1;33m⚠ WARNING\033[0m: $1"
}

echo "=== Hugo Sites Image Optimization ==="
echo

# Function to optimize images in a directory
optimize_directory() {
    local dir=$1
    local site_name=$2

    info "Optimizing images in: $dir"

    # Count images before optimization
    total_images=$(find "$dir" \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -not -path "*/node_modules/*" | wc -l)
    info "Found $total_images images to analyze"

    # Find large images (>500KB)
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
            if [[ $size -gt 512000 ]]; then
                size_kb=$((size / 1024))
                warning "Large image found: $file (${size_kb}KB)"
                info "Recommendation: Consider compressing or converting to WebP format"
            fi
        fi
    done < <(find "$dir" \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -not -path "*/node_modules/*" -print0)

    # Check for WebP usage (modern format)
    webp_count=$(find "$dir" -name "*.webp" -not -path "*/node_modules/*" | wc -l)
    if [[ $webp_count -eq 0 ]]; then
        warning "No WebP images found. Consider converting PNG/JPG to WebP for better compression"
    else
        success "Found $webp_count WebP images (good for performance)"
    fi
}

# Optimize both sites
optimize_directory "/opt/git/hugo-sites/hugo-graphwiz-ai/myhugoapp/static" "GraphWiz.ai"
optimize_directory "/opt/git/hugo-sites/hugo-tobias-weiss-org/myhugoapp/static" "Tobias-Weiss.org"

echo
success "Image optimization analysis complete!"
echo
echo "=== Additional Performance Metrics ==="
echo "1. Image Compression Ratio: Optimize for >70% compression"
echo "2. Format Modernization: Use WebP for next-gen format support"
echo "3. Loading Strategy: Implement lazy loading for below-fold images"
echo "4. Responsive Images: Use srcset for different screen sizes"
echo "5. CDN Optimization: Consider CDN for static assets"