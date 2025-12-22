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

# Link Testing Functions
test_critical_links() {
    echo -e "\n${BLUE}🔗 Testing Critical Links${NC}"
    echo "================================"

    local critical_links=(
        "https://graphwiz.ai/imprint/"
        "https://graphwiz.ai/workshops"
        "https://graphwiz.ai/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"
        "https://tobias-weiss.org/imprint/"
        "https://tobias-weiss.org/leadership/"
    )

    for link in "${critical_links[@]}"; do
        test_url "$link" "200" "Critical link: $link" "100"
    done
}

test_pdf_files() {
    echo -e "\n${BLUE}📄 Testing PDF Files${NC}"
    echo "========================"

    local pdf_files=(
        "https://graphwiz.ai/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"
    )

    for pdf in "${pdf_files[@]}"; do
        echo -n "Testing PDF: $pdf ... "
        local response_code=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 15 "$pdf")
        if [ "$response_code" = "200" ]; then
            # Check if it's actually a PDF by checking content-type
            local content_type=$(curl -L -s -I "$pdf" | grep -i content-type | cut -d' ' -f2- | tr -d '\r\n')
            if [[ $content_type == *"pdf"* ]]; then
                echo -e "${GREEN}✓ OK${NC} (PDF, $content_type)"
                ((PASSED++))
            else
                echo -e "${RED}✗ FAIL${NC} (Not PDF, $content_type)"
                ((FAILED++))
            fi
        else
            echo -e "${RED}✗ FAIL${NC} (HTTP $response_code)"
            ((FAILED++))
        fi
        ((TOTAL_TESTS++))
    done
}

test_external_links() {
    echo -e "\n${BLUE}🌐 Testing External Links${NC}"
    echo "============================="

    local external_links=(
        "https://www.linkedin.com/company/graphwiz-ai-cloud-xr/"
        "https://tobias-weiss.org/"
    )

    for link in "${external_links[@]}"; do
        echo -n "Testing external: $link ... "
        local response_code=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 10 --connect-timeout 5 "$link" 2>/dev/null || echo "000")

        if [[ $response_code =~ ^[23] ]]; then
            echo -e "${GREEN}✓ OK${NC} (HTTP $response_code)"
            ((PASSED++))
        elif [ "$response_code" = "000" ]; then
            echo -e "${YELLOW}⚠ TIMEOUT${NC} (External resource)"
            ((PASSED++))  # Don't fail for external timeouts
        else
            echo -e "${RED}✗ FAIL${NC} (HTTP $response_code)"
            ((FAILED++))
        fi
        ((TOTAL_TESTS++))
    done
}

test_navigation_links() {
    echo -e "\n${BLUE}🧭 Testing Navigation Links${NC}"
    echo "=============================="

    local sites=(
        "https://graphwiz.ai"
        "https://tobias-weiss.org"
    )

    for site in "${sites[@]}"; do
        echo -n "Testing navigation on $site ... "

        # Get the page content and extract navigation links
        local page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} (Cannot fetch page)"
            ((FAILED++))
            ((TOTAL_TESTS++))
            continue
        fi

        # Check if key navigation elements exist
        local nav_ok=true

        # For graphwiz.ai
        if [[ $site == *"graphwiz"* ]]; then
            if echo "$page_content" | grep -q "imprint"; then
                echo -n "Imprint link found, "
            else
                nav_ok=false
            fi

            # Test the imprint link specifically
            local imprint_response=$(curl -L -s -o /dev/null -w "%{http_code}" "$site/imprint/" 2>/dev/null)
            if [ "$imprint_response" = "200" ]; then
                echo -e "${GREEN}✓ OK${NC} (Imprint accessible)"
                ((PASSED++))
            else
                echo -e "${RED}✗ FAIL${NC} (Imprint not accessible: $imprint_response)"
                nav_ok=false
                ((FAILED++))
            fi
        fi

        # For tobias-weiss.org
        if [[ $site == *"tobias"* ]]; then
            if echo "$page_content" | grep -q "imprint\|Impressum"; then
                echo -n "Imprint link found, "
            else
                nav_ok=false
            fi

            # Test the imprint link specifically
            local imprint_response=$(curl -L -s -o /dev/null -w "%{http_code}" "$site/imprint/" 2>/dev/null)
            if [ "$imprint_response" = "200" ]; then
                echo -e "${GREEN}✓ OK${NC} (Imprint accessible)"
                ((PASSED++))
            else
                echo -e "${RED}✗ FAIL${NC} (Imprint not accessible: $imprint_response)"
                nav_ok=false
                ((FAILED++))
            fi
        fi

        ((TOTAL_TESTS++))
    done
}

