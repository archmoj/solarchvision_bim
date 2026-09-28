"""
solarch_3d_common.py

Shared code between SOLARCHVISION_OSM_3D_in_obj.py and
SOLARCHVISION_Overture_3D_in_obj.py. Not a standalone tool - imported by
both scripts (Python resolves `import solarch_3d_common` automatically
since it sits next to them in the same directory).

Contains:
  - OBJ writing, polygon triangulation/extrusion (data-source-agnostic)
  - Mesh2 / more_info.txt formatting (data-source-agnostic)
  - OSM height-tag parsing (`height`/`building:levels`-style strings) -
    used for tree heights by both scripts, and for building heights by
    the OSM script
  - Overpass fetch machinery (mirrors, retry, User-Agent-free since
    osmnx sets its own) - used for buildings+trees by the OSM script,
    and optionally for trees by the Overture script
    (--trees-source osm)

Deliberately NOT here (stays script-specific, since the two scripts
project differently - whole-GeoDataFrame via osmnx vs. per-ring via a
raw pyproj Transformer): projection/recentering, and each script's own
building-height-from-schema logic (OSM's building:levels vs Overture's
num_floors/min_height/has_parts).
"""

import math
import re
import sys

import numpy as np

try:
    import mapbox_earcut as earcut
except ImportError:
    print("Missing dependency: mapbox_earcut. Install with `pip install mapbox_earcut`.", file=sys.stderr)
    raise

try:
    from shapely.geometry import Polygon, MultiPolygon
except ImportError:
    print("Missing dependency: shapely. Install with `pip install shapely`.", file=sys.stderr)
    raise

# osmnx is only required if fetch_features() is actually called - the OSM
# script always calls it (hard dependency there), but the Overture script
# only needs it for the optional --trees-source osm path, so this import
# is lazy/soft here rather than raising at module load time.
try:
    import osmnx as ox
    HAS_OSMNX = True
except ImportError:
    HAS_OSMNX = False

try:
    import requests
except ImportError:
    requests = None  # osmnx depends on requests; if this import fails osmnx would have too


# ---------------------------------------------------------------------
# Generic finiteness guard (pandas/GeoDataFrame represents a missing
# column value as float NaN, not None or a KeyError - this must never
# leak into a written vertex coordinate or an extrusion height).
# ---------------------------------------------------------------------

def _finite_positive(x):
    """True only for a real, finite, positive number."""
    return x is not None and isinstance(x, (int, float)) and math.isfinite(x) and x > 0


def _finite(x, default=0.0):
    """x if it's a real finite number, else `default`."""
    if x is not None and isinstance(x, (int, float)) and math.isfinite(x):
        return float(x)
    return default


# ---------------------------------------------------------------------
# OSM height-tag parsing (e.g. "12", "12 m", "12.5m", `12'6"`). Used for
# tree heights by both scripts (trees are always OSM-tag-shaped, however
# they were fetched), and for OSM building heights by the OSM script.
# ---------------------------------------------------------------------

HEIGHT_RE = re.compile(r"[-+]?\d*\.?\d+")


