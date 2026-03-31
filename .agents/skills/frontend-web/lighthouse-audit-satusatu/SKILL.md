---
name: lighthouse-audit-satusatu
description: Use when auditing SatuSatu web performance — runs Lighthouse on homepage and catalog detail pages across 3 test modes (desktop, mobile-unthrottled, mobile-throttled), reads pre-researched travel/ticketing industry benchmarks, captures page screenshots, and generates a severity-graded markdown report with throttle impact analysis and techstack-specific fixes. Supports refresh-benchmarks command to update industry data.
---

# Lighthouse Audit — SatuSatu

## Role

You are a Senior Web Performance Engineer conducting a comprehensive Lighthouse audit for a travel/attractions e-commerce platform. You combine deep knowledge of Core Web Vitals, web performance optimization, and frontend architecture with awareness of industry-specific benchmarks for travel and ticketing websites.

## Commands

This skill supports two commands:

| Command | Purpose |
|---------|---------|
| **`audit`** (default) | Run full Lighthouse audit — screenshots, audits, severity grading, throttle impact analysis, markdown report |
| **`refresh-benchmarks`** | Research current industry benchmarks via WebSearch and update `industry-benchmarks.md` |

If no command is specified, run `audit`.

---

## Command: `audit`

### Audit URLs

| Page | URL |
|------|-----|
| Homepage | `https://satusatu.com/en-US` |
| Catalog Detail | `https://satusatu.com/en-US/catalog/uluwatu-temple-kecak-fire-dance-satusatu-curated-experience-sameday-booking-bonus-merchandise` |

### Test Modes

Audits run in **3 modes** to get a complete performance picture:

| Test Mode | Viewport | Network Throttling | CPU Slowdown | Purpose |
|-----------|----------|--------------------|--------------|---------|
| `desktop` | 1440×900 | None | None | Best-case baseline — raw site capability |
| `mobile-unthrottled` | 375×812 | None | None | Isolates mobile layout/rendering issues from network constraints |
| `mobile-throttled` | 375×812 | Simulated Slow 4G (1.6 Mbps ↓ / 750 Kbps ↑, 150ms RTT) | 4× | Real-world mobile experience |

Total audit runs: **6** (2 URLs × 3 modes). Do NOT skip any combination.

**Why 3 modes:** Comparing mobile-throttled vs mobile-unthrottled reveals whether performance issues come from the code itself or from network/CPU constraints. If unthrottled mobile is also slow, the problem is in the code — not the network.

### Lighthouse Settings

All audits use the following Lighthouse configuration. Include this in the report.

| Setting | Value |
|---------|-------|
| Lighthouse version | As reported by `mcp__lighthouse__run_audit` response (`version` field) |
| Categories | `performance`, `accessibility`, `best-practices`, `seo` |
| User agent | HeadlessChrome (as reported by Lighthouse) |

**Per-mode configuration:**

| Setting | Desktop | Mobile Unthrottled | Mobile Throttled |
|---------|---------|-------------------|------------------|
| Device emulation | `desktop` | `mobile` | `mobile` |
| `throttling` parameter | _(default)_ | `false` | _(default)_ |
| Network throttling | None | None | Slow 4G (1.6 Mbps ↓ / 750 Kbps ↑, 150ms RTT) |
| CPU slowdown | None | None | 4× |
| Viewport | 1440×900 | 375×812 | 375×812 |

### Output Directory

All output goes into: `lighthouse-audit-satusatu-report/`

```
lighthouse-audit-satusatu-report/
  screenshots/
    homepage-desktop.png
    homepage-mobile-unthrottled.png
    homepage-mobile-throttled.png
    catalog-detail-desktop.png
    catalog-detail-mobile-unthrottled.png
    catalog-detail-mobile-throttled.png
  report.md
```

Create this directory structure at the start. Use absolute paths from the current working directory.

### Process

Execute these steps in order:

#### Step 1 — Read Techstack

Read `techstack.md` from this skill's directory. All suggested fixes MUST be specific to the techstack defined there. Do NOT suggest generic fixes when a framework-specific solution exists.

#### Step 2 — Read Industry Benchmarks

Read `industry-benchmarks.md` from this skill's directory. This file contains pre-researched thresholds for Google's "Good" standards, travel/ticketing industry medians, and audit targets. Note the `last_updated` date from the frontmatter — include it in the report so readers know benchmark freshness.

Do NOT run WebSearch for benchmarks during `audit`. If `industry-benchmarks.md` is missing, instruct the user to run `refresh-benchmarks` first.

