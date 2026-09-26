#!/usr/bin/env python3
"""
SOLARCHVISION_OSM_3D_in_obj.py

Fetch a small 3D city-massing kit from OpenStreetMap around a given
latitude/longitude within a radius, written into one output folder:

    <outdir>/buildings.obj    - buildings, extruded from OSM footprints
    <outdir>/more_info.txt    - a header comment, a ground-rectangle
                                (Mesh2) line, then trees as plain-text
                                point+height entries

Buildings are extruded up to a height derived from (in priority order):
    1. the `height` tag (meters, tolerant of "12", "12 m", "12m")
    2. the `building:levels` tag * --level-height (default 3.0 m)
    3. --default-height (default 6.0 m)

Trees (OSM `natural=tree` nodes) get a height from their own `height` tag,
falling back to --tree-default-height (default 10.0 m).

more_info.txt looks like:

    # --lat 40.7484 --lon -73.9857 --radius 250
    Mesh2 m:8 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
    Tree x:-20.0000 y:-10.0000 z:0.0000 h:10.0000
    Tree x:20.0000 y:10.0000 z:0.0000 h:20.0000

The Mesh2 line describes a flat square ground rectangle (no thickness)
spanning the query radius (plus --ground-padding, if any), diagonally
from (x1, y1) to (x2, y2) at z=0, for the buildings/trees to sit on.

All outputs share one coordinate frame: meters, local/projected,
origin (0, 0) at the query lat/lon, z=0 at ground level.

Requires: osmnx, shapely, numpy, mapbox_earcut, pyproj
    pip install osmnx shapely mapbox_earcut pyproj numpy

If the Overpass fetch fails with a connection error (e.g. "Connection
refused" to overpass-api.de), that's a network reachability problem on
your machine (firewall, proxy, DNS, or no internet), not a bug in this
script -- see the printed diagnostic for things to check. --overpass-url
lets you point at a different Overpass instance (self-hosted, a mirror,
or one reachable through your proxy); by default the script also tries
a couple of public mirrors automatically if the primary one fails.

Example:
    python SOLARCHVISION_OSM_3D_in_obj.py --lat 40.7484 --lon -73.9857 \\
        --radius 250 --outdir empire_state_area
"""

import argparse
import math
import os
import re
import sys

import numpy as np

try:
    import osmnx as ox
except ImportError:
    print("Missing dependency: osmnx. Install with `pip install osmnx`.", file=sys.stderr)
    raise

try:
    import requests
except ImportError:
    requests = None  # osmnx depends on requests; if this import fails osmnx would have too

try:
    from shapely.geometry import Polygon, MultiPolygon, Point
except ImportError:
    print("Missing dependency: shapely. Install with `pip install shapely`.", file=sys.stderr)
    raise

try:
    import mapbox_earcut as earcut
except ImportError:
    print("Missing dependency: mapbox_earcut. Install with `pip install mapbox_earcut`.", file=sys.stderr)
    raise


# Public Overpass mirrors tried in order if --overpass-url isn't given and
# the primary instance is unreachable. Not guaranteed to be complete/current
# coverage -- if your organization runs its own instance, use --overpass-url.
DEFAULT_OVERPASS_MIRRORS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
]


HEIGHT_RE = re.compile(r"[-+]?\d*\.?\d+")


def _finite_positive(x):
    """True only for a real, finite, positive number. Filters out None, NaN
    (pandas represents missing tag values as float NaN, not None) and inf."""
    return x is not None and isinstance(x, (int, float)) and math.isfinite(x) and x > 0


