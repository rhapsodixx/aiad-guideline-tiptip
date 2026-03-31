---
last_updated: 2026-03-31
sources:
  - "web.dev Core Web Vitals — https://web.dev/articles/vitals"
  - "HTTP Archive 2025 Web Almanac Performance — https://almanac.httparchive.org/en/2025/performance"
  - "HTTP Archive 2025 Web Almanac Page Weight — https://almanac.httparchive.org/en/2025/page-weight"
  - "HTTP Archive 2025 Web Almanac Accessibility — https://almanac.httparchive.org/en/2025/accessibility"
  - "Practical Ecommerce — 70 Leading Retailers Lighthouse Scores — https://www.practicalecommerce.com/70-leading-retailers-lighthouse-scores-revealed"
  - "DebugBear — Lighthouse Performance Scoring — https://www.debugbear.com/docs/metrics/lighthouse-performance"
  - "Google PageSpeed Insights — https://developers.google.com/speed/docs/insights/v5/about"
---

# Industry Benchmarks — Travel/Ticketing

## Threshold Reference Table

| Metric | Google "Good" | Travel/Ticketing Industry Median | Audit Target | Notes |
|--------|---------------|----------------------------------|--------------|-------|
| Performance (mobile) | ≥ 90 (excellent), ≥ 50 (acceptable) | ~35 (mobile median across all sites: 37) | **≥ 50** | Travel sites with heavy imagery rarely hit 90; 50 is a realistic competitive bar |
| Performance (desktop) | ≥ 90 (excellent), ≥ 50 (acceptable) | ~72 (desktop median across all sites) | **≥ 72** | Desktop has more headroom; match the general web median |
| Accessibility | ≥ 90 | ~84 (web median), ~60 (ecommerce avg) | **≥ 85** | Web median improved to 85% in 2025; ecommerce significantly lags |
| Best Practices | ≥ 80 | ~75 (ecommerce typical) | **≥ 80** | Google's threshold is the higher bar here |
| SEO | ≥ 90 | ~86 (ecommerce avg from 70-retailer audit) | **≥ 90** | Google's threshold is the higher bar |
| LCP | ≤ 2.5s | ~3.0–4.0s (travel/image-heavy sites) | **≤ 2.5s** | Google's CWV threshold; 75th percentile metric |
| Page Weight (mobile) | ≤ 2.0 MB (best practice) | 2.6 MB (2025 HTTP Archive mobile median) | **≤ 2.6 MB** | Industry median grew 8.4% YoY; use median as realistic target |
| Page Weight (desktop) | ≤ 2.0 MB (best practice) | 2.9 MB (2025 HTTP Archive desktop median) | **≤ 2.9 MB** | Desktop median grew 7.3% YoY |

## Methodology

- **Audit Target** = the higher of Google's "Good" threshold OR the travel/ticketing industry median — whichever sets a more meaningful quality bar.
- Performance thresholds use "acceptable" (≥ 50) rather than "excellent" (≥ 90) because image-heavy travel/ticketing sites realistically cannot achieve 90+ without removing core content.
- All CWV metrics (LCP, CLS, INP) use Google's 75th-percentile "good" threshold from web.dev.

## Severity Classification Thresholds

| Severity | Criteria |
|----------|----------|
| **P0 (Critical)** | Below Google's "good" threshold AND below industry median — fundamentally broken, fix immediately |
| **P1 (High)** | Below Google's "good" threshold but near industry median — high user impact, prioritize within sprint |
| **P2 (Medium)** | Meets Google's minimum but below industry median — competitive disadvantage, plan for improvement |
| **P3 (Low)** | Meets both thresholds but individual audit items flag opportunities > 0.3s savings — nice-to-have |

## Competitor Context

Based on 2025 research across travel/ticketing platforms (Klook, GetYourGuide, Viator, Tiqets):

- **Mobile performance** in travel industry is consistently poor (median ~35), driven by heavy hero imagery, interactive calendars/date pickers, and third-party booking widgets.
- **Desktop performance** is significantly better (median ~72) due to stronger hardware and wider viewport reducing layout complexity.
- **Accessibility** across ecommerce averages only ~60, well below the general web median of ~84. Travel sites with strong accessibility (85+) have a competitive advantage.
- **SEO** is generally strong in travel ecommerce (~86 avg), as these sites invest heavily in organic search traffic which drives ~31% of total traffic.
- **Page weight** for image-heavy travel catalogs typically exceeds the general web median. Mobile booking completion rates are 40% lower than desktop, partly due to performance.
- **LCP** is a known pain point for travel sites due to hero images, image carousels, and dynamically loaded pricing widgets.

## Core Web Vitals Reference (Google 2025)

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP | ≤ 2.5s | 2.5s – 4.0s | > 4.0s |
| INP | ≤ 200ms | 200ms – 500ms | > 500ms |
| CLS | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |

## General Web Statistics (2025)

- Good CWV achievement: 48% of mobile sites, 56% of desktop sites
- Good FCP: 55% mobile, 70% desktop
- Median page weight: Mobile 2.6 MB (+8.4% YoY), Desktop 2.9 MB (+7.3% YoY)
- Median Lighthouse accessibility score: 85% (up from 84% in 2024)
