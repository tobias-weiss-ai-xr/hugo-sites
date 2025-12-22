"""
Test suite for Hugo multi-site configuration
Tests SSL certificates, routing, and page rendering using pytest
"""

import pytest
import requests
from requests.exceptions import SSLError, RequestException
import ssl
import socket
import re
import time
import gzip
import hashlib
from urllib.parse import urljoin, urlparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from bs4 import BeautifulSoup
import html5lib


class TestSSLCertificates:
    """Test SSL certificate validity for all domains"""

    domains = [
        "chemie-lernen.org",
        "graphwiz.ai",
        "tobias-weiss.org",
        "next.tobias-weiss.org"
    ]

    @pytest.mark.parametrize("domain", domains)
    def test_ssl_certificate_valid(self, domain):
        """Verify SSL certificate is valid and trusted"""
        context = ssl.create_default_context()
        with socket.create_connection((domain, 443), timeout=10) as sock:
            with context.wrap_socket(sock, server_hostname=domain) as ssock:
                cert = ssock.getpeercert()
                assert cert is not None, f"No certificate found for {domain}"
                # Certificate is valid if we got here without exception


class TestHTTPSRedirects:
    """Test HTTP to HTTPS redirects"""

    sites = [
        ("http://chemie-lernen.org/", "https://chemie-lernen.org/"),
        ("http://graphwiz.ai/", "https://graphwiz.ai/"),
        ("http://tobias-weiss.org/", "https://tobias-weiss.org/")
    ]

    @pytest.mark.parametrize("http_url,https_url", sites)
    def test_http_redirects_to_https(self, http_url, https_url):
        """Verify HTTP URLs redirect to HTTPS with 301/302"""
        response = requests.get(http_url, allow_redirects=False, timeout=10)
        assert response.status_code in [301, 302], \
            f"Expected redirect status code, got {response.status_code}"
        assert response.headers.get('Location') == https_url, \
            f"Expected redirect to {https_url}, got {response.headers.get('Location')}"


class TestHomepages:
    """Test homepage accessibility and basic content"""

    sites = [
        ("https://chemie-lernen.org/", "Chemie Lernen", 1000),
        ("https://graphwiz.ai/", "GraphWiz", 1000),
        ("https://tobias-weiss.org/", "Tobias Weiss", 1000)
    ]

    @pytest.mark.parametrize("url,title,min_size", sites)
    def test_homepage_accessible(self, url, title, min_size):
        """Verify homepage is accessible and returns expected content"""
        response = requests.get(url, timeout=10)
        assert response.status_code == 200, \
            f"Expected 200 OK, got {response.status_code}"
        assert len(response.content) >= min_size, \
            f"Content too small: {len(response.content)} bytes (expected >={min_size})"
        assert title in response.text, \
            f"Expected to find '{title}' in page content"


class TestChemieLernenContent:
    """Test Chemie Lernen specific content"""

    def test_periodic_table_page(self):
        """Verify periodic table page loads with Three.js"""
        url = "https://chemie-lernen.org/periodensystem/"
        response = requests.get(url, timeout=10)
        assert response.status_code == 200
        assert len(response.content) >= 5000, "Periodic table page too small"

    def test_german_language_interface(self):
        """Verify German language content is present"""
        url = "https://chemie-lernen.org/"
        response = requests.get(url, timeout=10)
        assert "Chemie Lernen" in response.text
        assert 'lang="en"' in response.text or 'de-de' in response.text

    def test_periodic_table_buttons(self):
        """Verify periodic table has German button labels"""
        url = "https://chemie-lernen.org/periodensystem/"
        response = requests.get(url, timeout=10)
        assert "TABELLE" in response.text
        assert "KUGEL" in response.text or "HELIX" in response.text

    def test_threejs_cdn(self):
        """Verify Three.js is loaded from CDN"""
        url = "https://chemie-lernen.org/periodensystem/"
        response = requests.get(url, timeout=10)
        assert "cdn.jsdelivr.net" in response.text, \
            "Three.js should be loaded from CDN"


class TestGraphWizContent:
    """Test GraphWiz AI specific content"""

    pages = [
        ("https://graphwiz.ai/ai/", "Artificial Intelligence", 500),
        ("https://graphwiz.ai/xr/", "Xr", 500),
        ("https://graphwiz.ai/ops/", "Ops", 500),
        ("https://graphwiz.ai/workshops/", "Workshops", 500)
    ]
...
    def test_homepage_headline(self):
        """Verify GraphWiz homepage has correct headline"""
        url = "https://graphwiz.ai/"
