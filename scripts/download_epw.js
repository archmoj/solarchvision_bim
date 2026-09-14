// Requires Node.js 18+ (uses the built-in global fetch).

const fs = require('fs/promises');
const path = require('path');

const OUT_FOLDER = '/home/solarch/org/solarchvision_bim/input/climate/TMYEPW/';
const GEOJSON_URL =
  'https://gist.githubusercontent.com/Myoldmopar/8c58eba49c0a40fdbbfd8cce36a0a96e/raw/830a33ec7e57aec610446d02c53e664c711c48d6/master.geojson';

// The geojson stores each EPW link as a literal `<a href=...>` snippet
// rather than a plain URL, so pull the href attribute out of it.
function extractHref(anchorHtml) {
  const match = anchorHtml.match(/href=["']?([^"'>]+)["']?/);
  return match ? match[1] : null;
}

async function fetchText(url) {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Request failed (${res.status} ${res.statusText}): ${url}`);
  }
  return res.text();
}

async function downloadEpwFiles() {
  const [currentFiles, geoStr] = await Promise.all([
    fs.readdir(OUT_FOLDER),
    fetchText(GEOJSON_URL),
  ]);

  const currentFileSet = new Set(currentFiles);

  const urls = JSON.parse(geoStr)
    .features.map((feature) => extractHref(feature.properties.epw))
    .filter(Boolean);

  // Downloaded one at a time (not in parallel) to avoid hammering the server.
  for (const url of urls) {
    const filename = path.basename(url);

    if (currentFileSet.has(filename)) {
      continue; // already downloaded
    }

    try {
      console.log('downloading:', url);
      const contents = await fetchText(url);

      const filepath = path.join(OUT_FOLDER, filename);
      await fs.writeFile(filepath, contents, 'utf8');

      console.log('downloaded:', filepath);
    } catch (error) {
      console.error(`failed to download ${url}:`, error.message);
    }
  }
}

downloadEpwFiles().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
