// @ts-check
const { test, expect } = require('@playwright/test');

const DOMAIN = 'chemie-lernen.org';

test.describe('Hugo Site Health Checks', () => {

  test('Hugo Chemie Lernen is reachable', async ({ page }) => {
    await page.goto(`https://${DOMAIN}/`);
    await expect(page).toHaveTitle(/Chemie Lernen/);
  });

  test('Periodic Table Page is reachable and has expected content', async ({ page }) => {
    await page.goto(`https://${DOMAIN}/periodic-table/`, { waitUntil: 'networkidle' });
    await expect(page).toHaveTitle('Periodic Table');
    // Check for a specific element on the periodic table page to ensure it rendered
    await expect(page.locator('#info')).toContainText('three.js css3d - periodic table.');
    await expect(page.locator('#container')).toBeVisible();
  });

  test('GraphWiz AI is reachable', async ({ page }) => {
    await page.goto('https://graphwiz.ai/');
    await expect(page).toHaveTitle(/GraphWiz/);
  });

  test('Tobias Weiss is reachable', async ({ page }) => {
    await page.goto('https://tobias-weiss.org/');
    await expect(page).toHaveTitle(/Tobias Weiss/);
  });
});