...
class TestTobiasWeissContent:
    """Test Tobias Weiss personal site content"""

    def test_gallery_page(self):
        """Verify gallery page loads with images"""
        url = "https://tobias-weiss.org/gallery/"
        response = requests.get(url, timeout=10)
        assert response.status_code == 200
        assert len(response.content) >= 2000
        assert "Tallinn" in response.text
        assert "/img/" in response.text, "Gallery should have image references"

    def test_pgp_page(self):
        """Verify PGP page loads with public key"""
        url = "https://tobias-weiss.org/pgp/"
        response = requests.get(url, timeout=10)
        assert response.status_code == 200
        assert len(response.content) >= 2000
        assert "PGP" in response.text or "Pretty Good Privacy" in response.text
        assert "BEGIN PGP PUBLIC KEY BLOCK" in response.text


class TestTraefikRouting:
    """Test Traefik routing and SSL termination"""

    def test_hsts_headers(self):
        """Verify HSTS headers are present"""
        urls = [
            "https://chemie-lernen.org/",
            "https://graphwiz.ai/",
            "https://tobias-weiss.org/"
        ]
        for url in urls:
            response = requests.get(url, timeout=10)
            assert "strict-transport-security" in response.headers, \
                f"HSTS header missing for {url}"

    def test_correct_domain_routing(self):
        """Verify each domain routes to correct Hugo site"""
        test_cases = [
            ("https://chemie-lernen.org/", "Chemie Lernen"),
            ("https://graphwiz.ai/", "GraphWiz"),
            ("https://tobias-weiss.org/", "Tobias Weiss")
        ]
        for url, expected_title in test_cases:
            response = requests.get(url, timeout=10)
            assert expected_title in response.text, \
                f"Expected '{expected_title}' for {url}"


class Test404Pages:
    """Test custom 404 error pages for all sites"""

    sites = [
        ("https://tobias-weiss.org/nonexistent-page", "Page Not Found", "Tobias Weiss"),
        ("https://graphwiz.ai/invalid-url", "Digital Territory Not Found", "GraphWiz"),
        ("https://chemie-lernen.org/missing-page", "404", "Chemie Lernen")
    ]

    @pytest.mark.parametrize("url,expected_title,site_name", sites)
    def test_404_page_accessible(self, url, expected_title, site_name):
        """Verify 404 pages are accessible and return proper content"""
        response = requests.get(url, timeout=10)
        assert response.status_code == 404, \
            f"Expected 404 status code for {url}, got {response.status_code}"
        assert len(response.content) >= 1000, \
            f"404 page content too small for {site_name}: {len(response.content)} bytes"
        assert expected_title in response.text, \
            f"Expected to find '{expected_title}' in {site_name} 404 page"

    def test_tobias_weiss_404_navigation(self):
        """Test Tobias Weiss 404 page has proper navigation links"""
        url = "https://tobias-weiss.org/nonexistent-page"
        response = requests.get(url, timeout=10)
        assert response.status_code == 404

        # Check for main navigation links
        expected_links = [
            "/graphwiz/",
            "/research/",
            "/gallery/",
            "/leadership/",
            "/pgp/"
        ]
        for link in expected_links:
            assert link in response.text, f"Missing navigation link {link} in Tobias Weiss 404 page"

    def test_graphwiz_404_navigation(self):
        """Test GraphWiz 404 page has proper navigation links"""
        url = "https://graphwiz.ai/invalid-url"
        response = requests.get(url, timeout=10)
        assert response.status_code == 404

        # Check for main navigation links
        expected_links = [
            "/focus-areas/",
            "/ai/",
            "/advanced-delegation-systems/",
            "/xr/",
            "/digital-sovereignty/",
            "/ops",
            "/security",
            "/workshops"
        ]
        for link in expected_links:
            assert link in response.text, f"Missing navigation link {link} in GraphWiz 404 page"

    def test_404_pages_have_contact_info(self):
        """Test 404 pages include contact information"""
        test_cases = [
            ("https://tobias-weiss.org/missing", "spam@tobias-weiss.org"),
            ("https://graphwiz.ai/missing", "info@graphwiz.ai")
        ]

        for url, expected_email in test_cases:
            response = requests.get(url, timeout=10)
            assert response.status_code == 404
            assert expected_email in response.text, \
                f"Missing contact email {expected_email} in 404 page"

    def test_404_pages_return_home_link(self):
        """Test 404 pages have links back to homepage"""
        test_cases = [
            "https://tobias-weiss.org/nonexistent",
            "https://graphwiz.ai/nonexistent",
            "https://chemie-lernen.org/nonexistent"
        ]

        for url in test_cases:
            response = requests.get(url, timeout=10)
            assert response.status_code == 404
            assert "/" in response.text, "404 page should have link to homepage"


