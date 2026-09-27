#!/usr/bin/env python3
"""
SOLARCHVISION_Overture_3D_in_obj.py

Alternative to SOLARCHVISION_OSM_3D_in_obj.py: fetches building massing
from Overture Maps (https://overturemaps.org) instead of OpenStreetMap,
around a given latitude/longitude within a radius, into the same output
folder contract:

    <outdir>/buildings.obj    - buildings, extruded from Overture footprints
    <outdir>/more_info.txt    - a header comment, a ground-rectangle
                                (Mesh2) line, and trees (if --trees-source
                                osm is used - see "Trees" below)

Why Overture instead of OSM/GlobalBuildingAtlas
------------------------------------------------
Overture's Buildings theme merges OpenStreetMap, Microsoft's ML-derived
building footprints, and Esri Community Maps contributions into one
schema, with heights where any source provides them (including USGS 3DEP
lidar in parts of the US) - often better coverage than OSM alone. Unlike
GlobalBuildingAtlas, Overture data is licensed under ODbL (same family as
OSM, no non-commercial restriction) and is genuinely queryable by a small
bounding box via cloud-native GeoParquet (Parquet row-group pruning on
Amazon S3) rather than requiring bulk multi-hundred-MB tile downloads.

Data access
-----------
Uses the official `overturemaps` PyPI package (maintained by the Overture
Maps Foundation), which resolves the latest release automatically via
Overture's STAC catalog and reads directly from their public S3 bucket -
no API key or AWS account needed, just outbound HTTPS access.

Height derivation (Overture's schema; see
https://github.com/OvertureMaps/schema/blob/main/schema/buildings/defs.yaml)
    1. the `height` tag, if present (already in meters)
    2. `num_floors` * --level-height (default 3.0 m)
    3. --default-height (default 6.0 m)
A building/part's `min_height` (if present) is used as the base of the
extrusion instead of 0 - this correctly models "floating" parts, e.g. a
section of a building that bridges over a driveway and doesn't reach
ground level, which Overture's schema represents explicitly.

Building parts (--include-parts)
---------------------------------
Like OSM's `building:part`, Overture splits complex buildings (towers,
domes, etc.) into `building_part` features linked to a parent `building`
via `building_id`. A building's `has_parts` flag says whether this
applies. With --include-parts: buildings with has_parts=true are NOT
extruded as a flat box (their footprint+height is a coarse envelope, not
real massing) - instead their `building_part` features are extruded
individually, avoiding doubled/overlapping volume. Buildings with
has_parts=false are always extruded normally, part fetching or not.

Trees (--trees-source osm)
---------------------------
Overture has no equivalent of OSM's `natural=tree` layer, so by default
(--trees-source none) more_info.txt from this script has 0 Tree lines.
Pass --trees-source osm to fetch trees from OpenStreetMap instead (via
the same Overpass machinery the OSM script uses, in
solarch_3d_common.py) while still sourcing buildings from Overture -
this needs osmnx installed additionally (`pip install osmnx`), only
when this flag is used.

Requires: overturemaps, geopandas, shapely, mapbox_earcut, pyproj, numpy
    pip install overturemaps geopandas shapely mapbox_earcut pyproj numpy
(add `osmnx` too if using --trees-source osm.
solarch_3d_common.py must sit alongside this script - it holds code
shared with SOLARCHVISION_OSM_3D_in_obj.py.)

Example:
    python SOLARCHVISION_Overture_3D_in_obj.py --lat 40.7484 --lon -73.9857 \\
        --radius 250 --outdir empire_state_area_overture --trees-source osm
"""

import argparse
import math
import os
import sys

try:
    import overturemaps.core as overture_core
except ImportError:
    print("Missing dependency: overturemaps. Install with `pip install overturemaps`.", file=sys.stderr)
    raise

try:
    from shapely.geometry import Polygon
except ImportError:
    print("Missing dependency: shapely. Install with `pip install shapely`.", file=sys.stderr)
    raise

try:
    import pyproj
except ImportError:
    print("Missing dependency: pyproj. Install with `pip install pyproj`.", file=sys.stderr)
    raise

try:
    import solarch_3d_common as common
except ImportError:
    print("Missing file: solarch_3d_common.py must sit alongside this script.", file=sys.stderr)
    raise


# ---------------------------------------------------------------------
# Overture-specific height/base-z derivation (uses `height`/`num_floors`/
# `min_height`; different schema from OSM's building:levels, so this
# stays here rather than in the shared module).
# ---------------------------------------------------------------------