def parse_height_meters(value):
    """Parse an OSM height-like tag value to meters. Returns None if it
    can't be parsed, is missing, or is NaN/inf."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
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
    """Parse a single height-like tag value, falling back to
    default_height. Always returns a finite, positive number."""
    h = parse_height_meters(height_tag_value)
    if _finite_positive(h):
        return h
    if _finite_positive(default_height):
        return default_height
    return 6.0  # last-resort hard fallback, in case a bad CLI value was passed


# ---------------------------------------------------------------------
# Polygon triangulation + extrusion + OBJ writing (data-source-agnostic:
# operates on already-projected/recentered [x, y] rings).
# ---------------------------------------------------------------------

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

    def write(self, path, generator="solarch_3d_common"):
        group_at = {start: name for start, name in self.groups}
        with open(path, "w") as f:
            f.write(f"# Generated by {generator}\n")
            f.write(f"# {len(self.vertices)} vertices, {len(self.faces)} faces\n")
            for x, y, z in self.vertices:
                f.write(f"v {x:.4f} {y:.4f} {z:.4f}\n")
            for i, face in enumerate(self.faces):
                if i in group_at:
                    f.write(f"g {group_at[i]}\n")
                f.write("f " + " ".join(str(v) for v in face) + "\n")


def add_extruded_polygon(writer: ObjWriter, ext, holes, height, base_z=0.0):
    """Extrude a footprint (already-projected/recentered [x, y] rings)
    into a closed 3D solid from z=base_z to z=base_z+height, and append
    it to the ObjWriter."""
    if len(ext) < 3:
        return
    try:
        points2d, tris = triangulate_footprint(ext, holes)
    except Exception:
        return  # skip malformed geometry rather than aborting the whole run
    if len(tris) == 0:
        return

    top_z = base_z + height

    # Bottom vertices (z=base_z) and top vertices (z=top_z), same local xy order
    bottom_start = writer.add_vertex(points2d[0][0], points2d[0][1], base_z)
    for x, y in points2d[1:]:
        writer.add_vertex(x, y, base_z)
    top_start = writer.add_vertex(points2d[0][0], points2d[0][1], top_z)
    for x, y in points2d[1:]:
        writer.add_vertex(x, y, top_z)

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
            writer.add_face((b0, b1, t1))
            writer.add_face((b0, t1, t0))
        offset += m


# ---------------------------------------------------------------------
# buildings.txt: SOLARCHVISION_BIM's own "Mesh" script command
# (app/src/solarchvision_bim/runScript.pde's `case "MESH":`, calling
# Create3D.pde's add_Mesh) natively supports a face with any number of
# vertices - unlike buildings.obj, a hole-free cap here does NOT need
# triangulating: the whole ring becomes one Mesh line. A footprint WITH
# holes (a courtyard) still has to be triangulated for its caps, same as
# the OBJ path - a single n-gon face can't represent an annulus. Walls
# are always a plain quad either way, hole or not.
#
#   Mesh m:7 tes:0 lyr:0 x1,y1,z1 x2,y2,z2 x3,y3,z3 ...
# ---------------------------------------------------------------------

class MeshWriter:
    """Accumulates 'Mesh ...' command lines for buildings.txt."""

    def __init__(self):
        self.lines = []

    def add_face(self, points, m, tes, lyr):
        """points: iterable of (x, y, z), at least 3, in order around the
        face (no closing repeat of the first point)."""
        pts = list(points)
        if len(pts) < 3:
            return
        for x, y, z in pts:
            if not (math.isfinite(x) and math.isfinite(y) and math.isfinite(z)):
                raise ValueError(f"Refusing to write non-finite vertex ({x}, {y}, {z})")
        pts_str = " ".join(f"{x:.4f},{y:.4f},{z:.4f}" for x, y, z in pts)
        self.lines.append(f"Mesh m:{m} tes:{tes} lyr:{lyr} {pts_str}")

    def write(self, path):
        with open(path, "w") as f:
            for line in self.lines:
                f.write(line + "\n")


def add_extruded_mesh(writer: MeshWriter, ext, holes, height, base_z=0.0, m=7, tes=0, lyr=0):
    """Same extruded solid as add_extruded_polygon, but as buildings.txt
    Mesh lines: hole-free caps are one n-gon face each (no triangulation);
    caps with holes are triangulated (see module docstring above)."""
    if len(ext) < 3:
        return
    top_z = base_z + height

    if not holes:
        # Bottom cap: reversed winding, one n-gon face, faces down/outward.
        writer.add_face(((x, y, base_z) for x, y in reversed(ext)), m, tes, lyr)
        # Top cap: natural winding, one n-gon face, faces up.
        writer.add_face(((x, y, top_z) for x, y in ext), m, tes, lyr)
    else:
        try:
            points2d, tris = triangulate_footprint(ext, holes)
        except Exception:
            points2d, tris = None, None
        if points2d is not None and len(tris) > 0:
            for a, b, c in tris:
                xa, ya = points2d[a]
                xb, yb = points2d[b]
                xc, yc = points2d[c]
                # Bottom: reversed winding. Top: natural winding.
                writer.add_face([(xa, ya, base_z), (xc, yc, base_z), (xb, yb, base_z)], m, tes, lyr)
                writer.add_face([(xa, ya, top_z), (xb, yb, top_z), (xc, yc, top_z)], m, tes, lyr)

    # Walls: one quad per edge, for every ring (exterior + holes) - same
    # (b0, b1, t1, t0) corner order as add_extruded_polygon's two wall
    # triangles combined, just kept as one 4-vertex face here.
    for ring in [ext] + list(holes):
        n = len(ring)
        for i in range(n):
            j = (i + 1) % n
            x0, y0 = ring[i]
            x1, y1 = ring[j]
            writer.add_face(
                [(x0, y0, base_z), (x1, y1, base_z), (x1, y1, top_z), (x0, y0, top_z)],
                m, tes, lyr,
            )


def iter_polygons(geom):
    if isinstance(geom, Polygon):
        yield geom
    elif isinstance(geom, MultiPolygon):
        for p in geom.geoms:
            yield p


def polygon_rings_from_shapely_local(poly: Polygon):
    """For a shapely Polygon already in local recentered [x, y] meters
    (no further projection needed): return (ext, holes) as lists of
    (x, y) tuples, with the duplicated closing vertex removed from each
    ring. Used by the OSM script, which projects a whole GeoDataFrame at
    once via osmnx before this point."""
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


# ---------------------------------------------------------------------
# Ground rectangle (Mesh2 line) + more_info.txt writer.
# ---------------------------------------------------------------------

def format_number(v: float) -> str:
    """Format a coordinate as a plain integer when it's a whole number
    (e.g. -250, matching the Mesh2/Tree line examples), else 4 decimals."""
    if math.isfinite(v) and float(v).is_integer():
        return str(int(v))
    return f"{v:.4f}"


def format_mesh2_line(radius: float) -> str:
    """Build the Mesh2 line describing a flat square ground rectangle at
    z=0, spanning [-radius, radius] on both x and y:
        Mesh2 m:3 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
    """
    r = format_number(radius)
    nr = format_number(-radius)
    return f"Mesh2 m:3 tes:6 x1:{nr} y1:{nr} z1:0 x2:{r} y2:{r} z2:0"


def write_more_info_txt(path, lat, lon, radius, ground_radius, trees=(), include_ground=True):
    """trees: iterable of (x, y, z, h), or empty (the Overture script has
    no tree layer unless --trees-source osm is used). Writes:
        # --lat ... --lon ... --radius ...
        Mesh2 m:3 tes:6 x1:... y1:... z1:0 x2:... y2:... z2:0   (if include_ground)
        Tree x:... y:... z:... h:...                            (one per tree, if any)
    """
    with open(path, "w") as f:
        f.write(f"# --lat {lat} --lon {lon} --radius {radius}\n")
        if include_ground:
            f.write(format_mesh2_line(ground_radius) + "\n")
        for x, y, z, h in trees:
            f.write(f"Tree x:{x:.4f} y:{y:.4f} z:{z:.4f} h:{h:.4f}\n")


# ---------------------------------------------------------------------
# Overpass fetch machinery (mirrors + retry). osmnx already sets its own
# descriptive User-Agent automatically (unlike the Node implementation,
# which has to do this explicitly), and already retries 429/504 with a
# pause internally - see ox._overpass._overpass_request. This wrapper
# adds cross-mirror fallback on top of that for connection-level
# failures (refused/timeout/DNS), which osmnx doesn't attempt on its own.
# ---------------------------------------------------------------------

# Public Overpass mirrors tried in order if overpass_urls isn't given and
# the primary instance is unreachable. Not guaranteed to be complete/current
# coverage -- if your organization runs its own instance, pass overpass_urls.
DEFAULT_OVERPASS_MIRRORS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://overpass.private.coffee/api/interpreter",
]


class OverpassUnreachableError(RuntimeError):
    pass


def fetch_features(lat, lon, radius, tags, overpass_urls=None):
    """Fetch raw (unprojected, EPSG:4326) OSM features matching `tags`
    within `radius` meters of (lat, lon), via osmnx. Tries each URL in
    `overpass_urls` in turn (default: DEFAULT_OVERPASS_MIRRORS) and
    raises OverpassUnreachableError with an actionable message if all
    fail to connect."""
    if not HAS_OSMNX:
        raise ImportError(
            "osmnx is required to fetch OSM features. Install with `pip install osmnx`."
        )
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
