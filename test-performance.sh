#!/bin/bash

# Comprehensive Performance Testing Script
# Tests page load speed, compression, caching, and optimization

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

# Sites to test
SITES=(
    "https://graphwiz.ai"
    "https://tobias-weiss.org"
    "https://chemie-lernen.org"
)

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_section() {
    echo -e "\n${PURPLE}🚀 $1${NC}"
    echo "-------------------------------------------"
}

print_metric() {
    local metric_name="$1"
    local value="$2"
    local unit="$3"
    local threshold="$4"
    local status="$5"

    echo -n "$metric_name: "

    if [[ "$status" == "PASS" ]]; then
        echo -e "${GREEN}✓ $value $unit${NC} (Target: <$threshold)"
    elif [[ "$status" == "WARN" ]]; then
        echo -e "${YELLOW}⚠ $value $unit${NC} (Target: <$threshold)"
    else
        echo -e "${RED}✗ $value $unit${NC} (Target: <$threshold)"
    fi
}

# Performance testing functions
test_page_load_speed() {
    print_section "Page Load Speed Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing: $site${NC}"

        # Test initial load time
        start_time=$(date +%s.%N)
        response=$(curl -L -s -w "%{http_code}" "$site" -o /dev/null)
        end_time=$(date +%s.%N)
        load_time=$(echo "$end_time - $start_time" | bc)

        if [ "$response" = "200" ]; then
            # Categorize performance
            if (( $(echo "$load_time < 2.0" | bc -l) )); then
                print_metric "Load time" "$(printf "%.2f" $load_time)" "s" "2.0s" "PASS"
                ((PASSED++))
            elif (( $(echo "$load_time < 5.0" | bc -l) )); then
                print_metric "Load time" "$(printf "%.2f" $load_time)" "s" "2.0s" "WARN"
                ((WARNINGS++))
            else
                print_metric "Load time" "$(printf "%.2f" $load_time)" "s" "2.0s" "FAIL"
                ((FAILED++))
            fi
        else
            echo -e "${RED}✗ FAILED${NC} - HTTP $response"
            ((FAILED++))
        fi
    done
}

test_compression() {
    print_section "Content Compression Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing compression for: $site${NC}"

        # Test without compression
        uncompressed_size=$(curl -L -s -H "Accept-Encoding: identity" "$site" | wc -c)

        # Test with compression
        compressed_size=$(curl -L -s -H "Accept-Encoding: gzip, deflate" "$site" | wc -c)

        if [ "$uncompressed_size" -gt 1000 ]; then
            compression_ratio=$(echo "scale=2; $compressed_size / $uncompressed_size" | bc)
            saved_bytes=$((uncompressed_size - compressed_size))
            saved_kb=$((saved_bytes / 1024))

            echo -n "Compression ratio: "
            if (( $(echo "$compression_ratio < 0.7" | bc -l) )); then
                echo -e "${GREEN}✓ $(printf "%.1f" $compression_ratio)${NC} (Saved: ${saved_kb}KB)"
                ((PASSED++))
            elif (( $(echo "$compression_ratio < 0.9" | bc -l) )); then
                echo -e "${YELLOW}⚠ $(printf "%.1f" $compression_ratio)${NC} (Saved: ${saved_kb}KB)"
                ((WARNINGS++))
            else
                echo -e "${RED}✗ $(printf "%.1f" $compression_ratio)${NC} (No compression)"
                ((FAILED++))
            fi
        else
            echo -e "${GREEN}✓ PASS${NC} (Content too small to benefit from compression)"
            ((PASSED++))
        fi
    done
}

