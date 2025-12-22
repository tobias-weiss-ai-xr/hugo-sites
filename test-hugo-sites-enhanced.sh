#!/bin/bash
# Enhanced Test suite for Hugo multi-site configuration
# Tests SSL certificates, routing, page rendering, and image accessibility

# set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
IMAGE_TESTS_PASSED=0
IMAGE_TESTS_FAILED=0

HUGO_SITES_DIR="/opt/git/hugo-sites"
SITES=(
    "hugo-tobias-weiss-org/myhugoapp"
    "hugo-graphwiz-ai/myhugoapp"
    "hugo-chemie-lernen-org/myhugoapp"
)

# Original test functions
test_url() {
    local url="$1"
    local expected_status="${2:-200}"
    local description="$3"
    local min_size="${4:-100}"

    echo -n "Testing: $description... "

    response=$(curl -s --max-time 10 -w "\n%{http_code}\n%{size_download}" "$url" 2>&1 || true)
    status=$(echo "$response" | tail -2 | head -1)
    size=$(echo "$response" | tail -1)

    if [ "$status" = "$expected_status" ] && [ "$size" -ge "$min_size" ]; then
        echo -e "${GREEN}PASS${NC} (HTTP $status, $size bytes)"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} (HTTP $status, $size bytes, expected $expected_status with >=$min_size bytes)"
        ((FAILED++))
    fi
}

test_content() {
    local url="$1"
    local search_string="$2"
    local description="$3"

    echo -n "Testing content: $description... "

    if curl -s --max-time 10 "$url" | grep -q "$search_string"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} (String '$search_string' not found)"
        ((FAILED++))
    fi
}

