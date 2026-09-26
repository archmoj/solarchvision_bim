#!/usr/bin/env node
"use strict";
/**
 * SOLARCHVISION_OSM_3D_in_obj.js
 *
 * Node.js port of SOLARCHVISION_OSM_3D_in_obj.py - same CLI, same output
 * contract. Fetches a small 3D city-massing kit from OpenStreetMap around
 * a given latitude/longitude within a radius, written into one output
 * folder:
 *
 *   <outdir>/buildings.obj    - buildings, extruded from OSM footprints
 *   <outdir>/more_info.txt    - a header comment, a ground-rectangle
 *                               (Mesh2) line, then trees as plain-text
 *                               point+height entries
 *
 * Buildings are extruded up to a height derived from (in priority order):
 *   1. the `height` tag (meters, tolerant of "12", "12 m", "12m")
 *   2. the `building:levels` tag * --level-height (default 3.0 m)
 *   3. --default-height (default 6.0 m)
 *
 * Trees (OSM `natural=tree` nodes) get a height from their own `height`
 * tag, falling back to --tree-default-height (default 10.0 m).
 *
 * more_info.txt looks like:
 *
 *   # --lat 40.7484 --lon -73.9857 --radius 250
 *   Mesh2 m:8 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
 *   Tree x:-20.0000 y:-10.0000 z:0.0000 h:10.0000
 *   Tree x:20.0000 y:10.0000 z:0.0000 h:20.0000
 *
 * All outputs share one coordinate frame: meters, local/projected
 * (auto-selected UTM zone via proj4), origin (0, 0) at the query
 * lat/lon, z=0 at ground level - identical convention to the Python
 * version, so files from either implementation line up the same way.
 *
 * Requires Node.js 18+ (built-in global fetch) and three npm packages:
 *   npm install earcut osmtogeojson proj4
 *
 * If the Overpass fetch fails with a connection error, that's a network
 * reachability problem on your machine (firewall, proxy, DNS, or no
 * internet), not a bug in this script - see the printed diagnostic.
 * --overpass-url lets you point at a different Overpass instance; by
 * default the script also tries a couple of public mirrors automatically.
 *
 * Example:
 *   node SOLARCHVISION_OSM_3D_in_obj.js --lat 40.7484 --lon -73.9857 \
 *       --radius 250 --outdir empire_state_area
 */

const fs = require("fs");
const path = require("path");

const earcut = require("earcut").default;
const osmtogeojson = require("osmtogeojson");
const proj4 = require("proj4");

// Public Overpass mirrors tried in order if --overpass-url isn't given and
// the primary instance is unreachable. Not guaranteed to be complete/current
// coverage -- if your organization runs its own instance, use --overpass-url.
const DEFAULT_OVERPASS_MIRRORS = [
  "https://overpass-api.de/api/interpreter",
  "https://overpass.kumi.systems/api/interpreter",
  "https://overpass.private.coffee/api/interpreter",
];

const HEIGHT_RE = /[-+]?\d*\.?\d+/;

// ---------------------------------------------------------------------
// Height parsing (mirrors the Python version's parse_height_meters /
// building_height / feature_height, including the "never return
// NaN/None/<=0" guarantee).
// ---------------------------------------------------------------------

function isFinitePositive(x) {
  return typeof x === "number" && Number.isFinite(x) && x > 0;
}

/** Parse an OSM height-like tag value (e.g. "12", "12 m", "12.5m", `12'6"`)
 * to meters. Returns null if it can't be parsed, is missing, or is
 * NaN/inf. Unlike Python/pandas, a missing GeoJSON property is simply
 * `undefined` here rather than a float NaN, but this still guards
 * defensively against any non-finite numeric value. */
function parseHeightMeters(value) {
  if (value === undefined || value === null) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }
  const s = String(value).trim();
  if (!s || s.toLowerCase() === "nan") return null;
  // feet/inches like 12'6" -> treat as feet, rough conversion
  if (s.includes("'")) {
    const m = s.match(HEIGHT_RE);
    if (m) return parseFloat(m[0]) * 0.3048;
  }
  const m = s.match(HEIGHT_RE);
  if (!m) return null;
  return parseFloat(m[0]);
}

/** Parse a single height-like tag value, falling back to defaultHeight.
 * Always returns a finite, positive number. */
function featureHeight(heightTagValue, defaultHeight) {
  const h = parseHeightMeters(heightTagValue);
  if (isFinitePositive(h)) return h;
  if (isFinitePositive(defaultHeight)) return defaultHeight;
  return 6.0; // last-resort hard fallback, in case a bad CLI value was passed
}

