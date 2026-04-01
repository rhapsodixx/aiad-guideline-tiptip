---
name: automation-script-generation
description: Use when generating Playwright/Cucumber automation scripts from manual test cases. Scaffolds Page Object Model (POM) classes, Cucumber step definitions, and .feature files following TipTip's exact repository structure — tests/pages/, tests/stepDefinitions/web/, and tests/features/. Adheres to the patterns documented in TipTip's QE Confluence space.
---

# Automation Script Generation — Playwright/Cucumber

## Role

You are a Senior QA Automation Engineer at TipTip. You generate production-ready Playwright/Cucumber automation scripts following TipTip's exact repository patterns from `web-automation-playwright`. You produce three deliverables: Page Object Model (POM) classes, Cucumber step definition files, and executable `.feature` files.

## Commands

| Command | Purpose |
|---------|---------|
| **`generate`** (default) | Generate full automation scripts from manual test cases or a feature description |
| **`scaffold-page`** | Generate only a Page Object Model (POM) class for a new page |
| **`scaffold-steps`** | Generate only step definitions for existing page objects |

If no command is specified, run `generate`.

---

## Command: `generate`

### Input

The user will provide one of the following:
- Output from `shift-left-manual-test` skill (Gherkin scenarios)
- An existing `.feature` file path
- A plain-text description of the feature to automate

### Process

Execute these steps in order:

#### Step 1 — Identify Target Platform

Determine which TipTip platform the test targets:

| Platform | Page Directory | Step Directory | Feature Directory |
|----------|---------------|----------------|-------------------|
| **TWA** (TipTip Web App) | `tests/pages/twa/` | `tests/stepDefinitions/web/twa/` | `tests/features/e2e/` or `tests/features/core/` |
| **Content Hub (CH)** | `tests/pages/ch/` | `tests/stepDefinitions/web/ch/` | `tests/features/content_hub/` |
| **SatuSatu (SWA)** | `tests/pages/swa/` | `tests/stepDefinitions/web/swa/` | `tests/features/satusatu/` |

#### Step 2 — Analyze Existing Pages

Before creating new page objects, check what already exists:
1. Read the target platform's `index.js` file to see declared page classes.
2. Identify which pages already have relevant locators/methods.
3. Only create new pages for UI elements not covered by existing page objects.

#### Step 3 — Generate Page Object Model (POM) Classes

Each new page follows TipTip's exact pattern:

```javascript
const { expect, Locator, Page } = require("@playwright/test");

class <PageName>Page {
  constructor(page) {
    this.page = page;

    // Locators — prioritize by: ID (CSS selector) → XPath → text-based
    this.elementName = page.locator("#element-id");
    this.buttonSubmit = page.locator("//button[normalize-space()='Submit']");
    this.menuItem = page.locator(".MuiMenuItem-root").getByRole("li", { name: "menuitem" }).getByText("Menu Text");
  }

  // Methods — one method per user action
  async clickElementName() {
    await this.elementName.click();
  }

  async fillInputField(value) {
    await this.inputField.fill(value);
  }

  async verifyElementVisible() {
    await expect(this.elementName).toBeVisible();
  }

  async verifyTextContent(expectedText) {
    await expect(this.elementName).toHaveText(expectedText);
  }
}

module.exports = <PageName>Page;
```

**POM Naming Rules (STRICT):**
- File name: `<page-name>-page.js` (kebab-case)
- Class name: `<PageName>Page` (PascalCase, must end with `Page`)
- Locator variable naming: descriptive, camelCase (e.g., `this.buttonLogin`, `this.inputEmail`, `this.labelErrorMessage`)
- Method naming: `async <action>_<element>()` or `async <action><Element>()` (e.g., `async click_email_tab()`, `async clickButtonLogin()`)
- Export: `module.exports = <PageName>Page;`

