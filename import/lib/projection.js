"use strict";
/**
 * lib/projection.js
 *
 * UTM auto-projection (matching the Python version's
 * ox.projection.project_geometry auto-selection) plus GeoJSON ring
 * projection/recentering.
 */

const proj4 = require("proj4");

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

module.exports = {
  utmProjString,
  getProjectionAndOrigin,
  projectAndRecenterPoint,
  projectRing,
  polygonRingsFromGeoJSON,
};
