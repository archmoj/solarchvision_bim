"use strict";
/**
 * lib/cli.js
 *
 * Usage text and argument parsing for SOLARCHVISION_OSM_3D_in_obj.js.
 */

const { DEFAULT_USER_AGENT } = require("./overpass");

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
  --overpass-user-agent <ua>  User-Agent/Referer sent with Overpass requests (default:
                               identifies this tool; overpass-api.de rejects requests
                               with no descriptive User-Agent at all)

  Buildings:
    --level-height <m>        Meters per building level when only building:levels
                               is tagged (default: 3.0)
    --default-height <m>      Fallback building height (default: 6.0)
    --include-parts           Also fetch building:part features

  buildings.txt (SOLARCHVISION_BIM's Mesh script command):
    --material <n>             Material index (m:) for Mesh lines (default: 7)
    --tessellation <n>         Tessellation index (tes:) for Mesh lines (default: 0)
    --layer <n>                Layer index (lyr:) for Mesh lines (default: 0)
    --no-buildings-txt          Skip writing buildings.txt

  Trees (more_info.txt):
    --tree-default-height <m> Fallback tree height (default: 10.0)
    --no-trees                Skip fetching trees

  Ground rectangle (Mesh2 line):
    --ground-padding <m>      Extra meters added to --radius for the Mesh2 extents (default: 0)
    --no-ground                Skip writing the Mesh2 line
`);
}

const BOOLEAN_FLAGS = new Set(["include-parts", "no-trees", "no-ground", "no-buildings-txt", "help"]);

function parseArgs(argv) {
  const args = {
    radius: 250,
    levelHeight: 3.0,
    defaultHeight: 6.0,
    includeParts: false,
    material: 7,
    tessellation: 0,
    layer: 0,
    noBuildingsTxt: false,
    treeDefaultHeight: 10.0,
    noTrees: false,
    groundPadding: 0.0,
    noGround: false,
    outdir: null,
    overpassUrl: null,
    overpassUserAgent: DEFAULT_USER_AGENT,
  };
  for (let i = 0; i < argv.length; i++) {
    const tok = argv[i];
    if (!tok.startsWith("--")) continue;
    const name = tok.slice(2);
    if (BOOLEAN_FLAGS.has(name)) {
      if (name === "include-parts") args.includeParts = true;
      else if (name === "no-trees") args.noTrees = true;
      else if (name === "no-ground") args.noGround = true;
      else if (name === "no-buildings-txt") args.noBuildingsTxt = true;
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
      case "material":
        args.material = parseInt(value, 10);
        break;
      case "tessellation":
        args.tessellation = parseInt(value, 10);
        break;
      case "layer":
        args.layer = parseInt(value, 10);
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
      case "overpass-user-agent":
        args.overpassUserAgent = value;
        break;
      default:
        throw new Error(`Unknown option: --${name}`);
    }
  }
  return args;
}

module.exports = { printUsage, BOOLEAN_FLAGS, parseArgs };