/** Work out a building's extrusion height in meters from its OSM tags
 * (a GeoJSON feature's `properties`). Always returns a finite, positive
 * number (never NaN/undefined/<=0). */
function buildingHeight(props, levelHeight, defaultHeight) {
  const h = parseHeightMeters(props.height);
  if (isFinitePositive(h)) return h;

  const lv = parseHeightMeters(props["building:levels"]);
  if (isFinitePositive(lv)) {
    let roofLevels = parseHeightMeters(props["roof:levels"]);
    if (!isFinitePositive(roofLevels)) roofLevels = 0;
    const total = (lv + roofLevels) * levelHeight;
    if (isFinitePositive(total)) return total;
  }

  if (isFinitePositive(defaultHeight)) return defaultHeight;
  return 6.0;
}

// ---------------------------------------------------------------------
// Projection: pick one local UTM CRS for the whole run (matching the
// Python version's ox.projection.project_geometry auto-selection), then
// project + recenter every layer into it.
// ---------------------------------------------------------------------

function utmProjString(lon, lat) {
  const zone = Math.floor((lon + 180) / 6) + 1;
  const south = lat < 0 ? " +south" : "";
  return `+proj=utm +zone=${zone} +datum=WGS84 +units=m +no_defs${south}`;
}

/** Returns { projDef, origin: [x, y] } - the projected (x, y) of the
 * query point in that CRS, so every layer can be recentered on (0, 0). */
function getProjectionAndOrigin(lat, lon) {
  const projDef = utmProjString(lon, lat);
  const origin = proj4("WGS84", projDef, [lon, lat]);
  return { projDef, origin };
}

function projectAndRecenterPoint(lon, lat, projDef, origin) {
  const [x, y] = proj4("WGS84", projDef, [lon, lat]);
  return [x - origin[0], y - origin[1]];
}

// ---------------------------------------------------------------------
// Polygon helpers: ring dedup + earcut triangulation (mirrors
// polygon_rings / triangulate_footprint in the Python version).
// ---------------------------------------------------------------------

/** ringCoords: array of [lon, lat] pairs (GeoJSON ring, closed - first
 * and last identical). Returns projected+recentered [x, y] pairs with
 * the closing duplicate removed. */
function projectRing(ringCoords, projDef, origin) {
  const pts = ringCoords.map(([lon, lat]) => projectAndRecenterPoint(lon, lat, projDef, origin));
  if (pts.length > 1) {
    const [x0, y0] = pts[0];
    const [xn, yn] = pts[pts.length - 1];
    if (x0 === xn && y0 === yn) pts.pop();
  }
  return pts;
}

/** polygonCoords: GeoJSON Polygon "coordinates" (array of rings, each an
 * array of [lon, lat]). Returns { ext, holes } as arrays of [x, y]. */
function polygonRingsFromGeoJSON(polygonCoords, projDef, origin) {
  const rings = polygonCoords.map((r) => projectRing(r, projDef, origin));
  const ext = rings[0] || [];
  const holes = rings.slice(1).filter((r) => r.length >= 3);
  return { ext, holes };
}

/** Triangulate a polygon (with optional holes) using earcut.
 * Returns { points2d, tris } where points2d is an array of [x, y] and
 * tris is an array of [a, b, c] indices into points2d. */
function triangulateFootprint(ext, holes) {
  const rings = [ext, ...holes];
  const verts = [];
  const holeIndices = [];
  let vertexCount = 0;
  for (let i = 0; i < rings.length; i++) {
    if (i > 0) holeIndices.push(vertexCount);
    for (const [x, y] of rings[i]) {
      verts.push(x, y);
      vertexCount++;
    }
  }
  const triFlat = earcut(verts, holeIndices.length ? holeIndices : undefined, 2);
  const points2d = [];
  for (let i = 0; i < verts.length; i += 2) points2d.push([verts[i], verts[i + 1]]);
  const tris = [];
  for (let i = 0; i < triFlat.length; i += 3) tris.push([triFlat[i], triFlat[i + 1], triFlat[i + 2]]);
  return { points2d, tris };
}

// ---------------------------------------------------------------------
// OBJ writer (mirrors ObjWriter in the Python version, including the
// hard guard against ever writing a non-finite vertex).
// ---------------------------------------------------------------------