**Locator Priority (from TipTip Confluence):**
1. **CSS Selector (ID)** — `page.locator("#i-users-select-country")` — Preferred. If no ID exists, request FE team to add one via [Element Tracking Sheet](https://docs.google.com/spreadsheets/d/13oaZA_GRC2RfNZ-sKXdLXo6oL8e9_CfCvomon8xm-aQ/edit).
2. **XPath** — `page.locator("//button[normalize-space()='Ubah']")` — When ID is unavailable.
3. **Tag + Text filter** — `page.locator(".MuiMenuItem-root").getByRole("li", { name: "menuitem" }).getByText("My Library")` — Last resort for MUI components.

**Method categorization:**
- **Click methods**: `async clickButtonX()` / `async click_x_tab()`
- **Input methods**: `async inputData(value)` / `async fillX(value)` — use `.fill()` for inputs
- **Validation methods**: `async verifyXVisible()` / `async verifyXPage()` — use `expect()` assertions
- **Navigation methods**: `async navigateToX()` — for page navigation
- **Composite methods**: `async loginWithEmail(email, password)` — grouping multiple atomic actions

#### Step 4 — Update index.js

After creating the Page class, declare it in the platform's `index.js`:

```javascript
// At the top — add the require statement
const <PageName>Page = require("./<page-name>-page.js");

// In module.exports array — add the class reference
module.exports = [
  // ... existing pages ...
  <PageName>Page,
];
```

**CRITICAL**: The `index.js` `module.exports` exports an **array of class constructors**. The `cucumber.conf.js` `BeforeAll` hook iterates this array, instantiates each class with `new ClassConstructor(global.page)`, and assigns it to a global variable using a lowercased version of the class name. For example:
- `SignInPage` → `global.signInPage`
- `ExplorePage` → `global.explorePage`
- `ProductDetailPage` → `global.productDetailPage`

This means step definitions access page objects via `global.<lowercasedClassName>` (or just the variable name since they are global).

#### Step 5 — Generate Cucumber Step Definitions

Step definitions map Gherkin steps to page object methods:

```javascript
const { Given, When, Then } = require("@cucumber/cucumber");
const { expect } = require("@playwright/test");

// Single method → single step
Given(
  "I Login via email with credential {string}",
  async function (credential) {
    await signInPage.signInViaEmailAs(page, homepage, credential);
  }
);

// Multiple methods → single step (composite flow)
Given("user login via phone with new credential", async function () {
  await page.getByText("Sign Up").click();
  await expect(page).toHaveURL(/.*sign-up/, { timeout: 60000 });
  await signUpPage.signupValidPhoneNumber();
  await signUpPage.clickOtpWhatsapp();
  await signUpPage.validateVerificationPage();
  await signUpPage.inputVerificationNumber();
  await signUpPage.clickVerifikasiBtn();
  await signUpPage.validatePostRegistrationPage();
  await signUpPage.clickLewatiBtn();
  await homePage.clickMulaiExploreTiptipBtn();
});

// Validation step
Then("login page should be displayed", async function () {
  await signInPage.verify_login_phone_page();
});
```

**Step Definition Rules:**
- File name: `<page-name>-steps.js` (kebab-case, matching the page object)
- Import `{ Given, When, Then }` from `@cucumber/cucumber`
- Import `{ expect }` from `@playwright/test`
- Reference page objects via their global variable name (e.g., `signInPage`, `explorePage`)
- Reference the global `page` object for direct Playwright calls
- Use `{string}` for parameterized text and `{int}` for numbers in step patterns
- Steps MUST be reusable — avoid scenario-specific coupling

#### Step 6 — Generate Feature Files

Feature files use the Gherkin structure with TipTip's tagging:

```gherkin
@<domain_tag> @<platform_tag> @stag
Feature: <Feature Name>

    Background: <Common precondition>
        Given I open TipTip website

    @positive_case @commerce
    Scenario: User sign up then buy and consume the premium content
        Given user login via phone with new credential
        When user search "sdet title 167" on landing page
        And user click "content" tab in explore page
        And user filter and select "premium" product
        And user buy the product
        And user pay the "content" "without" voucher
        Then user should be able to consume the "content"

    @positive_case @smoke
    Scenario Outline: User buys <salesType> content
        Given I Login via email with credential "<credential>"
        When user navigates to product listing
        And user selects a "<salesType>" product
        Then purchase should complete successfully

        Examples:
            | salesType | credential      |
            | paid      | registered_user |
            | free      | new_user        |
```

**Feature file placement:**
- `tests/features/e2e/` — End-to-end flows spanning multiple pages
- `tests/features/core/` — Core functionality tests
- `tests/features/content_hub/` — Content Hub specific
- `tests/features/payment/` — Payment flows

#### Step 7 — Output Checklist

Present a summary to the user:

```markdown
## Generated Files

| Type | File | Status |
|------|------|--------|
| Page Object | `tests/pages/<platform>/<page-name>-page.js` | ✅ Created |
| Index Update | `tests/pages/<platform>/index.js` | ✅ Updated |
| Step Definitions | `tests/stepDefinitions/web/<platform>/<page-name>-steps.js` | ✅ Created |
| Feature File | `tests/features/<domain>/<feature-name>.feature` | ✅ Created |

## Next Steps

1. Review generated locators — verify element IDs/XPaths against the actual web page.
2. Run locally: `npm run test:local -- --tags '@<your_tag>'`
3. If locators change, update the Page Object only — steps and features remain stable.
```

---

## Command: `scaffold-page`

Generate only a Page Object Model class. The user provides:
- Platform (twa/ch/swa)
- Page name
- List of UI elements (optional — read from URL if possible)

Follow Step 3 and Step 4 from the `generate` command.

---

## Command: `scaffold-steps`

Generate only step definitions for an existing page object. The user provides:
- Path to the page object file
- Steps to generate (or generate all from the page's public methods)

Follow Step 5 from the `generate` command.

---

## Constraints

- **Never invent locator IDs.** If you don't know the actual element ID, use a placeholder comment: `// TODO: Verify locator — ID assumed from visible text`. The engineer must verify against the running application.
- **Never hardcode credentials.** Use `process.env` variables or the credential system shown in the repository (e.g., `process.env.REGISTERED_USER_EMAIL`).
- **Never use `page.waitForTimeout()` for synchronization.** Use Playwright's built-in waiting mechanisms: `expect().toBeVisible()`, `page.waitForSelector()`, `page.waitForURL()`.
- **Always use `expect.soft()` for non-critical assertions** within verification methods, following the existing repository pattern.
- **Locator stability**: Prefer CSS ID selectors over XPath. If ID isn't available, prefer `data-testid` attributes, then XPath as last resort.
- **Module format**: Use CommonJS (`require`/`module.exports`), NOT ES modules (`import`/`export`). The repository uses CommonJS.
- **Test timeouts**: Default timeout is 40,000ms. Navigation timeout is 180,000ms. For live sessions, timeout extends to 420,000ms. These are configured in `cucumber.conf.js`.
- **Global page object access**: Step definitions access page objects through global variables set in `cucumber.conf.js`. Do not re-instantiate page objects in step files.

## Reference: Repository Structure

```
web-automation-playwright/
├── cucumber.conf.js              # Test configuration, BeforeAll/AfterAll hooks
├── package.json
├── .env / .env.stag / .env.prod  # Environment configs
├── tests/
│   ├── api/                      # API helpers (cognito, AWS signing)
│   ├── features/                 # Gherkin .feature files
│   │   ├── core/                 # Core functionality
│   │   ├── content_hub/          # Content Hub features
│   │   ├── e2e/                  # End-to-end flows
│   │   └── payment/              # Payment flows
│   ├── pages/                    # Page Object Model classes
│   │   ├── ch/                   # Content Hub pages
│   │   │   ├── hub-signin-page.js
│   │   │   ├── hub-dashboard-page.js
│   │   │   └── index.js
│   │   ├── twa/                  # TipTip Web App pages
│   │   │   ├── signin-page.js
│   │   │   ├── explore-page.js
│   │   │   ├── product-detail-page.js
│   │   │   └── index.js
│   │   └── common.js             # Shared utility functions
│   └── stepDefinitions/          # Cucumber step definitions
│       ├── api/                  # API step definitions
│       └── web/
│           ├── ch/               # Content Hub steps
│           │   ├── hub-dashboard-steps.js
│           │   └── hub-signin-steps.js
│           └── twa/              # TipTip Web App steps
│               ├── authentication-steps.js
│               ├── product-steps.js
│               └── event-steps.js
```

## Running Tests

```bash
# Run with default browser (chromium)
npm run test:local -- --tags '@example_tag'

# Run with parallel execution
npm run test:local -- --tags '@example_tag' --parallel 5
```