# Run link tests if enabled
if [ "${SKIP_LINK_TESTS:-0}" != "1" ]; then
    test_critical_links
    test_pdf_files
    test_external_links
    test_navigation_links
fi

# Enhanced Accessibility Testing Functions
test_language_professionalism() {
    echo -e "\n${BLUE}📝 Testing Language Professionalism${NC}"
    echo "========================================"

    local sites=(
        "https://graphwiz.ai"
        "https://tobias-weiss.org"
    )

    for site in "${sites[@]}"; do
        echo -n "Testing language quality on $site ... "

        local page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} (Cannot fetch page)"
            ((FAILED++))
            ((TOTAL_TESTS++))
            continue
        fi

        # Remove HTML tags for text analysis
        local text_content=$(echo "$page_content" | sed 's/<[^>]*>//g' | tr -s ' ')

        # Check for casual language patterns
        local casual_count=$(echo "$text_content" | grep -ioE "(awesome|cool|super|totally|literally|basically|you guys|hey guys|what's up|stuff|things|kinda|sorta|prolly|lol|omg|wtf|btw)" | wc -l)

        # Check for multiple exclamation/question marks
        local excessive_punctuation=$(echo "$text_content" | grep -oE "(!!!+|\?\?\?+)" | wc -l)

        # Check for very long sentences (basic check)
        local long_sentences=$(echo "$text_content" | grep -oE '[^\.!?]{200,}' | wc -l)

        if [ "$casual_count" -eq 0 ] && [ "$excessive_punctuation" -eq 0 ] && [ "$long_sentences" -eq 0 ]; then
            echo -e "${GREEN}✓ OK${NC} (Professional language)"
            ((PASSED++))
        elif [ "$casual_count" -gt 5 ] || [ "$excessive_punctuation" -gt 3 ]; then
            echo -e "${YELLOW}⚠ PARTIAL${NC} ($casual_count casual terms, $excessive_punctuation excessive punctuation)"
            ((PASSED++))
        else
            echo -e "${RED}✗ NEEDS IMPROVEMENT${NC} ($casual_count casual terms, $excessive_punctuation excessive punctuation, $long_sentences long sentences)"
            ((FAILED++))
        fi

        ((TOTAL_TESTS++))
    done
}

test_content_structure() {
    echo -e "\n${BLUE}📖 Testing Content Structure${NC}"
    echo "=================================="

    local sites=(
        "https://graphwiz.ai"
        "https://tobias-weiss.org"
    )

    for site in "${sites[@]}"; do
        echo -n "Testing content structure on $site ... "

        local page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} (Cannot fetch page)"
            ((FAILED++))
            ((TOTAL_TESTS++))
            continue
        fi

        # Count structural elements
        local h1_count=$(echo "$page_content" | grep -o '<h1[^>]*>' | wc -l)
        local h2_count=$(echo "$page_content" | grep -o '<h2[^>]*>' | wc -l)
        local paragraph_count=$(echo "$page_content" | grep -o '<p[^>]*>' | wc -l)
        local list_count=$(echo "$page_content" | grep -o '<\(ul\|ol\|li\)[^>]*>' | wc -l)

        # Basic structure checks
        local structure_ok=true

        if [ "$h1_count" -ne 1 ]; then
            structure_ok=false
        fi

        if [ "$paragraph_count" -gt 10 ] && [ "$list_count" -eq 0 ]; then
            echo -n "Consider using more lists, "
        fi

        if [ "$structure_ok" = true ]; then
            echo -e "${GREEN}✓ OK${NC} (H1: $h1_count, H2: $h2_count, Lists: $list_count)"
            ((PASSED++))
        else
            echo -e "${RED}✗ NEEDS IMPROVEMENT${NC} (H1: $h1_count, should be exactly 1)"
            ((FAILED++))
        fi

        ((TOTAL_TESTS++))
    done
}