test_cache_headers() {
    print_section "Cache Headers Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing cache headers for: $site${NC}"

        # Get response headers
        cache_control=$(curl -L -s -I "$site" | grep -i "cache-control" | tr -d '\r')
        expires=$(curl -L -s -I "$site" | grep -i "expires" | tr -d '\r')
        etag=$(curl -L -s -I "$site" | grep -i "etag" | tr -d '\r')
        last_modified=$(curl -L -s -I "$site" | grep -i "last-modified" | tr -d '\r')

        cache_score=0

        if [ -n "$cache_control" ]; then
            echo -e "${GREEN}✓ Cache-Control: ${cache_control#Cache-Control: }${NC}"
            ((cache_score++))
        else
            echo -e "${YELLOW}⚠ No Cache-Control header${NC}"
        fi

        if [ -n "$expires" ]; then
            echo -e "${GREEN}✓ Expires: ${expires#Expires: }${NC}"
            ((cache_score++))
        else
            echo -e "${YELLOW}⚠ No Expires header${NC}"
        fi

        if [ -n "$etag" ]; then
            echo -e "${GREEN}✓ ETag: ${etag#ETag: }${NC}"
            ((cache_score++))
        else
            echo -e "${YELLOW}⚠ No ETag header${NC}"
        fi

        if [ "$cache_score" -ge 2 ]; then
            echo -e "${GREEN}✓ Good caching configuration${NC}"
            ((PASSED++))
        elif [ "$cache_score" -eq 1 ]; then
            echo -e "${YELLOW}⚠ Basic caching configuration${NC}"
            ((WARNINGS++))
        else
            echo -e "${RED}✗ Poor caching configuration${NC}"
            ((FAILED++))
        fi
    done
}

test_security_headers() {
    print_section "Security Headers Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing security headers for: $site${NC}"

        security_headers=(
            "Strict-Transport-Security"
            "X-Frame-Options"
            "X-Content-Type-Options"
            "X-XSS-Protection"
            "Referrer-Policy"
        )

        security_score=0
        critical_missing=""

        for header in "${security_headers[@]}"; do
            if curl -L -s -I "$site" | grep -qi "$header"; then
                echo -e "  ${GREEN}✓ $header${NC}"
                ((security_score++))
            else
                if [[ "$header" == "Strict-Transport-Security" ]]; then
                    critical_missing="$critical_missing $header"
                    echo -e "  ${RED}✗ $header (CRITICAL)${NC}"
                else
                    echo -e "  ${YELLOW}⚠ $header${NC}"
                fi
            fi
        done

        if [ "$security_score" -ge 4 ]; then
            echo -e "${GREEN}✓ Excellent security headers${NC}"
            ((PASSED++))
        elif [ "$security_score" -ge 2 ]; then
            echo -e "${YELLOW}⚠ Basic security headers${NC}"
            ((WARNINGS++))
        else
            echo -e "${RED}✗ Poor security headers$critical_missing${NC}"
            ((FAILED++))
        fi
    done
}

test_resource_optimization() {
    print_section "Resource Optimization Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing resources for: $site${NC}"

        # Get HTML content
        html_content=$(curl -L -s "$site")

        # Count resources
        css_count=$(echo "$html_content" | grep -o '<link[^>]*rel="stylesheet"' | wc -l)
        js_count=$(echo "$html_content" | grep -o '<script[^>]*src=' | wc -l)
        img_count=$(echo "$html_content" | grep -o '<img[^>]*src=' | wc -l)

        echo "CSS files: $css_count"
        echo "JavaScript files: $js_count"
        echo "Images: $img_count"

        # Test minification (basic check)
        minified_content=$(echo "$html_content" | tr -d '\n\t ')
        original_lines=$(echo "$html_content" | wc -l)
        minified_lines=$(echo "$minified_content" | wc -l)

        if [ "$minified_lines" -lt "$((original_lines / 2))" ]; then
            echo -e "${GREEN}✓ Content appears minified${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ Content may not be minified${NC}"
            ((WARNINGS++))
        fi

        # Check for inline CSS/JS (not recommended for production)
        inline_style=$(echo "$html_content" | grep -c '<style')
        inline_script=$(echo "$html_content" | grep -c '<script[^>]*>.*</script>')

        if [ "$inline_style" -gt 0 ] || [ "$inline_script" -gt 2 ]; then
            echo -e "${YELLOW}⚠ Found $inline_style inline styles and $inline_script inline scripts${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✓ Minimal inline CSS/JS${NC}"
            ((PASSED++))
        fi
    done
}

