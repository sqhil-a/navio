import { cpSync, existsSync, readdirSync, rmSync } from "node:fs";
import { join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(join(fileURLToPath(new URL("..", import.meta.url))));
const dist = resolve(join(root, "dist"));
if (!existsSync(join(dist, "index.html"))) throw new Error("Build output is missing dist/index.html");

const assertInsideRoot = (target) => {
  const rel = relative(root, resolve(target));
  if (!rel || rel.startsWith("..") || rel.includes(":")) throw new Error(`Refusing to modify path outside the repository: ${target}`);
};

for (const entry of readdirSync(dist, { withFileTypes: true })) {
  const destination = join(root, entry.name);
  assertInsideRoot(destination);
  rmSync(destination, { recursive: true, force: true });
  cpSync(join(dist, entry.name), destination, { recursive: true });
}
console.log("Published the production build to the repository root for GitHub Pages.");
