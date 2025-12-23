const { test, expect } = require('@playwright/test');

/**
 * Visual test for footer spacing - captures screenshot and analyzes positions
 */

test.describe('Footer Visual Spacing Test', () => {
  const baseUrl = 'https://graphwiz.ai';

  test('capture footer screenshot and analyze spacing', async ({ page }) => {
    await page.goto(baseUrl, { waitUntil: 'networkidle' });

    // Wait for footer to be visible
    await page.waitForSelector('footer', { timeout: 5000 });

    // Get the footer navigation element
    const footerNav = page.locator('.footer-nav');
    await expect(footerNav).toBeVisible();

    // Get all footer links
    const links = await footerNav.locator('.list-inline-item a').all();
    console.log(`Found ${links.length} footer links`);

    // Get positions and widths of all links
    const linkInfo = [];
    for (let i = 0; i < links.length; i++) {
      const link = links[i];
      const box = await link.boundingBox();
      const text = await link.textContent();

      linkInfo.push({
        index: i,
        text: text.trim(),
        x: box.x,
        y: box.y,
        width: box.width,
        right: box.x + box.width
      });

      console.log(`Link ${i}: "${text.trim()}" - x: ${box.x}, width: ${box.width}, right: ${box.x + box.width}`);
    }

    // Calculate gaps between consecutive links
    console.log('\n=== Gap Analysis ===');
    const gaps = [];
    for (let i = 0; i < linkInfo.length - 1; i++) {
      const current = linkInfo[i];
      const next = linkInfo[i + 1];
      const gap = next.x - current.right;

      gaps.push({
        between: `${current.text} -> ${next.text}`,
        gap: gap
      });

      console.log(`Gap between "${current.text}" and "${next.text}": ${gap}px`);
    }

    // Check if gaps are approximately equal (within 5px tolerance)
    if (gaps.length > 0) {
      const avgGap = gaps.reduce((sum, g) => sum + g.gap, 0) / gaps.length;
      console.log(`\nAverage gap: ${avgGap.toFixed(2)}px`);

      const maxDeviation = Math.max(...gaps.map(g => Math.abs(g.gap - avgGap)));
      console.log(`Max deviation from average: ${maxDeviation.toFixed(2)}px`);

      if (maxDeviation > 5) {
        console.log('\n⚠️  WARNING: Gaps are NOT equidistant!');
        console.log('Deviations:');
        gaps.forEach(g => {
          const deviation = g.gap - avgGap;
          console.log(`  ${g.between}: ${g.gap}px (deviation: ${deviation > 0 ? '+' : ''}${deviation.toFixed(2)}px)`);
        });
      } else {
        console.log('\n✓ Gaps are approximately equidistant');
      }
    }

    // Take screenshot of footer for visual inspection
    await footerNav.screenshot({
      path: 'test-results/footer-spacing.png',
      fullPage: false
    });
    console.log('\nScreenshot saved to: test-results/footer-spacing.png');

    // Get the computed styles for list-inline-item
    const listItems = await footerNav.locator('.list-inline-item').all();
    console.log('\n=== Computed Styles ===');

    for (let i = 0; i < listItems.length; i++) {
      const item = listItems[i];
      const text = await item.locator('a').textContent();

      const marginLeft = await item.evaluate((el) =>
        window.getComputedStyle(el).marginLeft
      );
      const marginRight = await item.evaluate((el) =>
        window.getComputedStyle(el).marginRight
      );
      const paddingLeft = await item.evaluate((el) =>
        window.getComputedStyle(el).paddingLeft
      );
      const paddingRight = await item.evaluate((el) =>
        window.getComputedStyle(el).paddingRight
      );

      console.log(`\nItem ${i} (${text.trim()}):`);
      console.log(`  margin-left: ${marginLeft}`);
      console.log(`  margin-right: ${marginRight}`);
      console.log(`  padding-left: ${paddingLeft}`);
      console.log(`  padding-right: ${paddingRight}`);
    }

    // Check separator pipes
    console.log('\n=== Separator Pipes ===');
    for (let i = 0; i < listItems.length - 1; i++) {
      const item = listItems[i];
      const text = await item.locator('a').textContent();

      // Check ::after pseudo-element
      const afterContent = await item.evaluate((el) => {
        const styles = window.getComputedStyle(el, '::after');
        return {
          content: styles.content,
          marginLeft: styles.marginLeft,
          marginRight: styles.marginRight,
          width: styles.width
        };
      });

      console.log(`\nAfter "${text.trim()}":`);
      console.log(`  content: ${afterContent.content}`);
      console.log(`  margin-left: ${afterContent.marginLeft}`);
      console.log(`  margin-right: ${afterContent.marginRight}`);
      console.log(`  width: ${afterContent.width}`);
    }
  });

  test('full page screenshot for context', async ({ page }) => {
    await page.goto(baseUrl, { waitUntil: 'networkidle' });
    await page.waitForSelector('footer', { timeout: 5000 });

    // Scroll to footer
    await page.locator('footer').scrollIntoViewIfNeeded();

    // Take screenshot
    await page.screenshot({
      path: 'test-results/footer-full-page.png',
      fullPage: true
    });
    console.log('Full page screenshot saved to: test-results/footer-full-page.png');
  });
});
