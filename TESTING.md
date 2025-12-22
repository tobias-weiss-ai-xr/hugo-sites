# Testing Hugo Multi-Site Configuration

This repository includes comprehensive test suites for validating the Hugo multi-site configuration, including SSL certificates, routing, page rendering, link integrity, and accessibility.

## Test Suite Options

### 1. Enhanced Bash Test Script (Recommended)

The enhanced bash test script includes comprehensive testing including link integrity validation.

**Location**: `test-hugo-sites-enhanced.sh`

**Usage**:
```bash
chmod +x test-hugo-sites-enhanced.sh
./test-hugo-sites-enhanced.sh
```

**Features**:
- ✅ All features from basic test script
- ✅ **Link integrity testing** (critical links, PDF files, external links)
- ✅ **Navigation link validation**
- ✅ **PDF file accessibility and content-type validation**
- ✅ **Footer link functionality**
- ✅ **Image accessibility testing**
- ✅ **Performance recommendations**

**Requirements**:
- bash
- curl
- openssl (for SSL tests)

**Options**:
- `SKIP_LINK_TESTS=1 ./test-hugo-sites-enhanced.sh` - Skip link testing for faster execution

### 2. Python Test Suite (Advanced)

The Python test suite provides detailed testing with pytest framework and includes link integrity tests.

**Location**: `test_hugo_sites.py`

**Usage**:
```bash
# Install dependencies
pip install pytest requests

# Run all tests
pytest test_hugo_sites.py -v

# Run only link integrity tests
pytest test_hugo_sites.py::TestLinkIntegrity -v

# Run specific link test
pytest test_hugo_sites.py::TestLinkIntegrity::test_workshop_pdf_link -v
```

**Features**:
- ✅ **SSL certificate validation**
- ✅ **HTTP to HTTPS redirect tests**
- ✅ **Homepage accessibility tests**
- ✅ **Content validation for all sites**
- ✅ **Three.js CDN verification**
- ✅ **HSTS header checks**
- ✅ **Comprehensive link integrity testing**
- ✅ **PDF file validation**
- ✅ **External link responsiveness**
- ✅ **Internal link sampling**
- ✅ **Footer link functionality**

### 3. Dedicated Link Testing Tools

#### Comprehensive Link Testing
**Location**: `test-all-links.sh`

**Usage**:
```bash
chmod +x test-all-links.sh
./test-all-links.sh
```

**Features**:
- Complete link analysis for both domains
- Sitemap-based testing (if available)
- External link validation with timeout handling
- Detailed reporting with statistics
- Suitable for scheduled maintenance

#### Quick Link Testing
**Location**: `quick-link-test.sh`

**Usage**:
```bash
chmod +x quick-link-test.sh
./quick-link-test.sh
```

**Features**:
- Fast testing of critical links only
- Perfect for pre-deployment checks
- Tests PDF accessibility
- Validates imprint pages

### 4. Basic Bash Test Script

The original bash test script for basic functionality testing.

**Location**: `test-hugo-sites.sh`

**Usage**:
```bash
chmod +x test-hugo-sites.sh
./test-hugo-sites.sh
```

**Features**:
- SSL certificate validation
- HTTP to HTTPS redirect tests
- Homepage accessibility tests
- Content validation for all sites
- Three.js CDN verification
- HSTS header checks

**Requirements**:
- bash
- curl
- openssl (for SSL tests)

### 2. Pytest Test Suite (Optional)

A Python-based pytest test suite is also available for more structured testing.

**Location**: `test_hugo_sites.py`

**Usage**:
```bash
# Install dependencies (requires Python 3.7+)
pip install -r requirements.txt

# Run all tests
pytest test_hugo_sites.py -v

# Run specific test class
pytest test_hugo_sites.py::TestHomepages -v

# Run with HTML report
pytest test_hugo_sites.py --html=test-report.html --self-contained-html
```

**Features**:
- Parameterized tests for multiple domains
- Structured test organization by class
- Detailed test reporting
- Skip/conditional test execution
- Timeout handling
- HTML test reports

**Requirements**:
- Python 3.7+
- pytest >= 7.4.0
- requests >= 2.31.0
- pytest-timeout >= 2.1.0
- pytest-html >= 3.2.0 (optional, for HTML reports)

