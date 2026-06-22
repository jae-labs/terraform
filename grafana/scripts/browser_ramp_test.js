import { browser } from "k6/browser";
import { check, sleep } from "k6";

export const options = {
  scenarios: {
    portfolio_ramp_up: {
      executor: "ramping-vus",
      startVUs: 1,

      stages: [
        // Warm up
        { duration: "1m", target: 2 },

        // Gradually increase traffic
        { duration: "2m", target: 5 },

        // Peak browser VU load
        { duration: "2m", target: 10 },

        // Hold at peak to observe stability
        { duration: "3m", target: 10 },

        // Ramp down
        { duration: "1m", target: 0 },
      ],

      options: {
        browser: {
          type: "chromium",
        },
      },
    },
  },

  thresholds: {
    // Core Web Vitals under load
    browser_web_vital_lcp: ["p(95)<5500"],
    browser_web_vital_cls: ["p(95)<0.25"],
    browser_web_vital_fcp: ["p(95)<5500"],
    browser_web_vital_ttfb: ["p(95)<600"],
    browser_web_vital_inp: ["p(95)<2500"],

    // General reliability
    checks: ["rate>0.99"],
    browser_http_req_failed: ["rate<0.01"],
  },
};

export default async function () {
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate and wait until the page is stable
    const response = await page.goto("https://justanother.engineer", {
      waitUntil: "networkidle",
    });

    // Basic availability check
    check(response, {
      "status is 2xx": (r) => r && r.status() >= 200 && r.status() < 300,
    });

    // Small amount of user interaction
    // (simulates a visitor staying briefly)
    await page.locator("body").click();

    // Random think time between users
    sleep(Math.random() * 2 + 1);
  } finally {
    await page.close();
    await context.close();
  }
}
