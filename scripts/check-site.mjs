import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const roots = ["dist", "."];
const routes = [
  "index.html", "programs/career-clarity/index.html", "programs/career-clarity/workbook/index.html", "resources/index.html",
  "about/index.html", "contact/index.html", "privacy/index.html", "terms/index.html", "accessibility/index.html",
  "youth-safety/index.html", "links/index.html", "career-workshops/index.html", "journal/index.html", "404.html",
];
const errors = [];
const routePaths = new Set(routes.map((route) => route === "index.html" ? "/" : route === "404.html" ? "/404.html" : `/${route.replace(/index\.html$/, "")}`));
const minimumMainWords = new Map([
  ["index.html", 275], ["programs/career-clarity/index.html", 750], ["programs/career-clarity/workbook/index.html", 350],
  ["resources/index.html", 325], ["about/index.html", 240], ["contact/index.html", 120], ["privacy/index.html", 200],
  ["terms/index.html", 160], ["accessibility/index.html", 120], ["youth-safety/index.html", 200],
]);
const visibleWordCount = (html) => html
  .replace(/<script[\s\S]*?<\/script>/gi, " ")
  .replace(/<style[\s\S]*?<\/style>/gi, " ")
  .replace(/<[^>]+>/g, " ")
  .replace(/&[a-z0-9#]+;/gi, " ")
  .trim().split(/\s+/).filter(Boolean).length;

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
    if (/\/src\/(?:main\.jsx|client\.js)/.test(html)) errors.push(`${file} still references development source`);
    if (!/<html[^>]*lang="en-CA"/.test(html)) errors.push(`${file} is missing the Canadian English language declaration`);
    if ((html.match(/<h1(?:\s|>)/g) || []).length !== 1) errors.push(`${file} must contain exactly one h1`);
    if ((html.match(/<main(?:\s|>)/g) || []).length !== 1) errors.push(`${file} must contain exactly one main landmark`);
    if (/target="_blank"(?![^>]*rel="[^"]*noopener)/.test(html)) errors.push(`${file} has an unsafe new-tab link`);
    if (/<form(?:\s|>)/.test(html)) errors.push(`${file} contains an unexpected form`);
    if (/coming soon|under construction|in development|future initiative|not currently open|registration is not open|confirmed dates will|placeholder/i.test(html)) {
      errors.push(`${file} contains filler, placeholder, or unavailable-program language`);
    }
    const minimumWords = minimumMainWords.get(route);
    const mainHtml = html.match(/<main(?:\s[^>]*)?>([\s\S]*?)<\/main>/i)?.[1] || "";
    if (minimumWords && visibleWordCount(mainHtml) < minimumWords) errors.push(`${file} has ${visibleWordCount(mainHtml)} main-content words; expected at least ${minimumWords}`);

    const title = html.match(/<title>([\s\S]*?)<\/title>/)?.[1];
    const description = html.match(/<meta name="description" content="([\s\S]*?)"/i)?.[1];
    if (title) { if (titles.has(title)) errors.push(`${file} duplicates the title in ${titles.get(title)}`); titles.set(title, file); }
    if (description) { if (descriptions.has(description)) errors.push(`${file} duplicates the description in ${descriptions.get(description)}`); descriptions.set(description, file); }

    for (const [, href] of html.matchAll(/href="([^"]+)"/g)) {
      if (!href.startsWith("/") || href.startsWith("//")) continue;
      const localPath = href.split(/[?#]/, 1)[0];
      if (!localPath || localPath.startsWith("/assets/") || localPath === "/navio-favicon.svg" || routePaths.has(localPath)) continue;
      errors.push(`${file} links to missing local route ${localPath}`);
    }
  }
  for (const asset of ["assets/icon/navio-icon.png", "assets/images/navio-logo.png", "assets/images/navio-star-bg.png", "navio-favicon.svg", "sitemap.xml", "robots.txt", "CNAME", ".nojekyll"]) {
    if (!existsSync(join(root, asset))) errors.push(`${join(root, asset)} is missing`);
  }

  const home = readFileSync(join(root, "index.html"), "utf8");
  for (const expected of ["Navio Career Clarity Program", "Grades 9–12", "About 2.5 hours", "1001662092", "3140 Polo Place", "/programs/career-clarity/", "/programs/career-clarity/workbook/"]) {
    if (!home.includes(expected)) errors.push(`${join(root, "index.html")} is missing program or trust content: ${expected}`);
  }
  const program = readFileSync(join(root, "programs/career-clarity/index.html"), "utf8");
  for (const expected of ["Navio Career Clarity Program", "Status", "Open now", "Total time", "Career Clarity Portfolio", "Stage 1", "Stage 5", "Complete worksheet 1", "Complete worksheet 5", "30-Day Exploration Plan", "Published August 13, 2026", '"@type":"Course"']) {
    if (!program.includes(expected)) errors.push(`${join(root, "programs/career-clarity/index.html")} is missing required program detail: ${expected}`);
  }
  const workbook = readFileSync(join(root, "programs/career-clarity/workbook/index.html"), "utf8");
  for (const expected of ["Career Clarity Program Workbook", "Worksheet 1", "Worksheet 5", "Completion checklist", '"learningResourceType":"Workbook"']) {
    if (!workbook.includes(expected)) errors.push(`${join(root, "programs/career-clarity/workbook/index.html")} is missing required workbook detail: ${expected}`);
  }

  const scripts = readdirSync(join(root, "assets")).filter((asset) => asset.endsWith(".js"));
  if (scripts.length !== 1) errors.push(`${join(root, "assets")} should contain exactly one client JavaScript bundle; found ${scripts.length}`);
  for (const script of scripts) {
    const bytes = statSync(join(root, "assets", script)).size;
    if (bytes > 10000) errors.push(`${join(root, "assets", script)} is ${bytes} bytes; client JavaScript must stay below 10 KB`);
  }
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}
console.log(`Static checks passed for ${routes.length} routes in dist and the GitHub Pages root.`);
