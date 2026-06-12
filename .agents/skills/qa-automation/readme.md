# TipTip QA Automation Skills: A Complete Usage Guide

A practical, end-to-end guide to the three Claude Code skills the TipTip QA team uses to take a feature from a Jira ticket all the way to a validated, runnable Playwright/Cucumber test in the `web-automation-playwright` repository.

This guide assumes you already know Playwright, Cucumber, and Gherkin. It does **not** re-teach those tools. It teaches you how to drive the skills.

---

## Section 1 — Overview & The Three-Skill Pipeline

The three skills form a sequential pipeline. Each skill's output is the next skill's input — they were deliberately designed to hand off to one another.

```
                  PRD / Jira ticket / plain-text feature
                                 │
                                 ▼
                  ┌──────────────────────────────┐
                  │   shift-left-manual-test      │   "What should we test?"
                  └──────────────────────────────┘
                                 │
                                 ▼
              Gherkin .feature (manual test cases, tagged,
              with a test-data dependency matrix)
                                 │
                                 ▼
                  ┌──────────────────────────────┐
                  │  automation-script-generation │   "Make it runnable."
                  └──────────────────────────────┘
                                 │
                                 ▼
              POM class  +  step definitions  +  .feature
              (placed in the correct platform directories,
               index.js updated)
                                 │
                                 ▼
                  ┌──────────────────────────────┐
                  │ automation-script-validation  │   "Is it compliant?"
                  └──────────────────────────────┘
                                 │
                                 ▼
              Severity-graded audit report (P0/P1/P2)
              — read-only, modifies nothing
```

**Each output feeds the next input.** The Gherkin from skill 1 is written with steps that map cleanly onto Page Object methods, so skill 2 can scaffold without guessing. Skill 2 produces files in the exact repo layout that skill 3 knows how to audit.

> **Tip:** Validation is not just a final gate. Run `automation-script-validation` at **any** point — on hand-written legacy files, on a teammate's branch during code review, or immediately after generation to catch the one locator you forgot to verify. It never modifies files, so there is no risk in running it often.

---

## Section 2 — Prerequisites

Before using any of these skills, make sure you have:

- **A local clone of `web-automation-playwright`** — the skills read and write files relative to this repo's structure (`tests/pages/`, `tests/stepDefinitions/web/`, `tests/features/`).
- **Claude Code CLI** with the three skills installed (`shift-left-manual-test`, `automation-script-generation`, `automation-script-validation`).
- **Atlassian MCP configured** — required only for `shift-left-manual-test` when you pass a Jira key or Confluence URL. Plain-text input works without it.
- **Node.js and npm installed** — to run the generated tests (`npm run test:local`).
- **Working familiarity with Playwright, Cucumber, and Gherkin** — the skills generate idiomatic code; you need to read and verify it.

> **Note:** The skills never log you in to TipTip systems and never invent credentials. They reference `process.env` variables (e.g. `process.env.REGISTERED_USER_EMAIL`). Your local `.env` / `.env.stag` / `.env.prod` files must be configured separately.

---

## Section 3 — Skill 1: `shift-left-manual-test`

Turns a PRD, Jira ticket, or plain-text feature description into structured Gherkin manual test cases, tagged with TipTip's conventions and accompanied by a test-data dependency matrix. The output is shaped for direct consumption by `automation-script-generation`.

It has two commands: **`generate`** (default) and **`review`**.

### Command: `generate` (default)

**Purpose:** Produce a complete set of manual test cases (positive, negative, edge, boundary) from a requirement source.

**When to use it:** At the start of test design — the moment a ticket lands and before any automation exists.

**What input to provide** — one of three forms:

| Input type | Example prompt |
|------------|----------------|
| **Jira ticket key** | `shift-left-manual-test generate PT-12345` |
| **Confluence URL** | `shift-left-manual-test generate https://tiptip.atlassian.net/wiki/spaces/QE/pages/123456/Guest-Checkout-PRD` |
| **Plain-text description** | `shift-left-manual-test generate` then paste: *"Guest users can purchase a paid digital content item on TWA without creating an account, paying via Xendit."* |

