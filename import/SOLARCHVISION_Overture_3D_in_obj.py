#!/usr/bin/env python3
"""
SOLARCHVISION_Overture_3D_in_obj.py

Alternative to SOLARCHVISION_OSM_3D_in_obj.py: fetches building massing
from Overture Maps (https://overturemaps.org) instead of OpenStreetMap,
around a given latitude/longitude within a radius, into the same output
folder contract:

    <outdir>/buildings.obj    - buildings, extruded from Overture footprints
    <outdir>/more_info.txt    - a header comment and a ground-rectangle
                                (Mesh2) line (no trees - Overture has no
                                tree layer; see "Trees" below)

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

Trees
-----
Overture has no equivalent of OSM's `natural=tree` layer, so
more_info.txt from this script always has 0 Tree lines. It still gets
the header comment and Mesh2 ground-rectangle line, for the same
downstream import contract as the OSM version.

Requires: overturemaps, geopandas, shapely, mapbox_earcut, pyproj, numpy
    pip install overturemaps geopandas shapely mapbox_earcut pyproj numpy

Example:
    python SOLARCHVISION_Overture_3D_in_obj.py --lat 40.7484 --lon -73.9857 \\
        --radius 250 --outdir empire_state_area_overture
"""

import argparse
import math
import os
import sys

import numpy as np

try:
    import overturemaps.core as overture_core
except ImportError:
    print("Missing dependency: overturemaps. Install with `pip install overturemaps`.", file=sys.stderr)
    raise

try:
    from shapely.geometry import Polygon, MultiPolygon
except ImportError:
    print("Missing dependency: shapely. Install with `pip install shapely`.", file=sys.stderr)
    raise

try:
    import mapbox_earcut as earcut
except ImportError:
    print("Missing dependency: mapbox_earcut. Install with `pip install mapbox_earcut`.", file=sys.stderr)
    raise

try:
    import pyproj
except ImportError:
    print("Missing dependency: pyproj. Install with `pip install pyproj`.", file=sys.stderr)
    raise


# ---------------------------------------------------------------------
# Height/base-z derivation (mirrors the finite/positive guarantees in
# SOLARCHVISION_OSM_3D_in_obj.py: a GeoDataFrame column value that's
# missing comes through as float NaN, not None/NaN must never leak into
# a written vertex coordinate).
# ---------------------------------------------------------------------

def _finite_positive(x):
    return x is not None and isinstance(x, (int, float)) and math.isfinite(x) and x > 0


def _finite(x, default=0.0):
    if x is not None and isinstance(x, (int, float)) and math.isfinite(x):
        return float(x)
    return default


def building_height_and_base(props, level_height, default_height):
    """Work out a building/part's (base_z, height) in meters from its
    Overture properties. Always returns finite numbers, with height > 0."""
    height = props.get("height")
    if not _finite_positive(height):
        num_floors = props.get("num_floors")
        if _finite_positive(num_floors):
            height = num_floors * level_height
        else:
            height = None

    if not _finite_positive(height):
        height = default_height if _finite_positive(default_height) else 6.0

    base_z = _finite(props.get("min_height"), default=0.0)
    if base_z < 0:
        base_z = 0.0
    return base_z, height


# ---------------------------------------------------------------------
# Projection: one local UTM CRS for the whole run, auto-selected from
# the query point (same convention as SOLARCHVISION_OSM_3D_in_obj.py).
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


def project_and_recenter_ring(ring_coords, transformer, origin):
    """ring_coords: iterable of (lon, lat). Returns [(x, y), ...] recentered
    on origin, with the closing duplicate point removed."""
    xs, ys = transformer.transform([c[0] for c in ring_coords], [c[1] for c in ring_coords])
    pts = [(x - origin[0], y - origin[1]) for x, y in zip(xs, ys)]
    if len(pts) > 1 and pts[0] == pts[-1]:
        pts.pop()
    return pts


# ---------------------------------------------------------------------
# Polygon triangulation + extrusion (same approach as
# SOLARCHVISION_OSM_3D_in_obj.py, generalized with a base_z offset to
# support Overture's min_height for "floating" building parts).
# ---------------------------------------------------------------------

def polygon_rings(poly: Polygon, transformer, origin):
    ext = project_and_recenter_ring(list(poly.exterior.coords), transformer, origin)
    holes = []
    for interior in poly.interiors:
        ring = project_and_recenter_ring(list(interior.coords), transformer, origin)
        if len(ring) >= 3:
            holes.append(ring)
    return ext, holes


def triangulate_footprint(ext, holes):
    rings = [ext] + holes
    points = np.array([pt for ring in rings for pt in ring], dtype=np.float64)
    ring_end_counts = np.cumsum([len(r) for r in rings]).astype(np.uint32)
    tri_flat = earcut.triangulate_float64(points, ring_end_counts)
    tris = np.asarray(tri_flat, dtype=np.uint32).reshape(-1, 3)
    return points, tris