## Test Coverage

The test suites provide comprehensive coverage including:

### SSL/TLS Tests
- Valid SSL certificates for all domains
- Certificate trust chain validation

### Link Integrity Tests
- **Critical link accessibility** (imprint pages, PDF files, navigation)
- **PDF file validation** (content-type, file size, accessibility)
- **External link responsiveness** (LinkedIn, cross-site links)
- **Internal link sampling** (tests sample of internal links)
- **Navigation link validation** (footer links, main navigation)
- **Footer link functionality** (imprint, personal blog)

### Content Tests
- Homepage accessibility for all sites
- Minimum content size validation
- Expected content presence (titles, key phrases)
- Three.js library loading for chemistry site
- German language interface validation
- Periodic table functionality

### Performance Tests
- Response time validation
- HTTP to HTTPS redirects
- HSTS header validation
- Image accessibility and labeling

## Accessibility Testing

### Comprehensive Accessibility Testing

**Location**: `test-accessibility.sh`

**Usage**:
```bash
chmod +x test-accessibility.sh
./test-accessibility.sh
```

**Features**:
- ✅ **WCAG 2.1 compliance testing**
- ✅ **Language quality and professionalism checks**
- ✅ **Mobile accessibility testing**
- ✅ **Color contrast validation**
- ✅ **Image alt text verification**
- ✅ **Heading structure validation**
- ✅ **Keyboard navigation support**

### Accessibility Tests in Main Suite

The main test suites include accessibility testing:

**Python Suite** (`test_hugo_sites.py::TestAccessibility`):
- Alt text for images (WCAG 1.1.1)
- Heading hierarchy (WCAG 1.3.1)
- Form labels and associations (WCAG 1.3.1, 3.3.2)
- Link purpose and descriptive text (WCAG 2.4.4)
- Language attributes (WCAG 3.1.1)
- Focus management and keyboard navigation
- Video accessibility (captions, controls)
- Table accessibility (headers, captions)
- Responsive design elements
- ARIA landmark usage
- **Language formalism** (concise, understandable, professional)

**Enhanced Shell Suite** (`test-hugo-sites-enhanced.sh`):
- Language professionalism testing
- Content structure validation
- WCAG compliance basics
- Focus management testing
- Skip to: `SKIP_ACCESSIBILITY_TESTS=1 ./test-hugo-sites-enhanced.sh`

### Accessibility Best Practices

#### Language Quality Standards
- **Professional Tone**: Avoid casual language (awesome, cool, stuff)
- **Conciseness**: Keep sentences under 200 characters
- **Clarity**: Use simple, direct language
- **Consistency**: Maintain professional terminology
- **Avoid**: Corporate jargon, excessive exclamation marks

#### WCAG 2.1 Compliance Levels
- **Level A**: Essential accessibility features
- **Level AA**: Enhanced accessibility (recommended)
- **Level AAA**: Highest accessibility (optional)

#### Key Accessibility Requirements
1. **Images**: All decorative and informative images need alt text
2. **Headings**: Proper hierarchy (h1 → h2 → h3)
3. **Links**: Descriptive text, avoid "click here"
4. **Forms**: Associated labels for all inputs
5. **Color**: Sufficient contrast (4.5:1 for normal text)
6. **Keyboard**: All functionality available via keyboard
7. **Mobile**: Responsive design, touch targets ≥44px

#### Testing Tools Integration
```bash
# Run all accessibility tests
pytest test_hugo_sites.py::TestAccessibility -v

# Run language quality tests only
pytest test_hugo_sites.py::TestAccessibility::test_language_formalism_professionalism -v

# Run comprehensive accessibility checks
./test-accessibility.sh

# Skip accessibility in main test suite
SKIP_ACCESSIBILITY_TESTS=1 ./test-hugo-sites-enhanced.sh
```

## Link Testing Best Practices

### Critical Links to Monitor
1. **Legal Pages**: `/imprint/` on both domains
2. **PDF Resources**: Workshop materials, documentation
3. **Navigation Links**: Main menu, footer navigation
4. **External Links**: Social profiles, partner sites