When you pass a Jira key, the skill fetches it via the Atlassian MCP (`getJiraIssue`). When you pass a Confluence link, it extracts the page ID and fetches it (`getConfluencePage`). Plain text is parsed directly.

**What output to expect** — a markdown document containing a coverage summary, the Gherkin Feature, a dependency matrix, and automation notes. A realistic TWA sample:

```gherkin
@regression @commerce @twa @stag
Feature: Guest purchase of paid digital content

    Background: Guest lands on TipTip
        Given I open TipTip website

    @positive_case @smoke
    Scenario: Guest successfully buys a paid content item via Xendit
        Given user search "sdet title 167" on landing page
        And user click "content" tab in explore page
        When user filter and select "premium" product
        And user buy the product
        And user pay the "content" "without" voucher
        Then user should be able to consume the "content"

    @negative_case
    Scenario: Purchase blocked when payment is declined
        Given user search "sdet title 167" on landing page
        And user buy the product
        When user pays with a declined card
        Then an error "Payment failed, please try again" should be displayed
        And user remains on the payment page

    @edge_case
    Scenario: Purchase of a free content item skips payment entirely
        Given user search "free sdet title 09" on landing page
        And user filter and select "free" product
        When user claims the product
        Then user should be able to consume the "content"
        And no payment step is shown
```

…followed by a dependency matrix like:

```markdown
| Dependency           | Type            | Provisioning                       |
|----------------------|-----------------|------------------------------------|
| Premium content item | Test data       | Created via Content Hub API        |
| Xendit payment       | External service| Staging sandbox                    |
| OTP verification     | External service| Hardcoded test OTP (909090)        |
```

### Command: `review`

**Purpose:** Audit an existing set of manual test cases and suggest what's missing — uncovered negative paths, missing edge values, mis-applied tags, or steps too vague to map to a Page Object method.

**When to use it:** When you inherit a `.feature` file or want a second pass over your own scenarios before automating.

**Input:** a path to an existing `.feature` file or pasted manual test cases.

```text
shift-left-manual-test review tests/features/e2e/guest-purchase.feature
```

### Constraints to know upfront

- **No real PII, ever.** The skill uses TipTip standard test patterns — `"909090"` for OTP, `"8881588080XX"` for phone. It will not emit real emails, phone numbers, or payment details.
- **25-scenario cap per feature file.** If a feature needs more, the skill splits it into multiple files by sub-domain rather than producing one bloated file.
- **No invented element IDs.** Steps reference visible text or logical descriptions (`user clicks "Sign In" button`). Mapping to real locators is `automation-script-generation`'s job.
- **Generic, reusable steps.** Prefer `user clicks "<button_text>" button` over `user clicks the blue sign-in button on the login page`.

> **Common Mistakes — `shift-left-manual-test`**
> - **Writing implementation-coupled steps yourself and pasting them in.** Keep steps behavioral. `user fills #input-email` defeats the hand-off to skill 2.
> - **Expecting Jira fetching without the Atlassian MCP.** If the MCP isn't configured, paste the ticket text as plain input instead.
> - **Ignoring the dependency matrix.** It tells you what test data must exist (KYC accounts, premium content, vouchers) *before* the generated test can pass.
> - **Cramming unrelated behaviors into one feature.** If you blow past 25 scenarios, let the skill split by sub-domain — don't fight it.

---

## Section 4 — Skill 2: `automation-script-generation`

Takes Gherkin (from skill 1, an existing `.feature`, or a plain description) and generates three production-ready artifacts following the exact `web-automation-playwright` structure: a **Page Object Model (POM) class**, **Cucumber step definitions**, and a **`.feature` file** — and it registers the new page class in the platform's `index.js`.

Three commands: **`generate`** (default), **`scaffold-page`**, **`scaffold-steps`**.

### Platform detection & file placement

