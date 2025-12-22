#!/bin/bash

# Comprehensive Accessibility Testing Script
# Tests WCAG compliance, language professionalism, and user experience

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
    echo -e "\n${PURPLE}🔍 $1${NC}"
    echo "-------------------------------------------"
}

# Core accessibility tests
test_wcag_compliance() {
    print_section "WCAG 2.1 Compliance Tests"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing: $site${NC}"

        # Get page content
        page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} Cannot fetch page"
            ((FAILED++))
            continue
        fi

        # Test 1: Language attribute
        echo -n "Language attribute: "
        if echo "$page_content" | grep -q 'lang='; then
            echo -e "${GREEN}✓ PASS${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ FAIL${NC} Missing lang attribute"
            ((FAILED++))
        fi

        # Test 2: Page title
        echo -n "Page title: "
        if echo "$page_content" | grep -q '<title>' && echo "$page_content" | grep -q '</title>'; then
            echo -e "${GREEN}✓ PASS${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ FAIL${NC} Missing title tags"
            ((FAILED++))
        fi

        # Test 3: Viewport meta tag
        echo -n "Viewport meta tag: "
        if echo "$page_content" | grep -q 'viewport'; then
            echo -e "${GREEN}✓ PASS${NC}"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ WARN${NC} Missing viewport (affects mobile)"
            ((WARNINGS++))
        fi

        # Test 4: Image alt text
        echo -n "Image alt text: "
        total_images=$(echo "$page_content" | grep -o '<img[^>]*>' | wc -l)
        images_with_alt=$(echo "$page_content" | grep -o '<img[^>]*alt="[^"]*"[^>]*>' | wc -l)

        if [ "$total_images" -eq 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} (No images)"
        elif [ "$images_with_alt" -eq "$total_images" ]; then
            echo -e "${GREEN}✓ PASS${NC} ($images_with_alt/$total_images images have alt text)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ PARTIAL${NC} ($images_with_alt/$total_images images have alt text)"
            ((WARNINGS++))
        fi

        # Test 5: Heading structure
        echo -n "Heading structure: "
        h1_count=$(echo "$page_content" | grep -o '<h1' | wc -l)
        if [ "$h1_count" -eq 1 ]; then
            echo -e "${GREEN}✓ PASS${NC} (Single h1 found)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ PARTIAL${NC} ($h1_count h1 elements found)"
            ((WARNINGS++))
        fi

        # Test 6: Skip navigation link
        echo -n "Skip navigation: "
        if echo "$page_content" | grep -iq 'skip.*link\|jump.*content\|accessibility'; then
            echo -e "${GREEN}✓ PASS${NC} (Skip link found)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ WARN${NC} (No skip link for keyboard users)"
            ((WARNINGS++))
        fi
    done
}

test_language_quality() {
    print_section "Language Quality & Professionalism"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing language on: $site${NC}"

        page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} Cannot fetch page"
            ((FAILED++))
            continue
        fi

        # Remove HTML for text analysis
        text_content=$(echo "$page_content" | sed 's/<[^>]*>//g' | tr -s ' ')

        # Test for casual language
        echo -n "Professional language: "
        casual_terms=$(echo "$text_content" | grep -ioE "(awesome|cool|super|totally|literally|basically|you guys|hey guys|what's up|stuff|things|kinda|sorta|prolly)" | wc -l)
        excessive_punct=$(echo "$text_content" | grep -oE "(!!!+|\?\?\?+)" | wc -l)

        if [ "$casual_terms" -eq 0 ] && [ "$excessive_punct" -eq 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} (Professional tone)"
            ((PASSED++))
        elif [ "$casual_terms" -gt 5 ] || [ "$excessive_punct" -gt 3 ]; then
            echo -e "${RED}✗ FAIL${NC} ($casual_terms casual terms, $excessive_punct excessive punctuation)"
            ((FAILED++))
        else
            echo -e "${YELLOW}⚠ PARTIAL${NC} (Minor informalities: $casual_terms casual terms)"
            ((WARNINGS++))
        fi

        # Test for clarity (sentence length)
        echo -n "Sentence clarity: "
        long_sentences=$(echo "$text_content" | grep -oE '[^\.!?]{150,}' | wc -l)
        if [ "$long_sentences" -lt 3 ]; then
            echo -e "${GREEN}✓ PASS${NC} (Good sentence length)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ WARN${NC} ($long_sentences very long sentences)"
            ((WARNINGS++))
        fi

        # Test for corporate jargon
        echo -n "Jargon level: "
        jargon_count=$(echo "$text_content" | grep -ioE "(synergize|leverage|paradigm|optimize|maximize|solution-oriented|results-driven|value-added|end-to-end|seamless|holistic)" | wc -l)
        if [ "$jargon_count" -lt 5 ]; then
            echo -e "${GREEN}✓ PASS${NC} (Low jargon usage: $jargon_count)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ WARN${NC} (High jargon usage: $jargon_count instances)"
            ((WARNINGS++))
        fi
    done
}

