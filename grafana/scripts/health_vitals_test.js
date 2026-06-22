import { browser } from 'k6/browser';
import { check, sleep } from 'k6';

export const options = {
  scenarios: {
    portfolio_health: {
      executor: 'constant-vus',
      vus: 1,
      duration: '30s',

      options: {
        browser: {
          type: 'chromium',
        },
      },
    },
  },

  thresholds: {
    // Core Web Vitals
    browser_web_vital_lcp: ['p(95)<2500'],
    browser_web_vital_cls: ['p(95)<0.1'],
    browser_web_vital_fcp: ['p(95)<1800'],
    browser_web_vital_ttfb: ['p(95)<800'],
    browser_web_vital_inp: ['p(95)<200'],

    // Reliability
    checks: ['rate>0.99'],
    browser_http_req_failed: ['rate<0.01'],
  },
};

export default async function () {
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    const response = await page.goto(
      'https://justanother.engineer',
      {
        waitUntil: 'networkidle',
      }
    );

    check(response, {
      'status is 2xx': (r) =>
        r && r.status() >= 200 && r.status() < 300,
    });

    const title = await page.title();

    check(title, {
      'page has title': (t) => t.length > 0,
      'not an error page': (t) =>
        !t.toLowerCase().includes('404') &&
        !t.toLowerCase().includes('error'),
    });

    const bodyText = await page.evaluate(
      () => document.body.innerText
    );

    check(bodyText, {
      'page has content': (t) =>
        t && t.trim().length > 0,
    });

    // Simulate a tiny amount of user time on page
    sleep(1);

  } finally {
    await page.close();
    await context.close();
  }
}