The skill first detects the target platform and places every file accordingly:

| Platform | Page dir | Step dir | Feature dir |
|----------|----------|----------|-------------|
| **TWA** (`tiptip.tv`) | `tests/pages/twa/` | `tests/stepDefinitions/web/twa/` | `tests/features/e2e/` or `tests/features/core/` |
| **Content Hub** (`hub.tiptip.tv`) | `tests/pages/ch/` | `tests/stepDefinitions/web/ch/` | `tests/features/content_hub/` |
| **SatuSatu** (`satusatu.com`) | `tests/pages/swa/` | `tests/stepDefinitions/web/swa/` | `tests/features/satusatu/` |

Before creating anything, the skill reads the platform's `index.js` to see which page objects already exist, so it doesn't duplicate a page that's already there.

### Command: `generate` (default)

**Purpose:** Produce all three artifacts in one pass.

**When to use it vs the others:** Use `generate` when you're starting from a feature/scenario and need the full vertical slice. Use the scaffold commands when you only need one layer (see the decision guide below).

**What input to provide** — pass the Gherkin from Section 3 directly:

```text
automation-script-generation generate

[paste the @commerce @twa Gherkin feature from shift-left-manual-test here]
```

Or point it at a file: `automation-script-generation generate tests/features/e2e/guest-purchase.feature`

**Sample generated POM class** — note the locator priority in action (one ID, one XPath, one MUI text-based, with a `// TODO` where the ID is unverified):

```javascript
const { expect, Locator, Page } = require("@playwright/test");

class ProductDetailPage {
  constructor(page) {
    this.page = page;

    // 1. CSS ID — preferred
    this.buttonBuy = page.locator("#i-product-buy-button");

    // 2. XPath — when no ID exists
    this.buttonPayNow = page.locator("//button[normalize-space()='Pay Now']");

    // 3. Tag + text filter — last resort for MUI components
    this.voucherMenuItem = page
      .locator(".MuiMenuItem-root")
      .getByRole("li", { name: "menuitem" })
      .getByText("Apply Voucher");

    // TODO: Verify locator — ID assumed from visible text
    this.labelPaymentError = page.locator("#payment-error-message");
  }

  async clickButtonBuy() {
    await this.buttonBuy.click();
  }

  async clickButtonPayNow() {
    await this.buttonPayNow.click();
  }

  async verifyPaymentError(expectedText) {
    await expect.soft(this.labelPaymentError).toHaveText(expectedText);
  }
}

module.exports = ProductDetailPage;
```

**Sample generated feature file** — correct tagging, Background factored out:

```gherkin
@commerce @twa @stag
Feature: Guest purchase of paid digital content

    Background: Guest lands on TipTip
        Given I open TipTip website

    @positive_case @smoke
    Scenario: Guest successfully buys a paid content item via Xendit
        Given user search "sdet title 167" on landing page
        When user buy the product
        And user pay the "content" "without" voucher
        Then user should be able to consume the "content"
```

### How `index.js` gets updated — and why it matters

After creating a new page class, the skill registers it in the platform's `index.js`. The export is an **array of class constructors** — not instances:

```javascript
const ProductDetailPage = require("./product-detail-page.js");

module.exports = [
  // ... existing pages ...
  ProductDetailPage,
];
```

This matters because of the **`BeforeAll` hook** in `cucumber.conf.js`. That hook iterates the array, does `new ClassConstructor(global.page)` for each entry, and assigns the instance to a **lowercased global** named after the class:

```
SignInPage        →  global.signInPage
ProductDetailPage →  global.productDetailPage
```

Your step definitions then reference `productDetailPage` directly. **If the class is a file on disk but missing from `index.js`, the global is never created and your steps throw at runtime** — a silent failure that validation catches as `XREF-003`.

### Locator priority — the decision flowchart

