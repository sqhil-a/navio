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
      { "@type": "Organization", "@id": `${siteUrl}/#organization`, name: "Navio Pathways", legalName: "Navio Pathways", url: `${siteUrl}/`, email: "hello@naviopathways.com", areaServed: { "@type": "AdministrativeArea", name: "Ontario" }, sameAs: ["https://www.instagram.com/naviopathways/"] },
    ] : []),
    { "@type": "WebPage", "@id": `${siteUrl}${page.path}#page`, url: `${siteUrl}${page.path}`, name: page.title, description: page.description, isPartOf: { "@id": `${siteUrl}/#website` }, about: { "@id": `${siteUrl}/#organization` } },
  ];
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
