#!/bin/bash

# Image Accessibility Test Suite
# Tests for alt text, image optimization, and performance metrics

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result functions
pass_test() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

fail_test() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

info() {
    echo -e "${BLUE}ℹ INFO${NC}: $1"
}

warning() {
    echo -e "${YELLOW}⚠ WARNING${NC}: $1"
}

echo "=== Hugo Sites Image Accessibility & Performance Test Suite ==="
echo

# Function to test a single site
test_site() {
    local site_path=$1
    local site_name=$2

    info "Testing site: $site_name"
    echo

    # Test 1: Check for images without alt text in markdown files
    info "Checking markdown files for images without alt text..."

    while IFS= read -r -d '' file; do
        # Find <img> tags without alt attribute
        if grep -q "<img" "$file"; then
            img_tags=$(grep -o '<img[^>]*>' "$file" | grep -v 'alt=' || true)
            if [[ -n "$img_tags" ]]; then
                fail_test "$file contains <img> tags without alt attribute"
                echo "  Missing alt text in: $img_tags"
            else
                pass_test "$file has proper alt text on all <img> tags"
            fi
        fi

        # Find markdown images without alt text ![text](url) where text is empty
        if grep -q "!\[\](.*\.jpg\|.*\.png\|.*\.gif\|.*\.webp)" "$file"; then
            fail_test "$file contains markdown images without alt text"
        else
            pass_test "$file has proper alt text on markdown images"
        fi

        # Check for video poster images without alternative text
        if grep -q "poster=" "$file"; then
            poster_images=$(grep -o 'poster="[^"]*"' "$file")
            pass_test "$file has video poster image: $poster_images"
        fi

    done < <(find "$site_path" -name "*.md" -not -path "*/node_modules/*" -print0)

    echo

    # Test 2: Check for images without descriptive alt text
    info "Checking quality of alt text descriptions..."

    while IFS= read -r -d '' file; do
        if grep -q "alt=" "$file"; then
            # Check for alt text that's too short or generic
            while IFS= read -r line; do
                alt_text=$(echo "$line" | sed -n 's/.*alt="\([^"]*\)".*/\1/p')
                if [[ -n "$alt_text" ]]; then
                    if [[ ${#alt_text} -lt 10 ]]; then
                        warning "$file has short alt text: '$alt_text'"
                    elif [[ "$alt_text" == "image" || "$alt_text" == "picture" || "$alt_text" == "photo" ]]; then
                        fail_test "$file has non-descriptive alt text: '$alt_text'"
                    else
                        pass_test "$file has descriptive alt text: '$alt_text'"
                    fi
                fi
            done < <(grep "alt=" "$file")
        fi
    done < <(find "$site_path" -name "*.md" -not -path "*/node_modules/*" -print0)

    echo

    # Test 3: Check for image file sizes (performance metric)
    info "Checking image file sizes (performance optimization)..."

    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
            size_mb=$((size / 1024 / 1024))

            if [[ $size_mb -gt 5 ]]; then
                warning "$file is large: ${size_mb}MB (consider optimization)"
            elif [[ $size_mb -gt 1 ]]; then
                info "$file is ${size_mb}MB"
            else
                pass_test "$file is optimized: ${size_mb}MB"
            fi
        fi
    done < <(find "$site_path" \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) -not -path "*/node_modules/*" -print0)

    echo

    # Test 4: Check for responsive image attributes
    info "Checking for responsive image attributes..."

    while IFS= read -r -d '' file; do
        if grep -q "<img" "$file"; then
            if grep -q "class.*img-fluid\|style.*max-width.*100%" "$file"; then
                pass_test "$file has responsive image styling"
            else
                warning "$file may not have responsive image styling"
            fi

            if grep -q "loading=" "$file"; then
                pass_test "$file has lazy loading attribute"
            else
                warning "$file could benefit from lazy loading attribute"
            fi
        fi
    done < <(find "$site_path" -name "*.md" -not -path "*/node_modules/*" -print0)

    echo
}

# Test both sites
test_site "/opt/git/hugo-sites/hugo-graphwiz-ai/myhugoapp" "GraphWiz.ai"
test_site "/opt/git/hugo-sites/hugo-tobias-weiss-org/myhugoapp" "Tobias-Weiss.org"

# Test Results Summary
echo "=== Test Results Summary ==="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review and fix issues.${NC}"
    exit 1
fi