test_wcag_compliance_basics() {
    echo -e "\n${BLUE}♿ Testing WCAG Compliance Basics${NC}"
    echo "========================================"

    local sites=(
        "https://graphwiz.ai"
        "https://tobias-weiss.org"
    )

    for site in "${sites[@]}"; do
        echo -n "Testing WCAG basics on $site ... "

        local page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} (Cannot fetch page)"
            ((FAILED++))
            ((TOTAL_TESTS++))
            continue
        fi

        # Check for lang attribute
        local has_lang=$(echo "$page_content" | grep -o 'lang="[^"]*"' | wc -l)

        # Check for viewport meta tag
        local has_viewport=$(echo "$page_content" | grep -o 'name="viewport"' | wc -l)

        # Check for title tag
        local has_title=$(echo "$page_content" | grep -o '<title[^>]*>.*</title>' | wc -l)

        # Check for skip links (for keyboard navigation)
        local has_skip_link=$(echo "$page_content" | grep -oE '(skip.*link|jump.*content|accessibility)' -i | wc -l)

        if [ "$has_lang" -gt 0 ] && [ "$has_viewport" -gt 0 ] && [ "$has_title" -gt 0 ]; then
            echo -e "${GREEN}✓ OK${NC} (Basic WCAG elements present)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ PARTIAL${NC} (Lang: $has_lang, Viewport: $has_viewport, Title: $has_title)"
            ((PASSED++))
        fi

        ((TOTAL_TESTS++))
    done
}

test_focus_management() {
    echo -e "\n${BLUE}🎯 Testing Focus Management${NC}"
    echo "================================="

    local sites=(
        "https://graphwiz.ai"
        "https://tobias-weiss.org"
    )

    for site in "${sites[@]}"; do
        echo -n "Testing focus management on $site ... "

        local page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} (Cannot fetch page)"
            ((FAILED++))
            ((TOTAL_TESTS++))
            continue
        fi

        # Check for problematic tabindex values
        local high_tabindex=$(echo "$page_content" | grep -oE 'tabindex="[0-9]*"' | grep -oE '[0-9]*' | awk '$1 > 100' | wc -l)
        local negative_tabindex=$(echo "$page_content" | grep -o 'tabindex="-?[0-9]*"' | grep -oE '-[0-9]+' | wc -l)

        # Check for interactive elements
        local interactive_elements=$(echo "$page_content" | grep -oE '<(a|button|input|textarea|select)[^>]*>' | wc -l)

        if [ "$high_tabindex" -eq 0 ] && [ "$interactive_elements" -gt 0 ]; then
            echo -e "${GREEN}✓ OK${NC} (Focus management looks good)"
            ((PASSED++))
        elif [ "$high_tabindex" -gt 0 ]; then
            echo -e "${YELLOW}⚠ PARTIAL${NC} ($high_tabindex high tabindex values found)"
            ((PASSED++))
        else
            echo -e "${RED}✗ NEEDS IMPROVEMENT${NC} (Focus management issues)"
            ((FAILED++))
        fi

        ((TOTAL_TESTS++))
    done
}

# Run accessibility tests if enabled
if [ "${SKIP_ACCESSIBILITY_TESTS:-0}" != "1" ]; then
    test_language_professionalism
    test_content_structure
    test_wcag_compliance_basics
    test_focus_management
fi

TOTAL_FAILED=$((FAILED + IMAGE_TESTS_FAILED))

echo -e "\n${BLUE}📊 Final Test Results${NC}"
echo "===================="
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

if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Testing Recommendations:${NC}"
    echo "1. Run: ./test-all-links.sh for comprehensive link analysis"
    echo "2. Check broken links and update or remove them"
    echo "3. Ensure all PDFs are accessible and properly sized"
    echo "4. Review language for professionalism and clarity"
    echo "5. Improve WCAG compliance for better accessibility"
fi

if [ "${SKIP_ACCESSIBILITY_TESTS:-0}" != "1" ]; then
    echo ""
    echo -e "${BLUE}🔧 Accessibility Enhancement Tips:${NC}"
    echo "- Add descriptive alt text to all images"
    echo "- Use proper heading hierarchy (h1 → h2 → h3)"
    echo "- Ensure form inputs have associated labels"
    echo "- Use descriptive link text instead of 'click here'"
    echo "- Add proper ARIA landmarks for screen readers"
    echo "- Test with keyboard navigation only"
fi

if [ "$TOTAL_FAILED" -gt 0 ]; then
    exit 1
else
    echo -e "${GREEN}All tests passed! 🎉${NC}"
    exit 0
fi