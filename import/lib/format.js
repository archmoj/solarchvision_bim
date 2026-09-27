"use strict";
/**
 * lib/format.js
 *
 * Ground rectangle (Mesh2 line) + more_info.txt writer. Data-source-
 * agnostic (trees array may be empty), mirroring
 * solarch_3d_common.py's write_more_info_txt.
 */

const fs = require("fs");

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
 *   Mesh2 m:3 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0 */
function formatMesh2Line(radius) {
  const r = formatNumber(radius);
  const nr = formatNumber(-radius);
  return `Mesh2 m:3 tes:6 x1:${nr} y1:${nr} z1:0 x2:${r} y2:${r} z2:0`;
}

/** trees: array of [x, y, z, h] (may be empty). Writes more_info.txt:
 *   # --lat ... --lon ... --radius ...
 *   Mesh2 m:3 tes:6 x1:... y1:... z1:0 x2:... y2:... z2:0   (if includeGround)
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

module.exports = { formatPyFloatLike, formatNumber, formatMesh2Line, writeMoreInfoTxt };
