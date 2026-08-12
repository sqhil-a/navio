import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

const roots = ["dist", "."];
const routes = [
  "index.html", "about/index.html", "career-workshops/index.html", "opportunities/index.html", "get-involved/index.html",
  "resources/index.html", "updates/index.html", "contact/index.html", "links/index.html", "journal/index.html", "privacy/index.html", "terms/index.html",
  "accessibility/index.html", "youth-safety/index.html", "404.html",
];
const errors = [];
const routePaths = new Set(routes.map((route) => route === "index.html" ? "/" : route === "404.html" ? "/404.html" : `/${route.replace(/index\.html$/, "")}`));
const minimumMainWords = new Map([
  ["index.html", 400], ["about/index.html", 400], ["career-workshops/index.html", 750],
  ["opportunities/index.html", 220], ["resources/index.html", 550], ["updates/index.html", 250],
  ["get-involved/index.html", 280], ["contact/index.html", 160], ["privacy/index.html", 300],
  ["terms/index.html", 275], ["accessibility/index.html", 200], ["youth-safety/index.html", 275],
]);
const visibleWordCount = (html) => html
  .replace(/<script[\s\S]*?<\/script>/gi, " ")
  .replace(/<style[\s\S]*?<\/style>/gi, " ")
  .replace(/<[^>]+>/g, " ")
  .replace(/&[a-z0-9#]+;/gi, " ")
  .trim()
  .split(/\s+/)
  .filter(Boolean)
  .length;

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
    if (/<form(?:\s|>)/.test(html)) errors.push(`${file} contains an unexpected form`);
    if (/docs\.google\.com\/forms|closedform|coming soon|under construction|registration is not open|confirmed dates will/i.test(html)) errors.push(`${file} contains a closed, placeholder, or deprecated destination`);
    const minimumWords = minimumMainWords.get(route);
    const mainHtml = html.match(/<main(?:\s[^>]*)?>([\s\S]*?)<\/main>/i)?.[1] || "";
    if (minimumWords && visibleWordCount(mainHtml) < minimumWords) errors.push(`${file} has ${visibleWordCount(mainHtml)} main-content words; expected at least ${minimumWords}`);
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
      if (!localPath || localPath.startsWith("/assets/") || localPath === "/navio-favicon.svg" || routePaths.has(localPath)) continue;
      errors.push(`${file} links to missing local route ${localPath}`);
    }
  }
  for (const asset of ["assets/icon/navio-icon.png", "assets/images/navio-logo.png", "assets/images/navio-star-bg.png", "navio-favicon.svg", "site-config.js", "sitemap.xml", "robots.txt", "CNAME", ".nojekyll"]) {
    if (!existsSync(join(root, asset))) errors.push(`${join(root, asset)} is missing`);
  }
}

for (const root of roots) {
  const home = readFileSync(join(root, "index.html"), "utf8");
  for (const expected of ["Ontario incorporated not-for-profit", "1001662092", "3140 Polo Place", "/career-workshops/", "/resources/", "/updates/"]) {
    if (!home.includes(expected)) errors.push(`${join(root, "index.html")} is missing trust or navigation content: ${expected}`);
  }
  const workshop = readFileSync(join(root, "career-workshops/index.html"), "utf8");
  for (const expected of ["Grades 9–12", "Self-guided HTML toolkit", "No cost", "Not required", "Module 1", "Module 6", "Start module one"]) {
    if (!workshop.includes(expected)) errors.push(`${join(root, "career-workshops/index.html")} is missing active toolkit detail: ${expected}`);
  }
  for (const forbidden of ["/career-workshops/register/", "registrationOpen", "registrationEndpoint"]) {
    if (home.includes(forbidden) || workshop.includes(forbidden)) errors.push(`${root} still exposes deprecated registration content: ${forbidden}`);
  }
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}
console.log(`Static checks passed for ${routes.length} routes in dist and the GitHub Pages root.`);
