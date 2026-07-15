# Navio Pathways website

This repository contains the public website for Navio Pathways, an Ontario incorporated not-for-profit organization focused on youth career exploration, volunteering, leadership, and community experience.

## Stack and deployment

- React 19 and Vite 8
- Pre-rendered HTML for search engines and fast GitHub Pages delivery
- Permanent dark design using the Navio purple, white, and black brand palette
- Custom domain configured as `naviopathways.com`

The editable source lives in `site/src/`. Route content is stored in `site/src/page-content.js`. The build scripts pre-render every route, generate the sitemap, validate links and metadata, and publish the final files to the repository root.

## Site structure

The public site intentionally uses a small route set:

- Home
- About
- Opportunities
- Get involved
- Resources
- Contact
- Privacy, terms, accessibility, and youth safety

Older campaign, volunteer, partnership, update, and form-confirmation pages were consolidated into these core routes.

## Contact and applications

The static site does not submit inquiry forms. Visitors contact Navio Pathways directly by email or Instagram. The executive-team application opens an external Google Form.

## Local development

```powershell
npm install
npm run dev
```

## Production build

```powershell
npm run build
```

The build creates the browser and server-rendering bundles, pre-renders 11 routes, publishes the GitHub Pages files, and checks route integrity, metadata, external-link safety, and the absence of on-site forms.

## Content notes

Photo areas are intentionally marked as placeholders until real Navio Pathways photography is available with appropriate participant consent. Impact statistics and additional leadership or board biographies should be added only after they are verified.