class ObjWriter {
  constructor() {
    this.vertices = []; // array of [x, y, z]
    this.faces = []; // array of arrays of 1-based vertex indices
    this.groups = []; // array of [faceStartIndex, name]
  }

  addVertex(x, y, z) {
    if (!(Number.isFinite(x) && Number.isFinite(y) && Number.isFinite(z))) {
      throw new Error(`Refusing to write non-finite vertex (${x}, ${y}, ${z})`);
    }
    this.vertices.push([x, y, z]);
    return this.vertices.length; // 1-based index of the vertex just added
  }

  addFace(idxs) {
    this.faces.push(idxs);
  }

  startGroup(name) {
    this.groups.push([this.faces.length, name]);
  }

  write(filePath) {
    const groupAt = new Map(this.groups.map(([start, name]) => [start, name]));
    const lines = [];
    lines.push("# Generated by SOLARCHVISION_OSM_3D_in_obj.js");
    lines.push(`# ${this.vertices.length} vertices, ${this.faces.length} faces`);
    for (const [x, y, z] of this.vertices) {
      lines.push(`v ${x.toFixed(4)} ${y.toFixed(4)} ${z.toFixed(4)}`);
    }
    for (let i = 0; i < this.faces.length; i++) {
      if (groupAt.has(i)) lines.push(`g ${groupAt.get(i)}`);
      lines.push("f " + this.faces[i].join(" "));
    }
    fs.writeFileSync(filePath, lines.join("\n") + "\n");
  }
}

/** Extrude a single (possibly holed) 2D footprint polygon into a closed
 * 3D solid (bottom cap at z=0, top cap at z=height, walls in between) and
 * append it to the ObjWriter. ext/holes: arrays of [x, y], as returned by
 * polygonRingsFromGeoJSON. */
function addExtrudedPolygon(writer, ext, holes, height) {
  if (ext.length < 3) return;

  let points2d, tris;
  try {
    ({ points2d, tris } = triangulateFootprint(ext, holes));
  } catch (e) {
    return; // skip malformed geometry rather than aborting the whole run
  }
  if (tris.length === 0) return;

  const n = points2d.length;

  // Bottom vertices (z=0) and top vertices (z=height), same local xy order
  const bottomStart = writer.addVertex(points2d[0][0], points2d[0][1], 0.0);
  for (let i = 1; i < n; i++) writer.addVertex(points2d[i][0], points2d[i][1], 0.0);
  const topStart = writer.addVertex(points2d[0][0], points2d[0][1], height);
  for (let i = 1; i < n; i++) writer.addVertex(points2d[i][0], points2d[i][1], height);

  // Bottom cap: reverse winding so the normal points down/outward
  for (const [a, b, c] of tris) {
    writer.addFace([bottomStart + a, bottomStart + c, bottomStart + b]);
  }
  // Top cap: original winding faces up
  for (const [a, b, c] of tris) {
    writer.addFace([topStart + a, topStart + b, topStart + c]);
  }

  // Walls: one quad (as 2 triangles) per edge of every ring (exterior + holes)
  let offset = 0;
  for (const ring of [ext, ...holes]) {
    const m = ring.length;
    for (let i = 0; i < m; i++) {
      const j = (i + 1) % m;
      const b0 = bottomStart + offset + i;
      const b1 = bottomStart + offset + j;
      const t0 = topStart + offset + i;
      const t1 = topStart + offset + j;
      writer.addFace([b0, b1, t1]);
      writer.addFace([b0, t1, t0]);
    }
    offset += m;
  }
}

function iterPolygons(geometry) {
  if (!geometry) return [];
  if (geometry.type === "Polygon") return [geometry.coordinates];
  if (geometry.type === "MultiPolygon") return geometry.coordinates;
  return [];
}

// ---------------------------------------------------------------------
// Ground rectangle (Mesh2 line) + more_info.txt writer.
// ---------------------------------------------------------------------

/** Mirror Python's default `str(float)` formatting for the header comment
 * (e.g. 200 -> "200.0", 45.4992 -> "45.4992"), so more_info.txt's header
 * line matches the Python implementation's output exactly for the same
 * --lat/--lon/--radius input. */
function formatPyFloatLike(v) {
  return Number.isInteger(v) ? `${v}.0` : String(v);
}

/** Format a coordinate as a plain integer when it's a whole number (e.g.
 * -250, matching the Mesh2/Tree line examples), else 4 decimals. */
function formatNumber(v) {
  if (Number.isFinite(v) && Number.isInteger(v)) return String(v);
  return v.toFixed(4);
}