```
        Does the element have a CSS ID (#id)?
                       │
            ┌──────────┴──────────┐
           YES                    NO
            │                      │
   Use page.locator("#id")   Does it have a data-testid?
   (preferred)                     │
                          ┌────────┴────────┐
                         YES               NO
                          │                 │
              Use [data-testid="..."]   Is it a stable text/MUI component?
                                            │
                                  ┌─────────┴─────────┐
                                 YES                  NO
                                  │                    │
                       Use XPath //…[text()='…']   Use tag + getByText()
                       OR .MuiMenuItem-root …       as LAST resort
                                                    + add a // TODO and
                                                    request an ID via the
                                                    Element Tracking Sheet
```

### Command: `scaffold-page`

**Purpose:** Generate **only** a POM class (plus its `index.js` registration). Provide the platform, page name, and optionally a list of UI elements.

```text
automation-script-generation scaffold-page twa product-detail
elements: buy button, pay-now button, voucher menu, payment error label
```

### Command: `scaffold-steps`

**Purpose:** Generate **only** step definitions for an *existing* page object. Provide the page object file path.

```text
automation-script-generation scaffold-steps tests/pages/twa/product-detail-page.js
```

> **When to use `scaffold-page` vs `scaffold-steps` vs `generate`**
> ```
> Starting from a feature/scenario, need everything?  ──→  generate
> New page exists in the app, no POM yet?             ──→  scaffold-page
> POM exists, but steps aren't wired up yet?          ──→  scaffold-steps
> ```
> Use the scaffold commands for surgical, incremental work; use `generate` for a full vertical slice.

### Constraints to know upfront

- **No `page.waitForTimeout()`.** The skill uses Playwright's built-in waiting — `expect().toBeVisible()`, `waitForSelector()`, `waitForURL()`.
- **CommonJS only.** `require` / `module.exports` — never `import` / `export`.
- **No hardcoded credentials.** Uses `process.env` variables.
- **Never invents locator IDs.** Unknown IDs get a `// TODO: Verify locator` comment for you to confirm against the running app.
- **`expect.soft()` for non-critical assertions**, matching the repo convention.

> **Tip:** When a locator changes in the running app, edit **only the Page Object**. Step definitions and feature files reference behavior, not selectors, so they stay stable.

---

## Section 5 — Skill 3: `automation-script-validation`

Performs **static analysis** on generated or existing automation files and produces a severity-graded audit report. It is **read-only** — it modifies nothing and runs no tests.

Four commands: **`validate`** (default), **`validate-page`**, **`validate-steps`**, **`validate-feature`**.

**Purpose & when to run it:**
- **After generation** — catch the unverified locator or missing index entry before you commit.
- **Before a PR** — make the P0/P1 list your pre-merge checklist.
- **During code review** — audit a teammate's branch objectively against the same rules.

**What input to provide:**

| Input | Example |
|-------|---------|
| A single file | `automation-script-validation validate tests/pages/twa/product-detail-page.js` |
| A directory | `automation-script-validation validate tests/pages/twa/` |
| Everything | `automation-script-validation validate all` |

The scoped variants run only one layer: `validate-page` (POM + index), `validate-steps`, `validate-feature`. **Cross-reference checks (XREF) require the full `validate`** because they need all three layers loaded at once.

### Reading the report — P0 / P1 / P2

| Severity | Meaning | SLA | Concrete example |
|----------|---------|-----|------------------|
| **P0 — Critical** | Will cause a runtime failure | Fix before merge | A page file missing from `index.js` (`XREF-003`) — the global is never created, steps throw. |
| **P1 — High** | Causes flakiness or maintenance burden | Fix this sprint | A method using `page.waitForTimeout(5000)` (`POM-008` / `STEP-006`) — flaky timing. |
| **P2 — Medium** | Convention / quality issue | Plan for improvement | An XPath locator where an ID exists (`POM-006`) — works, but brittle. |

### A realistic audit report snippet

