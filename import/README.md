# SOLARCHVISION_OSM_3D_in_obj

Fetches a small 3D city-massing kit from OpenStreetMap around a lat/lon
within a radius, and writes it into one output folder:

```
empire_state_area/
  buildings.obj    # extruded building footprints
  more_info.txt    # header comment + ground rectangle (Mesh2) + trees
```

Both files share one coordinate frame: meters, local/projected, origin
`(0, 0)` at your query lat/lon, `z=0` at ground level.

## How it works
1. Queries OSM (via the [Overpass API](https://overpass-api.de), through
   the `osmnx` library) for `building=*` footprints and `natural=tree`
   points within the radius.
2. Picks one local projected CRS (auto UTM zone) for the whole run and
   projects every layer into it, then recenters everything on the query
   point — so buildings, trees, and the ground rectangle all line up in
   the same local-meter space.
3. **`buildings.obj`**: extrudes each footprint from `z=0` up to a height
   from:
   - the `height` tag, if present, else
   - `building:levels` × `--level-height` (default 3 m/level), else
   - `--default-height` (default 6 m).
   Triangulated (including footprints with courtyards/holes) with
   `mapbox_earcut` into a watertight solid per building.
4. **`more_info.txt`**:
   ```
   # --lat 40.7484 --lon -73.9857 --radius 250
   Mesh2 m:8 tes:6 x1:-250 y1:-250 z1:0 x2:250 y2:250 z2:0
   Tree x:-20.0000 y:-10.0000 z:0.0000 h:10.0000
   Tree x:20.0000 y:10.0000 z:0.0000 h:20.0000
   ```
   - Line 1: a comment recording the query (`--lat`, `--lon`, `--radius`).
   - Line 2: `Mesh2` describes a flat square ground rectangle (no
     thickness, just a footprint) at `z=0`, from corner `(x1, y1)` to
     `(x2, y2)`, spanning `[-radius, radius]` on both axes (plus
     `--ground-padding`, if given).
   - Remaining lines: one per OSM tree node in the radius. Height comes
     from the tree's own `height` tag, else `--tree-default-height`
     (default 10 m). `z` is always `0` (ground level) — OSM/this script
     has no terrain elevation model.

Roof shapes, textures, and colors are not modeled — this gives clean
extruded "block massing," which is what OSM's tags support well.

## Setup

```bash
pip install osmnx shapely mapbox_earcut pyproj numpy
```

## Usage

```bash
python SOLARCHVISION_OSM_3D_in_obj.py --lat 40.7484 --lon -73.9857 --radius 250 --outdir empire_state_area
```

Options:

| Flag | Default | Description |
|---|---|---|
| `--lat`, `--lon` | required | Center point (WGS84) |
| `--radius` | 250 | Search radius in meters |
| `--outdir` | `site_<lat>_<lon>` | Output folder (created if missing) — holds `buildings.obj`, `more_info.txt` |
| `--overpass-url` | (auto) | Overpass endpoint to use (self-hosted instance, or one reachable through your proxy). By default the script tries overpass-api.de then a couple of public mirrors. |
| **Buildings** | | |
| `--level-height` | 3.0 | Meters per floor, used when only `building:levels` is tagged |
| `--default-height` | 6.0 | Fallback building height when no height/level tags exist |
| `--include-parts` | off | Also fetch `building:part` features for finer massing on complex buildings |
| **Trees (`more_info.txt`)** | | |
| `--tree-default-height` | 10.0 | Fallback tree height when no `height` tag exists |
| `--no-trees` | off | Skip fetching trees (file still gets the header + Mesh2 line) |
| **Ground rectangle (`Mesh2` line)** | | |
| `--ground-padding` | 0 | Extra meters added to `--radius` for the Mesh2 extents |
| `--no-ground` | off | Skip writing the Mesh2 line |

## Notes
- Coverage depends entirely on OSM data quality in your area — some
  regions have detailed `height`/`building:levels`/tree tags, others
  have none (those fall back to the `--default-height`/`--tree-default-height` values).
- Buildings mapped as OSM *relations* (multipolygons, e.g. buildings
  with courtyards) are handled — `osmnx` assembles them into proper
  Shapely polygons with holes before extrusion.
- All coordinates (buildings, trees, ground rectangle) are in meters,
  in one shared local frame — no extra alignment needed between files.
- Import `buildings.obj` into Blender and it should scale correctly if
  your Blender scene unit is set to meters.
- Overpass has rate limits; for very large radii or dense areas
  (e.g. >1-2 km in a dense city), expect a slower fetch or consider
  running your own Overpass instance / using a regional `.pbf` extract
  instead.

## If the fetch fails with a connection error

`Connection refused`, `Max retries exceeded`, or similar when reaching
`overpass-api.de` (or any Overpass mirror) is a network reachability
problem on the machine running the script — not a bug in it. The script
already tries a couple of public mirrors automatically before giving up
and printing a clear error instead of a raw traceback. If it still fails:

1. Test plain connectivity from the same shell:
   `curl -v https://overpass-api.de/api/interpreter`
2. If you're behind a corporate firewall/proxy, outbound HTTPS to
   `overpass-api.de` and similar hosts may simply be blocked. Set
   `HTTPS_PROXY`/`HTTP_PROXY` env vars if your network requires an
   explicit proxy, or ask your network admin to allow it.
3. Check for DNS or `/etc/hosts` overrides pointing these hostnames
   somewhere unexpected (unusual, but possible on locked-down machines).
4. If your organization runs a private/self-hosted Overpass instance,
   or you know a mirror that *is* reachable from your network, point
   the script at it directly:
   ```bash
   python SOLARCHVISION_OSM_3D_in_obj.py --lat ... --lon ... --overpass-url https://your-overpass-host/api/interpreter
   ```