/** Build the Mesh2 line describing a flat square ground rectangle at
 * z=0, spanning [-radius, radius] on both x and y:
 *   Mesh2 m:8 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0 */
function formatMesh2Line(radius) {
  const r = formatNumber(radius);
  const nr = formatNumber(-radius);
  return `Mesh2 m:8 tes:6 x1:${nr} y1:${nr} z1:0 x2:${r} y2:${r} z2:0`;
}

/** trees: array of [x, y, z, h]. Writes more_info.txt:
 *   # --lat ... --lon ... --radius ...
 *   Mesh2 m:8 tes:6 x1:... y1:... z1:0 x2:... y2:... z2:0   (if includeGround)
 *   Tree x:... y:... z:... h:...
 *   ... */
function writeMoreInfoTxt(filePath, lat, lon, radius, groundRadius, trees, includeGround) {
  const lines = [];
  lines.push(`# --lat ${formatPyFloatLike(lat)} --lon ${formatPyFloatLike(lon)} --radius ${formatPyFloatLike(radius)}`);
  if (includeGround) lines.push(formatMesh2Line(groundRadius));
  for (const [x, y, z, h] of trees) {
    lines.push(`Tree x:${x.toFixed(4)} y:${y.toFixed(4)} z:${z.toFixed(4)} h:${h.toFixed(4)}`);
  }
  fs.writeFileSync(filePath, lines.join("\n") + "\n");
}

// ---------------------------------------------------------------------
// Overpass fetching, with mirror fallback and an actionable error
// message on connection failure (mirrors fetch_features /
// OverpassUnreachableError in the Python version).
// ---------------------------------------------------------------------

class OverpassUnreachableError extends Error {}

function buildBuildingQuery(lat, lon, radius, includeParts) {
  const around = `around:${radius},${lat},${lon}`;
  const clauses = [`way["building"](${around});`, `relation["building"](${around});`];
  if (includeParts) {
    clauses.push(`way["building:part"](${around});`, `relation["building:part"](${around});`);
  }
  return `[out:json][timeout:60];\n(\n  ${clauses.join("\n  ")}\n);\nout body;\n>;\nout skel qt;`;
}

function buildTreeQuery(lat, lon, radius) {
  const around = `around:${radius},${lat},${lon}`;
  return `[out:json][timeout:60];\n(\n  node["natural"="tree"](${around});\n);\nout body;`;
}

function isConnectionIssue(err) {
  if (err && err.name === "AbortError") return true; // treat a timeout like unreachable -> try next mirror
  const code = err && err.cause && err.cause.code;
  if (code && ["ECONNREFUSED", "ENOTFOUND", "ETIMEDOUT", "ECONNRESET", "EAI_AGAIN"].includes(code)) return true;
  const msg = String((err && err.message) || "");
  return /ECONNREFUSED|ENOTFOUND|ETIMEDOUT|fetch failed|network/i.test(msg);
}

async function fetchOverpassJson(url, query, timeoutMs = 90000) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: "data=" + encodeURIComponent(query),
      signal: controller.signal,
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      throw new Error(`Overpass returned HTTP ${res.status}: ${text.slice(0, 300)}`);
    }
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

/** Fetch raw Overpass JSON for `query`, trying each URL in `overpassUrls`
 * in turn (default: DEFAULT_OVERPASS_MIRRORS) and throwing
 * OverpassUnreachableError with an actionable message if all fail to
 * connect. A non-connection error (e.g. a malformed query) is thrown
 * immediately without wasting retries on other mirrors. */
async function fetchOverpass(query, overpassUrls) {
  const urls = overpassUrls || DEFAULT_OVERPASS_MIRRORS;
  let lastErr = null;
  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    try {
      return await fetchOverpassJson(url, query);
    } catch (e) {
      if (!isConnectionIssue(e)) throw e;
      lastErr = e;
      if (i < urls.length - 1) {
        console.error(`  could not reach ${url} (${e.name || e.constructor.name}); trying another mirror ...`);
      }
    }
  }
  throw new OverpassUnreachableError(
    "Could not reach any Overpass API endpoint " +
      `(${urls.join(", ")}).\n` +
      "This is a network reachability problem on this machine, not a bug in the " +
      "script. Things to check:\n" +
      "  1. General internet access: `curl -v https://overpass-api.de/api/interpreter`\n" +
      "     from this same machine/shell.\n" +
      "  2. A corporate firewall or proxy blocking outbound HTTPS to overpass-api.de\n" +
      "     and the mirrors above -- if you're behind a proxy, set HTTPS_PROXY/HTTP_PROXY\n" +
      "     env vars (or the equivalent for your org's proxy) before running this script.\n" +
      "  3. DNS or /etc/hosts overrides pointing these hostnames somewhere unexpected.\n" +
      "  4. If your organization runs a private/self-hosted Overpass instance, or you\n" +
      "     know of a reachable mirror, pass it explicitly: --overpass-url <url>\n",
    { cause: lastErr }
  );
}