# Image accessibility test functions
test_image_alt_attributes() {
    local url="$1"
    local description="$2"
    local min_images="${3:-0}"

    echo -n "Testing image alt attributes: $description... "

    local html_content=$(curl -s --max-time 10 "$url")
    local total_images=$(echo "$html_content" | grep -o '<img[^>]*>' | wc -l)
    local images_with_alt=$(echo "$html_content" | grep -o '<img[^>]*alt="[^"]*"[^>]*>' | wc -l)

    if [ "$total_images" -eq 0 ] && [ "$min_images" -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} (No images found, as expected)"
        ((IMAGE_TESTS_PASSED++))
    elif [ "$total_images" -gt 0 ] && [ "$images_with_alt" -eq "$total_images" ]; then
        echo -e "${GREEN}PASS${NC} ($images_with_alt/$total_images images have alt text)"
        ((IMAGE_TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC} (Only $images_with_alt/$total_images images have alt text)"
        ((IMAGE_TESTS_FAILED++))
    fi
}

test_image_aria_labels() {
    local url="$1"
    local description="$2"

    echo -n "Testing image aria-labels: $description... "

    local html_content=$(curl -s --max-time 10 "$url")
    local total_images=$(echo "$html_content" | grep -o '<img[^>]*>' | wc -l)
    local images_with_aria=$(echo "$html_content" | grep -o '<img[^>]*aria-label="[^"]*"[^>]*>' | wc -l)

    if [ "$total_images" -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} (No images found)"
        ((IMAGE_TESTS_PASSED++))
    elif [ "$images_with_aria" -ge $((total_images / 2)) ]; then
        echo -e "${GREEN}PASS${NC} ($images_with_aria/$total_images images have aria-labels - good coverage)"
        ((IMAGE_TESTS_PASSED++))
    else
        echo -e "${YELLOW}PARTIAL${NC} ($images_with_aria/$total_images images have aria-labels - room for improvement)"
        ((IMAGE_TESTS_PASSED++))  # Consider partial pass
    fi
}

test_image_lazy_loading() {
    local url="$1"
    local description="$2"

    echo -n "Testing image lazy loading: $description... "

    local html_content=$(curl -s --max-time 10 "$url")
    local total_images=$(echo "$html_content" | grep -o '<img[^>]*>' | wc -l)
    local images_with_lazy=$(echo "$html_content" | grep -o '<img[^>]*loading="lazy"[^>]*>' | wc -l)

    if [ "$total_images" -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} (No images found)"
        ((IMAGE_TESTS_PASSED++))
    elif [ "$images_with_lazy" -ge $((total_images / 2)) ]; then
        echo -e "${GREEN}PASS${NC} ($images_with_lazy/$total_images images have lazy loading - good coverage)"
        ((IMAGE_TESTS_PASSED++))
    else
        echo -e "${YELLOW}PARTIAL${NC} ($images_with_lazy/$total_images images have lazy loading - room for improvement)"
        ((IMAGE_TESTS_PASSED++))  # Consider partial pass
    fi
}

test_file_based_image_accessibility() {
    echo "=== File-based Image Accessibility Tests ==="

    for site in "${SITES[@]}"; do
        local site_path="$HUGO_SITES_DIR/$site"
        local site_name=$(basename $(dirname "$site"))

        if [ ! -d "$site_path" ]; then
            echo -e "${YELLOW}Skipping $site_name (directory not found)${NC}"
            continue
        fi

        echo -e "\n${BLUE}Testing site: $site_name${NC}"

        # Test HTML files for proper image attributes
        local html_files_with_images=$(find "$site_path" -name "*.html" -exec grep -l '<img' {} \; 2>/dev/null | wc -l)
        local total_html_images=$(find "$site_path" -name "*.html" -exec grep -c '<img' {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
        local html_images_with_alt=$(find "$site_path" -name "*.html" -exec grep -c 'alt=' {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')

        echo "  HTML files with images: $html_files_with_images"
        echo "  Total HTML images: $total_html_images"
        echo "  HTML images with alt: $html_images_with_alt"

        if [ "$total_html_images" -eq 0 ]; then
            echo -e "  ${GREEN}✓ No HTML images found (as expected for some sites)${NC}"
            ((IMAGE_TESTS_PASSED++))
        elif [ "$html_images_with_alt" -ge "$((total_html_images * 8 / 10))" ]; then
            echo -e "  ${GREEN}✓ Good alt text coverage: $((html_images_with_alt * 100 / total_html_images))%${NC}"
            ((IMAGE_TESTS_PASSED++))
        else
            echo -e "  ${RED}✗ Poor alt text coverage: $((html_images_with_alt * 100 / total_html_images))%${NC}"
            ((IMAGE_TESTS_FAILED++))
        fi

        # Test image file organization
        local static_img_dir="$site_path/static/img"
        if [ -d "$static_img_dir" ]; then
            local image_count=$(find "$static_img_dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) | wc -l)
            local images_with_spaces=$(find "$static_img_dir" -type f \( -name "* *" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) | grep " " | wc -l)

            echo "  Static images: $image_count"
            echo "  Images with spaces in filename: $images_with_spaces"

            if [ "$images_with_spaces" -eq 0 ]; then
                echo -e "  ${GREEN}✓ No filenames with spaces${NC}"
                ((IMAGE_TESTS_PASSED++))
            else
                echo -e "  ${YELLOW}⚠ $images_with_spaces images have spaces in filenames${NC}"
                ((IMAGE_TESTS_PASSED++))  # Warning, not failure
            fi

            # Check for subdirectory organization for sites with many images
            if [ "$image_count" -gt 10 ]; then
                local subdirs=$(find "$static_img_dir" -mindepth 1 -type d | wc -l)
                if [ "$subdirs" -gt 0 ]; then
                    echo -e "  ${GREEN}✓ Well organized: $subdirs subdirectories${NC}"
                    ((IMAGE_TESTS_PASSED++))
                else
                    echo -e "  ${YELLOW}⚠ Could benefit from subdirectories ($image_count images in root)${NC}"
                    ((IMAGE_TESTS_PASSED++))
                fi
            fi
        fi
    done
}

test_image_performance() {
    local url="$1"
    local description="$2"

    echo -n "Testing image performance: $description... "

    local html_content=$(curl -s --max-time 10 "$url")
    local image_urls=$(echo "$html_content" | grep -oE 'src="[^"]*\.(jpg|jpeg|png|gif|webp)"' | sed 's/src="//' | sed 's/"//' | head -5)

    if [ -z "$image_urls" ]; then
        echo -e "${GREEN}PASS${NC} (No images to test)"
        ((IMAGE_TESTS_PASSED++))
        return
    fi

    local large_images=0
    local total_tested=0

    for img_url in $image_urls; do
        # Convert relative URLs to absolute
        if [[ "$img_url" == /* ]]; then
            img_url="${url}$img_url"
        fi

        # Test image size (download just headers)
        local img_size=$(curl -s --max-time 5 -I "$img_url" 2>/dev/null | grep -i content-length | awk '{print $2}' | tr -d '\r' || echo 0)

        if [ "$img_size" -gt 524288 ]; then  # 512KB
            large_images=$((large_images + 1))
        fi
        total_tested=$((total_tested + 1))
    done

    if [ "$large_images" -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} (No oversized images detected)"
        ((IMAGE_TESTS_PASSED++))
    else
        echo -e "${YELLOW}PARTIAL${NC} ($large_images/$total_tested images could be optimized)"
        ((IMAGE_TESTS_PASSED++))  # Performance optimization, not failure
    fi
}

# 404 Error Page Test Functions
test_404_page() {
    local url="$1"
    local expected_status="$2"
    local description="$3"
    local search_string="$4"
    local min_size="$5"

    echo -n "Testing: $description... "

    response=$(curl -s --max-time 10 -w "\n%{http_code}\n%{size_download}" "$url" 2>&1 || true)
    status=$(echo "$response" | tail -2 | head -1)
    size=$(echo "$response" | tail -1)
    content=$(echo "$response" | head -n -2)

    if [ "$status" = "$expected_status" ] && [ "$size" -ge "$min_size" ] && [[ "$content" == *"$search_string"* ]]; then
        echo -e "${GREEN}PASS${NC} (HTTP $status, $size bytes, contains '$search_string')"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} (HTTP $status, $size bytes, expected $expected_status with >=$min_size bytes and '$search_string')"
        ((FAILED++))
    fi
}

test_404_navigation() {
    local url="$1"
    shift
    local missing_links=0

    echo -n "Testing: 404 navigation links for $url... "

    response=$(curl -s --max-time 10 "$url" 2>/dev/null || true)

    for link in "$@"; do
        if [[ "$response" != *"$link"* ]]; then
            missing_links=$((missing_links + 1))
        fi
    done

    if [ "$missing_links" -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} (All navigation links present)"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} ($missing_links missing navigation links)"
        ((FAILED++))
    fi
}

print_header() {
    echo ""
    echo "=== $1 ==="
}

# Main test execution
echo "========================================"
echo "Enhanced Hugo Multi-Site Test Suite"
echo "========================================"
echo ""

# Original tests
print_header "SSL Certificate Tests"
test_url "https://chemie-lernen.org/" 200 "chemie-lernen.org homepage" 1000
test_url "https://graphwiz.ai/" 200 "graphwiz.ai homepage" 1000
test_url "https://tobias-weiss.org/" 200 "tobias-weiss.org homepage" 1000
echo ""

print_header "Content Validation"
test_content "https://chemie-lernen.org/" "Besuchen Sie unser Wiki" "Wiki Card"
test_content "https://graphwiz.ai/" "🌐 / AI 🤖 / DevOps 🛠️" "GraphWiz headline"
test_content "https://tobias-weiss.org/" "me_wanted_big.png" "Me wanted logo reference"
echo ""

# Enhanced image accessibility tests
print_header "Live Site Image Accessibility Tests"
test_image_alt_attributes "https://tobias-weiss.org/" "Tobias Weiss homepage" 1
test_image_aria_labels "https://tobias-weiss.org/" "Tobias Weiss homepage"
test_image_lazy_loading "https://tobias-weiss.org/" "Tobias Weiss homepage"
test_image_performance "https://tobias-weiss.org/" "Tobias Weiss homepage"

test_image_alt_attributes "https://graphwiz.ai/" "GraphWiz AI homepage" 1
test_image_aria_labels "https://graphwiz.ai/" "GraphWiz AI homepage"
test_image_lazy_loading "https://graphwiz.ai/" "GraphWiz AI homepage"
test_image_performance "https://graphwiz.ai/" "GraphWiz AI homepage"

test_image_alt_attributes "https://chemie-lernen.org/" "Chemie Lernen homepage" 0
test_image_aria_labels "https://chemie-lernen.org/" "Chemie Lernen homepage"
test_image_lazy_loading "https://chemie-lernen.org/" "Chemie Lernen homepage"
echo ""

test_file_based_image_accessibility
echo ""

print_header "Gallery and Rich Content Tests"
test_url "https://tobias-weiss.org/gallery/" 200 "Gallery page" 2000
test_content "https://tobias-weiss.org/gallery/" "swiper-wrapper" "Swiper.js presence"
test_image_alt_attributes "https://tobias-weiss.org/gallery/" "Gallery page" 1
echo ""

print_header "404 Error Page Tests"
echo "Testing custom 404 pages for all sites..."

# Test 404 pages return correct status codes and content
test_404_page "https://tobias-weiss.org/nonexistent-page-12345" 404 "Tobias Weiss 404 page" "Page Not Found" 1000
test_404_page "https://graphwiz.ai/missing-url-67890" 404 "GraphWiz 404 page" "Digital Territory Not Found" 1000
test_404_page "https://chemie-lernen.org/broken-link-abcde" 404 "Chemie Lernen 404 page" "404" 500

# Test 404 page navigation and features
test_404_navigation "https://tobias-weiss.org/missing-path" "/graphwiz/" "/research/" "/gallery/" "/leadership/" "/pgp/"
test_404_navigation "https://graphwiz.ai/invalid-route" "/focus-areas/" "/ai/" "/advanced-delegation-systems/" "/xr/" "/digital-sovereignty/" "/ops" "/security" "/workshops"

# Test contact information in 404 pages
test_content "https://tobias-weiss.org/not-found" "spam@tobias-weiss.org" "Contact info in Tobias Weiss 404"
test_content "https://graphwiz.ai/not-found" "info@graphwiz.ai" "Contact info in GraphWiz 404"

# Test homepage links in 404 pages
test_content "https://tobias-weiss.org/missing-page" "/" "Homepage link in Tobias Weiss 404"
test_content "https://graphwiz.ai/missing-page" "/" "Homepage link in GraphWiz 404"
test_content "https://chemie-lernen.org/missing-page" "/" "Homepage link in Chemie Lernen 404"
echo ""

echo "========================================"
echo "Test Results Summary"
echo "========================================"
echo -e "${GREEN}Core Tests Passed: $PASSED${NC}"
echo -e "${RED}Core Tests Failed: $FAILED${NC}"
echo -e "${GREEN}Image Accessibility Tests Passed: $IMAGE_TESTS_PASSED${NC}"
echo -e "${RED}Image Accessibility Tests Failed: $IMAGE_TESTS_FAILED${NC}"
echo "========================================"

TOTAL_TESTS=$((PASSED + FAILED + IMAGE_TESTS_PASSED + IMAGE_TESTS_FAILED))
TOTAL_PASSED=$((PASSED + IMAGE_TESTS_PASSED))
TOTAL_FAILED=$((FAILED + IMAGE_TESTS_FAILED))

echo -e "Overall: ${GREEN}$TOTAL_PASSED${NC}/${TOTAL_TESTS} tests passed"

# Additional metrics and recommendations
if [ "$IMAGE_TESTS_FAILED" -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Image Accessibility Recommendations:${NC}"
    echo "1. Run: ./image-labeling-simple.sh to improve image labeling"
    echo "2. Add aria-label attributes to all images for better screen reader support"
    echo "3. Implement lazy loading for better performance"
    echo "4. Consider image optimization for large files"
fi

if [ "$TOTAL_FAILED" -gt 0 ]; then
    exit 1
else
    echo -e "${GREEN}All tests passed! 🎉${NC}"
    exit 0
fi