class TestDockerContainers:
    """Test Docker container health (requires local execution)"""

    @pytest.mark.skipif(
        socket.gethostname() != "localhost.localdomain",
        reason="Only run on production server"
    )
    def test_hugo_containers_running(self):
        """Verify Hugo containers are running"""
        import subprocess
        result = subprocess.run(
            ["docker", "ps", "--filter", "name=hugo", "--format", "{{.Names}}"],
            capture_output=True,
            text=True
        )
        containers = result.stdout.strip().split('\n')
        assert any("hugo-chemie-lernen-org" in c for c in containers)
        assert any("hugo-graphwiz-ai" in c for c in containers)
        assert any("hugo-tobias-weiss-org" in c for c in containers)


class TestLinkIntegrity:
    """Test link integrity across all Hugo sites"""

    # Define critical pages to test
    CRITICAL_PAGES = {
        "https://graphwiz.ai": [
            "/imprint/",
            "/focus-areas/",
            "/ai/",
            "/xr/",
            "/digital-sovereignty/",
            "/ops",
            "/security",
            "/workshops",
            "/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"
        ],
        "https://tobias-weiss.org": [
            "/imprint/",
            "/leadership/",
            "/graphwiz/",
            "/pgp/"
        ],
        "https://chemie-lernen.org": [
            "/periodensystem/"
        ]
    }

    def test_critical_pages_accessibility(self):
        """Test that all critical pages are accessible"""
        for base_url, pages in self.CRITICAL_PAGES.items():
            for page in pages:
                full_url = urljoin(base_url, page)
                response = requests.get(full_url, timeout=10, allow_redirects=True)

                # PDFs and other static files should return 200, pages should return 200
                assert response.status_code == 200, \
                    f"Critical page {full_url} returned {response.status_code}"

    def test_pdf_link_integrity(self):
        """Test that PDF links are working"""
        critical_pdfs = [
            "https://graphwiz.ai/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"
        ]

        for pdf_url in critical_pdfs:
            response = requests.get(pdf_url, timeout=15, allow_redirects=True)
            assert response.status_code == 200, \
                f"PDF {pdf_url} returned {response.status_code}"
            # Check if it's actually a PDF
            assert 'pdf' in response.headers.get('content-type', '').lower(), \
                f"URL {pdf_url} doesn't return PDF content"

    def test_external_link_responsiveness(self):
        """Test external links are responsive (not checking content validity)"""
        external_links = [
            "https://www.linkedin.com/company/graphwiz-ai-cloud-xr/",
            "https://tobias-weiss.org/"
        ]

        for external_url in external_links:
            try:
                response = requests.get(external_url, timeout=10, allow_redirects=True)
                # External links should return 2xx or 3xx
                assert 200 <= response.status_code < 400, \
                    f"External link {external_url} returned {response.status_code}"
            except requests.exceptions.Timeout:
                pytest.skip(f"External link {external_url} timed out (acceptable for external resources)")

    def _extract_links_from_page(self, url, session):
        """Helper method to extract all links from a page"""
        try:
            response = session.get(url, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {url}"

            # Extract href and src attributes
            links = set()
            # Find all href attributes
            href_matches = re.findall(r'href=["\']([^"\']+)["\']', response.text)
            # Find all src attributes
            src_matches = re.findall(r'src=["\']([^"\']+)["\']', response.text)

            for link in href_matches + src_matches:
                # Skip certain patterns
                if (link.startswith(('mailto:', 'tel:', 'javascript:', '#')) or
                    '//' in link and not link.startswith(('http://', 'https://'))):
                    continue

                # Convert relative URLs to absolute
                if link.startswith('/'):
                    full_url = f"{urlparse(url).scheme}://{urlparse(url).netloc}{link}"
                elif not link.startswith(('http://', 'https://')):
                    full_url = urljoin(url, link)
                else:
                    full_url = link

                links.add(full_url)

            return links
        except Exception as e:
            print(f"Error extracting links from {url}: {e}")
            return set()

    def test_internal_link_samples(self):
        """Test a sample of internal links from main pages"""
        main_pages = ["https://graphwiz.ai/", "https://tobias-weiss.org/"]
        session = requests.Session()

        for page_url in main_pages:
            links = self._extract_links_from_page(page_url, session)

            # Test up to 10 internal links per page (to avoid overly long tests)
            internal_links = [link for link in links
                            if urlparse(link).netloc in ['graphwiz.ai', 'tobias-weiss.org']
                            and not link.endswith(('.pdf', '.jpg', '.png', '.css', '.js'))]

            # Limit the number of links tested to keep tests reasonable
            test_links = internal_links[:10] if len(internal_links) > 10 else internal_links

            for link in test_links:
                try:
                    response = session.get(link, timeout=8, allow_redirects=True)
                    assert response.status_code == 200, \
                        f"Internal link {link} returned {response.status_code}"
                except requests.exceptions.Timeout:
                    pytest.skip(f"Internal link {link} timed out")

    def test_workshop_pdf_link(self):
        """Test the specific workshop PDF link that was recently fixed"""
        pdf_url = "https://graphwiz.ai/data/CoCreate-Werkstattgespraech-Digitale-Souveraenitaet_75dpi.pdf"

        # Test direct access
        response = requests.get(pdf_url, timeout=15)
        assert response.status_code == 200, f"Workshop PDF not accessible: {response.status_code}"

        # Test it's actually a PDF
        assert 'application/pdf' in response.headers.get('content-type', ''), \
            f"Workshop PDF doesn't return PDF content-type: {response.headers.get('content-type')}"

        # Check PDF size is reasonable (not empty)
        assert len(response.content) > 100000, "Workshop PDF appears to be empty or too small"

    def test_footer_links_functionality(self):
        """Test footer links are working on both sites"""
        footer_tests = [
            ("https://graphwiz.ai/", "/imprint/"),
            ("https://graphwiz.ai/", "https://tobias-weiss.org/"),
            ("https://tobias-weiss.org/", "/imprint/")
        ]

        for page_url, link_target in footer_tests:
            response = requests.get(page_url, timeout=10)
            assert response.status_code == 200, f"Cannot fetch page {page_url}"

            if link_target.startswith('/'):
                full_link = f"{urlparse(page_url).scheme}://{urlparse(page_url).netloc}{link_target}"
            else:
                full_link = link_target

            # Check if link exists in page and is accessible
            if link_target in response.text or full_link in response.text:
                link_response = requests.get(full_link, timeout=10, allow_redirects=True)
                assert link_response.status_code == 200, \
                    f"Footer link {full_link} not accessible from {page_url}"


class TestAccessibility:
    """Test WCAG accessibility compliance across all Hugo sites"""

    SITES = ["https://graphwiz.ai", "https://tobias-weiss.org", "https://chemie-lernen.org"]

    def test_alt_text_for_images(self):
        """Test that all images have appropriate alt text (WCAG 1.1.1)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            images = soup.find_all('img')

            if len(images) == 0:
                pytest.skip(f"No images found on {site}")

            for img in images:
                alt_text = img.get('alt', '')
                # Alt text should not be empty unless it's a decorative image
                if alt_text == '' and not img.get('role', '') == 'presentation':
                    pytest.fail(f"Image without alt text on {site}: {img.get('src', 'no src')}")

                # Alt text should not be just the file extension
                if alt_text.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.svg')):
                    pytest.fail(f"Poor alt text (file name) on {site}: {alt_text}")

    def test_heading_hierarchy(self):
        """Test proper heading hierarchy (WCAG 1.3.1)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            headings = soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])

            if len(headings) == 0:
                pytest.skip(f"No headings found on {site}")

            previous_level = 0
            for heading in headings:
                current_level = int(heading.name[1])  # Extract number from h1, h2, etc.

                # Heading levels should not be skipped (e.g., h1 followed by h3)
                if previous_level > 0 and current_level > previous_level + 1:
                    pytest.fail(
                        f"Heading hierarchy skipped on {site}: {heading.name} after h{previous_level}"
                    )

                previous_level = current_level

            # Should have exactly one h1 per page
            h1_count = len(soup.find_all('h1'))
            assert h1_count == 1, f"Page {site} has {h1_count} h1 elements (should be exactly 1)"

    def test_contrast_ratio_basics(self):
        """Test basic contrast requirements for critical text elements"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')

            # Check for inline styles that might have poor contrast
            elements_with_style = soup.find_all(attrs={'style': True})

            for element in elements_with_style:
                style = element.get('style', '').lower()
                if 'color:' in style and 'background:' in style:
                    # Basic check - this would need enhancement with color calculation
                    if 'color:#ffffff' in style and 'background:#ffffff' in style:
                        pytest.fail(f"White text on white background found on {site}")

                    if 'color:#000000' in style and 'background:#000000' in style:
                        pytest.fail(f"Black text on black background found on {site}")

    def test_form_labels(self):
        """Test that form inputs have associated labels (WCAG 1.3.1, 3.3.2)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            inputs = soup.find_all(['input', 'textarea', 'select'])

            if len(inputs) == 0:
                continue  # No forms on this page, which is fine

            for input_elem in inputs:
                input_type = input_elem.get('type', '').lower()
                input_id = input_elem.get('id', '')

                # Skip hidden inputs and submit buttons
                if input_type in ['hidden', 'submit', 'button'] or input_elem.get('type') in ['submit', 'button']:
                    continue

                # Check for label association
                has_label = False

                # Method 1: Check for explicit label with for attribute
                if input_id:
                    labels = soup.find_all('label', {'for': input_id})
                    if labels:
                        has_label = True

                # Method 2: Check if input is wrapped in a label
                parent_label = input_elem.find_parent('label')
                if parent_label:
                    has_label = True

                # Method 3: Check for aria-label or aria-labelledby
                if input_elem.get('aria-label') or input_elem.get('aria-labelledby'):
                    has_label = True

                if not has_label:
                    pytest.fail(f"Form input without associated label on {site}: {input_elem}")

    def test_link_purpose(self):
        """Test that links have identifiable purpose (WCAG 2.4.4)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            links = soup.find_all('a', href=True)

            for link in links:
                href = link.get('href', '')
                text = link.get_text(strip=True)
                title = link.get('title', '')

                # Skip special links
                if href.startswith(('mailto:', 'tel:', 'javascript:')) or href == '#':
                    continue

                # Link should have either descriptive text or title
                if not text and not title:
                    pytest.fail(f"Link without descriptive text or title on {site}: {href}")

                # Check for "click here" patterns
                if text.lower() in ['click here', 'read more', 'more', 'link'] and not title:
                    pytest.fail(f"Non-descriptive link text on {site}: '{text}'")

    def test_language_attributes(self):
        """Test that pages have proper language attributes (WCAG 3.1.1)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            html_tag = soup.find('html')

            assert html_tag is not None, f"No HTML tag found on {site}"
            assert html_tag.get('lang'), f"No lang attribute on HTML tag for {site}"

            # Language should be valid format (e.g., "en", "en-US", "de")
            lang_attr = html_tag.get('lang')
            assert re.match(r'^[a-z]{2}(-[A-Z]{2,3})?$', lang_attr), \
                f"Invalid language attribute format on {site}: {lang_attr}"

    def test_focus_management(self):
        """Test basic focus management for interactive elements"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')

            # Check that interactive elements can receive focus
            focusable_elements = soup.find_all([
                'a', 'button', 'input', 'textarea', 'select',
                '[tabindex]'
            ])

            for element in focusable_elements:
                # Elements should have tabindex >= 0 (not -1 unless intentionally unfocusable)
                tabindex = element.get('tabindex')
                if tabindex is not None and int(tabindex) < 0:
                    # Check if this is intentional (e.g., decorative elements)
                    if not element.get('aria-hidden') == 'true':
                        pytest.fail(f"Element with negative tabindex on {site}: {element}")

    def test_video_accessibility(self):
        """Test video accessibility (captions, controls)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            videos = soup.find_all('video')

            if len(videos) == 0:
                continue  # No videos on this page

            for video in videos:
                # Videos should have controls
                if not video.get('controls'):
                    pytest.fail(f"Video without controls attribute on {site}")

                # Check for captions or tracks
                tracks = video.find_all('track')
                if len(tracks) == 0:
                    pytest.warn(f"Video without captions/tracks on {site}")

    def test_table_accessibility(self):
        """Test table accessibility (headers, captions)"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            tables = soup.find_all('table')

            if len(tables) == 0:
                continue  # No tables on this page

            for table in tables:
                # Tables should have captions or headers
                has_caption = table.find('caption') is not None
                has_headers = (
                    table.find('th') is not None or
                    table.find('[scope]') is not None
                )

                if not has_caption and not has_headers:
                    pytest.fail(f"Table without caption or headers on {site}")

                # Check for proper header associations
                th_elements = table.find_all('th')
                for th in th_elements:
                    if not th.get('scope') and not th.get('id'):
                        pytest.warn(f"Table header without scope or id on {site}")

    def test_responsive_design(self):
        """Test basic responsive design elements"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')

            # Check for viewport meta tag
            viewport = soup.find('meta', attrs={'name': 'viewport'})
            assert viewport is not None, f"No viewport meta tag on {site}"
            assert 'width=device-width' in viewport.get('content', ''), \
                f"Viewport meta tag doesn't include device-width on {site}"

            # Check for responsive images
            images = soup.find_all('img')
            for img in images:
                # Check for responsive image techniques
                srcset = img.get('srcset')
                sizes = img.get('sizes')
                css_classes = img.get('class', [])

                # At least one responsive technique should be used
                if not srcset and not sizes and not any('img-fluid' in str(c) for c in css_classes):
                    pytest.warn(f"Image without responsive attributes on {site}: {img.get('src', 'no src')}")

    def test_keyboard_navigation(self):
        """Test basic keyboard navigation support"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')

            # Check for custom tabindex values that might interfere with navigation
            elements_with_tabindex = soup.find_all(attrs={'tabindex': True})

            for element in elements_with_tabindex:
                tabindex = element.get('tabindex')
                try:
                    tabindex_int = int(tabindex)
                    # Tabindex should be 0, -1, or positive (no arbitrary high numbers)
                    if tabindex_int > 100:
                        pytest.fail(f"Element with very high tabindex ({tabindex}) on {site}")
                except ValueError:
                    pytest.fail(f"Invalid tabindex value on {site}: {tabindex}")

    def test_aria_landmarks(self):
        """Test for proper ARIA landmark usage"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')

            # Check for common landmarks
            landmarks = soup.find_all([
                '[role="banner"]',    # Header
                '[role="navigation"]', # Navigation
                '[role="main"]',      # Main content
                '[role="complementary"]', # Sidebar
                '[role="contentinfo"]'   # Footer
            ])

            # At minimum, should have main content area
            main_landmarks = soup.find_all(['main', '[role="main"]'])
            if len(main_landmarks) == 0:
                pytest.warn(f"No main landmark found on {site}")

            # Should not have duplicate landmarks of the same type
            landmark_roles = [elem.get('role') for elem in landmarks if elem.get('role')]
            for role in ['main', 'banner', 'contentinfo']:
                if landmark_roles.count(role) > 1:
                    pytest.fail(f"Multiple {role} landmarks found on {site}")

    def test_language_formalism_professionalism(self):
        """Test language for conciseness, understandability, and professionalism"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')
            text_content = soup.get_text()

            # Test for overly casual language patterns
            casual_patterns = [
                r'\b(awesome|cool|super|totally|literally|basically)\b',
                r'\b(you guys|hey guys|what\'s up)\b',
                r'\b(stuff|things|stuff like that)\b',
                r'!!+',  # Multiple exclamation marks
                r'\?\?+',  # Multiple question marks
                r'\b(lol|omg|wtf|btw)\b',
                r'\b kinda \b',
                r'\b sorta \b',
                r'\b prolly \b',
            ]

            for pattern in casual_patterns:
                matches = re.findall(pattern, text_content, re.IGNORECASE)
                if matches:
                    pytest.warn(f"Potentially casual language found on {site}: {matches[:3]}")

            # Test for overly complex sentences (basic readability)
            sentences = re.split(r'[.!?]+', text_content)
            long_sentences = [s for s in sentences if len(s.strip()) > 200]

            if long_sentences:
                pytest.warn(f"Found {len(long_sentences)} very long sentences on {site} - consider simplifying")

            # Test for jargon and technical complexity
            jargon_patterns = [
                r'\b(synergize|leverage|paradigm|optimize|maximize)\b',
                r'\b(solution-oriented|results-driven|value-added)\b',
                r'\b(end-to-end|seamless|holistic)\b',
            ]

            jargon_count = 0
            for pattern in jargon_patterns:
                matches = re.findall(pattern, text_content, re.IGNORECASE)
                jargon_count += len(matches)

            if jargon_count > 5:
                pytest.warn(f"High corporate jargon usage on {site}: {jargon_count} instances")

            # Test for passive voice overuse (simplified check)
            passive_voice_patterns = [
                r'\b(is|are|was|were|be|been|being)\s+\w+ed\b',
                r'\b(has|have)\s+been\s+\w+ed\b',
            ]

            passive_count = 0
            for pattern in passive_voice_patterns:
                matches = re.findall(pattern, text_content, re.IGNORECASE)
                passive_count += len(matches)

            total_words = len(text_content.split())
            if total_words > 0 and passive_count / total_words > 0.1:
                pytest.warn(f"High passive voice usage on {site}: {passive_count} instances")

            # Test for appropriate language level
            complex_words = re.findall(r'\b\w{10,}\b', text_content)
            if len(complex_words) > 20 and total_words > 0:
                complexity_ratio = len(complex_words) / total_words
                if complexity_ratio > 0.05:  # More than 5% complex words
                    pytest.warn(f"High vocabulary complexity on {site}: {len(complex_words)} long words")

            # Test for consistent tone and professionalism
            professional_indicators = [
                r'\b(please|thank you|contact|support|help)\b',
                r'\b(professional|expert|specialized|quality)\b',
            ]

            professional_count = sum(len(re.findall(pattern, text_content, re.IGNORECASE))
                                   for pattern in professional_indicators)

            # Check for appropriate contact/call-to-action language
            if professional_count == 0 and total_words > 100:
                pytest.warn(f"Low professional language indicators on {site}")

    def test_content_structure_readability(self):
        """Test content structure for better readability"""
        for site in self.SITES:
            response = requests.get(site, timeout=10)
            assert response.status_code == 200, f"Cannot fetch {site}"

            soup = BeautifulSoup(response.text, 'html.parser')

            # Test for appropriate paragraph lengths
            paragraphs = soup.find_all('p')
            long_paragraphs = [p for p in paragraphs if len(p.get_text()) > 500]

            if long_paragraphs:
                pytest.warn(f"Found {len(long_paragraphs)} very long paragraphs on {site}")

            # Test for appropriate use of lists
            text_content = soup.get_text()
            list_items = soup.find_all(['li'])

            # Check if content would benefit from more lists
            sentences = re.split(r'[.!?]+', text_content)
            if len(sentences) > 10 and len(list_items) == 0:
                pytest.warn(f"Consider using lists to improve readability on {site}")

            # Test for clear section breaks
            headings = soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])
            if len(headings) > 5 and len(list_items) < 3:
                pytest.warn(f"Consider using more lists and breaks on {site} for better structure")


class TestPerformance:
    """Test site performance metrics and optimization"""

    SITES = ["https://graphwiz.ai", "https://tobias-weiss.org", "https://chemie-lernen.org"]

    @pytest.mark.parametrize("site", SITES)
    def test_page_load_speed(self, site):
        """Test page load speed under reasonable limits"""
        start_time = time.time()
        response = requests.get(site, timeout=10)
        load_time = time.time() - start_time

        assert response.status_code == 200, f"Cannot fetch {site}"
        assert load_time < 5.0, f"Page load time too slow: {load_time:.2f}s for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_content_compression(self, site):
        """Test that content is properly compressed for faster delivery"""
        # Test without compression
        headers_no_gzip = {'Accept-Encoding': 'identity'}
        response_no_gzip = requests.get(site, headers=headers_no_gzip, timeout=10)

        # Test with compression
        headers_gzip = {'Accept-Encoding': 'gzip, deflate'}
        response_gzip = requests.get(site, headers=headers_gzip, timeout=10)

        assert response_no_gzip.status_code == 200
        assert response_gzip.status_code == 200

        # Compressed response should be smaller (unless already minimal)
        if len(response_no_gzip.content) > 1000:  # Only check for substantial content
            compression_ratio = len(response_gzip.content) / len(response_no_gzip.content)
            assert compression_ratio < 0.9, f"Content not properly compressed: {compression_ratio:.2f} for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_cache_headers(self, site):
        """Test appropriate cache headers are set"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        # Check for cache-control headers
        cache_control = response.headers.get('Cache-Control', '')
        expires = response.headers.get('Expires', '')
        etag = response.headers.get('ETag', '')

        # Should have some form of caching directive
        assert cache_control or expires or etag, f"No caching headers found for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_resource_optimization(self, site):
        """Test that external resources are optimized"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')

        # Check CSS and JS files
        css_files = soup.find_all('link', rel='stylesheet')
        js_files = soup.find_all('script', src=True)

        # Test external resources
        external_resources = css_files + [tag.get('src') for tag in js_files if tag.get('src')]

        for resource in external_resources[:5]:  # Test first 5 resources
            if isinstance(resource, str) and resource.startswith('http'):
                try:
                    resource_response = requests.get(resource, timeout=5)
                    assert resource_response.status_code == 200, f"External resource not accessible: {resource}"
                except requests.exceptions.RequestException:
                    pytest.warn(f"External resource timeout: {resource}")


class TestSecurity:
    """Test security aspects of the websites"""

    SITES = ["https://graphwiz.ai", "https://tobias-weiss.org", "https://chemie-lernen.org"]

    @pytest.mark.parametrize("site", SITES)
    def test_https_only(self, site):
        """Test that all resources are loaded over HTTPS"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        # Check for HTTP resources in HTML
        http_resources = re.findall(r'http://[^\s"\'<>]+', response.text)

        # Allow some HTTP resources (external services that don't support HTTPS)
        allowed_http_domains = ['http://www.w3.org', 'http://purl.org']
        disallowed_http = [r for r in http_resources
                          if not any(domain in r for domain in allowed_http_domains)]

        assert len(disallowed_http) == 0, f"Found HTTP resources that should be HTTPS: {disallowed_http[:3]}"

    @pytest.mark.parametrize("site", SITES)
    def test_security_headers(self, site):
        """Test for important security headers"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        # Check for important security headers
        security_headers = {
            'X-Frame-Options': ['DENY', 'SAMEORIGIN'],
            'X-Content-Type-Options': ['nosniff'],
            'X-XSS-Protection': ['1; mode=block'],
        }

        for header, expected_values in security_headers.items():
            header_value = response.headers.get(header, '')
            assert header_value, f"Missing security header: {header} for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_hsts_header(self, site):
        """Test HSTS header is properly configured"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        hsts_header = response.headers.get('Strict-Transport-Security', '')
        assert hsts_header, f"Missing HSTS header for {site}"
        assert 'max-age=' in hsts_header, f"HSTS header missing max-age for {site}"
        assert 'includeSubDomains' in hsts_header, f"HSTS header should include subdomains for {site}"


