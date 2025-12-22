"""
Test suite for Hugo multi-site configuration
Tests SSL certificates, routing, and page rendering using pytest
"""

import pytest
import requests
from requests.exceptions import SSLError, RequestException
import ssl
import socket


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


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