### Link Testing Workflow
1. **Before Deployment**: Run `./quick-link-test.sh`
2. **After Major Changes**: Run `./test-hugo-sites-enhanced.sh`
3. **Weekly Maintenance**: Run `./test-all-links.sh`
4. **CI/CD Integration**: Use `pytest test_hugo_sites.py::TestLinkIntegrity`

### Troubleshooting Link Issues
- **404 Errors**: Check if files exist in correct static directory
- **PDF Issues**: Verify files are in `myhugoapp/static/data/` not `data/`
- **External Timeouts**: Consider network issues, may need retry logic
- **Redirects**: Ensure proper HTTP to HTTPS redirect configuration

### Link Test Results Interpretation
- ✅ **OK**: Link returns 200-299 status code
- ⚠ **WARN**: Link accessible but with issues (timeout, redirect)
- ❌ **FAIL**: Link returns error status (404, 500, etc.)
- ℹ **INFO**: Skipped links (mailto:, javascript:, etc.)

### Automated Link Testing
For continuous monitoring, consider adding to crontab:
```bash
# Daily link check at 9 AM
0 9 * * * /opt/git/hugo-sites/quick-link-test.sh >> /var/log/link-tests.log 2>&1

# Weekly comprehensive test on Sundays at 2 AM
0 2 * * 0 /opt/git/hugo-sites/test-all-links.sh >> /var/log/comprehensive-tests.log 2>&1
```
- Certificate expiration
- Trusted certificate chain

### HTTP Redirect Tests
- HTTP to HTTPS 301 redirects
- Correct redirect URLs
- HSTS header presence

### Content Tests
- Homepage accessibility (200 OK)
- Minimum content size validation
- Site-specific content presence

### Site-Specific Tests

**Chemie Lernen (chemie-lernen.org)**:
- German language interface
- Periodic table page with Three.js
- German button labels (TABELLE, KUGEL, HELIX, GITTER)
- Three.js loaded from CDN

**GraphWiz AI (graphwiz.ai)**:
- Headline: "AI / Enthusiam / DevOps / Digital Sovereignty / XR"
- AI, XR, Ops, Workshops section pages
- Content accessibility

**Tobias Weiss (tobias-weiss.org, www.tobias-weiss.org, next.tobias-weiss.org)**:
- Gallery page with Tallinn images
- PGP page with public key
- Multiple domain access (tobias-weiss.org, www.tobias-weiss.org, next.tobias-weiss.org)

### 404 Error Page Tests
- Custom 404 pages for all domains with proper 404 status codes
- Navigation links to main sections in 404 pages
- Contact information availability in error pages
- Homepage links for easy navigation from error pages

**Tobias Weiss 404 Page Features**:
- Navigation to: graphwiz, research, gallery, leadership, pgp
- Contact email: spam@tobias-weiss.org
- Professional tone matching personal site style

**GraphWiz AI 404 Page Features**:
- Navigation to: focus-areas, ai, advanced-delegation-systems, xr, digital-sovereignty, ops, security, workshops
- Contact email: info@graphwiz.ai
- Technology-focused tone with digital sovereignty branding

**Chemie Lernen 404 Page Features**:
- Basic 404 error handling (uses theme default)
- German language context

### Traefik Tests
- Domain routing to correct backends
- HSTS headers on all responses
- SSL termination working correctly via ACME

## Continuous Integration

The bash test script can be integrated into CI/CD pipelines:

```bash
# Example GitHub Actions workflow
- name: Test Hugo Sites
  run: |
    chmod +x test-hugo-sites.sh
    ./test-hugo-sites.sh
```

## Troubleshooting Tests

### SSL Certificate Failures
- Check if certificates are renewed: `docker logs traefik`
- Verify domain DNS points to correct IP
- Check Traefik's `acme.json` file in `./letsencrypt/`

### Content Test Failures
- Verify Hugo containers are running: `docker ps | grep hugo`
- Check Hugo logs: `docker logs hugo-chemie-lernen-org`
- Test backend directly: `curl http://localhost:1313`

### Timeout Failures
- Increase timeout in pytest: Edit `pytest.ini` timeout value
- Check network connectivity
- Verify services are responding: `curl -I https://domain.com/`

## Test Development

To add new tests:

### Bash Script
Edit `test-hugo-sites.sh` and add test functions following the pattern:
```bash
test_url "https://example.com/page" 200 "Description" 1000
test_content "https://example.com/" "Expected String" "Description"
```

