import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

const roots = ["dist", "."];
const routes = [
  "index.html", "about/index.html", "opportunities/index.html", "volunteer/index.html",
  "get-involved/index.html", "partner/index.html", "updates/index.html", "resources/index.html",
  "contact/index.html", "privacy/index.html", "terms/index.html", "accessibility/index.html",
  "youth-safety/index.html", "career-exploration/index.html", "leadership-opportunities/index.html",
  "mentorship/index.html", "thank-you/contact/index.html", "thank-you/volunteer/index.html",
  "thank-you/partner/index.html", "thank-you/application/index.html", "thank-you/newsletter/index.html",
  "404.html",
];
const errors = [];
const routePaths = new Set(routes.map((route) => route === "index.html" ? "/" : route === "404.html" ? "/404.html" : `/${route.replace(/index\.html$/, "")}`));

for (const root of roots) {
  const titles = new Map();
  const descriptions = new Map();
  for (const route of routes) {
    const file = join(root, route);
    if (!existsSync(file)) { errors.push(`${file} is missing`); continue; }
    const html = readFileSync(file, "utf8");
    for (const expected of ["<title>", "name=\"description\"", "rel=\"canonical\"", "id=\"root\"", "<h1"]) {
      if (!html.includes(expected)) errors.push(`${file} is missing ${expected}`);
    }
    if (/__PAGE_|__CANONICAL_|__STRUCTURED_/.test(html)) errors.push(`${file} contains an unreplaced build token`);
    if (html.includes('/src/main.jsx')) errors.push(`${file} still references development source`);
    if (!/<html[^>]*lang="en-CA"/.test(html)) errors.push(`${file} is missing the Canadian English language declaration`);
    if ((html.match(/<h1(?:\s|>)/g) || []).length !== 1) errors.push(`${file} must contain exactly one h1`);
    if ((html.match(/<main(?:\s|>)/g) || []).length !== 1) errors.push(`${file} must contain exactly one main landmark`);
    if (/target="_blank"(?![^>]*rel="[^"]*noopener)/.test(html)) errors.push(`${file} has an unsafe new-tab link`);

    const title = html.match(/<title>([\s\S]*?)<\/title>/)?.[1];
    const description = html.match(/<meta name="description" content="([\s\S]*?)"/i)?.[1];
    if (title) {
      if (titles.has(title)) errors.push(`${file} duplicates the title in ${titles.get(title)}`);
      titles.set(title, file);
    }
    if (description) {
      if (descriptions.has(description)) errors.push(`${file} duplicates the description in ${descriptions.get(description)}`);
      descriptions.set(description, file);
    }

    for (const [, href] of html.matchAll(/href="([^"]+)"/g)) {
      if (!href.startsWith("/") || href.startsWith("//")) continue;
      const localPath = href.split(/[?#]/, 1)[0];
      if (!localPath || localPath.startsWith("/assets/") || routePaths.has(localPath)) continue;
      errors.push(`${file} links to missing local route ${localPath}`);
    }
  }
  for (const asset of ["assets/icon/icon.png", "assets/images/Star.png", "site-config.js", "sitemap.xml", "robots.txt", "CNAME", ".nojekyll"]) {
    if (!existsSync(join(root, asset))) errors.push(`${join(root, asset)} is missing`);
  }
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}
console.log(`Static checks passed for ${routes.length} routes in dist and the GitHub Pages root.`);
