# Navio Pathways website

This repository contains the public website for Navio Pathways, an Ontario incorporated not-for-profit organization operating the annual Navio Pathways Case Competition (NPCC) for Ontario secondary students.

## Stack and deployment

- React 19 and Vite 8
- Pre-rendered HTML for search engines and fast GitHub Pages delivery
- Permanent dark design using the Navio purple, white, and black brand palette
- Custom domain configured as `naviopathways.com`

The editable source lives in `site/src/`. Route content is stored in `site/src/page-content.js`. The build scripts pre-render every route, generate the sitemap, validate links and metadata, and publish the final files to the repository root.

## Site structure

The public site uses 13 pre-rendered routes, including:

- Home and About
- NPCC 2026 details and team registration
- Official competition rules and judging rubric
- Participant preparation guide
- Contact
- Privacy, Terms, Accessibility, and Youth safety

Superseded career-program, resource, educator, opportunity, update, and recruitment routes are no longer published.

## Contact and participation

Teams register for NPCC through the monitored organization inbox. The public site collects no visitor information and documents the exact registration fields, eligibility requirements, dates, event schedule, submission limits, judging rubric, conduct rules, privacy practices, and youth-safety boundaries.

## Local development

```powershell
npm install
npm run dev
```

## Production build

```powershell
npm run build
```

The build creates the browser and server-rendering bundles, pre-renders 13 routes, publishes the GitHub Pages files, and checks route integrity, metadata, nonprofit facts, program completeness, registration instructions, competition rules, preparation guidance, and external-link safety.

## Content notes

Prizes, judges, sponsors, participant totals, impact statistics, partnerships, and additional leadership or board biographies should be published only after they are verified and approved. The production build rejects placeholder, closed-registration, deprecated-program, and workbook language.