def building_height_and_base(props, level_height, default_height):
    """Work out a building/part's (base_z, height) in meters from its
    Overture properties. Always returns finite numbers, with height > 0."""
    height = props.get("height")
    if not common._finite_positive(height):
        num_floors = props.get("num_floors")
        if common._finite_positive(num_floors):
            height = num_floors * level_height
        else:
            height = None

    if not common._finite_positive(height):
        height = default_height if common._finite_positive(default_height) else 6.0

    base_z = common._finite(props.get("min_height"), default=0.0)
    if base_z < 0:
        base_z = 0.0
    return base_z, height


# ---------------------------------------------------------------------
# Projection: one local UTM CRS for the whole run, auto-selected from
# the query point (same convention as SOLARCHVISION_OSM_3D_in_obj.py,
# but via a raw pyproj Transformer applied per-ring/per-point rather
# than a whole-GeoDataFrame osmnx projection - different data shape, so
# this stays here rather than in the shared module).
# ---------------------------------------------------------------------

def utm_proj_string(lon, lat):
    zone = int((lon + 180) / 6) + 1
    south = " +south" if lat < 0 else ""
    return f"+proj=utm +zone={zone} +datum=WGS84 +units=m +no_defs{south}"


def get_projection_and_origin(lat, lon):
    proj_def = utm_proj_string(lon, lat)
    transformer = pyproj.Transformer.from_crs("EPSG:4326", proj_def, always_xy=True)
    ox, oy = transformer.transform(lon, lat)
    return transformer, (ox, oy)


def project_and_recenter_point(lon, lat, transformer, origin):
    x, y = transformer.transform(lon, lat)
    return x - origin[0], y - origin[1]


def project_and_recenter_ring(ring_coords, transformer, origin):
    """ring_coords: iterable of (lon, lat). Returns [(x, y), ...] recentered
    on origin, with the closing duplicate point removed."""
    xs, ys = transformer.transform([c[0] for c in ring_coords], [c[1] for c in ring_coords])
    pts = [(x - origin[0], y - origin[1]) for x, y in zip(xs, ys)]
    if len(pts) > 1 and pts[0] == pts[-1]:
        pts.pop()
    return pts


def polygon_rings(poly: Polygon, transformer, origin):
    ext = project_and_recenter_ring(list(poly.exterior.coords), transformer, origin)
    holes = []
    for interior in poly.interiors:
        ring = project_and_recenter_ring(list(interior.coords), transformer, origin)
        if len(ring) >= 3:
            holes.append(ring)
    return ext, holes


# ---------------------------------------------------------------------
# Overture fetching
# ---------------------------------------------------------------------

class OvertureUnreachableError(RuntimeError):
    pass


def compute_bbox(lat, lon, radius, padding_factor=1.15):
    """A generous (xmin, ymin, xmax, ymax) lon/lat bounding box around the
    query point, used for Overture's own Parquet row-group pruning. The
    precise circular radius filter happens later, in local meters."""
    lat_pad = (radius * padding_factor) / 111_320.0
    coslat = max(math.cos(math.radians(lat)), 1e-6)
    lon_pad = (radius * padding_factor) / (111_320.0 * coslat)
    return (lon - lon_pad, lat - lat_pad, lon + lon_pad, lat + lat_pad)


def fetch_overture(overture_type, lat, lon, radius, release=None, use_stac=True):
    """Fetch a GeoDataFrame of the given Overture type within a bounding
    box around (lat, lon). Raises OvertureUnreachableError with an
    actionable message on network/S3 failures.

    Tries the STAC-accelerated path first (faster - it narrows down which
    Parquet files to open before scanning), then falls back to a direct
    dataset scan (stac=False) if that fails. This works around a known
    overturemaps<=1.0.2 bug: when the STAC catalog reports zero
    intersecting files for a bbox+release (which can happen for a very
    recently published release the catalog hasn't fully indexed yet, or
    a genuine catalog gap), `geodataframe(..., stac=True)` crashes with a
    confusing `TypeError: Expected pandas DataFrame, ...` instead of
    returning an empty result - see geodataframe()/record_batch_reader()/
    _prepare_query() in overturemaps/core.py. The stac=False path doesn't
    have this bug: it scans the dataset directly and applies the same
    bbox filter at the Parquet row-group level without depending on the
    STAC catalog at all, so it reliably finds real data even when the
    STAC-accelerated path can't."""
    bbox = compute_bbox(lat, lon, radius)
    attempts = [True, False] if use_stac else [False]
    last_exc = None
    for i, stac_flag in enumerate(attempts):
        try:
            return overture_core.geodataframe(overture_type, bbox=bbox, release=release, stac=stac_flag)
        except Exception as e:
            last_exc = e
            if i < len(attempts) - 1:
                print(f"  STAC-accelerated query for '{overture_type}' failed ({e}); "
                      "retrying with a direct dataset scan (--no-stac) ...", file=sys.stderr)
    raise OvertureUnreachableError(
        f"Could not fetch Overture '{overture_type}' data: {last_exc}\n"
        "This reads directly from Overture's public Amazon S3 bucket over HTTPS.\n"
        "Things to check:\n"
        "  1. General internet access / outbound HTTPS to amazonaws.com from this machine.\n"
        "  2. A corporate firewall or proxy blocking S3 access - set HTTPS_PROXY/HTTP_PROXY\n"
        "     env vars if your network requires an explicit proxy.\n"
        "  3. If this is a transient S3/STAC catalog hiccup, simply re-running often helps.\n"
        "  4. Pin a specific --release if the auto-detected latest release has an issue.\n"
    ) from last_exc


