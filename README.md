# Navio Pathways website

This repository contains the public website for **NAVIO PATHWAYS**, an Ontario incorporated not-for-profit organization supporting youth development through career exploration, mentorship, leadership development, volunteering, and community experience.

The former Flutter application and unused platform/backend files have been removed. Everything committed here now supports the website or its release review.

## Stack and deployment

- React 19 for the shared layout, navigation, forms, analytics hooks, and page rendering
- Vite 8 for local development and production bundling
- React server rendering for pre-rendered, search-friendly HTML on every route
- Generated production files committed at the repository root for the existing GitHub Pages `main`/root deployment
- Custom domain configured by `CNAME` as `naviopathways.com`

The editable React source lives in `site/src/`. `site/src/page-content.js` contains the reviewed route content rendered by the React shell. The build scripts in `scripts/` pre-render the site, generate metadata/sitemap files, and copy the production artifact to the repository root.

## Local development

Requirements: Node.js 20.19+ or 22.12+ and npm.

```powershell
npm install
npm run dev
```

Vite prints the local preview URL. Navigation uses real directory URLs so production behavior remains compatible with GitHub Pages.

## Production build and checks

```powershell
npm run build
```

That single command:

1. builds the browser bundle;
2. builds the React server-rendering entry;
3. pre-renders all 22 routes with unique metadata and structured data;
4. generates `sitemap.xml` and `robots.txt`;
5. publishes the artifact to the repository root; and
6. validates both `dist/` and the committed Pages output.

Commit the React source, scripts, lockfile, and regenerated root files together. `dist/`, `.ssr/`, and `node_modules/` are local-only.

## Forms

The contact, volunteer-interest, partnership, and newsletter forms are accessible and preserve visitor entries after a recoverable error. No fake endpoint is configured, so the current production behavior directs visitors to `hello@naviopathways.com` instead of claiming that an unsent form succeeded.

Set public HTTPS endpoints in `site/public/site-config.js` under `formEndpoints`. The receiving service must perform server-side validation, spam protection, rate limiting, safe storage, and origin checks. Never put secrets in this file: it is visible to every browser.

A successful response redirects to the matching `/thank-you/` route and only then records the appropriate analytics event.

## Analytics

Analytics is disabled by default. After privacy and consent review, set a real Google Analytics measurement ID in `site/public/site-config.js`. The integration accepts only the `G-...` format and does not send form values.

Implemented submission events include:

- `contact_form_submit`
- `volunteer_application_submit`
- `partner_inquiry_submit`
- `newsletter_signup`

## Content and release review

Core routes include `/`, `/about/`, `/opportunities/`, `/volunteer/`, `/get-involved/`, `/partner/`, `/updates/`, `/resources/`, `/contact/`, and the policy pages. Campaign-ready guidance pages cover career exploration, leadership opportunities, and mentorship. Confirmation pages are marked `noindex`.

Before a public release, review:

- `CONTENT_CHECKLIST.md`
- `ACCESSIBILITY_CHECKLIST.md`
- `DEPLOYMENT_CHECKLIST.md`
- `GOOGLE_AD_GRANTS_READINESS.md`

Policy and youth-safety pages are intentionally labelled as drafts requiring organizational and professional review. Website quality supports—but does not guarantee—Google for Nonprofits or Ad Grants eligibility or approval.