```markdown
### tests/pages/twa/product-detail-page.js

#### POM-008: No hardcoded waits — P1

**Current (line 14):**
```javascript
async clickButtonPayNow() {
  await this.page.waitForTimeout(5000);
  await this.buttonPayNow.click();
}
```

**Expected:**
```javascript
async clickButtonPayNow() {
  await expect(this.buttonPayNow).toBeVisible();
  await this.buttonPayNow.click();
}
```

**Rationale:** Fixed waits make tests slow and flaky. A 5s sleep either wastes
time when the element is ready sooner, or fails when it isn't ready yet.
Playwright's auto-waiting via expect().toBeVisible() resolves the moment the
element is actionable.
```

### Cross-reference validation & the silent failure (`XREF-003`)

The XREF rules check relationships *between* files — the failures a single-file lint can't see:

- **XREF-001 (P1):** a page object with methods but no matching step-definition file.
- **XREF-002 (P2):** a class declared in `index.js` but never used by any step.
- **XREF-003 (P0):** a `*-page.js` file that exists on disk but is **not listed in `index.js`**.

`XREF-003` is the dangerous one. The file compiles, the class is correct, your steps look right — but because the `BeforeAll` hook only instantiates classes in the `index.js` array, the global page object (`productDetailPage`) is never created. The test fails at runtime with an undefined-reference error that points nowhere near the real cause. That's why it's graded **P0** and surfaced in a dedicated "Missing from index.js" section of the report.

### Fix Priority Guide

| Rule ID | Layer | Severity | Action to take |
|---------|-------|----------|----------------|
| POM-001 | POM | P0 | Rename class to PascalCase ending in `Page`. |
| POM-003 | POM | P0 | Accept `page` in constructor; move all locators into it. |
| POM-005 | POM | P0 | End file with `module.exports = <ClassName>;` (CommonJS). |
| POM-002 | POM | P1 | Rename file to kebab-case `*-page.js`. |
| POM-004 | POM | P1 | Move `page.locator()` calls out of methods into the constructor. |
| POM-007 | POM | P1 | Make interaction methods `async`. |
| POM-008 | POM | P1 | Replace `waitForTimeout()` with auto-waiting. |
| POM-011 | POM | P1 | Import `{ expect }` from `@playwright/test`. |
| POM-006 | POM | P2 | Prefer ID over XPath/text locators. |
| POM-009 | POM | P2 | Use `expect.soft()` for non-blocking assertions. |
| POM-010 | POM | P2 | Remove business logic/assertions from page objects. |
| IDX-001 | index | P0 | Add `require()` + array entry for every page file. |
| IDX-003 | index | P0 | Export an array of constructors, not instances. |
| IDX-002 | index | P1 | Remove `require()` of non-existent files. |
| IDX-004 | index | P2 | Match require variable names to class names. |
| STEP-001 | steps | P0 | Import `{ Given, When, Then }` from `@cucumber/cucumber`. |
| STEP-002 | steps | P1 | Access page objects via globals, don't re-instantiate. |
| STEP-003 | steps | P1 | Move `page.locator()` calls into page objects. |
| STEP-006 | steps | P1 | Replace `waitForTimeout()` with explicit waits. |
| STEP-007 | steps | P1 | Rename file to kebab-case `*-steps.js`. |
| STEP-004 | steps | P2 | Make steps generic/reusable. |
| STEP-005 | steps | P2 | Parameterize with `{string}` / `{int}`. |
| FEAT-001 | feature | P1 | Add a domain tag and `@stag`. |
| FEAT-002 | feature | P1 | Add a type tag to every scenario. |
| FEAT-006 | feature | P0 | Ensure every step has a definition (no orphans). |
| FEAT-003 | feature | P2 | Move common preconditions into `Background`. |
| FEAT-004 | feature | P2 | Use `Scenario Outline` + `Examples` for data-driven tests. |
| FEAT-005 | feature | P2 | Split scenarios over 10 steps — one behavior each. |
| FEAT-007 | feature | P2 | Describe behavior, not implementation. |
| XREF-001 | cross | P1 | Add a step-definition file for the page object. |
| XREF-002 | cross | P2 | Remove or use the orphaned page class. |
| XREF-003 | cross | P0 | Register the page file in `index.js`. |

