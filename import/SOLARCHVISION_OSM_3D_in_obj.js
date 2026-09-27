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
 *   Mesh2 m:3 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
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
 * (the lib/ folder next to this script holds the actual logic, split
 * into height.js, projection.js, geometry.js, format.js, overpass.js,
 * cli.js - this file is just CLI orchestration. Mirrors the
 * height/geometry/format/Overpass split in the Python side's
 * solarch_3d_common.py, which SOLARCHVISION_Overture_3D_in_obj.py also
 * uses; a future Node script sourcing buildings from elsewhere could
 * reuse lib/geometry.js, lib/format.js, and lib/overpass.js as-is.)
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

const { isFinitePositive, parseHeightMeters, featureHeight, buildingHeight } = require("./lib/height");
const { utmProjString, getProjectionAndOrigin, projectAndRecenterPoint, polygonRingsFromGeoJSON } = require("./lib/projection");
const { triangulateFootprint, ObjWriter, addExtrudedPolygon, iterPolygons } = require("./lib/geometry");
const { formatPyFloatLike, formatNumber, formatMesh2Line, writeMoreInfoTxt } = require("./lib/format");
const {
  DEFAULT_USER_AGENT,
  OverpassUnreachableError,
  buildBuildingQuery,
  buildTreeQuery,
  fetchOverpass,
  fetchFeaturesGeoJSON,
} = require("./lib/overpass");
const { printUsage, parseArgs } = require("./lib/cli");

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
    buildingsGeoJSON = await fetchFeaturesGeoJSON(buildingQuery, overpassUrls, args.overpassUserAgent);
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
  // Trees are a best-effort supplementary layer: if this fetch fails, we
  // still want to keep the buildings.obj already written above and finish
  // writing more_info.txt (with zero trees) rather than aborting the run.
  const treeRows = [];
  if (!args.noTrees) {
    console.log(`Fetching OSM trees within ${args.radius} m ...`);
    const treeQuery = buildTreeQuery(args.lat, args.lon, args.radius);
    let treesGeoJSON = null;
    try {
      treesGeoJSON = await fetchFeaturesGeoJSON(treeQuery, overpassUrls, args.overpassUserAgent);
    } catch (e) {
      if (e instanceof OverpassUnreachableError) {
        console.error(
          `\nWARNING: could not fetch trees (${e.message.split("\n")[0]}); ` +
            "continuing with 0 trees. buildings.obj above is unaffected."
        );
        process.exitCode = 1; // still flag the run as partially incomplete
      } else {
        throw e;
      }
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

// Flat re-export of everything, for backward compatibility with anything
// (tests included) that does require('./SOLARCHVISION_OSM_3D_in_obj.js').xyz
// directly rather than reaching into lib/*.
module.exports = {
  isFinitePositive,
  parseHeightMeters,
  featureHeight,
  buildingHeight,
  utmProjString,
  getProjectionAndOrigin,
  projectAndRecenterPoint,
  polygonRingsFromGeoJSON,
  triangulateFootprint,
  ObjWriter,
  addExtrudedPolygon,
  iterPolygons,
  formatPyFloatLike,
  formatNumber,
  formatMesh2Line,
  writeMoreInfoTxt,
  DEFAULT_USER_AGENT,
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
