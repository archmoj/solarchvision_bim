"use strict";
/**
 * lib/height.js
 *
 * OSM height-tag parsing (e.g. "12", "12 m", "12.5m", `12'6"`), mirroring
 * solarch_3d_common.py's parse_height_meters/feature_height on the
 * Python side, including the "never return NaN/undefined/<=0" guarantee.
 */

const HEIGHT_RE = /[-+]?\d*\.?\d+/;

function isFinitePositive(x) {
  return typeof x === "number" && Number.isFinite(x) && x > 0;
}

/** Parse an OSM height-like tag value to meters. Returns null if it
 * can't be parsed, is missing, or is NaN/inf. Unlike Python/pandas, a
 * missing GeoJSON property is simply `undefined` here rather than a
 * float NaN, but this still guards defensively against any non-finite
 * numeric value. */
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
 * Always returns a finite, positive number. Used for tree heights
 * (trees have no levels concept, unlike buildings). */
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

module.exports = { isFinitePositive, parseHeightMeters, featureHeight, buildingHeight };
