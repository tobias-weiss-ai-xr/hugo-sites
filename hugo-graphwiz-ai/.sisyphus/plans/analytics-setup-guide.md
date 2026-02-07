# Analytics Setup Guide

Complete guide to setting up analytics tracking for graphwiz-ai using Plausible, Microsoft Clarity, and Google Search Console.

---

## Table of Contents

1. [Plausible Analytics](#1-plausible-analytics)
2. [Microsoft Clarity](#2-microsoft-clarity)
3. [Google Search Console](#3-google-search-console)
4. [Integration with Hugo](#4-integration-with-hugo)
5. [Privacy Compliance](#5-privacy-compliance)

---

## 1. Plausible Analytics

### Overview

Plausible is a privacy-focused, open-source web analytics alternative to Google Analytics. It's GDPR-compliant, doesn't use cookies, and provides simple, actionable insights.

**Key Benefits**:
- No cookies, GDPR-compliant
- Lightweight (1KB vs. 100KB for GA)
- Real-time data
- Simple dashboard with actionable insights
- Self-hosted option available

### Setup Instructions

#### Step 1: Create Plausible Account

1. Go to https://plausible.io/
2. Click "Get Started"
3. Choose between:
   - **Cloud plan** (hosted by Plausible, 30-day free trial)
   - **Self-hosted** (Docker deployment, complete data control)

#### Step 2: Add Website

1. After login, click "Add website"
2. Enter:
   - **Domain**: `graphwiz.ai`
   - **Timezone**: `Europe/Berlin`
   - **Exclude Bounce Rate**: Optional (default 30%)
3. Click "Add site"

#### Step 3: Install Tracking Script

**Option A: Add to Hugo Layout**

Add Plausible tracking to your base template or head include file:

```html
<!-- File: layouts/partials/head.html or similar -->
<script defer data-domain="graphwiz.ai" src="https://plausible.io/js/script.js"></script>
```

**Option B: Add to Individual Pages**

Add to specific pages or article templates:

```html
<script defer data-domain="graphwiz.ai" src="https://plausible.io/js/script.js"></script>
```

#### Step 4: Configure Custom Goals

1. Navigate to your site in Plausible
2. Click "Settings" → "Goals"
3. Add custom goals for tracking:

**Example Goals for graphwiz-ai**:

| Goal Name | Type | Description |
|-----------|------|-------------|
| Article View | Pageview | User visits article page |
| Contact Form Submit | Event | User submits contact form |
| Social Share Click | Event | User clicks social share button |
| 3D Visualization Interaction | Event | User interacts with Three.js viz |
| Search Query | Event | User performs site search |

**Custom Goal Configuration**:

```javascript
// Track custom events
plausible('contact_form_submit', { method: 'email' });
plausible('social_share', { platform: 'linkedin', article: 'ai-infrastructure' });
plausible('3d_viz_interaction', { type: 'click', component: 'traefik' });
```

#### Step 5: Configure Funnel Tracking

**Example Funnel for Service Interest**:

1. **Step 1**: User views AI services page
2. **Step 2**: User clicks "Learn More" for specific service
3. **Step 3**: User views pricing page
4. **Step 4**: User submits contact form

In Plausible:
- Navigate to "Settings" → "Funnels"
- Create funnel with above steps
- Set funnel goal: "Service Inquiry"

### Hugo Integration

**Single Page Template**:

```html
<!-- File: layouts/_default/single.html -->
{{ if not .Site.Params.plausible.disabled }}
<script defer data-domain="{{ .Site.BaseURL }}" src="https://plausible.io/js/script.js"></script>
{{ end }}
```

**Add to config.toml**:

```toml
[params.plausible]
disabled = false
domain = "graphwiz.ai"
```

---

## 2. Microsoft Clarity

### Overview

Microsoft Clarity is a free, privacy-focused analytics tool that provides heatmaps, session recordings, and user behavior insights. Unlike Google Analytics, it focuses on user interaction patterns.

**Key Benefits**:
- Completely free
- Privacy-compliant (no personal data collection)
- Heatmaps showing user engagement
- Session recordings (playback user journeys)
- Scroll depth and click tracking
- Works with Plausible

### Setup Instructions

#### Step 1: Create Microsoft Clarity Project

1. Go to https://clarity.microsoft.com/
2. Sign in with Microsoft account
3. Click "Get started"
4. Create new project:
   - **Name**: `graphwiz-ai`
   - **URL**: `https://graphwiz.ai/`
   - **Category**: `Website`

#### Step 2: Install Clarity Tracking Code

Clarity provides a simple installation script. Choose one of the following:

**Option A: Clarity Script (Recommended)**

```html
<!-- Add to <head> section -->
<script type="text/javascript">
  (function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    c[l]=c[l]||function(){(c[l].q=c[l].q||[]).push(arguments)};
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    c[l]=c[l]||function(){(c[l].q=c[l].q||[]).push(arguments)};
  })(window,"clarity","script","6mwdgrb8q","tag","{src:"https://clarity.ms/tag/"+i+"/a/v"+l+"/t.js?ref="+t});
</script>
```

**Option B: WordPress Plugin** (if using WP)
**Option C: Google Tag Manager** (if using GTM)

#### Step 3: Configure Clarity Settings

After adding the script, return to Clarity dashboard to configure:

**Basic Settings**:

1. **Recording Sampling**:
   - Session recording: 100% (record all sessions) or sample percentage
   - Heatmaps: 100% (capture all interactions)

2. **Data Retention**:
   - Session recordings: 7-30 days
   - Heatmaps: 90 days

3. **IP Anonymization**:
   - Enable (recommended) - Anonymizes IP addresses
   - Disable - Records full IPs

**Advanced Settings for graphwiz-ai**:

1. **Exclude Areas**:
   - Exclude `/admin/` from tracking
   - Exclude `/test/` directories

2. **Custom Tags**:
   ```html
   <!-- Add tags to specific sections -->
   <span clarity-region="article-content">...</span>
   <span clarity-region="3d-visualization">...</span>
   ```

#### Step 4: Create Custom Events

Track specific interactions relevant to graphwiz-ai:

```javascript
// Track article completion
clarity("event", "article_read", {
    article_title: document.title,
    reading_time: "5 minutes",
    scroll_depth: "100%"
});

// Track 3D visualization interactions
clarity("event", "3d_viz_interaction", {
    component: "architecture_diagram",
    interaction_type: "hover_or_click",
    model_count: 5
});

// Track social media clicks
clarity("event", "social_share", {
    platform: "linkedin",
    article_id: "ai-infrastructure"
});
```

### Hugo Integration

**Add to Base Template**:

```html
<!-- File: layouts/partials/head.html -->
<!-- Microsoft Clarity -->
<script type="text/javascript">
  (function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    c[l]=c[l]||function(){(c[l].q=c[l].q||[]).push(arguments)};
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    c[l]=c[l]||function(){(c[l].q=c[l].q||[]).push(arguments)};
  })(window,"clarity","script","6mwdgrb8q","tag","{src:"https://clarity.ms/tag/"+i+"/a/v"+l+"/t.js?ref="+t});
</script>
```

---

## 3. Google Search Console

### Overview

Google Search Console provides insights about how Google crawls, indexes, and ranks your site. It's essential for SEO optimization and discovering technical issues.

**Key Benefits**:
- Monitor search performance
- Submit sitemaps for faster indexing
- Identify crawling errors
- View mobile usability issues
- Core Web Vitals reporting

### Setup Instructions

#### Step 1: Add and Verify Property

1. Go to https://search.google.com/search-console/
2. Sign in with Google account
3. Click "Add property"
4. Choose verification method:

**Recommended Method: HTML File Upload**

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0;url=https://graphwiz.ai/">
    <title>Google Search Console Verification</title>
</head>
<body>
    <p>Verification successful. Please wait...</p>
</body>
</html>
```

Save as: `google1234567890123.html` (Google provides unique filename)

Upload to: `https://graphwiz.ai/google1234567890123.html`

Click "Verify"

**Alternative Methods**:
- DNS TXT record
- HTML tag in `<head>`
- Google Analytics account (if already set up)

#### Step 2: Submit Sitemap

Create and submit XML sitemap for Hugo:

```bash
# Generate sitemap (Hugo creates this automatically at /sitemap.xml)
cd myhugoapp
hugo

# Verify sitemap is accessible
curl https://graphwiz.ai/sitemap.xml

# Submit to Search Console
# Navigate to: Sitemaps → Add a new sitemap
# Enter: https://graphwiz.ai/sitemap.xml
```

#### Step 3: Configure Index Coverage

Monitor which pages are indexed and identify issues:

1. **Not Indexed Pages**:
   - Check if articles are in "Indexed" status
   - Investigate why pages aren't indexed (robots.txt blocking, no-index tags)

2. **Coverage Report**:
   - Review "Valid" vs. "Excluded" pages
   - Fix excluded pages that should be indexed

3. **Mobile Usability**:
   - Check mobile-friendliness of pages
   - Fix issues like text too small to read, clickable elements too close

#### Step 4: Monitor Search Analytics

Track performance over time:

**Key Metrics**:
- **Total Clicks**: How often your site appears in search results
- **Total Impressions**: How many times your pages appear
- **Average CTR**: Click-through rate
- **Average Position**: Average ranking position

**Article-Specific Tracking**:

For individual articles, monitor:
- **Keywords**: Which search queries bring users to each article
- **CTR**: Click-through rate for each article
- **Position Change**: Ranking improvements over time

**Example Monitoring Dashboard**:

1. Navigate to: Performance → Search results
2. Filter by: "Pages" or "Queries"
3. Set date range: "Last 28 days"
4. Review top-performing articles
5. Identify content opportunities (high impressions, low CTR)

---

## 4. Integration with Hugo

### Recommended Implementation

**Single Analytics Include File**:

Create: `layouts/partials/analytics.html`

```html
<!-- Privacy-first Analytics for graphwiz-ai -->
{{ if not .Site.Params.analytics.disabled }}

<!-- Plausible Analytics -->
<script defer data-domain="{{ .Site.BaseURL | relURL }}" src="https://plausible.io/js/script.js"></script>

<!-- Microsoft Clarity -->
<script type="text/javascript">
  (function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    c[l]=c[l]||function(){(c[l].q=c[l].q||[]).push(arguments)};
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    c[l]=c[l]||function(){(c[l].q=c[l].q||[]).push(arguments)};
  })(window,"clarity","script","6mwdgrb8q","tag","{src:"https://clarity.ms/tag/"+i+"/a/v"+l+"/t.js?ref="+t});
</script>

<!-- Google Site Verification (for Search Console) -->
{{ if eq .Kind "page" }}
  {{ with .Site.Params.google_site_verification }}
    <meta name="google-site-verification" content="{{ . }}">
  {{ end }}
{{ end }}
```

**Update Base Layout**:

```html
<!-- File: layouts/_default/baseof.html -->
<!DOCTYPE html>
<html lang="{{ .Site.LanguageCode }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ .Title }}</title>
    
    {{ partial "head.html" . }}
    {{ partial "analytics.html" . }}
</head>
<body>
    {{ block "main" . }}
</body>
</html>
```

**Config.toml Configuration**:

```toml
# myhugoapp/config.toml

[params.analytics]
disabled = false

[params.plausible]
disabled = false
domain = "graphwiz.ai"

[params.google_site_verification]
# Get from Search Console: https://search.google.com/search-console/
verification = "google1234567890123"
```

### Environment-Specific Analytics

**Development Environment** (localhost):

Disable analytics locally:

```toml
# config/config.develpment.toml
[params.analytics]
disabled = true
```

**Production Environment**:

Enable all analytics:

```toml
# config/config.production.toml
[params.analytics]
disabled = false
```

---

## 5. Privacy Compliance

### Cookie Banner

Implement privacy-compliant cookie banner for EU visitors:

```html
<!-- File: layouts/partials/cookie-banner.html -->
<div id="cookie-banner" class="cookie-banner" style="display: none;">
    <div class="cookie-banner-content">
        <p>
            <strong>🍪 Privacy First</strong>
            We use Plausible Analytics and Microsoft Clarity to improve our site. 
            No cookies, no tracking—just privacy-compliant analytics.
        </p>
        <button onclick="acceptAnalytics()" class="btn-accept">Accept</button>
        <button onclick="closeBanner()" class="btn-close">Close</button>
    </div>
</div>

<style>
.cookie-banner {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: #1a1a2e;
    color: #ffffff;
    padding: 20px;
    box-shadow: 0 -4px 6px rgba(0,0,0,0.3);
    z-index: 9999;
}

.cookie-banner-content {
    max-width: 800px;
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
}

.cookie-banner-content p {
    margin: 0;
}

.btn-accept {
    background: #00bfff;
    color: #ffffff;
    border: none;
    padding: 12px 24px;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
}

.btn-close {
    background: transparent;
    color: #ffffff;
    border: 2px solid #ffffff;
    padding: 8px 20px;
    border-radius: 4px;
    cursor: pointer;
}

@media (max-width: 768px) {
    .cookie-banner-content {
        flex-direction: column;
        text-align: center;
    }
}
</style>

<script>
// Check if user has consent
if (!localStorage.getItem('analytics_consent')) {
    document.getElementById('cookie-banner').style.display = 'block';
}

function acceptAnalytics() {
    localStorage.setItem('analytics_consent', 'true');
    document.getElementById('cookie-banner').style.display = 'none';
    // Enable analytics (they're loaded but blocked)
}

function closeBanner() {
    document.getElementById('cookie-banner').style.display = 'none';
}
</script>
```

### GDPR Compliance Checklist

- ✅ Privacy Policy page (`/privacy/`)
- ✅ Terms of Service page (`/terms/`)
- ✅ Cookie Consent mechanism
- ✅ Right to data deletion (contact email)
- ✅ Clear data collection statement
- ✅ No unnecessary data collection
- ✅ Data retention policy documented
- ✅ User access to their data

### robots.txt Configuration

```text
# File: static/robots.txt

User-agent: *
Allow: /

# Block admin areas from indexing
Disallow: /admin/
Disallow: /private/
Disallow: /api/
Disallow: /*.md$

# Allow search engines to access sitemap
Sitemap: https://graphwiz.ai/sitemap.xml
```

---

## Dashboard Configuration

### Plausible Dashboard Setup

**Custom Dashboard**:

1. Navigate to: https://plausible.io/graphwiz.ai/
2. Click "Dashboard" → "Custom"
3. Create custom dashboard widgets:

**Recommended Widgets**:

| Widget Name | Metric | Timeframe |
|-------------|--------|-----------|
| Top Pages | Top 10 pages by pageviews | Last 30 days |
| Entry Sources | Traffic by referrer | Last 30 days |
| Bounce Rate | Bounce rate by page | Last 7 days |
| Visit Duration | Average time on site | Last 30 days |
| Top Sources | Entry sources (direct, social, search) | Last 30 days |
| Goals | Goal completions | Last 30 days |

**Article Performance Tracking**:

Create dashboard specifically for article performance:

1. Filter by: `/posts/` path
2. Add widgets:
   - Pageviews per article
   - Entry sources (which articles get most LinkedIn traffic)
   - Reading time (track scroll depth)
   - Exit rate (how many users leave quickly)

### Clarity Dashboard Setup

**Heatmap Configuration**:

1. Navigate to: https://clarity.microsoft.com/
2. Select your project: `graphwiz-ai`
3. Click "Heatmaps" → "Manage heatmaps"
4. Add heatmaps for key pages:

**Priority Pages for Heatmaps**:
- Homepage (`/`)
- AI services overview (`/ai/`)
- Top 3 articles by traffic
- Contact page (`/contact/`)

**Session Recording Configuration**:

1. Navigate to: "Recordings" → "Manage recordings"
2. Configure recording rules:
   - Sampling rate: 10% (record 1 in 10 sessions)
   - Filter by: Pages (exclude test pages)
   - Max recording length: 5 minutes

### Google Search Console Setup

**Performance Monitoring**:

1. Navigate to: Performance
2. Add all pages from graphwiz.ai to monitoring
3. Set alerts:
   - **Core Web Vitals**: Alert if LCP > 2.5s, FID > 100ms, CLS > 0.1
   - **Indexed pages**: Alert if indexed pages drop by 10%

**Sitemap Monitoring**:

1. Navigate to: Sitemaps
2. Verify sitemap is current
3. Check last submission date
4. Submit manually if not submitted in 7 days

---

## KPI Targets

### Monthly Targets

| Metric | Target Month 1 | Target Month 2 | Target Month 3 |
|---------|----------------|----------------|----------------|
| Unique Visitors | 2,500 | 5,000 | 7,500 |
| Pageviews | 8,000 | 20,000 | 30,000 |
| Average Session Duration | 2:30 | 2:45 | 3:00 |
| Bounce Rate | <60% | <55% | <50% |
| Pages per Session | 3 | 3.2 | 3.5 |

### Article-Specific Targets

| Metric | Baseline | Target Q1 | Target Q2 |
|---------|----------|-----------|-----------|
| Article Avg. Views | 50 | 100 | 150 |
| Social Share Rate | 5% | 8% | 10% |
| 3D Viz Interaction Rate | 15% | 25% | 30% |
| Time on Page (avg) | 2:00 | 3:30 | 4:00 |

### Conversion Goals

| Goal | Baseline | Target | Metric |
|------|----------|--------|--------|
| Contact Form Submission | 5/month | 15/month | Form submissions |
| Service Inquiry | 2/month | 8/month | Email inquiries |
| Social Media Follow | 3% | 8% | LinkedIn followers from site |
| Article Return Visitors | 10% | 20% | Visitors returning within 30 days |

---

## Troubleshooting

### Common Issues

**Plausible Not Tracking**:
1. Check script is correctly added to `<head>`
2. Verify domain matches in data-domain attribute
3. Check browser console for errors
4. Clear cache and test again

**Clarity Not Recording**:
1. Check script is in `<head>`
2. Verify project ID matches
3. Check if ad-blocker is blocking clarity.ms
4. Verify site is published (not localhost)

**Google Search Console Not Indexing**:
1. Verify robots.txt allows crawling
2. Check for noindex meta tags on pages
3. Submit sitemap manually
4. Check for duplicate content issues

**Data Not Matching**:
1. Ensure Plausible and Clarity are enabled on production
2. Check date ranges match across all dashboards
3. Verify timezone settings are correct (Europe/Berlin)
4. Check for caching issues

---

## Maintenance

### Regular Tasks

**Weekly**:
- Check analytics for anomalies
- Review top-performing articles
- Monitor bounce rate
- Check social media traffic sources

**Monthly**:
- Review KPI targets vs. actuals
- Update content strategy based on data
- Review and update goals
- Check for technical issues (404s, crawling errors)

**Quarterly**:
- Full analytics audit
- Review privacy compliance
- Update tracking code for new features
- Review and adjust strategy

**Annual**:
- Review all analytics tools
- Audit data collection practices
- Update privacy policy
- Evaluate new analytics tools

---

## Resources

### Documentation Links

- Plausible: https://plausible.io/docs/
- Clarity: https://learn.microsoft.com/en-us/clarity/
- Hugo: https://gohugo.io/documentation/
- GDPR: https://gdpr.eu/

### Support

For questions or issues with analytics setup:
- Plausible Support: support@plausible.io
- Clarity Support: https://github.com/microsoft/clarity/issues
- Google Support: https://support.google.com/webmasters/

---

**Last Updated**: February 7, 2026
**Version**: 1.0
**Maintainer**: graphwiz-ai team
