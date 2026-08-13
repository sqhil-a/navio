# Deployment checklist

Last updated: July 14, 2026

## Ownership and release control

- [ ] Confirm the production host, repository, branch, deployment source, DNS, registrar, and CDN accounts are organization-controlled.
- [ ] Require multi-factor authentication for administrative accounts.
- [ ] Identify the person authorized to approve content and production releases.
- [ ] Confirm the release contains only the React website, its generated Pages output, and review documentation.
- [ ] Back up current production DNS and hosting settings before changing them.

## Pre-build

- [ ] Complete the publish-blocking items in `CONTENT_CHECKLIST.md`.
- [ ] Approve organization status, founder/contact details, social links, and public claims.
- [ ] Review policy drafts; keep draft notices visible until approval.
- [ ] Confirm no private address, phone number, youth information, API key, token, `.env`, or `.dev.vars` file is staged.
- [ ] Review `git diff` for unintended content, configuration, or generated-output changes.

## Build and automated checks

Run from the repository root:

```powershell
npm ci
npm run build
```

- [ ] Confirm the pre-renderer reports the expected number of React pages.
- [ ] Confirm the public-site check passes with unique metadata and no broken local links.
- [ ] Inspect the generated diff; generated HTML, `sitemap.xml`, and `robots.txt` should match the source.
- [ ] Confirm `npm audit` reports no unresolved production vulnerability.

## Third-party services

- [ ] Keep the public program free of unnecessary third-party scripts and embeds.
- [ ] Add analytics only after privacy/consent approval and a new performance review.
- [ ] Run `npm run build` after any approved service change so the Pages root is refreshed.

## Hosting and routing

- [ ] Confirm `CNAME` contains `naviopathways.com` and matches host settings.
- [ ] Confirm `.nojekyll` is deployed where required.
- [ ] Confirm directory routes such as `/about/` resolve to their `index.html` files.
- [ ] Confirm unknown paths serve `404.html` with an actual 404 status where the host supports it.
- [ ] Confirm `robots.txt` and `sitemap.xml` return 200 with correct MIME types.
- [ ] Confirm thank-you routes are `noindex` and blocked from sitemap inclusion.
- [ ] Confirm the canonical domain and trailing-slash strategy do not create duplicate pages.

## HTTPS and DNS

- [ ] Valid certificate on the apex domain.
- [ ] HTTP permanently redirects to HTTPS.
- [ ] `www` consistently redirects to the canonical apex domain or is intentionally unconfigured.
- [ ] No mixed HTTP assets or form endpoints.
- [ ] DNS records do not expose an abandoned host or unused subdomain takeover risk.
- [ ] CAA, DNSSEC, and registrar lock reviewed where supported and appropriate.

## Security headers

Configure at the host/CDN and test before enforcement:

- [ ] `Content-Security-Policy` limited to required origins. Include the configured form host and Google tag origins only if those services are enabled.
- [ ] `Referrer-Policy: strict-origin-when-cross-origin`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] Clickjacking protection through CSP `frame-ancestors 'none'` (or an approved narrower policy)
- [ ] `Permissions-Policy` disabling unneeded camera, microphone, geolocation, payment, and other capabilities
- [ ] HSTS after HTTPS and all subdomains are verified; do not enable `includeSubDomains` or preload prematurely

Also verify compression, cache headers, MIME types, and that HTML is revalidated while versioned/static assets can be cached longer.

## Privacy and contact

- [ ] Confirm the public program and workbook do not collect or transmit student answers.
- [ ] Confirm no personal information is placed in URLs, browser logs, or error text.
- [ ] Test the public email route, ownership, response, privacy request, accessibility request, and youth-safety escalation.

## Manual browser QA

- [ ] Chrome, Firefox, Safari, and Edge current versions where available.
- [ ] 320, 375, 768, 1024, 1280, and 1440 CSS-pixel widths.
- [ ] Mobile menu open, focus trap, Escape close, link close, and resize reset.
- [ ] Header, footer, primary CTAs, disclosures, print action, policy links, external links, and 404 page.
- [ ] 200% and 400% zoom, keyboard-only, reduced-motion, screen-reader smoke test, and high-contrast mode.
- [ ] No console errors, failed network requests, layout shifts, clipped text, or horizontal scroll.

## SEO and analytics

- [ ] View source on representative pages and confirm unique title, description, canonical, Open Graph, and JSON-LD.
- [ ] Validate structured data against Google's current testing tools.
- [ ] Submit the sitemap in organization-controlled Search Console.
- [ ] Confirm production is indexable and no staging domain is indexed.
- [ ] If analytics is enabled, confirm no duplicate tag and no personal information in events.

## Performance

- [ ] Run Lighthouse mobile and desktop on production, not only localhost.
- [ ] Review LCP, INP, CLS, FCP, TBT, and Speed Index.
- [ ] Confirm no render-blocking third-party font or unnecessary library.
- [ ] Optimize any future images and set intrinsic dimensions.
- [ ] Re-test after adding analytics, CAPTCHA, form provider, social embeds, or event images.

## Release and rollback

- [ ] Record release commit, approver, date, and configuration changes.
- [ ] Deploy to a preview/staging URL first when the host supports it.
- [ ] Perform a production smoke test immediately after release.
- [ ] Keep a tested rollback path that restores the prior static artifact and configuration without changing DNS unnecessarily.
- [ ] Monitor form receipts, errors, uptime, certificate expiry, broken links, and stale event content.
