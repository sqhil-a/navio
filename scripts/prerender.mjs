import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { getPageCatalog, render } from "../.ssr/entry-server.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dist = join(root, "dist");
const template = readFileSync(join(dist, "index.html"), "utf8");
const siteUrl = "https://naviopathways.com";
const buildDate = new Date().toISOString().slice(0, 10);
const catalog = getPageCatalog();

const escapeAttribute = (value) => value.replaceAll("&", "&amp;").replaceAll('"', "&quot;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
const normalizeText = (value) => value.replaceAll("\r\n", "\n").replace(/[ \t]+(?=\n)/g, "");
const outputFor = (path) => path === "/" ? "index.html" : path === "/404.html" ? "404.html" : join(path.slice(1), "index.html");
const schemaFor = (page) => {
  const graph = [
    ...(page.path === "/" ? [
      { "@type": "WebSite", "@id": `${siteUrl}/#website`, url: `${siteUrl}/`, name: "Navio Pathways" },
      { "@type": "Organization", "@id": `${siteUrl}/#organization`, name: "Navio Pathways", legalName: "Navio Pathways", identifier: "Ontario Corporation Number 1001662092", description: "Ontario incorporated not-for-profit operating the free Navio Career Clarity Program for secondary students.", url: `${siteUrl}/`, email: "hello@naviopathways.com", address: { "@type": "PostalAddress", streetAddress: "3140 Polo Place", addressLocality: "Mississauga", addressRegion: "Ontario", addressCountry: "CA" }, founder: { "@type": "Person", name: "Sahil Ambegaonkar", jobTitle: "Founder and President", url: "https://sqhil-a.github.io/portfolio/" }, areaServed: { "@type": "AdministrativeArea", name: "Ontario" }, sameAs: ["https://www.instagram.com/naviopathways/", "https://www.linkedin.com/company/navio-pathways/", "https://journal.naviopathways.com/"] },
    ] : []),
    { "@type": "WebPage", "@id": `${siteUrl}${page.path}#page`, url: `${siteUrl}${page.path}`, name: page.title, description: page.description, isPartOf: { "@id": `${siteUrl}/#website` }, about: { "@id": `${siteUrl}/#organization` } },
  ];
  if (page.path === "/programs/career-clarity/") {
    graph.push({
      "@type": "Course",
      "@id": `${siteUrl}/programs/career-clarity/#course`,
      name: "Navio Career Clarity Program",
      description: "A free five-stage, self-paced career exploration program for Ontario secondary students in Grades 9–12.",
      provider: { "@id": `${siteUrl}/#organization` },
      educationalLevel: "Grades 9–12",
      timeRequired: "PT2H30M",
      isAccessibleForFree: true,
      audience: { "@type": "EducationalAudience", educationalRole: "student", geographicArea: { "@type": "AdministrativeArea", name: "Ontario" } },
      offers: { "@type": "Offer", price: 0, priceCurrency: "CAD", availability: "https://schema.org/InStock", url: `${siteUrl}/programs/career-clarity/` },
      hasCourseInstance: { "@type": "CourseInstance", courseMode: "online", name: "Self-paced online program" },
    });
  }
  if (page.path === "/programs/career-clarity/workbook/") {
    graph.push({
      "@type": "CreativeWork",
      "@id": `${siteUrl}/programs/career-clarity/workbook/#workbook`,
      name: "Navio Career Clarity Program Workbook",
      author: { "@id": `${siteUrl}/#organization` },
      isAccessibleForFree: true,
      educationalLevel: "Grades 9–12",
      learningResourceType: "Workbook",
    });
  }
  if (page.path !== "/" && page.path !== "/404.html") {
    graph.push({
      "@type": "BreadcrumbList",
      itemListElement: [
        { "@type": "ListItem", position: 1, name: "Home", item: `${siteUrl}/` },
        { "@type": "ListItem", position: 2, name: page.title.replace(" | Navio Pathways", ""), item: `${siteUrl}${page.path}` },
      ],
    });
  }
  return { "@context": "https://schema.org", "@graph": graph };
};

for (const page of catalog) {
  const canonicalPath = page.path === "/404.html" ? "/404.html" : page.path;
  const html = template
    .replaceAll("__PAGE_TITLE__", escapeAttribute(page.title))
    .replaceAll("__PAGE_DESCRIPTION__", escapeAttribute(page.description))
    .replaceAll("__CANONICAL_PATH__", canonicalPath)
    .replaceAll("__ROBOTS__", page.noindex ? "noindex, follow" : "index, follow")
    .replace("__STRUCTURED_DATA__", JSON.stringify(schemaFor(page)).replaceAll("<", "\\u003c"))
    .replace("<!--app-html-->", render(page.path));
  const destination = join(dist, outputFor(page.path));
  mkdirSync(dirname(destination), { recursive: true });
  writeFileSync(destination, normalizeText(html));
}

const sitemap = catalog
  .filter((page) => !page.noindex && page.path !== "/404.html")
  .map((page) => `  <url><loc>${siteUrl}${page.path}</loc><lastmod>${buildDate}</lastmod></url>`)
  .join("\n");
writeFileSync(join(dist, "sitemap.xml"), `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${sitemap}\n</urlset>\n`);
writeFileSync(join(dist, "robots.txt"), `User-agent: *\nAllow: /\n\nSitemap: ${siteUrl}/sitemap.xml\n`);
console.log(`Pre-rendered ${catalog.length} React routes.`);
