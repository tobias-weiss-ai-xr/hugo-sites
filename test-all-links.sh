#!/bin/bash

# Comprehensive Link Testing Script for Hugo Sites
# Tests all internal and external links across graphwiz.ai and tobias-weiss.org

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Sites to test
SITES=("https://graphwiz.ai" "https://tobias-weiss.org")

# Results counters
TOTAL_LINKS=0
WORKING_LINKS=0
BROKEN_LINKS=0
WARNINGS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✓ OK${NC} $message"
            ((WORKING_LINKS++))
            ;;
        "FAIL")
            echo -e "${RED}✗ FAIL${NC} $message"
            ((BROKEN_LINKS++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠ WARN${NC} $message"
            ((WARNINGS++))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ INFO${NC} $message"
            ;;
    esac
    ((TOTAL_LINKS++))
}

# Function to test a single link
test_link() {
    local url=$1
    local source_page=$2

    # Skip certain patterns
    if [[ $url =~ ^mailto: ]] || [[ $url =~ ^tel: ]] || [[ $url =~ ^# ]] || [[ $url =~ ^javascript: ]]; then
        print_status "INFO" "Skipping $url (non-HTTP link)"
        return 0
    fi

    # Handle relative URLs
    if [[ $url != ^http:// && $url != ^https:// ]]; then
        # Convert relative URL to absolute
        if [[ $source_page ]]; then
            url=$(echo "$source_page" | sed 's|/[^/]*$||')/$url
            url=$(echo "$url" | sed 's|/\./|/|g' | sed 's|[^/]*/\.\./|/../|g' | sed 's|/[^/]\+/\.\./|/|g')
        else
            print_status "WARN" "Cannot resolve relative URL: $url"
            return 1
        fi
    fi

    # Test the link
    local response_code
    response_code=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 10 --retry 1 "$url" 2>/dev/null)

    case $response_code in
        200|201|202|204)
            print_status "OK" "$url (HTTP $response_code)"
            ;;
        301|302|303|307|308)
            print_status "OK" "$url (Redirect HTTP $response_code)"
            ;;
        403|401)
            print_status "WARN" "$url (HTTP $response_code - Access restricted)"
            ;;
        404)
            print_status "FAIL" "$url (HTTP $response_code - Not found)"
            ;;
        500|502|503|504)
            print_status "FAIL" "$url (HTTP $response_code - Server error)"
            ;;
        000)
            print_status "FAIL" "$url (Connection failed)"
            ;;
        *)
            print_status "WARN" "$url (HTTP $response_code - Unknown status)"
            ;;
    esac
}

# Function to extract and test all links from a page
test_page_links() {
    local page_url=$1
    local site=$2

    echo -e "\n${BLUE}Testing page: $page_url${NC}"

    # Get the page content
    local page_content
    page_content=$(curl -L -s "$page_url" 2>/dev/null)

    if [ $? -ne 0 ]; then
        print_status "FAIL" "Cannot fetch page: $page_url"
        return 1
    fi

    # Extract links using grep and sed
    local links
    links=$(echo "$page_content" | grep -oE 'href="[^"]+"|src="[^"]+"' | sed 's/href="\|src="//g' | sed 's/"$//g' | sort | uniq)

    if [ -z "$links" ]; then
        print_status "WARN" "No links found on page: $page_url"
        return 0
    fi

    echo "Found $(echo "$links" | wc -l) unique links"

    # Test each link
    while IFS= read -r link; do
        if [ -n "$link" ]; then
            test_link "$link" "$page_url"
        fi
    done <<< "$links"
}

# Function to test site sitemap
test_site_sitemap() {
    local site=$1

    echo -e "\n${BLUE}Testing sitemap: $site/sitemap.xml${NC}"

    local sitemap_content
    sitemap_content=$(curl -L -s "$site/sitemap.xml" 2>/dev/null)

    if [ $? -ne 0 ]; then
        print_status "WARN" "No sitemap found for $site"
        return 1
    fi

    # Extract URLs from sitemap
    local urls
    urls=$(echo "$sitemap_content" | grep -oE '<loc>[^<]+</loc>' | sed 's|<loc>||g' | sed 's|</loc>||g')

    if [ -z "$urls" ]; then
        print_status "WARN" "No URLs found in sitemap for $site"
        return 1
    fi

    echo "Found $(echo "$urls" | wc -l) pages in sitemap"

    # Test each page
    while IFS= read -r url; do
        if [ -n "$url" ]; then
            test_page_links "$url" "$site"
        fi
    done <<< "$urls"
}

# Function to test specific known pages
test_known_pages() {
    local site=$1
    shift
    local pages=("$@")

    for page in "${pages[@]}"; do
        local full_url="${site}${page}"
        echo -e "\n${BLUE}Testing known page: $full_url${NC}"

        local response_code
        response_code=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 10 "$full_url" 2>/dev/null)

        if [ "$response_code" = "200" ]; then
            print_status "OK" "$full_url (HTTP $response_code)"
            test_page_links "$full_url" "$site"
        else
            print_status "FAIL" "$full_url (HTTP $response_code - Not found)"
        fi
    done
}

# Main script
echo -e "${BLUE}🔗 Comprehensive Link Testing for Hugo Sites${NC}"
echo "=================================================="

# Test each site
for site in "${SITES[@]}"; do
    echo -e "\n${YELLOW}🌐 Testing site: $site${NC}"
    echo "-------------------------------------------"

    # Test main page
    echo -e "\n${BLUE}Testing main page: $site${NC}"
    main_response=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 10 "$site" 2>/dev/null)
    if [ "$main_response" = "200" ]; then
        print_status "OK" "$site (Main page accessible)"
        test_page_links "$site" "$site"
    else
        print_status "FAIL" "$site (Main page not accessible - HTTP $main_response)"
        continue
    fi

    # Test specific important pages
    if [[ $site == *"graphwiz.ai"* ]]; then
        test_known_pages "$site" \
            "/imprint/" \
            "/focus-areas/" \
            "/ai/" \
            "/xr/" \
            "/digital-sovereignty/" \
            "/ops" \
            "/security" \
            "/workshops" \
            "/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"
    elif [[ $site == *"tobias-weiss.org"* ]]; then
        test_known_pages "$site" \
            "/imprint/" \
            "/leadership/" \
            "/graphwiz/" \
            "/pgp/"
    fi

    # Try to test sitemap if it exists
    test_site_sitemap "$site"
done

# Summary
echo -e "\n${YELLOW}📊 Test Summary${NC}"
echo "==================="
echo -e "Total links tested: ${BLUE}$TOTAL_LINKS${NC}"
echo -e "Working links: ${GREEN}$WORKING_LINKS${NC}"
echo -e "Broken links: ${RED}$BROKEN_LINKS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [ $BROKEN_LINKS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All critical links are working!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ $BROKEN_LINKS broken links found. Please fix them.${NC}"
    exit 1
fi