// Generates a radioactive-trefoil app icon (green on dark) -> src-tauri/icon-src.png
import sharp from "sharp";
import { mkdirSync } from "node:fs";

const S = 1024;
const c = S / 2;
const cR = 120; // center disc radius
const r1 = 175; // blade inner radius
const r2 = 445; // blade outer radius

const rad = (d) => (d * Math.PI) / 180;
const pol = (r, d) => [c + r * Math.cos(rad(d)), c - r * Math.sin(rad(d))];
const f = (n) => n.toFixed(2);

function blade(center) {
  const a1 = center - 30;
  const a2 = center + 30;
  const [x1, y1] = pol(r1, a1);
  const [x2, y2] = pol(r2, a1);
  const [x3, y3] = pol(r2, a2);
  const [x4, y4] = pol(r1, a2);
  return `M${f(x1)},${f(y1)} L${f(x2)},${f(y2)} A${r2},${r2} 0 0 0 ${f(x3)},${f(y3)} L${f(x4)},${f(y4)} A${r1},${r1} 0 0 1 ${f(x1)},${f(y1)} Z`;
}

const blades = [90, 210, 330].map(blade).join(" ");

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  <defs>
    <radialGradient id="bg" cx="50%" cy="40%" r="65%">
      <stop offset="0%" stop-color="#102a1a"/>
      <stop offset="100%" stop-color="#070b08"/>
    </radialGradient>
  </defs>
  <rect width="${S}" height="${S}" rx="210" fill="url(#bg)"/>
  <circle cx="${c}" cy="${c}" r="${r2 + 22}" fill="#22e06b" opacity="0.10"/>
  <g fill="#22e06b">
    <circle cx="${c}" cy="${c}" r="${cR}"/>
    <path d="${blades}"/>
  </g>
</svg>`;

mkdirSync("src-tauri", { recursive: true });
await sharp(Buffer.from(svg)).png().toFile("src-tauri/icon-src.png");
console.log("✓ src-tauri/icon-src.png written");
