# Google Ad Grants readiness

Last reviewed against official Google guidance: July 14, 2026

This is a readiness checklist, not an eligibility or approval claim. Google can change its requirements and reviews each organization and website. Re-check the official sources before applying:

- [Google for Nonprofits eligibility guidelines for Canada](https://support.google.com/nonprofits/answer/3215869?co=GENIE.CountryCode%3DCA&hl=en)
- [Google Ad Grants website policy](https://support.google.com/nonprofits/answer/1657899?hl=en)
- [Ad Grants policy compliance guide](https://support.google.com/nonprofits/answer/9314402?hl=en)
- [Ad Grants conversion tracking setup](https://support.google.com/grants/answer/9165556?hl=en)

## Eligibility gate

- [x] The public site describes NAVIO PATHWAYS as an Ontario incorporated not-for-profit and does not describe it as a school or academic institution.
- [x] Google's current Canadian list includes a “Provincial nonprofit” as a recognized registration category.
- [ ] **Confirm the organization meets all current Canadian eligibility requirements and can be verified by Google's validation partner.** Incorporation wording on a website is not verification.
- [ ] Gather the legal registration document, registration/identification number, legal address, authorized representative information, and any Goodstack-requested documentation.
- [ ] Confirm the legal name and registration data exactly match the application.
- [ ] Confirm the organization is not excluded under Google's current ineligible-organization categories.
- [ ] Obtain internal authority to accept the Google for Nonprofits and Ad Grants terms.

## Completed website foundations

- [x] Mission is prominent on the homepage and About page.
- [x] Youth-development purpose, audiences, activity areas, and community benefit are explained in original HTML content.
- [x] Legal and public organization names and Ontario not-for-profit wording are visible.
- [x] The website does not claim registered-charity status, tax deductions, charitable receipts, government endorsement, guaranteed hours, or guaranteed outcomes.
- [x] The organization is clearly distinguished from a school, tutoring company, and commercial career platform.
- [x] Current program, event, and application availability is stated honestly; no sample events or fake openings are presented as real.
- [x] Meaningful routes exist for About, opportunities, volunteering, involvement, partnerships, updates, resources, contact, accessibility, privacy, terms, and youth safety.
- [x] Intent-specific landing pages exist for career exploration, leadership development, mentorship, volunteering, partnerships, resources, and updates.
- [x] Useful original resource content is available as HTML rather than only as PDFs.
- [x] Navigation and footer are consistent across generated pages.
- [x] Unique titles, descriptions, canonical URLs, Open Graph metadata, and JSON-LD are generated.
- [x] Organization and breadcrumb structured data are limited to supported, verified facts.
- [x] `sitemap.xml`, `robots.txt`, root-relative internal links, and custom `404.html` are present.
- [x] Responsive layouts, keyboard navigation, visible focus, form labels, reduced motion, and accessible status states are implemented.
- [x] No AdSense, affiliate links, third-party advertising, donation claims, or paid/commercial focus was added.
- [x] Static implementation has no public-site dependencies, external fonts, ad scripts, or large decorative media.

## Remaining content verification

- [ ] Complete every required item in `CONTENT_CHECKLIST.md`.
- [ ] Approve the official contact email and add an appropriate public address if the organization chooses to publish one.
- [ ] Confirm founder information and publish only approved leadership/team details.
- [ ] Add real current programs when their eligibility, dates, locations, capacity, cost, consent, safety, and application destinations are approved.
- [ ] Add real upcoming events with clear status and real registration links.
- [ ] Add partner/sponsor names, logos, testimonials, impact data, and photos only with evidence and permission.
- [ ] Keep at least the core Home, About, Opportunities, Contact, Resources, and policy content substantial and current.
- [ ] Establish an editorial owner and review cadence so the site does not appear abandoned.

## Domain and HTTPS checks

- [ ] Confirm NAVIO PATHWAYS owns or has administrative control of `naviopathways.com`, DNS, hosting, Search Console, analytics, and form-provider accounts.
- [ ] Confirm `https://naviopathways.com/` serves a valid certificate with no browser warnings.
- [ ] Confirm `http://naviopathways.com/` permanently redirects to HTTPS.
- [ ] Confirm `https://www.naviopathways.com/` either resolves and redirects to the canonical non-`www` domain or is intentionally not used.
- [ ] Confirm there is no mixed content on any route.
- [ ] Verify canonical URLs match the final redirect/canonical-domain policy.
- [ ] Verify all ad destinations remain on an approved, organization-controlled domain.
- [ ] Add and verify the domain property in Google Search Console; submit `sitemap.xml`.

## Form testing checklist

The interface is complete, but online submission is intentionally unavailable until a real service is configured. Email is the current working contact destination.

- [ ] Select an organization-approved HTTPS form processor or backend.
- [ ] Complete a privacy/security/data-retention review and data-processing terms.
- [ ] Configure server-side validation, allowlisted origins, rate limiting, spam controls, logging limits, and safe error responses.
- [ ] Generate `site-config.js` from deployment environment variables; do not place secrets in browser code.
- [ ] Test contact inquiry success and `/thank-you/contact/` redirect.
- [ ] Test volunteer interest success and `/thank-you/volunteer/` redirect.
- [ ] Test partnership inquiry success and `/thank-you/partner/` redirect.
- [ ] Test newsletter signup, confirmed consent, unsubscribe, and `/thank-you/newsletter/` redirect.
- [ ] Test validation, timeout, server error, offline mode, duplicate clicks, spam field, keyboard use, and screen-reader announcements.
- [ ] Verify no thank-you page can be reached automatically when a submission fails.
- [ ] Verify submitted values are not placed in URLs, analytics events, logs, or page content.
- [ ] Assign an inbox owner and response/escalation process.

## Conversion tracking checklist

Primary conversions should represent completed meaningful actions:

- [ ] `contact_form_submit`
- [ ] `volunteer_application_submit`
- [ ] `program_application_submit`
- [ ] `partner_inquiry_submit`
- [ ] `mentor_interest_submit`
- [ ] `newsletter_signup`
- [ ] A real event-registration completion imported from the registration service

Secondary actions may include:

- [ ] `volunteer_application_start`
- [ ] `program_application_start`
- [ ] `event_registration_click` for a verified external registration destination
- [ ] `resource_download` for a real resource file
- [ ] `contact_email_click`

Do not configure homepage visits, ordinary page views, every outbound click, or short time-on-site as primary conversions. The current code fires submission events only after an endpoint returns success. Thank-you routes are `noindex` and can also be used as destination conversions after forms are operational.

## Analytics setup

- [ ] Approve the analytics purpose, data minimization, retention, access, and any consent mechanism.
- [ ] Create the property/account under an organization-controlled login.
- [ ] Set `NAVIO_ANALYTICS_ENABLED=true` and the real `NAVIO_GA_ID` only in the deployment environment.
- [ ] Generate `site-config.js` during deployment.
- [ ] Update the Privacy Policy with the real provider, cookies/storage, controls, retention, and contact.
- [ ] Test DebugView/Tag Assistant without submitting real youth personal information.
- [ ] Mark only meaningful completed actions as conversions.
- [ ] Verify conversion values/counting methods and exclude internal/test traffic.
- [ ] Reconcile analytics events against form-provider receipts before relying on them.
- [ ] Never send names, email addresses, free-text messages, or other personal information in event parameters.

## Policy review

- [ ] Obtain authorized review and approval of the draft Privacy Policy.
- [ ] Obtain authorized review and approval of the draft Terms of Use.
- [ ] Review and operationalize the Accessibility Statement.
- [ ] Obtain qualified youth-safety review; designate a trained reporting contact and escalation process.
- [ ] Remove “draft” notices only after approval and record the approval/review date.
- [ ] Ensure actual practices match published policies before accepting forms or youth participation.

## Broken-link and functional review

- [x] Local automated route, fragment, asset, metadata, ID, label, and JSON-LD checks are available in `scripts/check_public_site.mjs`.
- [ ] Run the check on the final deployment artifact.
- [ ] Crawl the deployed HTTPS site, including redirect and custom-404 behaviour.
- [ ] Manually test every mail, social, application, registration, partner, policy, and resource link.
- [ ] Check that closed opportunities are updated or removed promptly.
- [ ] Check third-party pages for safety, accessibility, privacy, status, and ownership before linking.

## Mobile and performance review

- [ ] Complete the manual checks in `ACCESSIBILITY_CHECKLIST.md` at phone, tablet, and desktop widths.
- [ ] Run mobile and desktop Lighthouse on the deployed HTTPS site.
- [ ] Target strong real-world performance without deleting useful content.
- [ ] Review Core Web Vitals after enough field data exists.
- [ ] Confirm compression, caching, correct MIME types, and HTTP/2 or newer at the host.
- [ ] Re-test after enabling analytics, forms, CAPTCHA, images, or external embeds.

## Final pre-application checklist

- [ ] Eligibility and Goodstack verification path confirmed.
- [ ] Domain control and HTTPS verified.
- [ ] Organization/legal/contact facts approved.
- [ ] At least one genuine, current organizational activity or program is accurately documented.
- [ ] Forms or other primary conversion destinations work end to end.
- [ ] Accurate conversion tracking works and records only meaningful actions.
- [ ] Policies reflect actual operations and have been reviewed.
- [ ] Youth-safety and privacy contacts/processes are operational.
- [ ] No broken links, placeholder content, invented claims, or stale “upcoming” items.
- [ ] Mobile, accessibility, performance, and security review completed on production.
- [ ] Current Google website, mission-based campaign, keyword, conversion, and account policies re-read immediately before application.

## Readiness conclusion

The website foundation is substantially stronger and aligned with Google's published quality themes: clear mission, original content, easy navigation, mobile usability, HTTPS compatibility, and meaningful conversion destinations. Application readiness is **not complete** until eligibility verification, real organizational content/activity, operational forms, accurate conversions, policy approval, production HTTPS checks, and final manual QA are complete.