test_mobile_accessibility() {
    print_section "Mobile Accessibility"

    for site in "${SITES[@]}"; do
        echo -e "\n${YELLOW}Testing mobile on: $site${NC}"

        page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} Cannot fetch page"
            ((FAILED++))
            continue
        fi

        # Test for responsive design
        echo -n "Responsive design: "
        viewport_check=$(echo "$page_content" | grep -o 'width=device-width' | wc -l)
        if [ "$viewport_check" -gt 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} (Device-width viewport set)"
            ((PASSED++))
        else
            echo -e "${RED}✗ FAIL${NC} (Not mobile-responsive)"
            ((FAILED++))
        fi

        # Test for touch-friendly elements (basic check)
        echo -n "Touch targets: "
        if echo "$page_content" | grep -q 'button\|input.*type.*submit\|input.*type.*button'; then
            echo -e "${GREEN}✓ PASS${NC} (Interactive elements found)"
            ((PASSED++))
        else
            echo -e "${YELLOW}⚠ WARN${NC} (Limited interactive elements)"
            ((WARNINGS++))
        fi
    done
}

test_color_contrast() {
    print_section "Color Contrast (Basic)"

    echo -e "${YELLOW}Checking for obvious contrast issues:${NC}"

    for site in "${SITES[@]}"; do
        echo -n "$site: "

        page_content=$(curl -L -s "$site" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ FAIL${NC} Cannot fetch page"
            ((FAILED++))
            continue
        fi

        # Basic check for same color text and background
        if echo "$page_content" | grep -qi "color:#ffffff.*background:#ffffff\|color:#000000.*background:#000000"; then
            echo -e "${RED}✗ FAIL${NC} (Same color text/background found)"
            ((FAILED++))
        else
            echo -e "${GREEN}✓ PASS${NC} (No obvious contrast issues)"
            ((PASSED++))
        fi
    done
}

# Main execution
print_header "🔐 Comprehensive Accessibility Testing Suite"
echo "Testing WCAG 2.1 compliance, language quality, and user experience"

test_wcag_compliance
test_language_quality
test_mobile_accessibility
test_color_contrast

# Summary
print_header "📊 Accessibility Test Summary"
echo "=================================="
total_tests=$((PASSED + FAILED + WARNINGS))
echo -e "Total tests: $total_tests"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $WARNINGS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}💡 Accessibility Recommendations:${NC}"
    echo "1. Add descriptive alt text to all images"
    echo "2. Ensure proper heading hierarchy (h1 → h2 → h3)"
    echo "3. Use professional, clear language"
    echo "4. Implement skip navigation for keyboard users"
    echo "5. Test with screen readers and keyboard-only navigation"
    echo "6. Consider using accessibility testing tools like axe-core"
fi

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Critical accessibility issues found!${NC}"
    echo "Please address these issues before deployment."
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ Accessibility tests completed successfully!${NC}"
    echo "Your sites meet basic accessibility standards."
    exit 0
fi