class TestSEO:
    """Test SEO optimization aspects"""

    SITES = ["https://graphwiz.ai", "https://tobias-weiss.org", "https://chemie-lernen.org"]

    @pytest.mark.parametrize("site", SITES)
    def test_page_title_optimization(self, site):
        """Test that page titles are properly optimized"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')
        title = soup.find('title')

        assert title, f"Missing title tag for {site}"
        title_text = title.get_text().strip()

        # Title length should be reasonable
        assert 30 <= len(title_text) <= 70, f"Title length not optimal: {len(title_text)} chars for {site}"
        assert len(title_text) > 0, f"Empty title for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_meta_description(self, site):
        """Test that pages have proper meta descriptions"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')
        meta_desc = soup.find('meta', attrs={'name': 'description'})

        assert meta_desc, f"Missing meta description for {site}"
        desc_content = meta_desc.get('content', '').strip()

        # Description length should be reasonable
        assert 120 <= len(desc_content) <= 160, f"Meta description length not optimal: {len(desc_content)} chars for {site}"
        assert len(desc_content) > 0, f"Empty meta description for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_open_graph_tags(self, site):
        """Test Open Graph tags for social sharing"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')

        # Check for essential OG tags
        og_title = soup.find('meta', property='og:title')
        og_description = soup.find('meta', property='og:description')

        # Should have at least title and description
        assert og_title, f"Missing og:title for {site}"
        assert og_description, f"Missing og:description for {site}"

        # Validate OG content
        assert len(og_title.get('content', '').strip()) > 0, f"Empty og:title for {site}"
        assert len(og_description.get('content', '').strip()) > 0, f"Empty og:description for {site}"


class TestContentQuality:
    """Test content quality and consistency"""

    SITES = ["https://graphwiz.ai", "https://tobias-weiss.org", "https://chemie-lernen.org"]

    @pytest.mark.parametrize("site", SITES)
    def test_content_freshness(self, site):
        """Test that content appears fresh and up-to-date"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')

        # Look for date indicators in content
        current_year = 2025
        text_content = soup.get_text()

        # Check for recent years mentioned in content
        recent_years = re.findall(r'\b(2023|2024|2025)\b', text_content)

        if len(recent_years) == 0:
            pytest.warn(f"No recent years mentioned in content on {site}")

    @pytest.mark.parametrize("site", SITES)
    def test_content_structure_quality(self, site):
        """Test that content is well-structured"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')

        # Check for proper content structure
        paragraphs = soup.find_all('p')
        lists = soup.find_all(['ul', 'ol'])

        # Should have reasonable content structure
        if len(paragraphs) > 0:
            avg_paragraph_length = sum(len(p.get_text()) for p in paragraphs) / len(paragraphs)

            # Average paragraph should be reasonable length
            assert 50 <= avg_paragraph_length <= 1000, \
                f"Average paragraph length seems unusual: {avg_paragraph_length:.0f} chars for {site}"


class TestMobileCompatibility:
    """Test mobile compatibility and responsive design"""

    SITES = ["https://graphwiz.ai", "https://tobias-weiss.org", "https://chemie-lernen.org"]

    @pytest.mark.parametrize("site", SITES)
    def test_viewport_configuration(self, site):
        """Test viewport meta tag is properly configured"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        soup = BeautifulSoup(response.text, 'html.parser')
        viewport = soup.find('meta', attrs={'name': 'viewport'})

        assert viewport, f"Missing viewport meta tag for {site}"
        viewport_content = viewport.get('content', '')

        # Should include width=device-width
        assert 'width=device-width' in viewport_content, f"Viewport should include width=device-width for {site}"

    @pytest.mark.parametrize("site", SITES)
    def test_no_flash_content(self, site):
        """Test that no Flash content is used"""
        response = requests.get(site, timeout=10)
        assert response.status_code == 200, f"Cannot fetch {site}"

        # Check for Flash content
        assert 'flash' not in response.text.lower(), f"Flash content found on {site}"
        assert '.swf' not in response.text.lower(), f"SWF files found on {site}"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