### Pytest
Add test methods to existing classes or create new test classes in `test_hugo_sites.py`:
```python
class TestNewFeature:
    def test_something(self):
        response = requests.get("https://example.com/")
        assert "expected" in response.text
```

## Manual Testing

For quick manual verification:

```bash
# Test SSL certificates
openssl s_client -connect chemie-lernen.org:443 -servername chemie-lernen.org

# Test HTTP redirect
curl -I http://graphwiz.ai/

# Test content
curl -s https://tobias-weiss.org/gallery/ | grep Tallinn

# Test Traefik routing
curl -v -H "Host: tobias-weiss.org" https://localhost/gallery/
```

## Additional Testing Suites

### Performance Testing Suite

**Location**: `test_hugo_sites.py::TestPerformance`

**Features**:
- ✅ **Page load speed validation** (<5 seconds target)
- ✅ **Content compression testing** (gzip/deflate)
- ✅ **Cache headers verification**
- ✅ **Resource optimization checks**
- ✅ **Mobile performance testing**
- ✅ **Image size validation**

**Usage**:
```bash
pytest test_hugo_sites.py::TestPerformance -v

# Run specific performance test
pytest test_hugo_sites.py::TestPerformance::test_page_load_speed -v
```

### Security Testing Suite

**Location**: `test_hugo_sites.py::TestSecurity`

**Features**:
- ✅ **HTTPS enforcement** (no mixed content)
- ✅ **Security headers validation** (X-Frame-Options, X-Content-Type-Options, XSS-Protection)
- ✅ **HSTS header verification** (strict transport security)
- ✅ **Sensitive data exposure checks**
- ✅ **Form security validation** (CSRF protection)
- ✅ **Error page information disclosure prevention**

**Usage**:
```bash
pytest test_hugo_sites.py::TestSecurity -v

# Check security headers specifically
pytest test_hugo_sites.py::TestSecurity::test_security_headers -v
```

### SEO Testing Suite

**Location**: `test_hugo_sites.py::TestSEO`

**Features**:
- ✅ **Page title optimization** (30-70 characters)
- ✅ **Meta description validation** (120-160 characters)
- ✅ **Open Graph tags** (social sharing)
- ✅ **Heading structure** (single H1, proper hierarchy)
- ✅ **Canonical tags** (duplicate content prevention)
- ✅ **Robots meta tags** (search engine instructions)

**Usage**:
```bash
pytest test_hugo_sites.py::TestSEO -v

# Test Open Graph tags
pytest test_hugo_sites.py::TestSEO::test_open_graph_tags -v
```

### Content Quality Testing Suite

**Location**: `test_hugo_sites.py::TestContentQuality`

**Features**:
- ✅ **Content freshness** (recent year mentions)
- ✅ **Content structure quality** (paragraphs, lists)
- ✅ **Readability metrics** (sentence length, vocabulary)
- ✅ **Consistency checks** (formatting, spacing)
- ✅ **External link quality** (broken link detection)

**Usage**:
```bash
pytest test_hugo_sites.py::TestContentQuality -v

# Test content freshness
pytest test_hugo_sites.py::TestContentQuality::test_content_freshness -v
```

### Mobile Compatibility Testing Suite

**Location**: `test_hugo_sites.py::TestMobileCompatibility`

**Features**:
- ✅ **Viewport meta tag** (mobile-friendly configuration)
- ✅ **Responsive image techniques**
- ✅ **Touch target validation** (44px minimum)
- ✅ **Flash content elimination**
- ✅ **Mobile user agent testing**

**Usage**:
```bash
pytest test_hugo_sites.py::TestMobileCompatibility -v

# Test viewport configuration
pytest test_hugo_sites.py::TestMobileCompatibility::test_viewport_configuration -v
```

### Standalone Performance Script

**Location**: `test-performance.sh`

**Comprehensive performance testing:**
- ✅ **Page load speed measurement**
- ✅ **Compression ratio analysis**
- ✅ **Cache headers evaluation**
- ✅ **Security headers validation**
- ✅ **Resource optimization checks**
- ✅ **Mobile optimization testing**
- ✅ **SEO basics validation**

**Usage**:
```bash
chmod +x test-performance.sh
./test-performance.sh
```