def keep_within_radius(gdf, transformer, origin, radius):
    """Filter a GeoDataFrame to features whose geometry is within `radius`
    meters of the origin, in the local projected frame (precise, unlike
    the coarse bbox used for the remote fetch)."""
    if gdf is None or gdf.empty:
        return gdf
    from shapely.geometry import Point as ShapelyPoint
    from shapely.ops import transform as shapely_transform

    origin_pt = ShapelyPoint(0, 0)

    def _proj(x, y, z=None):
        px, py = transformer.transform(x, y)
        return (px - origin[0], py - origin[1])

    keep_mask = []
    for geom in gdf.geometry:
        if geom is None or geom.is_empty:
            keep_mask.append(False)
            continue
        try:
            local_geom = shapely_transform(_proj, geom)
            keep_mask.append(local_geom.distance(origin_pt) <= radius)
        except Exception:
            keep_mask.append(False)
    return gdf[keep_mask]


# ---------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--lat", type=float, required=True, help="Center latitude (WGS84)")
    ap.add_argument("--lon", type=float, required=True, help="Center longitude (WGS84)")
    ap.add_argument("--radius", type=float, default=250.0, help="Radius in meters (default: 250)")

    ap.add_argument("--level-height", type=float, default=3.0, help="Meters per floor when only num_floors is present (default: 3.0)")
    ap.add_argument("--default-height", type=float, default=6.0, help="Fallback height in meters when no height/num_floors is present (default: 6.0)")
    ap.add_argument("--include-parts", action="store_true", help="Also fetch building_part features for finer massing on complex buildings (towers, domes, etc.)")

    ap.add_argument("--trees-source", choices=["none", "osm"], default="none", help="Where to get trees from for more_info.txt. 'osm' fetches OpenStreetMap natural=tree nodes (requires `pip install osmnx` additionally). Default: none (Overture has no tree layer of its own).")
    ap.add_argument("--tree-default-height", type=float, default=10.0, help="Fallback tree height in meters when no height tag exists (only used with --trees-source osm; default: 10.0)")
    ap.add_argument("--overpass-url", default=None, help="Overpass API endpoint to use for --trees-source osm (default: try overpass-api.de, then a couple of public mirrors)")

    ap.add_argument("--ground-padding", type=float, default=0.0, help="Extra meters added to --radius for the Mesh2 ground-rectangle extents (default: 0)")
    ap.add_argument("--no-ground", action="store_true", help="Skip writing the Mesh2 ground-rectangle line in more_info.txt")

    ap.add_argument("--release", default=None, help="Overture release version to use (default: latest, auto-resolved via Overture's STAC catalog)")
    ap.add_argument("--no-stac", action="store_true", help="Skip the STAC-accelerated query and go straight to a direct dataset scan (slower, but immune to a known overturemaps bug where a STAC catalog gap causes a crash instead of an empty result)")
    ap.add_argument("--outdir", default=None, help="Output folder for buildings.obj and more_info.txt (default: derived from lat/lon, e.g. 'site_40.7484_-73.9857')")
    args = ap.parse_args()

    outdir = args.outdir or f"site_{args.lat}_{args.lon}"
    os.makedirs(outdir, exist_ok=True)
    buildings_path = os.path.join(outdir, "buildings.obj")
    info_path = os.path.join(outdir, "more_info.txt")

    transformer, origin = get_projection_and_origin(args.lat, args.lon)

    # ---- Buildings (Overture) ----
    print(f"Fetching Overture buildings within {args.radius} m of ({args.lat}, {args.lon}) ...")
    try:
        buildings_gdf = fetch_overture("building", args.lat, args.lon, args.radius, args.release, use_stac=not args.no_stac)
    except OvertureUnreachableError as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        sys.exit(1)
    buildings_gdf = keep_within_radius(buildings_gdf, transformer, origin, args.radius)

    parts_gdf = None
    parts_failed = False
    if args.include_parts:
        print(f"Fetching Overture building_part features within {args.radius} m ...")
        try:
            parts_gdf = fetch_overture("building_part", args.lat, args.lon, args.radius, args.release, use_stac=not args.no_stac)
        except OvertureUnreachableError as e:
            print(f"\nWARNING: could not fetch building_part features ({e}); "
                  "continuing with buildings only.", file=sys.stderr)
            parts_gdf = None
            parts_failed = True
        else:
            parts_gdf = keep_within_radius(parts_gdf, transformer, origin, args.radius)

    writer = common.ObjWriter()
    n_written = 0

    if buildings_gdf is None or buildings_gdf.empty:
        print("No buildings found in that area.", file=sys.stderr)
    else:
        print(f"Found {len(buildings_gdf)} building features. Extruding...")
        for _, row in buildings_gdf.iterrows():
            geom = row.geometry
            if geom is None or geom.is_empty:
                continue
            # A building with has_parts=true is a coarse envelope, not
            # real massing - when we're also fetching parts, extrude the
            # parts instead of this flat box to avoid doubled volume.
            has_parts = bool(row.get("has_parts")) if row.get("has_parts") is not None else False
            if args.include_parts and not parts_failed and has_parts:
                continue

            base_z, height = building_height_and_base(row, args.level_height, args.default_height)
            for poly in common.iter_polygons(geom):
                ext, holes = polygon_rings(poly, transformer, origin)
                vcount, fcount = len(writer.vertices), len(writer.faces)
                writer.start_group(f"building_{n_written}")
                try:
                    common.add_extruded_polygon(writer, ext, holes, height, base_z)
                    n_written += 1
                except ValueError as e:
                    print(f"  skipping one building: {e}", file=sys.stderr)
                    del writer.vertices[vcount:]
                    del writer.faces[fcount:]
                    writer.groups.pop()

    if parts_gdf is not None and not parts_gdf.empty:
        print(f"Found {len(parts_gdf)} building_part features. Extruding...")
        for _, row in parts_gdf.iterrows():
            geom = row.geometry
            if geom is None or geom.is_empty:
                continue
            base_z, height = building_height_and_base(row, args.level_height, args.default_height)
            for poly in common.iter_polygons(geom):
                ext, holes = polygon_rings(poly, transformer, origin)
                vcount, fcount = len(writer.vertices), len(writer.faces)
                writer.start_group(f"building_part_{n_written}")
                try:
                    common.add_extruded_polygon(writer, ext, holes, height, base_z)
                    n_written += 1
                except ValueError as e:
                    print(f"  skipping one building part: {e}", file=sys.stderr)
                    del writer.vertices[vcount:]
                    del writer.faces[fcount:]
                    writer.groups.pop()

    writer.write(buildings_path, generator="SOLARCHVISION_Overture_3D_in_obj.py")
    print(f"Wrote {n_written} building solids ({len(writer.vertices)} vertices, "
          f"{len(writer.faces)} faces) to {buildings_path}")

    # ---- Trees (optional, from OSM) -> more_info.txt ----
    # Best-effort, like the parts fetch above: a failure here must not
    # discard the buildings.obj already written.
    tree_rows = []
    trees_failed = False
    if args.trees_source == "osm":
        print(f"Fetching OSM trees within {args.radius} m ...")
        overpass_urls = [args.overpass_url] if args.overpass_url else None
        try:
            trees_raw = common.fetch_features(args.lat, args.lon, args.radius, {"natural": "tree"}, overpass_urls)
        except common.OverpassUnreachableError as e:
            print(f"\nWARNING: could not fetch trees ({str(e).splitlines()[0]}); "
                  "continuing with 0 trees. buildings.obj above is unaffected.", file=sys.stderr)
            trees_failed = True
            trees_raw = None
        except ImportError as e:
            print(f"\nWARNING: {e} continuing with 0 trees.", file=sys.stderr)
            trees_failed = True
            trees_raw = None

        if trees_raw is not None and not trees_raw.empty:
            for _, row in trees_raw.iterrows():
                geom = row.geometry
                if geom is None or geom.is_empty or geom.geom_type != "Point":
                    continue
                x, y = project_and_recenter_point(geom.x, geom.y, transformer, origin)
                h = common.feature_height(row.get("height"), args.tree_default_height)
                if not (math.isfinite(x) and math.isfinite(y) and math.isfinite(h)):
                    continue
                tree_rows.append((x, y, 0.0, h))

    ground_radius = args.radius + max(args.ground_padding, 0.0)
    common.write_more_info_txt(info_path, args.lat, args.lon, args.radius, ground_radius,
                                tree_rows, include_ground=not args.no_ground)
    tree_note = f"{len(tree_rows)} trees" if args.trees_source == "osm" else "0 trees (--trees-source none)"
    print(f"Wrote {tree_note}"
          + ("" if args.no_ground else f" and a Mesh2 ground rectangle (radius {ground_radius:.1f} m)")
          + f" to {info_path}")

    if parts_failed or trees_failed:
        sys.exit(1)  # flag the run as partially incomplete, after writing everything we could


if __name__ == "__main__":
    main()
