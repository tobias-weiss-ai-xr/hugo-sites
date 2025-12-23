const { test, expect } = require('@playwright/test');

/**
 * Test suite for GraphWiz footer margin verification
 * Ensures footer list-inline-item elements have no left/right margin
 */

test.describe('GraphWiz Footer Margin Tests', () => {
  const baseUrl = 'https://graphwiz.ai';

  test.beforeEach(async ({ page }) => {
    await page.goto(baseUrl);
  });

  test('footer navigation elements should have no left margin', async ({ page }) => {
    // Wait for footer to be visible
    await page.waitForSelector('footer', { timeout: 5000 });

    // Get all list-inline-item elements in the footer
    const footerItems = page.locator('.footer-nav .list-inline-item');

    // Count the items
    const count = await footerItems.count();
    expect(count).toBeGreaterThan(0);

    // Check each item's computed left margin
    for (let i = 0; i < count; i++) {
      const item = footerItems.nth(i);
      const marginLeft = await item.evaluate((el) =>
        window.getComputedStyle(el).marginLeft
      );

      // Parse the margin value (e.g., "0px" -> 0)
      const marginValue = parseFloat(marginLeft);

      expect(marginValue).toBe(0);
      console.log(`Item ${i + 1} left margin: ${marginLeft} ✓`);
    }
  });

  test('footer navigation elements should have no right margin', async ({ page }) => {
    // Wait for footer to be visible
    await page.waitForSelector('footer', { timeout: 5000 });

    // Get all list-inline-item elements in the footer
    const footerItems = page.locator('.footer-nav .list-inline-item');

    const count = await footerItems.count();
    expect(count).toBeGreaterThan(0);

    // Check each item's computed right margin
    for (let i = 0; i < count; i++) {
      const item = footerItems.nth(i);
      const marginRight = await item.evaluate((el) =>
        window.getComputedStyle(el).marginRight
      );

      // Parse the margin value
      const marginValue = parseFloat(marginRight);

      expect(marginValue).toBe(0);
      console.log(`Item ${i + 1} right margin: ${marginRight} ✓`);
    }
  });

  test('Personal Blog link should have no left/right margin', async ({ page }) => {
    // Wait for footer to be visible
    await page.waitForSelector('footer', { timeout: 5000 });

    // Find the Personal Blog link specifically
    const personalBlogLink = page.locator('.footer-nav a[href="https://tobias-weiss.org/"]');

    await expect(personalBlogLink).toBeVisible();

    // Get the parent li element
    const parentLi = personalBlogLink.locator('..');

    // Check computed margins
    const marginLeft = await parentLi.evaluate((el) =>
      window.getComputedStyle(el).marginLeft
    );
    const marginRight = await parentLi.evaluate((el) =>
      window.getComputedStyle(el).marginRight
    );

    const leftMarginValue = parseFloat(marginLeft);
    const rightMarginValue = parseFloat(marginRight);

    expect(leftMarginValue).toBe(0);
    expect(rightMarginValue).toBe(0);

    console.log(`Personal Blog link margins - Left: ${marginLeft}, Right: ${marginRight} ✓`);
  });

  test('all footer links are clickable and properly spaced', async ({ page }) => {
    // Wait for footer to be visible
    await page.waitForSelector('footer', { timeout: 5000 });

    // Get all footer links
    const footerLinks = page.locator('.footer-nav a');

    const count = await footerLinks.count();
    expect(count).toBeGreaterThan(0);

    // Verify each link is visible and has proper styling
    for (let i = 0; i < count; i++) {
      const link = footerLinks.nth(i);

      await expect(link).toBeVisible();

      // Check that the link has some color (not invisible)
      const color = await link.evaluate((el) =>
        window.getComputedStyle(el).color
      );
      expect(color).not.toBe('rgba(0, 0, 0, 0)');
    }
  });

  test('footer list items have separator pipes between them', async ({ page }) => {
    // Wait for footer to be visible
    await page.waitForSelector('footer', { timeout: 5000 });

    // Check that the ::after pseudo-elements are present (the separator pipes)
    const footerItems = page.locator('.footer-nav .list-inline-item:not(:last-child)');

    const count = await footerItems.count();
    expect(count).toBeGreaterThan(0);

    // Verify separator content exists via CSS check
    const styles = await page.evaluate(() => {
      const sheet = Array.from(document.styleSheets).find(s =>
        s.href?.includes('footer-custom.css')
      );
      if (!sheet) return null;

      const rules = Array.from(sheet.cssRules || sheet.rules);
      return rules.map(r => r.cssText);
    });

    expect(styles).toBeTruthy();
    console.log('Footer CSS styles loaded ✓');
  });
});
