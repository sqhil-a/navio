# Google Ad Grants review readiness

Last reviewed: August 12, 2026

This checklist reduces known website-policy risks; Google retains discretion over approval.

## Implemented website remediation

- [x] The homepage prominently identifies Navio Pathways as an Ontario incorporated not-for-profit.
- [x] Legal identity is consistent: Corporation Number 1001662092 and 3140 Polo Place, Mississauga, Ontario.
- [x] The homepage explains the mission, Ontario secondary-student audience, active work, and public benefit.
- [x] The primary service is a substantial six-module self-guided career toolkit that is available immediately.
- [x] The toolkit and three companion guides require no account, application, registration, or collection of student responses.
- [x] Closed and contingent registration pages, forms, CTAs, configuration, and sitemap entries were removed.
- [x] Guided group use is accurately presented as an inquiry for schools and community organizations, not an open public event.
- [x] Navigation includes About, Career Toolkit, Resources, Updates, Get Involved, and Contact.
- [x] A dated Updates page records meaningful program, resource, and organization changes.
- [x] About, Contact, Privacy, Terms, Accessibility, and Youth Safety describe the active resource-based operating model.
- [x] Structured data includes the verified organization address, email, service area, founder, and corporation identifier.
- [x] Build checks enforce route integrity, unique metadata, safe links, minimum content, organization facts, and active-toolkit content.
- [x] HTTPS, apex-domain canonicalization, `www` redirect, sitemap, robots file, and GitHub Pages delivery were previously verified.
- [x] Production dependencies reported zero known vulnerabilities at the prior production review.

## Verification before resubmission

- [ ] Run mobile and desktop Lighthouse on production for Home, Career Toolkit, Resources, About, and Contact.
- [ ] Meet the release gates: Performance at least 90; Accessibility, Best Practices, and SEO at least 95; lab LCP at most 2.5 s; CLS at most 0.1; TBT at most 200 ms.
- [ ] Crawl production and verify no broken links, console errors, mixed content, or horizontal overflow at 320 px.
- [ ] Verify Search Console ownership, submit `sitemap.xml`, and request indexing for the revised core routes.
- [ ] Save the final build output, Lighthouse and crawl reports, organization documents, domain-control evidence, and screenshots in the application review packet.
- [ ] Compare the exact new Google rejection wording with the live fixes before resubmitting.

## Resubmission explanation

Use only after the revised pages are live and verified:

> We revised naviopathways.com to address the website-quality feedback. The homepage prominently identifies Navio Pathways as an Ontario incorporated not-for-profit and explains our mission, audience, active work, and public benefit. Our primary program is now a substantial six-module career-exploration toolkit that students can use immediately without an account, application, or submission of personal information. We also publish three original companion guides, dated updates, complete organization and contact details, and current privacy, accessibility, terms, and youth-safety information. We removed the closed registration workflow and every contingent or placeholder call-to-action, then verified production navigation, HTTPS, responsive behavior, metadata, sitemap inclusion, and internal links.

Edit this note only to reflect facts verified on the resubmission date.

## Current official guidance

- [Canadian eligibility requirements](https://support.google.com/nonprofits/answer/3215869?co=GENIE.CountryCode%3DCA&hl=en)
- [Ad Grants website policy](https://support.google.com/nonprofits/answer/1657899?hl=en)
- [Ad Grants policy compliance guide](https://support.google.com/nonprofits/answer/9314402?hl=en)
- [Core Web Vitals](https://web.dev/articles/vitals)