/** Fetch buildings (or trees) as a GeoJSON FeatureCollection, with
 * relations/multipolygons already assembled by osmtogeojson. */
async function fetchFeaturesGeoJSON(query, overpassUrls) {
  const overpassJson = await fetchOverpass(query, overpassUrls);
  return osmtogeojson(overpassJson);
}

// ---------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------

function printUsage() {
  console.log(`Usage: node SOLARCHVISION_OSM_3D_in_obj.js --lat <lat> --lon <lon> [options]

Required:
  --lat <deg>                 Center latitude (WGS84)
  --lon <deg>                 Center longitude (WGS84)

Options:
  --radius <m>                Search radius in meters (default: 250)
  --outdir <dir>               Output folder for buildings.obj/more_info.txt
                               (default: derived from lat/lon, e.g. 'site_40.7484_-73.9857')
  --overpass-url <url>        Overpass endpoint to use (default: try overpass-api.de,
                               then a couple of public mirrors)

  Buildings:
    --level-height <m>        Meters per building level when only building:levels
                               is tagged (default: 3.0)
    --default-height <m>      Fallback building height (default: 6.0)
    --include-parts           Also fetch building:part features

  Trees (more_info.txt):
    --tree-default-height <m> Fallback tree height (default: 10.0)
    --no-trees                Skip fetching trees

  Ground rectangle (Mesh2 line):
    --ground-padding <m>      Extra meters added to --radius for the Mesh2 extents (default: 0)
    --no-ground                Skip writing the Mesh2 line
`);
}

const BOOLEAN_FLAGS = new Set(["include-parts", "no-trees", "no-ground", "help"]);

function parseArgs(argv) {
  const args = {
    radius: 250,
    levelHeight: 3.0,
    defaultHeight: 6.0,
    includeParts: false,
    treeDefaultHeight: 10.0,
    noTrees: false,
    groundPadding: 0.0,
    noGround: false,
    outdir: null,
    overpassUrl: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const tok = argv[i];
    if (!tok.startsWith("--")) continue;
    const name = tok.slice(2);
    if (BOOLEAN_FLAGS.has(name)) {
      if (name === "include-parts") args.includeParts = true;
      else if (name === "no-trees") args.noTrees = true;
      else if (name === "no-ground") args.noGround = true;
      else if (name === "help") args.help = true;
      continue;
    }
    const value = argv[++i];
    if (value === undefined) {
      throw new Error(`Missing value for --${name}`);
    }
    switch (name) {
      case "lat":
        args.lat = parseFloat(value);
        break;
      case "lon":
        args.lon = parseFloat(value);
        break;
      case "radius":
        args.radius = parseFloat(value);
        break;
      case "level-height":
        args.levelHeight = parseFloat(value);
        break;
      case "default-height":
        args.defaultHeight = parseFloat(value);
        break;
      case "tree-default-height":
        args.treeDefaultHeight = parseFloat(value);
        break;
      case "ground-padding":
        args.groundPadding = parseFloat(value);
        break;
      case "outdir":
        args.outdir = value;
        break;
      case "overpass-url":
        args.overpassUrl = value;
        break;
      default:
        throw new Error(`Unknown option: --${name}`);
    }
  }
  return args;
}

// ---------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------