#### Step 3 — Capture Screenshots

Use Playwright MCP to capture full-page screenshots of each URL at each viewport. These screenshots provide visual context for the audit report.

For each of the 6 combinations (2 URLs × 3 modes):

1. Navigate to the URL using `mcp__plugin_playwright_playwright__browser_navigate`
2. Resize viewport using `mcp__plugin_playwright_playwright__browser_resize`:
   - Desktop: width 1440, height 900
   - Mobile (both modes): width 375, height 812
3. Wait for page load using `mcp__plugin_playwright_playwright__browser_wait_for` (wait 3 seconds)
4. Take a full-page screenshot using `mcp__plugin_playwright_playwright__browser_take_screenshot`

File names:
- `screenshots/homepage-desktop.png`
- `screenshots/homepage-mobile-unthrottled.png`
- `screenshots/homepage-mobile-throttled.png`
- `screenshots/catalog-detail-desktop.png`
- `screenshots/catalog-detail-mobile-unthrottled.png`
- `screenshots/catalog-detail-mobile-throttled.png`

**Note:** Mobile-unthrottled and mobile-throttled use the same viewport (375×812). Capture separate screenshots anyway — page content may render differently under throttled conditions (lazy-loaded images, deferred content may not have loaded).

#### Step 4 — Run Lighthouse Audits

Use `mcp__lighthouse__run_audit` for all 6 combinations with categories: `performance`, `accessibility`, `best-practices`, `seo`.

**API call parameters per mode:**

| Mode | `device` | `throttling` |
|------|----------|-------------|
| Desktop | `"desktop"` | _(omit — default: no throttle)_ |
| Mobile Unthrottled | `"mobile"` | `false` |
| Mobile Throttled | `"mobile"` | _(omit — default: true)_ |

Record the Lighthouse version and user agent from the first response for the report's Lighthouse Settings section.

#### Step 5 — Collect & Categorize Scores

Extract from each of the 6 audit runs:
- Performance (overall score)
- Accessibility
- Best Practices
- SEO
- LCP (from performance details)
- FCP (from performance details)
- TBT (from performance details)
- CLS (from performance details)
- Speed Index (from performance details)
- TTI (from performance details)

#### Step 6 — Compare Against Benchmarks

Use the **Audit Target** column from `industry-benchmarks.md` as the quality bar. Apply the appropriate threshold (mobile or desktop) for each test mode:
- Desktop → use desktop thresholds
- Mobile Unthrottled → use mobile thresholds (layout/rendering baseline)
- Mobile Throttled → use mobile thresholds (real-world target)

#### Step 7 — Severity Classification

Use the severity criteria defined in `industry-benchmarks.md` under "Severity Classification Thresholds":

| Severity | Criteria |
|----------|----------|
| **P0 (Critical)** | Below Google's "good" threshold AND below industry median — fundamentally broken, fix immediately |
| **P1 (High)** | Below Google's "good" threshold but near industry median — high user impact, prioritize within sprint |
| **P2 (Medium)** | Meets Google's minimum but below industry median — competitive disadvantage, plan for improvement |
| **P3 (Low)** | Meets both thresholds but individual audit items flag opportunities > 0.3s savings — nice-to-have |

**Severity is determined from the mobile-throttled results** (real-world scenario). Mobile-unthrottled results inform the root cause analysis, not the severity grade.

#### Step 8 — Generate Markdown Report

Write the report to `lighthouse-audit-satusatu-report/report.md`.

Use section-by-section file appending if the report exceeds 500 lines. Never print large reports to terminal.

<report_structure>
The markdown report MUST follow this structure:

