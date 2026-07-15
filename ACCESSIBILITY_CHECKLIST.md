# Accessibility checklist

Target: WCAG 2.2 Level AA best practices
Last reviewed: July 14, 2026

This checklist combines implementation status with manual tests that must be repeated after content, form-provider, or hosting changes. A checked implementation item is not a certification of conformance.

## Implemented in the public site

- [x] `lang="en-CA"` on every generated page
- [x] Skip-to-content link with visible focus
- [x] Semantic header, navigation, main, sections, headings, lists, forms, and footer
- [x] One page-level `h1` per route and logical generated heading structure
- [x] Keyboard-operable navigation, links, buttons, native disclosures, forms, and print action
- [x] Mobile menu state exposed with `aria-expanded`/`aria-controls`
- [x] Escape closes the mobile menu; focus stays within it while open and returns to the trigger
- [x] Visible high-contrast `:focus-visible` treatment
- [x] Form controls have explicit labels, instructions, required indicators, and live status messages
- [x] Invalid fields receive `aria-invalid`; focus moves to the first invalid field
- [x] Entered form data remains after network/configuration errors
- [x] Status and availability use words, not colour alone
- [x] External new-tab links identify the behaviour and use `noopener noreferrer`
- [x] Responsive layouts and touch targets designed for phone, tablet, and desktop widths
- [x] Reduced-motion mode disables non-essential transitions and smooth scrolling
- [x] System fonts avoid third-party font downloads and flash/layout shift
- [x] Print styles produce readable resource guides
- [x] No autoplay, carousel, audio, video, drag-only interaction, or inaccessible custom control
- [x] CSS-generated decoration is hidden from assistive technology

## Manual keyboard review

- [ ] At 320 px width, Tab through the entire page without horizontal scrolling.
- [ ] Verify the skip link is the first focusable control and lands on main content.
- [ ] Open the mobile menu with Enter and Space.
- [ ] Confirm focus enters the menu, wraps inside it, closes with Escape, and returns to the button.
- [ ] Confirm no focus is hidden beneath the sticky header.
- [ ] Operate every disclosure with Enter/Space.
- [ ] Submit each form empty; confirm understandable browser and inline feedback.
- [ ] Correct fields and confirm error state clears.
- [ ] Confirm every link and button has a visible focus state against its background.

## Screen-reader review

- [ ] Test current NVDA + Chrome or Firefox on Windows.
- [ ] Test VoiceOver + Safari on iOS or macOS when available.
- [ ] Review landmark navigation and page titles.
- [ ] Confirm navigation current-page state is announced.
- [ ] Confirm mobile-menu open/closed state and button name are announced.
- [ ] Confirm form label, required state, hint, invalid state, and status message are understandable.
- [ ] Confirm draft-policy warnings and opportunity-status notices are read in a logical sequence.
- [ ] Confirm decorative marks do not add noise.

## Visual and reflow review

- [ ] Test at 200% and 400% browser zoom.
- [ ] Test 320, 375, 768, 1024, 1280, and 1440 CSS-pixel widths.
- [ ] Check portrait and landscape orientations.
- [ ] Check Windows High Contrast/forced-colours mode.
- [ ] Verify text spacing overrides do not clip or overlap content.
- [ ] Verify headings, labels, and error messages remain readable with long content.
- [ ] Check contrast with an automated tool and manually verify focus indicators, status chips, link states, and disabled controls.

## Content and media

- [ ] Give every future meaningful image concise, contextual alt text.
- [ ] Use `alt=""` for decorative images and avoid repeating adjacent text.
- [ ] Provide captions/transcripts for future recorded media.
- [ ] Do not place essential text inside images.
- [ ] Use descriptive link text instead of repeated “learn more” links.
- [ ] State dates with month names and include time zones.
- [ ] Describe location, transit, venue access, sensory conditions, and accommodation contact for future events.

## Forms and third parties

- [ ] Re-test accessibility after a real form endpoint, CAPTCHA, analytics consent tool, newsletter provider, or registration service is integrated.
- [ ] Avoid inaccessible image puzzles. If bot protection is required, prefer low-friction server-side controls and an accessible fallback.
- [ ] Confirm errors returned by the service are mapped to understandable text and do not expose technical details.
- [ ] Confirm time limits can be extended or are not imposed.
- [ ] Provide an email alternative when a third-party form is inaccessible.

## Organizational actions

- [ ] Designate an accessibility feedback owner.
- [ ] Approve accommodation-request and response procedures.
- [ ] Review the draft Accessibility Statement.
- [ ] Establish a schedule for accessibility checks and issue tracking.
- [ ] Record known barriers, owners, priorities, and remediation dates.
