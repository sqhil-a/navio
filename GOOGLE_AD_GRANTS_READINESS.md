# Google Ad Grants review readiness

Last reviewed: August 12, 2026

This checklist reduces known website-policy risks; it does not guarantee approval. Google reviews the organization, account, website, and policy compliance independently.

## Implemented website remediation

- [x] The homepage prominently identifies Navio Pathways as an Ontario incorporated not-for-profit.
- [x] Legal identity is consistent: Corporation Number 1001662092 and 3140 Polo Place, Mississauga, Ontario.
- [x] The homepage explains the mission, audience, current work, workshop model, resources, and public benefit.
- [x] A substantial `/career-workshops/` page explains audience, online delivery, cost, learning objectives, agenda, professional perspectives, preparation, outcomes, accessibility, safety, cancellation, and registration status.
- [x] A gated first-party `/career-workshops/register/` workflow refuses to collect data until real sessions and an approved HTTPS endpoint are configured.
- [x] The closed executive-team Google Form and every CTA pointing to it were removed.
- [x] Navigation includes About, Career Workshops, Resources, Updates, Get Involved, and Contact.
- [x] Three substantial original HTML career resources are publicly available without registration.
- [x] A dated Updates page reports meaningful program, resource, and organization changes.
- [x] About, Contact, Privacy, Terms, Accessibility, and Youth Safety now reflect the workshop operating model.
- [x] Structured data includes the verified organization address, email, service area, founder, and corporation identifier.
- [x] Build checks enforce route integrity, unique metadata, safe links, minimum core-page content, organization facts, workshop details, and registration configuration safety.
- [x] HTTPS, apex-domain canonicalization, `www` redirect, sitemap, robots file, and GitHub Pages delivery were previously verified.
- [x] Production dependencies report zero known vulnerabilities as of this review.

## Hard launch blockers

Do not resubmit the Ad Grants website until every item below is complete:

- [ ] Add at least one confirmed session to `site/public/site-config.js`, including a stable ID and a public label containing the date, time, and Eastern Time designation.
- [ ] Confirm and publish the session duration, capacity, registration deadline, and any parent/guardian requirement on `/career-workshops/`.
- [ ] Configure an organization-approved HTTPS registration endpoint in `site/public/site-config.js`.
- [ ] Set `registrationOpen: true` only after end-to-end privacy, delivery, duplicate, error, accessibility, and inbox-routing tests pass.
- [ ] Verify a real submission is received by the accountable program owner and produces the promised participant confirmation.
- [ ] Publish guest names or biographies only after participation and publication consent are documented; names are not required to open registration.
- [ ] Run mobile and desktop Lighthouse on production for Home, Career Workshops, Registration, Resources, and Contact.
- [ ] Meet the release gates: Performance at least 90; Accessibility, Best Practices, and SEO at least 95; lab LCP at most 2.5 s; CLS at most 0.1; TBT at most 200 ms.
- [ ] Crawl production and verify no broken links, console errors, mixed content, horizontal overflow at 320 px, or failed form states.
- [ ] Verify Search Console ownership, submit `sitemap.xml`, and request indexing for the revised core routes.
- [ ] Save the final build output, Lighthouse reports, crawl report, session schedule, form receipt, organization documents, domain-control evidence, and screenshots in the application review packet.

## Resubmission explanation

Use a concise, evidence-based note:

> We revised naviopathways.com to address the website-quality feedback. The homepage now prominently identifies Navio Pathways as an Ontario incorporated not-for-profit and explains our mission, audience, and active career-awareness work. We added a substantial online workshop page with confirmed session information and working registration, expanded three original career resources, added dated organizational updates, strengthened contact and policy information, removed a closed application link, and verified mobile performance, navigation, HTTPS, and link functionality.

Edit that note only to reflect facts that are live and verified on the resubmission date.

## Current official guidance

- [Canadian eligibility requirements](https://support.google.com/nonprofits/answer/3215869?co=GENIE.CountryCode%3DCA&hl=en)
- [Ad Grants website policy](https://support.google.com/nonprofits/answer/1657899?hl=en)
- [Ad Grants policy compliance guide](https://support.google.com/nonprofits/answer/9314402?hl=en)
- [Core Web Vitals](https://web.dev/articles/vitals)