```markdown
# SatuSatu Lighthouse Audit Report

> **Generated:** {date}
> **Techstack:** {from techstack.md}
> **Benchmarks last updated:** {last_updated from industry-benchmarks.md frontmatter}

## Lighthouse Settings

| Setting | Value |
|---------|-------|
| Lighthouse version | {from audit response} |
| Categories | performance, accessibility, best-practices, seo |
| User agent | {from audit response} |

| Setting | Desktop | Mobile Unthrottled | Mobile Throttled |
|---------|---------|-------------------|------------------|
| Network throttling | None | None | Slow 4G (1.6 Mbps / 750 Kbps, 150ms RTT) |
| CPU slowdown | None | None | 4× |
| Viewport | 1440 × 900 | 375 × 812 | 375 × 812 |

## Screenshots

### Homepage
| Desktop | Mobile Unthrottled | Mobile Throttled |
|---------|-------------------|------------------|
| ![](screenshots/homepage-desktop.png) | ![](screenshots/homepage-mobile-unthrottled.png) | ![](screenshots/homepage-mobile-throttled.png) |

### Catalog Detail
| Desktop | Mobile Unthrottled | Mobile Throttled |
|---------|-------------------|------------------|
| ![](screenshots/catalog-detail-desktop.png) | ![](screenshots/catalog-detail-mobile-unthrottled.png) | ![](screenshots/catalog-detail-mobile-throttled.png) |

## Industry Benchmark Context

> Benchmarks last researched: {last_updated from industry-benchmarks.md}
> Run `/lighthouse-audit-satusatu refresh-benchmarks` to update.

{Threshold Reference Table copied from industry-benchmarks.md with sources}

| Metric | Google "Good" | Travel/Ticketing Industry Median | Audit Target | Sources |
|--------|---------------|----------------------------------|--------------|---------|
| ... | ... | ... | ... | ... |

## Executive Summary

{Pass/Fail matrix per category, per URL, across all 3 modes}
- ✅ Pass (meets audit target)
- ⚠️ Needs Work (between Google "good" and industry median)
- ❌ Fail (below both)

### Homepage

| Category | Desktop | Mobile Unthrottled | Mobile Throttled |
|----------|---------|-------------------|------------------|
| Performance | ... | ... | ... |
| Accessibility | ... | ... | ... |
| Best Practices | ... | ... | ... |
| SEO | ... | ... | ... |
| LCP | ... | ... | ... |

### Catalog Detail

| Category | Desktop | Mobile Unthrottled | Mobile Throttled |
|----------|---------|-------------------|------------------|
| Performance | ... | ... | ... |
| Accessibility | ... | ... | ... |
| Best Practices | ... | ... | ... |
| SEO | ... | ... | ... |
| LCP | ... | ... | ... |

## Score Dashboard

{Detailed scores with all threshold columns — 6 rows per category}

| Category | URL | Mode | Score | Google "Good" | Industry Median | Target | Status |
|----------|-----|------|-------|---------------|-----------------|--------|--------|
| ... | ... | ... | ... | ... | ... | ... | ... |

### Additional Metrics

| Metric | Homepage Desktop | Homepage Mobile Unthrottled | Homepage Mobile Throttled | Catalog Desktop | Catalog Mobile Unthrottled | Catalog Mobile Throttled |
|--------|-----------------|----------------------------|--------------------------|-----------------|----------------------------|--------------------------|
| FCP | ... | ... | ... | ... | ... | ... |
| LCP | ... | ... | ... | ... | ... | ... |
| TBT | ... | ... | ... | ... | ... | ... |
| Speed Index | ... | ... | ... | ... | ... | ... |
| TTI | ... | ... | ... | ... | ... | ... |
| CLS | ... | ... | ... | ... | ... | ... |

## Throttle Impact Analysis

Compares mobile-unthrottled vs mobile-throttled to isolate network/CPU impact from code issues.

### Homepage

| Metric | Unthrottled | Throttled | Delta | Bottleneck |
|--------|-------------|-----------|-------|------------|
| Performance | ... | ... | ... | Code / Network / Both |
| LCP | ... | ... | ... | ... |
| TBT | ... | ... | ... | ... |
| FCP | ... | ... | ... | ... |
| Speed Index | ... | ... | ... | ... |
| TTI | ... | ... | ... | ... |

### Catalog Detail

| Metric | Unthrottled | Throttled | Delta | Bottleneck |
|--------|-------------|-----------|-------|------------|
| Performance | ... | ... | ... | Code / Network / Both |
| LCP | ... | ... | ... | ... |
| TBT | ... | ... | ... | ... |
| FCP | ... | ... | ... | ... |
| Speed Index | ... | ... | ... | ... |
| TTI | ... | ... | ... | ... |

**Bottleneck Classification:**
- **Code** — Unthrottled score is also poor (below audit target). The problem is in the code regardless of network conditions. Fix: optimize JS bundles, rendering pipeline, image sizes.
- **Network** — Unthrottled passes but throttled fails. The code is fine but transfer sizes or server response times degrade under constrained networks. Fix: reduce payload sizes, improve caching, optimize TTFB.
- **Both** — Unthrottled is borderline (near target) and throttling pushes it to failure. Both code optimization and network optimization needed.

## Findings by Severity

### P0 — Critical
{Each finding with: category, URL, mode, current vs target, bottleneck from throttle analysis, suggested fix, effort}

### P1 — High
...

### P2 — Medium
...

### P3 — Low
...

## Competitor Context

{From industry-benchmarks.md — how SatuSatu compares to travel/ticketing benchmarks}

## Priority Action Plan

| Priority | Finding | Bottleneck | Effort | Expected Impact |
|----------|---------|------------|--------|-----------------|
| ... | ... | Code/Network/Both | ... | ... |

## Techstack Context

{Current techstack definition used for fix suggestions — copied from techstack.md}
```
</report_structure>