def parse_height_meters(value):
    """Parse an OSM height-like tag value (e.g. '12', '12 m', '12.5m', "12'") to meters.
    Returns None if it can't be parsed, is missing, or is NaN/inf."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
        # pandas/GeoDataFrame represents a missing tag as float('nan'), not None
        if not math.isfinite(value):
            return None
        return float(value)
    s = str(value).strip()
    if not s or s.lower() == "nan":
        return None
    # feet/inches like 12'6" -> treat as feet, rough conversion
    if "'" in s:
        m = HEIGHT_RE.findall(s)
        if m:
            feet = float(m[0])
            return feet * 0.3048
    m = HEIGHT_RE.search(s)
    if not m:
        return None
    return float(m.group())


def feature_height(height_tag_value, default_height):
    """Parse a single height-like tag value, falling back to default_height.
    Always returns a finite, positive number."""
    h = parse_height_meters(height_tag_value)
    if _finite_positive(h):
        return h
    if _finite_positive(default_height):
        return default_height
    return 6.0  # last-resort hard fallback, in case a bad CLI value was passed


def building_height(tags, level_height, default_height):
    """Work out a building's extrusion height in meters from its OSM tags.
    Always returns a finite, positive number (never NaN/None/<=0)."""
    h = parse_height_meters(tags.get("height"))
    if _finite_positive(h):
        return h

    lv = parse_height_meters(tags.get("building:levels"))
    if _finite_positive(lv):
        roof_levels = parse_height_meters(tags.get("roof:levels"))
        if not _finite_positive(roof_levels):
            roof_levels = 0.0
        total = (lv + roof_levels) * level_height
        if _finite_positive(total):
            return total

    if _finite_positive(default_height):
        return default_height
    return 6.0  # last-resort hard fallback, in case a bad CLI value was passed


def polygon_rings(poly: Polygon):
    """Return (exterior_coords, [hole_coords, ...]) as lists of (x, y) tuples,
    with the duplicated closing vertex removed from each ring."""
    ext = list(poly.exterior.coords)
    if ext[0] == ext[-1]:
        ext = ext[:-1]
    holes = []
    for interior in poly.interiors:
        ring = list(interior.coords)
        if ring[0] == ring[-1]:
            ring = ring[:-1]
        if len(ring) >= 3:
            holes.append(ring)
    return ext, holes


def triangulate_footprint(ext, holes):
    """Triangulate a polygon (with optional holes) using earcut.
    Returns (points Nx2 array, triangle_indices Mx3 array) where indices
    reference rows of `points`."""
    rings = [ext] + holes
    points = np.array([pt for ring in rings for pt in ring], dtype=np.float64)
    ring_end_counts = np.cumsum([len(r) for r in rings]).astype(np.uint32)
    tri_flat = earcut.triangulate_float64(points, ring_end_counts)
    tris = np.asarray(tri_flat, dtype=np.uint32).reshape(-1, 3)
    return points, tris


class ObjWriter:
    """Accumulates vertices/faces and writes a Wavefront .obj file.
    OBJ indices are 1-based."""

    def __init__(self):
        self.vertices = []  # list of (x, y, z)
        self.faces = []     # list of tuples of 1-based vertex indices
        self.groups = []    # list of (face_start_index, group_name)

    def add_vertex(self, x, y, z):
        if not (math.isfinite(x) and math.isfinite(y) and math.isfinite(z)):
            raise ValueError(f"Refusing to write non-finite vertex ({x}, {y}, {z})")
        self.vertices.append((x, y, z))
        return len(self.vertices)  # 1-based index of the vertex just added

    def add_face(self, idxs):
        """idxs: iterable of 1-based vertex indices, in order (CCW for outward normal)."""
        self.faces.append(tuple(idxs))

    def start_group(self, name):
        self.groups.append((len(self.faces), name))

    def write(self, path):
        group_at = {start: name for start, name in self.groups}
        with open(path, "w") as f:
            f.write("# Generated by SOLARCHVISION_OSM_3D_in_obj.py\n")
            f.write(f"# {len(self.vertices)} vertices, {len(self.faces)} faces\n")
            for x, y, z in self.vertices:
                f.write(f"v {x:.4f} {y:.4f} {z:.4f}\n")
            for i, face in enumerate(self.faces):
                if i in group_at:
                    f.write(f"g {group_at[i]}\n")
                f.write("f " + " ".join(str(v) for v in face) + "\n")


def add_extruded_polygon(writer: ObjWriter, poly: Polygon, height: float):
    """Extrude a single (possibly holed) 2D footprint polygon into a closed
    3D solid (bottom cap at z=0, top cap at z=height, walls in between) and
    append it to the ObjWriter."""
    ext, holes = polygon_rings(poly)
    if len(ext) < 3:
        return

    try:
        points2d, tris = triangulate_footprint(ext, holes)
    except Exception:
        return  # skip malformed geometry rather than aborting the whole run
    if len(tris) == 0:
        return

    n = len(points2d)

    # Bottom vertices (z=0) and top vertices (z=height), same local xy order
    bottom_start = writer.add_vertex(points2d[0][0], points2d[0][1], 0.0)
    for x, y in points2d[1:]:
        writer.add_vertex(x, y, 0.0)
    top_start = writer.add_vertex(points2d[0][0], points2d[0][1], height)
    for x, y in points2d[1:]:
        writer.add_vertex(x, y, height)

    # Bottom cap: reverse winding so the normal points down/outward
    for a, b, c in tris:
        writer.add_face((bottom_start + a, bottom_start + c, bottom_start + b))

    # Top cap: original winding faces up
    for a, b, c in tris:
        writer.add_face((top_start + a, top_start + b, top_start + c))

    # Walls: one quad (as 2 triangles) per edge of every ring (exterior + holes)
    offset = 0
    for ring in [ext] + holes:
        m = len(ring)
        for i in range(m):
            j = (i + 1) % m
            b0, b1 = bottom_start + offset + i, bottom_start + offset + j
            t0, t1 = top_start + offset + i, top_start + offset + j
            # two triangles per wall quad, wound outward
            writer.add_face((b0, b1, t1))
            writer.add_face((b0, t1, t0))
        offset += m


def format_number(v: float) -> str:
    """Format a coordinate as a plain integer when it's a whole number
    (e.g. -250, matching the Mesh2/Tree line examples), else 4 decimals."""
    if math.isfinite(v) and float(v).is_integer():
        return str(int(v))
    return f"{v:.4f}"


def format_mesh2_line(radius: float) -> str:
    """Build the Mesh2 line describing a flat square ground rectangle at
    z=0, spanning [-radius, radius] on both x and y:
        Mesh2 m:8 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
    """
    r = format_number(radius)
    nr = format_number(-radius)
    return f"Mesh2 m:8 tes:6 x1:{nr} y1:{nr} z1:0 x2:{r} y2:{r} z2:0"


def iter_polygons(geom):
    if isinstance(geom, Polygon):
        yield geom
    elif isinstance(geom, MultiPolygon):
        for p in geom.geoms:
            yield p


class OverpassUnreachableError(RuntimeError):
    pass


def fetch_features(lat, lon, radius, tags, overpass_urls=None):
    """Fetch raw (unprojected, EPSG:4326) OSM features matching `tags`
    within `radius` meters of (lat, lon). Tries each URL in `overpass_urls`
    in turn (default: DEFAULT_OVERPASS_MIRRORS) and raises
    OverpassUnreachableError with an actionable message if all fail to
    connect."""
    urls = overpass_urls or DEFAULT_OVERPASS_MIRRORS
    last_exc = None
    for i, url in enumerate(urls):
        ox.settings.overpass_url = url
        try:
            return ox.features.features_from_point((lat, lon), tags=tags, dist=radius)
        except Exception as e:
            is_connection_issue = (
                (requests is not None and isinstance(e, requests.exceptions.ConnectionError))
                or "Connection refused" in str(e)
                or "Failed to establish a new connection" in str(e)
                or "Max retries exceeded" in str(e)
            )
            if not is_connection_issue:
                raise  # a real query/data error -- don't mask it by trying other mirrors
            last_exc = e
            if i < len(urls) - 1:
                print(f"  could not reach {url} ({e.__class__.__name__}); trying another mirror ...", file=sys.stderr)

    raise OverpassUnreachableError(
        "Could not reach any Overpass API endpoint "
        f"({', '.join(urls)}).\n"
        "This is a network reachability problem on this machine, not a bug in the "
        "script. Things to check:\n"
        "  1. General internet access: `curl -v https://overpass-api.de/api/interpreter`\n"
        "     from this same machine/shell.\n"
        "  2. A corporate firewall or proxy blocking outbound HTTPS to overpass-api.de\n"
        "     and the mirrors above -- if you're behind a proxy, set HTTPS_PROXY/HTTP_PROXY\n"
        "     env vars (or the equivalent for your org's proxy) before running this script.\n"
        "  3. DNS or /etc/hosts overrides pointing these hostnames somewhere unexpected.\n"
        "  4. If your organization runs a private/self-hosted Overpass instance, or you\n"
        "     know of a reachable mirror, pass it explicitly: --overpass-url <url>\n"
    ) from last_exc


def get_projection_crs_and_origin(lat, lon):
    """Pick one local projected CRS (auto-selected UTM zone) for the whole
    run, and the projected (x, y) of the query point in that CRS, so every
    layer (buildings, trees, ground) can be recentered on the same origin."""
    proj_pt, crs = ox.projection.project_geometry(Point(lon, lat))
    return crs, (proj_pt.x, proj_pt.y)


def project_and_recenter_gdf(gdf, crs, origin):
    """Project a features GeoDataFrame into `crs` and shift its geometries
    so the query point sits at local (0, 0)."""
    if gdf.empty:
        return gdf
    gdf_proj = ox.projection.project_gdf(gdf, to_crs=crs)
    ox_x, oy_y = origin
    gdf_proj = gdf_proj.copy()
    gdf_proj["geometry"] = gdf_proj["geometry"].translate(xoff=-ox_x, yoff=-oy_y)
    return gdf_proj


def write_more_info_txt(path, lat, lon, radius, ground_radius, trees, include_ground=True):
    """trees: iterable of (x, y, z, h). Writes more_info.txt:
        # --lat ... --lon ... --radius ...
        Mesh2 m:8 tes:6 x1:... y1:... z1:0 x2:... y2:... z2:0   (if include_ground)
        Tree x:... y:... z:... h:...
        ...
    """
    with open(path, "w") as f:
        f.write(f"# --lat {lat} --lon {lon} --radius {radius}\n")
        if include_ground:
            f.write(format_mesh2_line(ground_radius) + "\n")
        for x, y, z, h in trees:
            f.write(f"Tree x:{x:.4f} y:{y:.4f} z:{z:.4f} h:{h:.4f}\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--lat", type=float, required=True, help="Center latitude (WGS84)")
    ap.add_argument("--lon", type=float, required=True, help="Center longitude (WGS84)")
    ap.add_argument("--radius", type=float, default=250.0, help="Radius in meters (default: 250)")

    ap.add_argument("--level-height", type=float, default=3.0, help="Meters per building level when no explicit height tag exists (default: 3.0)")
    ap.add_argument("--default-height", type=float, default=6.0, help="Fallback building height in meters when no height/levels tags exist (default: 6.0)")
    ap.add_argument("--include-parts", action="store_true", help="Also include building:part features (finer massing for complex buildings)")

    ap.add_argument("--tree-default-height", type=float, default=10.0, help="Fallback tree height in meters when no height tag exists (default: 10.0)")
    ap.add_argument("--no-trees", action="store_true", help="Skip fetching/writing the tree layer in more_info.txt")

    ap.add_argument("--ground-padding", type=float, default=0.0, help="Extra meters added to --radius for the Mesh2 ground-rectangle extents in more_info.txt (default: 0)")
    ap.add_argument("--no-ground", action="store_true", help="Skip writing the Mesh2 ground-rectangle line in more_info.txt")

    ap.add_argument("--outdir", default=None, help="Output folder for buildings.obj and more_info.txt (default: derived from lat/lon, e.g. 'site_40.7484_-73.9857')")
    ap.add_argument("--overpass-url", default=None, help="Overpass API endpoint to use (e.g. a self-hosted instance, or one reachable through your proxy). Default: try overpass-api.de, then a couple of public mirrors.")
    args = ap.parse_args()

    overpass_urls = [args.overpass_url] if args.overpass_url else None

    outdir = args.outdir or f"site_{args.lat}_{args.lon}"
    os.makedirs(outdir, exist_ok=True)
    buildings_path = os.path.join(outdir, "buildings.obj")
    info_path = os.path.join(outdir, "more_info.txt")

    crs, origin = get_projection_crs_and_origin(args.lat, args.lon)

    # ---- Buildings ----
    print(f"Fetching OSM buildings within {args.radius} m of ({args.lat}, {args.lon}) ...")
    building_tags = {"building": True}
    if args.include_parts:
        building_tags["building:part"] = True
    try:
        buildings_raw = fetch_features(args.lat, args.lon, args.radius, building_tags, overpass_urls)
    except OverpassUnreachableError as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        sys.exit(1)
    buildings = project_and_recenter_gdf(buildings_raw, crs, origin)

    writer = ObjWriter()
    n_written = 0
    if buildings.empty:
        print("No buildings found in that area.", file=sys.stderr)
    else:
        print(f"Found {len(buildings)} building features. Extruding...")
        for _, row in buildings.iterrows():
            geom = row.geometry
            if geom is None or geom.is_empty:
                continue
            height = building_height(row, args.level_height, args.default_height)

            for poly in iter_polygons(geom):
                vcount, fcount = len(writer.vertices), len(writer.faces)
                writer.start_group(f"building_{n_written}")
                try:
                    add_extruded_polygon(writer, poly, height)
                    n_written += 1
                except ValueError as e:
                    # Non-finite vertex (should not happen after the height
                    # sanitization above, but guard against bad geometry too).
                    print(f"  skipping one building: {e}", file=sys.stderr)
                    del writer.vertices[vcount:]
                    del writer.faces[fcount:]
                    writer.groups.pop()

    writer.write(buildings_path)
    print(f"Wrote {n_written} building solids ({len(writer.vertices)} vertices, "
          f"{len(writer.faces)} faces) to {buildings_path}")

    # ---- Trees -> more_info.txt ----
    tree_rows = []
    if not args.no_trees:
        print(f"Fetching OSM trees within {args.radius} m ...")
        try:
            trees_raw = fetch_features(args.lat, args.lon, args.radius, {"natural": "tree"}, overpass_urls)
        except OverpassUnreachableError as e:
            print(f"\nERROR: {e}", file=sys.stderr)
            sys.exit(1)
        trees = project_and_recenter_gdf(trees_raw, crs, origin)

        if not trees.empty:
            for _, row in trees.iterrows():
                geom = row.geometry
                if geom is None or geom.is_empty or geom.geom_type != "Point":
                    continue
                h = feature_height(row.get("height"), args.tree_default_height)
                x, y = geom.x, geom.y
                if not (math.isfinite(x) and math.isfinite(y) and math.isfinite(h)):
                    continue
                tree_rows.append((x, y, 0.0, h))

    ground_radius = args.radius + max(args.ground_padding, 0.0)
    write_more_info_txt(info_path, args.lat, args.lon, args.radius, ground_radius,
                         tree_rows, include_ground=not args.no_ground)
    print(f"Wrote {len(tree_rows)} trees"
          + ("" if args.no_ground else f" and a Mesh2 ground rectangle (radius {ground_radius:.1f} m)")
          + f" to {info_path}")


if __name__ == "__main__":
    main()