test_mobile_optimization() {
    print_section "Mobile Optimization Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing mobile optimization for: $site${NC}"

        # Test with mobile user agent
        mobile_response=$(curl -L -s -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15" "$site")

        # Check for viewport
        if echo "$mobile_response" | grep -q 'viewport.*width=device-width'; then
            echo -e "${GREEN}✓ Mobile viewport configured${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ Mobile viewport not configured${NC}"
            ((FAILED++))
        fi

        # Check for responsive design elements
        responsive_indicators=(
            "max-width"
            "bootstrap"
            "flex"
            "grid"
            "@media"
        )

        responsive_count=0
        for indicator in "${responsive_indicators[@]}"; do
            if echo "$mobile_response" | grep -qi "$indicator"; then
                ((responsive_count++))
            fi
        done

        if [ "$responsive_count" -ge 2 ]; then
            echo -e "${GREEN}✓ Responsive design detected ($responsive_count indicators)${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ Limited responsive indicators ($responsive_count indicators)${NC}"
            ((WARNINGS++))
        fi
    done
}

test_seo_basics() {
    print_section "SEO Basics Testing"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing SEO basics for: $site${NC}"

        html_content=$(curl -L -s "$site")

        # Check title tag
        if echo "$html_content" | grep -q '<title>'; then
            title_length=$(echo "$html_content" | grep -o '<title[^>]*>.*</title>' | sed 's/<[^>]*>//g' | wc -c)
            if [ "$title_length" -ge 30 ] && [ "$title_length" -le 70 ]; then
                echo -e "${GREEN}✓ Title tag optimized ($title_length chars)${NC}"
                ((PASSED++))
            else
                echo -e "${YELLOW}⚠ Title tag not optimal ($title_length chars)${NC}"
                ((WARNINGS++))
            fi
        else
            echo -e "${RED}✗ Missing title tag${NC}"
            ((FAILED++))
        fi

        # Check meta description
        if echo "$html_content" | grep -q 'name="description"'; then
            desc_length=$(echo "$html_content" | grep -o 'name="description"[^>]*content="[^"]*"' | sed 's/.*content="//' | wc -c)
            if [ "$desc_length" -ge 120 ] && [ "$desc_length" -le 160 ]; then
                echo -e "${GREEN}✓ Meta description optimized ($desc_length chars)${NC}"
                ((PASSED++))
            else
                echo -e "${YELLOW}⚠ Meta description not optimal ($desc_length chars)${NC}"
                ((WARNINGS++))
            fi
        else
            echo -e "${RED}✗ Missing meta description${NC}"
            ((FAILED++))
        fi

        # Check for heading structure
        h1_count=$(echo "$html_content" | grep -c '<h1')
        if [ "$h1_count" -eq 1 ]; then
            echo -e "${GREEN}✓ Single H1 tag${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ $h1_count H1 tags found${NC}"
            ((WARNINGS++))
        fi
    done
}

# Main execution
print_header "🚀 Comprehensive Performance Testing Suite"
echo "Testing speed, compression, caching, security, and SEO optimization"

test_page_load_speed
test_compression
test_cache_headers
test_security_headers
test_resource_optimization
test_mobile_optimization
test_seo_basics

# Summary
print_header "📊 Performance Test Summary"
echo "=================================="
total_tests=$((PASSED + FAILED + WARNINGS))
echo -e "Total tests: $total_tests"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $WARNINGS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}💡 Performance Recommendations:${NC}"
    echo "1. Enable GZIP compression for better load times"
    echo "2. Configure proper caching headers"
    echo "3. Minify CSS and JavaScript files"
    echo "4. Optimize images and use responsive images"
    echo "5. Implement critical security headers"
    echo "6. Use CDN for static resources"
    echo "7. Enable HTTP/2 if available"
fi

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Critical performance issues found!${NC}"
    echo "Please address these issues before deployment."
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ Performance tests completed successfully!${NC}"
    echo "Your sites have good performance characteristics."
    exit 0
fi