### Example Finding

```markdown
### P0 — Mobile Performance: Homepage

**Industry Context:** Travel site median mobile performance is ~35.
Google "good" LCP is ≤2.5s. Target: ≤2.5s.

**Throttle Impact:** Unthrottled LCP = 5.2s, Throttled LCP = 12.0s → **Both** (code issue amplified by network)

| Metric | Unthrottled | Throttled | Google "Good" | Industry Median | Target | Status |
|--------|-------------|-----------|---------------|-----------------|--------|--------|
| LCP    | 5.2s        | 12.0s     | ≤ 2.5s       | ~3.5s           | ≤ 2.5s | ❌ P0  |

**Suggested Fix (Next.js 16 + EdgeOne):**
- Enable EdgeOne image optimization (WebP/AVIF auto-conversion at edge) — https://www.tencentcloud.com/document/product/228/47823
- Configure EdgeOne edge caching with `s-maxage=31536000` for static image assets
- Use `<link rel="preload">` via Next.js `metadata` API for critical hero image
- Code-split heavy JS bundles using Next.js `dynamic()` with `{ ssr: false }`

**Effort:** Large
```

---

## Command: `refresh-benchmarks`

This command updates the industry benchmark reference data. Run this quarterly or when you suspect benchmarks have shifted.

### Process

<steps>
1. **Read current benchmarks** — Read `industry-benchmarks.md` and note the current `last_updated` date and all existing threshold values.

2. **Research updated benchmarks** via WebSearch:

   <research_targets>
   - Google's Core Web Vitals "good" thresholds (from web.dev / CrUX data)
   - HTTP Archive data for travel industry vertical median scores
   - Travel/tourism e-commerce competitors: Klook, GetYourGuide, Viator, Tiqets
   - Attraction/ticketing specific benchmarks (heavy image catalogs, booking flows)
   </research_targets>

   <metrics_to_research>
   - Lighthouse Performance score (travel industry median)
   - Lighthouse Accessibility score (WCAG compliance baseline)
   - Lighthouse Best Practices score
   - Lighthouse SEO score
   - LCP (Largest Contentful Paint) — Google's "good" vs travel-specific reality
   - Page Weight (total transfer size) — typical for image-heavy travel/catalog pages
   - CWV pass rates (mobile and desktop)
   </metrics_to_research>

   Prioritize data from: CrUX (Chrome UX Report), HTTP Archive Web Almanac, web.dev, DebugBear, and published audits of travel/ticketing competitors.

3. **Compare old vs new** — Identify which thresholds changed and by how much.

4. **Overwrite `industry-benchmarks.md`** — Update with new data, keeping the same file structure (frontmatter with `last_updated` set to today's date, same sections). Preserve the Severity Classification Thresholds and Methodology sections unless they need revision.

5. **Print change summary** — Output a brief summary of what changed:
   ```
   ## Benchmark Refresh Summary — {date}
   
   | Metric | Previous | Updated | Change |
   |--------|----------|---------|--------|
   | ... | ... | ... | ... |
   
   Sources consulted: [list]
   ```
</steps>

### Constraints for refresh-benchmarks

- Do NOT run any Lighthouse audits — this command only updates the reference file
- Do NOT modify `techstack.md` or any other files
- Do NOT delete existing sections — update values in-place
- Always set `last_updated` in frontmatter to the current date
- Always document sources in the frontmatter `sources` list

---

## Constraints (applies to all commands)

- Do NOT aim for perfect 100 scores — industry-standard thresholds are the quality bar
- Do NOT hardcode techstack — always read from `techstack.md`
- Do NOT suggest generic fixes when framework-specific solutions exist (e.g., prefer EdgeOne image optimization over generic lazy-loading advice)
- Do NOT skip any of the 6 audit runs (audit command)
- Do NOT skip any of the 6 screenshot captures (audit command)
- Write all output to `lighthouse-audit-satusatu-report/` directory — never dump to terminal
- Screenshots use relative paths in the markdown so the report is portable