class ObjWriter:
    def __init__(self):
        self.vertices = []
        self.faces = []
        self.groups = []

    def add_vertex(self, x, y, z):
        if not (math.isfinite(x) and math.isfinite(y) and math.isfinite(z)):
            raise ValueError(f"Refusing to write non-finite vertex ({x}, {y}, {z})")
        self.vertices.append((x, y, z))
        return len(self.vertices)

    def add_face(self, idxs):
        self.faces.append(tuple(idxs))

    def start_group(self, name):
        self.groups.append((len(self.faces), name))

    def write(self, path):
        group_at = {start: name for start, name in self.groups}
        with open(path, "w") as f:
            f.write("# Generated by SOLARCHVISION_Overture_3D_in_obj.py\n")
            f.write(f"# {len(self.vertices)} vertices, {len(self.faces)} faces\n")
            for x, y, z in self.vertices:
                f.write(f"v {x:.4f} {y:.4f} {z:.4f}\n")
            for i, face in enumerate(self.faces):
                if i in group_at:
                    f.write(f"g {group_at[i]}\n")
                f.write("f " + " ".join(str(v) for v in face) + "\n")


def add_extruded_polygon(writer: ObjWriter, ext, holes, height, base_z=0.0):
    """Extrude a footprint (already projected/recentered [x,y] rings) into
    a closed 3D solid from z=base_z to z=base_z+height, and append it to
    the ObjWriter."""
    if len(ext) < 3:
        return
    try:
        points2d, tris = triangulate_footprint(ext, holes)
    except Exception:
        return
    if len(tris) == 0:
        return

    n = len(points2d)
    top_z = base_z + height

    bottom_start = writer.add_vertex(points2d[0][0], points2d[0][1], base_z)
    for x, y in points2d[1:]:
        writer.add_vertex(x, y, base_z)
    top_start = writer.add_vertex(points2d[0][0], points2d[0][1], top_z)
    for x, y in points2d[1:]:
        writer.add_vertex(x, y, top_z)

    for a, b, c in tris:
        writer.add_face((bottom_start + a, bottom_start + c, bottom_start + b))
    for a, b, c in tris:
        writer.add_face((top_start + a, top_start + b, top_start + c))

    offset = 0
    for ring in [ext] + holes:
        m = len(ring)
        for i in range(m):
            j = (i + 1) % m
            b0, b1 = bottom_start + offset + i, bottom_start + offset + j
            t0, t1 = top_start + offset + i, top_start + offset + j
            writer.add_face((b0, b1, t1))
            writer.add_face((b0, t1, t0))
        offset += m


def iter_polygons(geom):
    if isinstance(geom, Polygon):
        yield geom
    elif isinstance(geom, MultiPolygon):
        for p in geom.geoms:
            yield p


# ---------------------------------------------------------------------
# Ground rectangle (Mesh2 line) + more_info.txt writer - identical format
# to SOLARCHVISION_OSM_3D_in_obj.py, minus the tree lines.
# ---------------------------------------------------------------------

def format_number(v):
    if math.isfinite(v) and float(v).is_integer():
        return str(int(v))
    return f"{v:.4f}"


def format_mesh2_line(radius):
    r = format_number(radius)
    nr = format_number(-radius)
    return f"Mesh2 m:3 tes:6 x1:{nr} y1:{nr} z1:0 x2:{r} y2:{r} z2:0"


def write_more_info_txt(path, lat, lon, radius, ground_radius, include_ground=True):
    with open(path, "w") as f:
        f.write(f"# --lat {lat} --lon {lon} --radius {radius}\n")
        if include_ground:
            f.write(format_mesh2_line(ground_radius) + "\n")
        # No Tree lines: Overture has no tree/vegetation layer.


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

    writer = ObjWriter()
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
            for poly in iter_polygons(geom):
                ext, holes = polygon_rings(poly, transformer, origin)
                vcount, fcount = len(writer.vertices), len(writer.faces)
                writer.start_group(f"building_{n_written}")
                try:
                    add_extruded_polygon(writer, ext, holes, height, base_z)
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
            for poly in iter_polygons(geom):
                ext, holes = polygon_rings(poly, transformer, origin)
                vcount, fcount = len(writer.vertices), len(writer.faces)
                writer.start_group(f"building_part_{n_written}")
                try:
                    add_extruded_polygon(writer, ext, holes, height, base_z)
                    n_written += 1
                except ValueError as e:
                    print(f"  skipping one building part: {e}", file=sys.stderr)
                    del writer.vertices[vcount:]
                    del writer.faces[fcount:]
                    writer.groups.pop()

    writer.write(buildings_path)
    print(f"Wrote {n_written} building solids ({len(writer.vertices)} vertices, "
          f"{len(writer.faces)} faces) to {buildings_path}")

    ground_radius = args.radius + max(args.ground_padding, 0.0)
    write_more_info_txt(info_path, args.lat, args.lon, args.radius, ground_radius,
                         include_ground=not args.no_ground)
    print(f"Wrote more_info.txt (0 trees - Overture has no tree layer"
          + ("" if args.no_ground else f"; Mesh2 ground rectangle radius {ground_radius:.1f} m")
          + f") to {info_path}")

    if parts_failed:
        sys.exit(1)  # flag the run as partially incomplete, after writing everything we could


if __name__ == "__main__":
    main()