> **Note:** The report always cites exact line numbers and provides copy-paste-ready fixes. Files that pass every rule are listed explicitly as `✅ PASS`.

---

## Section 6 — End-to-End Walkthrough

A real session, start to finish, on TWA.

**Scenario:** Jira ticket **PT-99999 — "Allow guest users to purchase content."**

### Step 1 — Generate manual test cases from the ticket

You type into Claude Code:

```text
shift-left-manual-test generate PT-99999
```

The skill fetches PT-99999 via the Atlassian MCP and returns (abridged):

```gherkin
@regression @commerce @twa @stag
Feature: Guest purchase of paid digital content

    Background: Guest lands on TipTip
        Given I open TipTip website

    @positive_case @smoke
    Scenario: Guest buys a paid content item via Xendit
        Given user search "sdet title 167" on landing page
        And user buy the product
        When user pay the "content" "without" voucher
        Then user should be able to consume the "content"

    @negative_case
    Scenario: Purchase blocked when payment is declined
        Given user search "sdet title 167" on landing page
        And user buy the product
        When user pays with a declined card
        Then an error "Payment failed, please try again" should be displayed
```

Plus a dependency matrix flagging that a **premium content item** and the **Xendit staging sandbox** are required.

### Step 2 — Generate the automation scripts

You paste that Gherkin into the next command:

```text
automation-script-generation generate

@regression @commerce @twa @stag
Feature: Guest purchase of paid digital content
... [full Gherkin pasted] ...
```

The skill detects **TWA**, reads `tests/pages/twa/index.js`, sees no `ProductDetailPage`, and creates:

| Type | File |
|------|------|
| Page Object | `tests/pages/twa/product-detail-page.js` |
| Index update | `tests/pages/twa/index.js` |
| Step definitions | `tests/stepDefinitions/web/twa/product-steps.js` |
| Feature file | `tests/features/e2e/guest-purchase.feature` |

A snippet of the step definitions it generates:

```javascript
const { Given, When, Then } = require("@cucumber/cucumber");
const { expect } = require("@playwright/test");

When("user buy the product", async function () {
  await productDetailPage.clickButtonBuy();
});

When("user pay the {string} {string} voucher", async function (item, voucherMode) {
  await productDetailPage.clickButtonPayNow();
});

Then("an error {string} should be displayed", async function (message) {
  await productDetailPage.verifyPaymentError(message);
});
```

### Step 3 — Validate before you commit

```text
automation-script-validation validate tests/pages/twa/
```

The report comes back with one **P1**:

```markdown
#### POM-008: No hardcoded waits — P1

**Current (line 19, product-detail-page.js):**
async clickButtonPayNow() {
  await this.page.waitForTimeout(3000);
  await this.buttonPayNow.click();
}

**Expected:**
async clickButtonPayNow() {
  await expect(this.buttonPayNow).toBeVisible();
  await this.buttonPayNow.click();
}

**Rationale:** Fixed waits cause flakiness; rely on Playwright auto-waiting.
```

You apply the fix to the Page Object (steps and feature stay untouched), then re-run validation to confirm `✅ PASS`.

### Step 4 — Run the test locally

```bash
npm run test:local -- --tags '@commerce and @smoke'
```

When green, you commit. The whole loop — ticket to validated, passing test — happened without leaving Claude Code except to run npm.

> **Tip:** Don't forget the dependency matrix from Step 1. If the premium content item or the Xendit sandbox isn't provisioned in staging, the test fails for data reasons, not code reasons. Validation can't catch that — only the matrix warns you.

---

## Section 7 — Quick Reference

### Table 1 — Command Reference

