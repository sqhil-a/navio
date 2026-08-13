import { cpSync, existsSync, mkdirSync, readdirSync, rmSync } from "node:fs";
import { join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(join(fileURLToPath(new URL("..", import.meta.url))));
const dist = resolve(join(root, "dist"));
if (!existsSync(join(dist, "index.html"))) throw new Error("Build output is missing dist/index.html");

// Keep the published email-signature URL stable alongside the public root copy.
const emailSignature = join(root, "site/public/email-signature.png");
if (existsSync(emailSignature)) {
  mkdirSync(join(dist, "assets"), { recursive: true });
  cpSync(emailSignature, join(dist, "assets/email-signature.png"));
}

// Preserve manually uploaded public icons that live beside the generated bundles.
for (const filename of ["instagram.png", "linkedin.png", "website.png"]) {
  const source = join(root, "assets", filename);
  if (existsSync(source)) {
    mkdirSync(join(dist, "assets"), { recursive: true });
    cpSync(source, join(dist, "assets", filename));
  }
}

const assertInsideRoot = (target) => {
  const rel = relative(root, resolve(target));
  if (!rel || rel.startsWith("..") || rel.includes(":")) throw new Error(`Refusing to modify path outside the repository: ${target}`);
};

// Remove generated routes that no longer belong to the public site.
for (const staleEntry of ["opportunities", "updates", "get-involved", "career-workshops", "journal"]) {
  const target = join(root, staleEntry);
  assertInsideRoot(target);
  rmSync(target, { recursive: true, force: true });
}

for (const entry of readdirSync(dist, { withFileTypes: true })) {
  const destination = join(root, entry.name);
  assertInsideRoot(destination);
  rmSync(destination, { recursive: true, force: true });
  cpSync(join(dist, entry.name), destination, { recursive: true });
}
console.log("Published the production build to the repository root for GitHub Pages.");
