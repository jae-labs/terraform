import { browser } from "k6/browser";
import { expect } from "https://jslib.k6.io/k6-testing/0.5.0/index.js";
import { check } from 'https://jslib.k6.io/k6-utils/1.5.0/index.js';
// import secrets from 'k6/secrets';

// ------------------------------------------------------------//
//   Record your browser script using Grafana k6 Studio!       //
//   Visit https://grafana.com/docs/k6-studio/set-up/install/  //
// ------------------------------------------------------------//

export const options = {
  scenarios: {
    default: {
      executor: "shared-iterations",
      options: { browser: { type: "chromium" } },
    },
  },
};

// This example logs into quickpizza.grafana.com
export default async function () {
  const context = await browser.newContext();
  const page = await context.newPage();
  try {
    await page.goto('https://quickpizza.grafana.com/admin', { waitUntil: 'networkidle' });

    // TIP: Secure your credentials using secrets.get()
    // https://grafana.com/docs/grafana-cloud/testing/synthetic-monitoring/create-checks/manage-secrets/
    const username = 'admin'; // username = await secrets.get('quickpizza-username');
    const password = 'admin'; // password = await secrets.get('quickpizza-password');

    await page.getByRole('textbox', { name: 'Username' }).fill(username);
    await page.getByRole('textbox', { name: 'Password' }).fill(password);

    const signIn = page.getByRole('button', { name: 'Sign in' });
    await signIn.click();
    await expect(signIn).toBeHidden();

    const heading = page.getByRole('heading');
    await expect(heading).toBeVisible();
    console.log('H2 header: ', await heading.textContent()); // will appear as logs in Loki

    // TIP: Use expect() to immediately abort execution and fail a test (impacts uptime/reachability)
    await expect(heading).toContainText("Latest pizza recommendations");

    // TIP: Use check() to report test results in the 'assertions' dashboard panel
    // Scripts continue to run even if a check fails. Failed checks don't impact uptime and reachability
    await check(heading, {
      ["Header is present"]: async (h) => (await h.textContent()) == "Latest pizza recommendations"
    });

  } catch (e) {
    console.log('Error during execution:', e);
    throw e;
  } finally {
    await page.close();
  }
}