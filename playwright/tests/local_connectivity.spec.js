// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Hugo Local Connectivity Checks', () => {

  test('Hugo Chemie Lernen (localhost:1313) is reachable', async ({ request }) => {
    const response = await request.get('http://localhost:1313/');
    expect(response.ok()).toBeTruthy();
  });

  test('Hugo GraphWiz AI (localhost:1314) is reachable', async ({ request }) => {
    // Port 1314 was used in hubs-compose
    const response = await request.get('http://localhost:1314/');
    expect(response.ok()).toBeTruthy();
  });

  test('Hugo Tobias Weiss (localhost:1315) is reachable', async ({ request }) => {
    // Port 1315 was used in hubs-compose
    const response = await request.get('http://localhost:1315/');
    expect(response.ok()).toBeTruthy();
  });

});
