# Navio Pathways website

This repository contains the public website for Navio Pathways, an Ontario incorporated not-for-profit organization focused on youth career exploration, volunteering, leadership, and community experience.

## Stack and deployment

- React 19 and Vite 8
- Pre-rendered HTML for search engines and fast GitHub Pages delivery
- Permanent dark design using the Navio purple, white, and black brand palette
- Custom domain configured as `naviopathways.com`

The editable source lives in `site/src/`. Route content is stored in `site/src/page-content.js`. The build scripts pre-render every route, generate the sitemap, validate links and metadata, and publish the final files to the repository root.

## Site structure

The public site uses 16 pre-rendered routes, including:

- Home and About
- The Navio Career Clarity Program and workbook
- Resources, About, and Contact
- Contact
- Privacy, Terms, Accessibility, and Youth safety

The former career-workshop URL redirects to the Career Clarity Program. Unavailable opportunity, update, and recruitment routes are no longer published.

## Contact and participation

Visitors contact Navio Pathways directly through the monitored domain email or its public social profiles. The Career Clarity Program, workbook, and supporting resources are available immediately without an account, registration form, or collection of student responses.

## Local development

```powershell
npm install
npm run dev
```

## Production build

```powershell
npm run build
```

The build creates the browser and server-rendering bundles, pre-renders 14 routes, publishes the GitHub Pages files, and checks route integrity, metadata, nonprofit facts, program completeness, workbook content, and external-link safety.

## Content notes

Event dates, speakers, impact statistics, partnerships, and additional leadership or board biographies should be published only after they are verified and approved. The production build rejects placeholder, closed-registration, and deprecated form language.