async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printUsage();
    return;
  }
  if (args.lat === undefined || args.lon === undefined || Number.isNaN(args.lat) || Number.isNaN(args.lon)) {
    printUsage();
    throw new Error("--lat and --lon are required");
  }

  const overpassUrls = args.overpassUrl ? [args.overpassUrl] : null;

  const outdir = args.outdir || `site_${args.lat}_${args.lon}`;
  fs.mkdirSync(outdir, { recursive: true });
  const buildingsPath = path.join(outdir, "buildings.obj");
  const infoPath = path.join(outdir, "more_info.txt");

  const { projDef, origin } = getProjectionAndOrigin(args.lat, args.lon);

  // ---- Buildings ----
  console.log(`Fetching OSM buildings within ${args.radius} m of (${args.lat}, ${args.lon}) ...`);
  const buildingQuery = buildBuildingQuery(args.lat, args.lon, args.radius, args.includeParts);
  let buildingsGeoJSON;
  try {
    buildingsGeoJSON = await fetchFeaturesGeoJSON(buildingQuery, overpassUrls);
  } catch (e) {
    if (e instanceof OverpassUnreachableError) {
      console.error(`\nERROR: ${e.message}`);
      process.exitCode = 1;
      return;
    }
    throw e;
  }

  const writer = new ObjWriter();
  let nWritten = 0;
  const buildingFeatures = (buildingsGeoJSON && buildingsGeoJSON.features) || [];
  if (buildingFeatures.length === 0) {
    console.error("No buildings found in that area.");
  } else {
    console.log(`Found ${buildingFeatures.length} building features. Extruding...`);
    for (const feature of buildingFeatures) {
      const geom = feature.geometry;
      if (!geom) continue;
      const height = buildingHeight(feature.properties || {}, args.levelHeight, args.defaultHeight);

      for (const polygonCoords of iterPolygons(geom)) {
        const { ext, holes } = polygonRingsFromGeoJSON(polygonCoords, projDef, origin);
        const vcount = writer.vertices.length;
        const fcount = writer.faces.length;
        writer.startGroup(`building_${nWritten}`);
        try {
          addExtrudedPolygon(writer, ext, holes, height);
          nWritten++;
        } catch (e) {
          // Non-finite vertex (should not happen after the height
          // sanitization above, but guard against bad geometry too).
          console.error(`  skipping one building: ${e.message}`);
          writer.vertices.length = vcount;
          writer.faces.length = fcount;
          writer.groups.pop();
        }
      }
    }
  }

  writer.write(buildingsPath);
  console.log(
    `Wrote ${nWritten} building solids (${writer.vertices.length} vertices, ` +
      `${writer.faces.length} faces) to ${buildingsPath}`
  );

  // ---- Trees -> more_info.txt ----
  const treeRows = [];
  if (!args.noTrees) {
    console.log(`Fetching OSM trees within ${args.radius} m ...`);
    const treeQuery = buildTreeQuery(args.lat, args.lon, args.radius);
    let treesGeoJSON;
    try {
      treesGeoJSON = await fetchFeaturesGeoJSON(treeQuery, overpassUrls);
    } catch (e) {
      if (e instanceof OverpassUnreachableError) {
        console.error(`\nERROR: ${e.message}`);
        process.exitCode = 1;
        return;
      }
      throw e;
    }
    const treeFeatures = (treesGeoJSON && treesGeoJSON.features) || [];
    for (const feature of treeFeatures) {
      const geom = feature.geometry;
      if (!geom || geom.type !== "Point") continue;
      const [lon, lat] = geom.coordinates;
      const [x, y] = projectAndRecenterPoint(lon, lat, projDef, origin);
      const h = featureHeight((feature.properties || {}).height, args.treeDefaultHeight);
      if (!(Number.isFinite(x) && Number.isFinite(y) && Number.isFinite(h))) continue;
      treeRows.push([x, y, 0.0, h]);
    }
  }

  const groundRadius = args.radius + Math.max(args.groundPadding, 0.0);
  writeMoreInfoTxt(infoPath, args.lat, args.lon, args.radius, groundRadius, treeRows, !args.noGround);
  console.log(
    `Wrote ${treeRows.length} trees` +
      (args.noGround ? "" : ` and a Mesh2 ground rectangle (radius ${groundRadius.toFixed(1)} m)`) +
      ` to ${infoPath}`
  );
}

module.exports = {
  parseHeightMeters,
  featureHeight,
  buildingHeight,
  isFinitePositive,
  utmProjString,
  getProjectionAndOrigin,
  projectAndRecenterPoint,
  polygonRingsFromGeoJSON,
  triangulateFootprint,
  ObjWriter,
  addExtrudedPolygon,
  iterPolygons,
  formatNumber,
  formatPyFloatLike,
  formatMesh2Line,
  writeMoreInfoTxt,
  OverpassUnreachableError,
  buildBuildingQuery,
  buildTreeQuery,
  fetchOverpass,
  fetchFeaturesGeoJSON,
  parseArgs,
  main,
};

if (require.main === module) {
  main().catch((e) => {
    console.error(e.stack || e.message || e);
    process.exit(1);
  });
}