| Skill | Command | Input | Output |
|-------|---------|-------|--------|
| shift-left-manual-test | `generate` (default) | Jira key, Confluence URL, or plain-text feature | Tagged Gherkin manual test cases + coverage summary + dependency matrix |
| shift-left-manual-test | `review` | Path to existing `.feature` / pasted cases | Review report: missing negative/edge cases, tag gaps, vague steps |
| automation-script-generation | `generate` (default) | Gherkin, `.feature` path, or plain description | POM class + step defs + `.feature` + `index.js` update (all 3 platforms supported) |
| automation-script-generation | `scaffold-page` | Platform + page name + optional UI elements | A single POM class + `index.js` registration |
| automation-script-generation | `scaffold-steps` | Path to an existing page object file | Step definitions for that page's methods |
| automation-script-validation | `validate` (default) | File path, directory, or `all` | Full severity-graded audit report (incl. XREF cross-checks) |
| automation-script-validation | `validate-page` | POM file(s) / directory | POM + index audit only (no XREF) |
| automation-script-validation | `validate-steps` | Step definition file(s) | Step-definition audit only |
| automation-script-validation | `validate-feature` | `.feature` file(s) | Feature-file audit only |

### Table 2 — Rule Reference (validation)

| Rule ID | Layer | Severity | What it checks |
|---------|-------|----------|----------------|
| POM-001 | Page Object | P0 | Class name PascalCase, ends with `Page` |
| POM-002 | Page Object | P1 | File name kebab-case, ends with `-page.js` |
| POM-003 | Page Object | P0 | Constructor takes `page`, assigns `this.page`; locators in constructor |
| POM-004 | Page Object | P1 | All `page.locator()` calls in constructor, not methods |
| POM-005 | Page Object | P0 | Ends with `module.exports = <ClassName>;` (CommonJS) |
| POM-006 | Page Object | P2 | Locator priority: ID > XPath > text-based |
| POM-007 | Page Object | P1 | Interaction methods are `async` |
| POM-008 | Page Object | P1 | No `page.waitForTimeout()` |
| POM-009 | Page Object | P2 | `expect.soft()` for non-blocking assertions |
| POM-010 | Page Object | P2 | No business logic / assertions in page objects |
| POM-011 | Page Object | P1 | Imports `{ expect }` from `@playwright/test` when asserting |
| IDX-001 | index.js | P0 | Every `*-page.js` has a `require()` + array entry |
| IDX-002 | index.js | P1 | No orphaned `require()` of non-existent files |
| IDX-003 | index.js | P0 | Exports an array of class constructors, not instances |
| IDX-004 | index.js | P2 | Require variable names match class names |
| STEP-001 | Step defs | P0 | Imports `{ Given, When, Then }` from `@cucumber/cucumber` |
| STEP-002 | Step defs | P1 | Accesses page objects via globals, no re-instantiation |
| STEP-003 | Step defs | P1 | No `page.locator()` in steps (one-off getByText/getByRole OK) |
| STEP-004 | Step defs | P2 | Steps are generic / reusable |
| STEP-005 | Step defs | P2 | Parameterized with `{string}` / `{int}` |
| STEP-006 | Step defs | P1 | No `page.waitForTimeout()` |
| STEP-007 | Step defs | P1 | File name kebab-case, ends with `-steps.js` |
| FEAT-001 | Feature | P1 | Feature has a domain tag + environment tag (`@stag`) |
| FEAT-002 | Feature | P1 | Every scenario has a type tag (positive/negative/edge) |
| FEAT-003 | Feature | P2 | Common preconditions in `Background` |
| FEAT-004 | Feature | P2 | Data-driven tests use `Scenario Outline` + `Examples` |
| FEAT-005 | Feature | P2 | One behavior per scenario (flags >10 steps) |
| FEAT-006 | Feature | P0 | Every step has a corresponding step definition |
| FEAT-007 | Feature | P2 | Steps describe behavior, not implementation |
| XREF-001 | Cross-ref | P1 | Page object with methods has a step-definition file |
| XREF-002 | Cross-ref | P2 | Page class declared in index but unused by any step |
| XREF-003 | Cross-ref | P0 | Page file on disk but missing from `index.js` (silent runtime failure) |
