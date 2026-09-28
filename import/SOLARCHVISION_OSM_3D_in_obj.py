#!/usr/bin/env python3
"""
SOLARCHVISION_OSM_3D_in_obj.py

Fetch a small 3D city-massing kit from OpenStreetMap around a given
latitude/longitude within a radius, written into one output folder:

    <outdir>/buildings.obj    - buildings, extruded from OSM footprints,
                                triangulated (for tools that need triangles)
    <outdir>/buildings.txt    - the same buildings as SOLARCHVISION_BIM's
                                own "Mesh" script command (see below) -
                                hole-free caps are a single n-gon face
                                each, not triangulated
    <outdir>/more_info.txt    - a header comment, a ground-rectangle
                                (Mesh2) line, then trees as plain-text
                                point+height entries

Buildings are extruded up to a height derived from (in priority order):
    1. the `height` tag (meters, tolerant of "12", "12 m", "12m")
    2. the `building:levels` tag * --level-height (default 3.0 m)
    3. --default-height (default 6.0 m)

Trees (OSM `natural=tree` nodes) get a height from their own `height` tag,
falling back to --tree-default-height (default 10.0 m).

buildings.txt (SOLARCHVISION_BIM's `Mesh` script command; see
app/src/solarchvision_bim/runScript.pde's `case "MESH":`, which calls
Create3D.pde's add_Mesh) looks like:

    Mesh m:7 tes:0 lyr:0 -20.0000,-10.0000,0.0000 20.0000,-10.0000,0.0000 20.0000,10.0000,0.0000 -20.0000,10.0000,0.0000
    ...

One line per flat face (bottom cap, top cap, and one per wall). Unlike
buildings.obj, SOLARCHVISION_BIM's own face model natively supports more
than 3 vertices per face, so a hole-free footprint's cap is written as a
single face with its full vertex list - no triangulation needed. A
footprint with holes (a courtyard) still gets its caps triangulated
(the same way buildings.obj does): a single n-gon face can't represent
an annulus. Walls are always a plain 4-vertex quad either way.

more_info.txt looks like:

    # --lat 40.7484 --lon -73.9857 --radius 250
    Mesh2 m:3 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
    Tree x:-20.0000 y:-10.0000 z:0.0000 h:10.0000
    Tree x:20.0000 y:10.0000 z:0.0000 h:20.0000

The Mesh2 line describes a flat square ground rectangle (no thickness)
spanning the query radius (plus --ground-padding, if any), diagonally
from (x1, y1) to (x2, y2) at z=0, for the buildings/trees to sit on.

All outputs share one coordinate frame: meters, local/projected,
origin (0, 0) at the query lat/lon, z=0 at ground level.

Requires: osmnx, shapely, numpy, mapbox_earcut, pyproj
    pip install osmnx shapely mapbox_earcut pyproj numpy
(solarch_3d_common.py must sit alongside this script - it holds code
shared with SOLARCHVISION_Overture_3D_in_obj.py.)

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
import sys

try:
    import osmnx as ox
except ImportError:
    print("Missing dependency: osmnx. Install with `pip install osmnx`.", file=sys.stderr)
    raise

try:
    from shapely.geometry import Polygon, MultiPolygon, Point
except ImportError:
    print("Missing dependency: shapely. Install with `pip install shapely`.", file=sys.stderr)
    raise

try:
    import solarch_3d_common as common
except ImportError:
    print("Missing file: solarch_3d_common.py must sit alongside this script.", file=sys.stderr)
    raise


# ---------------------------------------------------------------------
# OSM-specific building height derivation (uses `height`/`building:levels`/
# `roof:levels` tags; tree heights instead use common.feature_height,
# since trees have no levels concept).
# ---------------------------------------------------------------------

def building_height(tags, level_height, default_height):
    """Work out a building's extrusion height in meters from its OSM tags.
    Always returns a finite, positive number (never NaN/None/<=0)."""
    h = common.parse_height_meters(tags.get("height"))
    if common._finite_positive(h):
        return h

    lv = common.parse_height_meters(tags.get("building:levels"))
    if common._finite_positive(lv):
        roof_levels = common.parse_height_meters(tags.get("roof:levels"))
        if not common._finite_positive(roof_levels):
            roof_levels = 0.0
        total = (lv + roof_levels) * level_height
        if common._finite_positive(total):
            return total

    if common._finite_positive(default_height):
        return default_height
    return 6.0  # last-resort hard fallback, in case a bad CLI value was passed


# ---------------------------------------------------------------------
# Projection: one local UTM CRS for the whole run (auto-selected via
# osmnx, which projects a whole GeoDataFrame at once - different data
# shape from the Overture script's per-ring pyproj approach, so this
# stays here rather than in the shared module).
# ---------------------------------------------------------------------

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


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--lat", type=float, required=True, help="Center latitude (WGS84)")
    ap.add_argument("--lon", type=float, required=True, help="Center longitude (WGS84)")
    ap.add_argument("--radius", type=float, default=250.0, help="Radius in meters (default: 250)")

    ap.add_argument("--level-height", type=float, default=3.0, help="Meters per building level when no explicit height tag exists (default: 3.0)")
    ap.add_argument("--default-height", type=float, default=6.0, help="Fallback building height in meters when no height/levels tags exist (default: 6.0)")
    ap.add_argument("--include-parts", action="store_true", help="Also include building:part features (finer massing for complex buildings)")

    ap.add_argument("--material", type=int, default=7, help="Material index (m:) for buildings.txt Mesh lines (default: 7)")
    ap.add_argument("--tessellation", type=int, default=0, help="Tessellation index (tes:) for buildings.txt Mesh lines (default: 0)")
    ap.add_argument("--layer", type=int, default=0, help="Layer index (lyr:) for buildings.txt Mesh lines (default: 0)")
    ap.add_argument("--no-buildings-txt", action="store_true", help="Skip writing buildings.txt (the SOLARCHVISION_BIM Mesh-command form)")

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
    buildings_txt_path = os.path.join(outdir, "buildings.txt")
    info_path = os.path.join(outdir, "more_info.txt")

    crs, origin = get_projection_crs_and_origin(args.lat, args.lon)

    # ---- Buildings ----
    print(f"Fetching OSM buildings within {args.radius} m of ({args.lat}, {args.lon}) ...")
    building_tags = {"building": True}
    if args.include_parts:
        building_tags["building:part"] = True
    try:
        buildings_raw = common.fetch_features(args.lat, args.lon, args.radius, building_tags, overpass_urls)
    except common.OverpassUnreachableError as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        sys.exit(1)
    buildings = project_and_recenter_gdf(buildings_raw, crs, origin)

    writer = common.ObjWriter()
    mesh_writer = common.MeshWriter()
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

            for poly in common.iter_polygons(geom):
                ext, holes = common.polygon_rings_from_shapely_local(poly)
                vcount, fcount = len(writer.vertices), len(writer.faces)
                mcount = len(mesh_writer.lines)
                writer.start_group(f"building_{n_written}")
                try:
                    common.add_extruded_polygon(writer, ext, holes, height)
                    if not args.no_buildings_txt:
                        common.add_extruded_mesh(mesh_writer, ext, holes, height,
                                                  m=args.material, tes=args.tessellation, lyr=args.layer)
                    n_written += 1
                except ValueError as e:
                    # Non-finite vertex (should not happen after the height
                    # sanitization above, but guard against bad geometry too).
                    print(f"  skipping one building: {e}", file=sys.stderr)
                    del writer.vertices[vcount:]
                    del writer.faces[fcount:]
                    del mesh_writer.lines[mcount:]
                    writer.groups.pop()

    writer.write(buildings_path, generator="SOLARCHVISION_OSM_3D_in_obj.py")
    print(f"Wrote {n_written} building solids ({len(writer.vertices)} vertices, "
          f"{len(writer.faces)} faces) to {buildings_path}")

    if not args.no_buildings_txt:
        mesh_writer.write(buildings_txt_path)
        print(f"Wrote {len(mesh_writer.lines)} Mesh faces to {buildings_txt_path}")

    # ---- Trees -> more_info.txt ----
    # Trees are a best-effort supplementary layer: if this fetch fails, we
    # still want to keep the buildings.obj already written above and finish
    # writing more_info.txt (with zero trees) rather than aborting the run.
    tree_rows = []
    trees_failed = False
    if not args.no_trees:
        print(f"Fetching OSM trees within {args.radius} m ...")
        try:
            trees_raw = common.fetch_features(args.lat, args.lon, args.radius, {"natural": "tree"}, overpass_urls)
        except common.OverpassUnreachableError as e:
            print(f"\nWARNING: could not fetch trees ({str(e).splitlines()[0]}); "
                  "continuing with 0 trees. buildings.obj above is unaffected.", file=sys.stderr)
            trees_failed = True
            trees_raw = None

        trees = project_and_recenter_gdf(trees_raw, crs, origin) if trees_raw is not None else None
        if trees is not None and not trees.empty:
            for _, row in trees.iterrows():
                geom = row.geometry
                if geom is None or geom.is_empty or geom.geom_type != "Point":
                    continue
                h = common.feature_height(row.get("height"), args.tree_default_height)
                x, y = geom.x, geom.y
                if not (math.isfinite(x) and math.isfinite(y) and math.isfinite(h)):
                    continue
                tree_rows.append((x, y, 0.0, h))

    ground_radius = args.radius + max(args.ground_padding, 0.0)
    common.write_more_info_txt(info_path, args.lat, args.lon, args.radius, ground_radius,
                                tree_rows, include_ground=not args.no_ground)
    print(f"Wrote {len(tree_rows)} trees"
          + ("" if args.no_ground else f" and a Mesh2 ground rectangle (radius {ground_radius:.1f} m)")
          + f" to {info_path}")

    if trees_failed:
        sys.exit(1)  # flag the run as partially incomplete, after writing everything we could


if __name__ == "__main__":
    main()
