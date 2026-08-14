import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const roots = ["dist", "."];
const routes = [
  "index.html", "programs/npcc/index.html", "programs/npcc/register/index.html",
  "programs/npcc/rules/index.html", "programs/npcc/prepare/index.html", "about/index.html",
  "contact/index.html", "privacy/index.html", "terms/index.html", "accessibility/index.html",
  "youth-safety/index.html", "links/index.html", "404.html",
];
const errors = [];
const routePaths = new Set(routes.map((route) => route === "index.html" ? "/" : route === "404.html" ? "/404.html" : `/${route.replace(/index\.html$/, "")}`));
const minimumMainWords = new Map([
  ["index.html", 350], ["programs/npcc/index.html", 650], ["programs/npcc/register/index.html", 400],
  ["programs/npcc/rules/index.html", 750], ["programs/npcc/prepare/index.html", 600],
  ["about/index.html", 450], ["contact/index.html", 140], ["privacy/index.html", 250],
  ["terms/index.html", 220], ["accessibility/index.html", 140], ["youth-safety/index.html", 220],
]);
const bannedLanguage = /workbook|Career Clarity|worksheet|self-paced|coming soon|under construction|in development|future initiative|not currently open|registration is not open|confirmed dates will|placeholder/i;
const visibleWordCount = (html) => html
  .replace(/<script[\s\S]*?<\/script>/gi, " ")
  .replace(/<style[\s\S]*?<\/style>/gi, " ")
  .replace(/<[^>]+>/g, " ")
  .replace(/&[a-z0-9#]+;/gi, " ")
  .trim().split(/\s+/).filter(Boolean).length;

const requireText = (html, file, values, label) => {
  for (const value of values) if (!html.includes(value)) errors.push(`${file} is missing ${label}: ${value}`);
};

for (const root of roots) {
  const titles = new Map();
  const descriptions = new Map();
  for (const route of routes) {
    const file = join(root, route);
    if (!existsSync(file)) { errors.push(`${file} is missing`); continue; }
    const html = readFileSync(file, "utf8");
    requireText(html, file, ["<title>", "name=\"description\"", "rel=\"canonical\"", "id=\"root\"", "<h1"], "document element");
    if (/__PAGE_|__CANONICAL_|__STRUCTURED_/.test(html)) errors.push(`${file} contains an unreplaced build token`);
    if (/\/src\/(?:main\.jsx|client\.js)/.test(html)) errors.push(`${file} still references development source`);
    if (!/<html[^>]*lang="en-CA"/.test(html)) errors.push(`${file} is missing the Canadian English language declaration`);
    if ((html.match(/<h1(?:\s|>)/g) || []).length !== 1) errors.push(`${file} must contain exactly one h1`);
    if ((html.match(/<main(?:\s|>)/g) || []).length !== 1) errors.push(`${file} must contain exactly one main landmark`);
    if (/target="_blank"(?![^>]*rel="[^"]*noopener)/.test(html)) errors.push(`${file} has an unsafe new-tab link`);
    if (/<form(?:\s|>)/.test(html)) errors.push(`${file} contains an unexpected form`);
    if (bannedLanguage.test(html)) errors.push(`${file} contains filler, placeholder, or superseded-program language`);

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

  for (const asset of ["assets/icon/navio-icon.png", "assets/images/navio-logo.png", "assets/images/navio-star-bg.png", "navio-favicon.svg", "google679ac1915f24aeb4.html", "sitemap.xml", "robots.txt", "CNAME", ".nojekyll"]) {
    if (!existsSync(join(root, asset))) errors.push(`${join(root, asset)} is missing`);
  }

  const homeFile = join(root, "index.html");
  const home = readFileSync(homeFile, "utf8");
  requireText(home, homeFile, ["Navio Pathways Case Competition 2026", "NPCC", "November 15, 2026", "Grades 9–12", "Teams of 2–4", "No entry fee", "1001662092", "3140 Polo Place", "/programs/npcc/", "/programs/npcc/register/"], "program or trust content");

  const programFile = join(root, "programs/npcc/index.html");
  const program = readFileSync(programFile, "utf8");
  requireText(program, programFile, ["Registration status: open", "November 1, 2026", "Nov. 9", "November 15, 2026", "Online", "seven-slide", "seven-minute", "five-minute", "100-point rubric", "Problem analysis — 25 points", "12:00", '"@type":"Event"'], "confirmed competition detail");

  const registerFile = join(root, "programs/npcc/register/index.html");
  const register = readFileSync(registerFile, "utf8");
  requireText(register, registerFile, ["registration · Open", "November 1, 2026", "Within 3 business days", "Email team registration", "Do not send birth dates", "Privacy and youth safety"], "registration detail");

  const rulesFile = join(root, "programs/npcc/rules/index.html");
  const rules = readFileSync(rulesFile, "utf8");
  requireText(rules, rulesFile, ["1. Eligibility", "Original work and technology", "7. Judging", "Problem analysis", "Recommendation and tradeoffs", "Implementation and feasibility", "Evidence and assumptions", "Presentation and questions", "A tie is resolved", '"learningResourceType":"Competition rules"'], "official rule");

  const prepareFile = join(root, "programs/npcc/prepare/index.html");
  const prepare = readFileSync(prepareFile, "utf8");
  requireText(prepare, prepareFile, ["Slide 1", "Slide 7", "Final submission check", "seven minutes", '"learningResourceType":"Participant guide"'], "preparation detail");

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
