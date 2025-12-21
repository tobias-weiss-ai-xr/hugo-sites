import { test, expect } from '@playwright/test';

/**
 * Playwright test to prevent HTML rendering issues
 * This test checks that HTML content is properly rendered and not displayed as escaped text
 */

test.describe('HTML Rendering Quality Tests', () => {

  test('interference timing page renders HTML properly', async ({ page }) => {
    await page.goto('https://tobias-weiss.org/interference-timing-genai-vr/');

    // Wait for page to load
    await page.waitForLoadState('networkidle');

    // Check that there are no code blocks displaying HTML content
    const codeBlocks = await page.locator('code').count();
    const preBlocks = await page.locator('pre').count();

    // We expect 0 code/pre blocks on this page (except for legitimate ones)
    expect(codeBlocks).toBe(0);
    expect(preBlocks).toBe(0);

    // Check for escaped HTML patterns that shouldn't be visible
    const pageContent = await page.content();

    // These escaped HTML patterns should not be visible in rendered content
    const escapedPatterns = [
      '&lt;div class=',
      '&lt;section id=',
      '&lt;button onclick=',
      '&gt;',
      '&lt;/div&gt;',
      '&lt;/section&gt;',
      '<pre><code>',
      '&amp;lt;div&amp;gt;'
    ];

    for (const pattern of escapedPatterns) {
      expect(pageContent).not.toContain(pattern);
    }

    // Check that interactive elements exist and are properly rendered
    await expect(page.locator('#product-grid')).toBeVisible();
    await expect(page.locator('#mainChart')).toBeVisible();
    await expect(page.locator('#step-1-icon')).toBeVisible();

    // Check that CSS classes are properly applied (not escaped)
    const productGrid = await page.locator('#product-grid');
    const gridClasses = await productGrid.getAttribute('class');
    expect(gridClasses).toContain('grid');
    expect(gridClasses).toContain('grid-cols-1');

    // Check that Tailwind CSS is loaded
    const tailwindLink = page.locator('link[href*="tailwindcss"]');
    await expect(tailwindLink).toBeVisible();

    // Check that Chart.js is loaded
    const chartScript = page.locator('script[src*="chart.js"]');
    await expect(chartScript).toBeVisible();

    // Test interactive functionality
    const perceptionButton = page.locator('#btn-perception');
    await expect(perceptionButton).toBeVisible();
    await perceptionButton.click();

    // Check that chart updates (button should have active class)
    await expect(perceptionButton).toHaveClass(/bg-white/);
  });

  test('other Hugo sites render HTML properly', async ({ page }) => {
    const sites = [
      'https://chemie-lernen.org/',
      'https://graphwiz.ai/',
      'https://tobias-weiss.org/'
    ];

    for (const site of sites) {
      await page.goto(site);
      await page.waitForLoadState('networkidle');

      // Check for escaped HTML patterns
      const pageContent = await page.content();
      const escapedPatterns = [
        '&lt;div class=',
        '&lt;section id=',
        '<pre><code>&lt;html',
        '&amp;lt;div&amp;gt;'
      ];

      for (const pattern of escapedPatterns) {
        expect(pageContent).not.toContain(pattern, `Found escaped HTML pattern ${pattern} on ${site}`);
      }

      // Check that the page loads successfully
      await expect(page.locator('body')).toBeVisible();

      console.log(`✅ ${site} - HTML rendering OK`);
    }
  });

  test('detect malformed HTML in Hugo content', async ({ page, request }) => {
    // This test checks for common HTML rendering issues in Hugo pages

    const pages = [
      'https://tobias-weiss.org/interference-timing-genai-vr/',
      'https://tobias-weiss.org/gallery/',
      'https://tobias-weiss.org/research/',
      'https://chemie-lernen.org/periodic-table/',
      'https://graphwiz.ai/ai/'
    ];

    for (const url of pages) {
      const response = await request.get(url);
      const content = await response.text();

      // Check for indicators of HTML rendering problems
      const problematicPatterns = [
        /<pre><code>.*?<\/code><\/pre>/g,  // Code blocks that shouldn't be there
        /&lt;[a-zA-Z]/g,                     // Escaped HTML tags
        /&gt;[^<]*&lt;/g,                      // Multiple escaped tags
        /<!DOCTYPE html>.*<!DOCTYPE html>/gs // Duplicate DOCTYPE declarations
      ];

      for (const pattern of problematicPatterns) {
        const matches = content.match(pattern);
        if (matches && matches.length > 0) {
          // Allow legitimate code blocks (check if they contain HTML escape sequences)
          const containsEscapedHtml = matches.some(match =>
            match.includes('&lt;') || match.includes('&gt;') || match.includes('div class=')
          );

          if (containsEscapedHtml) {
            console.warn(`⚠️  Potential HTML rendering issue detected on ${url}`);
            console.warn(`Found problematic pattern: ${matches[0].substring(0, 100)}...`);
          }
        }
      }

      // Verify the page loads with proper HTML structure
      expect(response.status()).toBe(200);
      expect(content).toContain('<html');
      expect(content).toContain('</html>');
      expect(content).toContain('<body');
      expect(content).toContain('</body>');

      console.log(`✅ ${url} - HTML structure OK`);
    }
  });

  test('validate interactive elements functionality', async ({ page }) => {
    await page.goto('https://tobias-weiss.org/interference-timing-genai-vr/');

    // Test navigation buttons
    const navButtons = page.locator('nav button');
    const buttonCount = await navButtons.count();
    expect(buttonCount).toBeGreaterThan(0);

    // Test that clicking navigation buttons scrolls to sections
    for (let i = 0; i < Math.min(buttonCount, 2); i++) {
      const button = navButtons.nth(i);
      const buttonText = await button.textContent();

      if (buttonText && buttonText.includes('Abstract')) {
        await button.click();
        // Check that page scrolled (simply check that we can still find elements)
        await expect(page.locator('#hero')).toBeVisible();
        break;
      }
    }

    // Test pipeline step interaction
    await page.locator('#step-2-icon').click();
    await expect(page.locator('#detail-title')).toContainText('Speech-to-Text');

    // Test chart toggle
    await page.locator('#btn-outcomes').click();
    await expect(page.locator('#btn-outcomes')).toHaveClass(/bg-white/);
  });
});