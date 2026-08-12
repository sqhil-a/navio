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
- Career workshops and workshop registration
- Opportunities, Resources, Updates, and Get involved
- Contact
- Privacy, Terms, Accessibility, and Youth safety

Older campaign and form-confirmation pages remain consolidated into these current routes. The journal URL redirects visitors to Resources and Updates.

## Contact and registration

Visitors contact Navio Pathways directly through the monitored domain email or its public social profiles. Workshop registration uses a first-party page and remains closed until confirmed sessions, a reviewed HTTPS submission endpoint, and the required privacy and youth-safety controls are configured in `site/public/site-config.js`.

## Local development

```powershell
npm install
npm run dev
```

## Production build

```powershell
npm run build
```

The build creates the browser and server-rendering bundles, pre-renders 16 routes, publishes the GitHub Pages files, and checks route integrity, metadata, nonprofit facts, content depth, registration safety, and external-link safety.

## Content notes

Workshop dates, speakers, impact statistics, partnerships, and additional leadership or board biographies should be published only after they are verified and approved. The production build rejects placeholder language and unsafe registration configuration.
