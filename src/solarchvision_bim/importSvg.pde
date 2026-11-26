// Minimal, dependency-free importer for an SVG (Scalable Vector Graphics)
// file - the same "hand-roll the parser, no external library" choice
// every other importer in this app already makes (importDxf.pde's/
// importKml.pde's own header comments, among others). SVG is plain XML,
// so this uses Processing's own built-in XML class (xmlHelpers.pde/
// loadXML()), the exact same tool importKml.pde/importCitygml.pde/
// importDae.pde already parse their own XML-based formats with.
//
// Processing does have a SECOND, built-in way to read an SVG file -
// loadShape()/PShapeSVG, which already parses path data, basic shapes,
// and nested <g> groups into a PShape tree. It is deliberately NOT used
// here: a PShape's own accumulated transform (translate/scale/rotate/...
// from a <g transform="..."> ancestor) is kept internally as a protected
// PMatrix field with no public getter - there is no way, from outside
// processing.core's own package, to read back the matrix that would
// need to be applied to a child shape's own (still-local, untransformed)
// vertex coordinates. Since a real-world SVG (anything exported from
// Illustrator/Inkscape/Figma) routinely wraps its content in at least one
// transform-bearing <g>, silently skipping that transform would silently
// produce wrong geometry rather than an honest error - so this importer
// walks the raw XML itself and accumulates `transform` attributes into
// its own running 2x3 affine matrix instead (svgParseTransformAttr()/
// svgComposeMatrix() below), the same "full control over the format's
// own coordinate math" posture importGeojson.pde's own coordinate/
// winding handling already takes.
//
// v1 scope - elements:
//   - <path> - its own "d" attribute, parsed by a small hand-rolled
//     scanner (SvgPathScanner, below) into one or more subpaths/contours.
//     Supported commands: M/m L/l H/h V/v C/c S/s Q/q T/t Z/z (every
//     straight-line and cubic/quadratic-Bezier command the spec
//     defines). A/a (elliptical arc) is NOT supported - SVG's own
//     endpoint-to-center arc parameterization (5 parameters: rx, ry,
//     x-axis-rotation, large-arc-flag, sweep-flag, plus the endpoint) is
//     a materially bigger undertaking than straight lines/Bezier curves,
//     and no existing importer in this app evaluates an elliptical arc
//     analytically either (importDxf.pde's own ARC entity is chorded
//     from an already-known center/radius/sweep, a much simpler case).
//     An A/a command stops that one subpath where it is - whatever was
//     already collected is kept, the same "salvage what was readable,
//     don't throw" tolerance every other importer's own malformed-input
//     handling already takes.
//   - <rect>, <circle>, <ellipse>, <line>, <polyline>, <polygon> - each
//     built directly into the same contour shape a <path> would produce.
//     A <rect>'s own rounded corners (rx/ry) are NOT supported - treated
//     as a plain rectangle (documented limitation, the same "every
//     segment comes in straight" tolerance importDxf.pde's own
//     unevaluated LWPOLYLINE bulge already takes for its own format).
//   - <g> (and <svg>/<a>, which behave like a group for this importer's
//     purposes) - recursed into; contributes its own "transform"
//     attribute to every descendant's accumulated matrix, and its own
//     "id"/"fill" to every descendant that doesn't set its own (SVG's
//     own attribute-inheritance rule, "Grouping"/"Fill vs stroke" below).
//   - <defs>, <symbol>, <clipPath>, <mask>, <pattern> are template-only
//     content, never rendered directly on their own - their children are
//     never walked at all, the same way importDxf.pde's own BLOCKS
//     section is read only when INSERT-referenced (never acted on
//     directly) and this importer doesn't resolve <use> references
//     either (so a <symbol> referenced via <use> is silently invisible
//     to this version, same as an unreferenced DXF BLOCK already is).
//   - Everything else (<text>, <image>, <use>, gradients, CSS
//     <style> sheets, ...) is unconditionally skipped - not vector path
//     geometry this importer evaluates, the same blanket posture
//     importDxf.pde's own SPLINE/MESH/TEXT/HATCH/... skip list already
//     takes for its own format.
//
// Fill vs stroke -> Face vs Polyline: SVG's own default fill, when
// nothing in a shape's own ancestry sets one, is solid black (opaque) -
// so a bare <path d="..."> with no "fill" attribute anywhere above it is
// still filled, per the spec. This importer reads a shape's own "fill"
// attribute (or a "fill:" entry inside its own "style" attribute, the
// only inline-style property this version reads at all - no CSS
// <style>-sheet/class-selector support), inheriting down from the
// nearest ancestor that sets one when the shape itself doesn't, and
// defaulting to filled when nothing anywhere sets one at all. "none" (an
// explicit fill="none" or style="fill:none") is this importer's one and
// only "treat this as open/stroke-only drafting geometry" signal - the
// actual fill COLOR is never read or interpreted, since nothing in this
// version ever groups or cycles by it (just like every sibling importer,
// "material"/"layer" stay numbers the person already controls via m/
// lyr, never derived from a color). <line> is always stroke-only
// regardless of its own fill (the spec itself gives fill no effect on a
// <line>).
//
// A filled shape's own first subpath is its outer ring; every subpath
// after it is treated as a hole and bridged into the outer ring via
// PolygonHoles.mergeHolesIntoOuterLoop() - the exact same technique
// importGeojson.pde's/importCitygml.pde's/importIfc.pde's own hole
// handling already uses. This importer does not evaluate a shape's own
// fill-rule (nonzero vs evenodd) at all - ring 2+ is always a hole
// regardless, the same "ring ordinal position, not a winding-rule
// evaluation, decides hole-vs-outer" posture every GIS importer in this
// app already takes for its own format's analogous rings.
//
// Bezier tessellation: a fixed number of samples per individual cubic/
// quadratic curve SEGMENT (SVG_BEZIER_SAMPLES below) - not driven by
// curve length, curvature, or the `tes` parameter - the same fixed-
// density-regardless-of-model-size posture importDxf.pde's own ~6-
// degrees-per-chord arc tessellation and importIfc.pde's own circle
// tessellation already take for their own curved geometry.
//
// Coordinates: SVG user-space X increases rightward and Y increases
// DOWNWARD (screen-space convention) - the opposite sense from this
// app's own XY plane, where +Y is north/up (functions.pde's own
// convert_lonlat2XY()). This is an unconditional, always-on Y negation,
// NOT a toggle like the shared importSwapAxisYZ checkbox every OBJ/GLB/
// STL/PLY/DAE/DXF import already offers - that checkbox resolves a
// GENUINE ambiguity (none of those formats declares its own up-axis at
// all), whereas SVG's own Y-down convention is unambiguous, just the
// opposite sense from this app's, so there is nothing for the person to
// decide here. Z is always 0 before this import's own cz/sz (SVG itself
// carries no native elevation or extrusion data) - every shape comes in
// perfectly flat; the app's own existing manual height/extrude
// selection tools remain the way to add height afterward, the same
// conservative "don't invent height data the file doesn't actually
// carry" stance importGeojson.pde's own (per-Feature, property-driven)
// geojsonHeightProperty default takes, just with no per-shape property
// to read in the first place.
//
// Units: this importer does not read an <svg> root's own "width"/
// "height"/"viewBox" attributes to auto-detect a physical unit (px vs
// mm vs real-world meters) at all - every path-data number is taken as
// already being in whatever unit the person will scale via this
// import's own sx/sy/sz, the exact same "don't auto-detect units, the
// person already has a uniform scale dialog" posture importDxf.pde's/
// importObj.pde's/importStl.pde's own imports already take.
//
// Grouping: OFF by default (svgGroupById, below) - when turned on via
// this importer's own options dialog, a shape's own "id" attribute (or,
// when it has none, the nearest ancestor <g>'s own "id") becomes the
// grouping/material-cycling boundary, the same "a value differs from the
// previous shape's -> start a new group, cycle material" mechanism
// importDxf.pde's own per-layer logic already uses for its own format -
// but opt-in here, unlike DXF's own unconditional layer-grouping, since
// an arbitrary SVG's own ids are a far less reliable, far less
// consistently-authored grouping signal than a DXF layer (many real-
// world SVGs carry auto-generated, meaningless per-element ids, or none
// at all) - the same conservative "don't invent a grouping signal the
// file doesn't obviously offer" instinct geojsonGroupProperty's own
// blank default already takes for GeoJSON/TopoJSON/KML.

boolean svgImportShowOptionsDialog = false;
boolean svgGroupById = false;

boolean svgCycleMaterial = false;
String svgCurrentGroupKey = null;

int svgFacesImported = 0;
int svgLinesImported = 0;

int svgElementsTotal = 0;
int svgElementsWalked = 0;
float svgPrintedProgress = 0;
ProgressWindow svgProgressWindow = null;
boolean svgImportAborted = false;

// A fixed number of straight-line samples per individual cubic/
// quadratic Bezier curve segment - this file's own header comment,
// "Bezier tessellation".
final int SVG_BEZIER_SAMPLES = 12;

void import_objects_SVG (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_DXF()'s/import_objects_GEOJSON()'s own
  // identical blocks - see either one's own comment for why this sits
  // here rather than earlier, and what a cancelled dialog does.
  if (svgImportShowOptionsDialog) {
    svgImportShowOptionsDialog = false;
    if (!svgShowImportOptionsDialog()) return;
  }

  println("\nImporting SVG. Please wait...");
  showWaitCursor();
  isImportingInProgress = true; // see this flag's own comment (globalFunctions.pde) for why - cleared alongside showArrowCursor() at every exit

  svgCycleMaterial = (m == -1);
  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  svgCurrentGroupKey = null;
  svgFacesImported = 0;
  svgLinesImported = 0;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  // Same reasoning as importKml.pde's/importCitygml.pde's own identical
  // try/catch around their own loadXML() call - a malformed XML document
  // throws straight out of Processing's own XML parser rather than
  // returning null, unlike a missing/unreadable file (which does return
  // null on its own).
  XML root = null;
  try {
    root = loadXML(FileName);
  }
  catch (RuntimeException e) {
    root = null;
  }
  if (root == null) {
    println("\nSVG import: could not read or parse " + FileName);
    isImportingInProgress = false;
    showArrowCursor();
    return;
  }

  progressBarHeader();

  svgElementsTotal = svgCountElements(root);
  svgElementsWalked = 0;
  svgPrintedProgress = 0;
  svgImportAborted = false;

  svgProgressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("\nImporting SVG") : null;
  if (svgProgressWindow != null) svgProgressWindow.setVisible(true);

  float[] identity = new float[]{1, 0, 0, 1, 0, 0};

  try {
    svgWalkElement(root, identity, "black", null, cx, cy, cz, sx, sy, sz, clz);
  } finally {
    if (svgProgressWindow != null) svgProgressWindow.dispose();
    svgProgressWindow = null;
  }

  if (!svgImportAborted && (svgFacesImported == 0) && (svgLinesImported == 0)) {
    println("\nSVG import: no <path>/<rect>/<circle>/<ellipse>/<line>/<polyline>/<polygon> geometry found - this version doesn't read <text>, <image>, <use>, or any CSS-stylesheet-driven content");
  }

  if (!svgImportAborted) {
    int remaining = (int) floor(100 - svgPrintedProgress);
    printProgressBarChunk(remaining);
    println();

    String summary = "SVG import complete: " + svgFacesImported + " face(s), " + svgLinesImported + " line(s) imported.";
    println();
    println(summary);
  }

  isImportingInProgress = false;
  showArrowCursor();
}

// A cheap upfront count of every element in the document (root
// included) - same "count first, so the real walk can show a percentage
// against a known total" shape importDae.pde's own
// daeCountGeometryInstances()/dae_totalGeometryInstances already uses,
// just counting raw elements instead of <instance_geometry> nodes (an
// SVG document has no equivalent flat, easily-countable top-level list -
// every element, nested arbitrarily deep, is this importer's own unit of
// progress instead).
int svgCountElements (XML el) {
  int count = 1;
  for (XML child : el.getChildren()) {
    count += svgCountElements(child);
  }
  return count;
}

// One progress-window/console update, called once per element visited
// by svgWalkElement() below - same shape as importDae.pde's own
// daeReportProgress().
void svgReportProgress () {
  if (svgImportAborted) return;

  if ((svgProgressWindow != null) && svgProgressWindow.abortRequested) {
    echoAbortProgress();
    svgImportAborted = true;
    return;
  }

  svgElementsWalked += 1;

  if (control != USER_AUTO) {
    float progress = (svgElementsTotal > 0) ? (100 * svgElementsWalked / (float) svgElementsTotal) : 100;
    int delta = (int) floor(progress - svgPrintedProgress);
    if (delta >= 1) {
      printProgressBarChunk(delta);
      svgPrintedProgress = floor(progress);
      if (svgProgressWindow != null) svgProgressWindow.updateFraction(progress / 100.0f);
    }
  }
}

// Walks one XML element (and, recursively, its own children) - `matrix`
// is the already-accumulated 2x3 affine transform from every ancestor's
// own "transform" attribute (svgComposeMatrix()'s own comment);
// `inheritedFill`/`inheritedId` are the nearest ancestor's own resolved
// "fill"/"id" (this file's own header comment, "Fill vs stroke"/
// "Grouping") - passed down, never re-derived from scratch per element,
// exactly the same inheritance importTopojson.pde's own
// topojsonHandleGeometry() GeometryCollection branch already documents
// for its own enclosing-object "properties".
void svgWalkElement (XML el, float[] matrix, String inheritedFill, String inheritedId, float cx, float cy, float cz, float sx, float sy, float sz, int clzParam) {
  if (svgImportAborted) return;
  svgReportProgress();
  if (svgImportAborted) return;

  String tag = el.getName();
  if (tag == null) return;

  // Template-only content - never rendered directly, and this importer
  // doesn't resolve <use> references to it either (this file's own
  // header comment).
  if (tag.equals("defs") || tag.equals("symbol") || tag.equals("clipPath") || tag.equals("mask") || tag.equals("pattern")) return;

  float[] ownTransform = svgParseTransformAttr(svgAttrOrEmpty(el, "transform"));
  float[] combined = svgComposeMatrix(matrix, ownTransform);

  String fill = svgResolveFill(el, inheritedFill);
  String id = svgResolveId(el, inheritedId);

  if (tag.equals("g") || tag.equals("svg") || tag.equals("a")) {
    for (XML child : el.getChildren()) {
      svgWalkElement(child, combined, fill, id, cx, cy, cz, sx, sy, sz, clzParam);
      if (svgImportAborted) return;
    }
    return;
  }

  ArrayList<SvgContour> localContours;

  if (tag.equals("path")) {
    localContours = svgParsePathData(svgAttrOrEmpty(el, "d"));
  } else if (tag.equals("rect")) {
    localContours = svgContoursFromRect(el);
  } else if (tag.equals("circle")) {
    localContours = svgContoursFromCircle(el);
  } else if (tag.equals("ellipse")) {
    localContours = svgContoursFromEllipse(el);
  } else if (tag.equals("line")) {
    localContours = svgContoursFromLine(el);
  } else if (tag.equals("polyline")) {
    localContours = svgContoursFromPoints(el, false);
  } else if (tag.equals("polygon")) {
    localContours = svgContoursFromPoints(el, true);
  } else {
    return; // <text>, <image>, <use>, ... - not vector path geometry this importer evaluates (this file's own header comment)
  }

  if (localContours == null || localContours.size() == 0) return;

  ArrayList<ArrayList<PVector>> worldContours = new ArrayList<ArrayList<PVector>>();
  for (SvgContour c : localContours) {
    ArrayList<PVector> pts = new ArrayList<PVector>();
    for (PVector p : c.points) {
      pts.add(svgTransformPoint(combined, p.x, p.y, cx, cy, cz, sx, sy, sz));
    }
    worldContours.add(pts);
  }

  // The spec gives "fill" no effect on <line> at all - always stroke-only.
  boolean filled = !tag.equals("line") && !(fill == null || fill.trim().length() == 0 || fill.trim().equalsIgnoreCase("none"));

  if (filled) {
    ArrayList<PVector> outer = worldContours.get(0);
    if (outer.size() < 3) return;

    ArrayList<ArrayList<PVector>> holes = new ArrayList<ArrayList<PVector>>();
    for (int i = 1; i < worldContours.size(); i++) {
      if (worldContours.get(i).size() >= 3) holes.add(worldContours.get(i));
    }

    svgApplyGrouping(id);
    ArrayList<PVector> ring = (holes.size() > 0) ? PolygonHoles.mergeHolesIntoOuterLoop(outer, holes) : outer;
    svgEmitFlatFace(ring, id);
  } else {
    for (int i = 0; i < worldContours.size(); i++) {
      ArrayList<PVector> pts = worldContours.get(i);
      if (pts.size() < 2) continue;
      svgApplyGrouping(id);
      svgEmitPolyline(pts, localContours.get(i).closed, clzParam, id);
    }
  }
}

// Starts a new group/cycles material exactly when this shape's own
// grouping-key value (its own, or its nearest ancestor <g>'s own, "id" -
// null when neither it nor any ancestor has one) differs from the
// PREVIOUS shape's - same "repetition/change, not a per-call flag,
// decides it" shape importDxf.pde's own per-layer check/
// geojsonApplyGrouping() (importGeojson.pde) already use, just gated
// behind svgGroupById (off by default - this file's own header comment,
// "Grouping") since this one is opt-in, unlike either of those.
void svgApplyGrouping (String key) {
  if (!svgGroupById) return;

  boolean changed = (key == null) ? (svgCurrentGroupKey != null) : !key.equals(svgCurrentGroupKey);
  if (changed) {
    svgCurrentGroupKey = key;
    if (svgCycleMaterial) current_Material = 1 + (current_Material % 8); // same "g" tag/DXF-layer cycling importObj.pde's/importDxf.pde's own already use
    if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
  }
}

// This SVG importer's own extraParams capture - this shape's own (or its nearest ancestor
// <g>'s own) resolved "id", the same value svgApplyGrouping() above
// already reads for grouping, now ALSO offered as this item's own
// extraParams - gated by the shared importExtraParams checkbox
// (fileSelected.pde) exactly like geojsonPropertiesToExtraParams()
// (importGeojson.pde) is for every other format sharing that core; "" (no
// extraParams at all) whenever that's unchecked or this shape/its
// ancestors never carried an "id" to begin with.
String svgIdToExtraParams (String id) {
  if (!importExtraParams || id == null || id.trim().length() == 0) return "";
  JSONObject obj = new JSONObject();
  obj.setString("id", id);
  return obj.toString();
}

// One hole-free (or already hole-bridged) ring -> one flat n-gon Face,
// exactly as given - never triangulated, the same "the file's own n-gon,
// don't triangulate" choice importGeojson.pde's own geojsonEmitFlatFace()
// already makes for its own format.
void svgEmitFlatFace (ArrayList<PVector> ring, String id) {
  if (ring.size() < 3) return;
  int[] nodes = new int[ring.size()];
  for (int i = 0; i < ring.size(); i++) {
    PVector p = ring.get(i);
    nodes[i] = allPoints.create(p.x, p.y, p.z);
  }
  // Set right before, reset right after - current_ExtraParams must never
  // leak into the next, unrelated piece of geometry someone creates (its
  // own comment, globalVariables.pde).
  current_ExtraParams = svgIdToExtraParams(id);
  allFaces.create(nodes);
  current_ExtraParams = "";
  svgFacesImported++;
}

// One stroke-only (or fill="none") contour -> one Polyline - `closed`
// is whatever this contour's own data said (a "Z"-closed path subpath,
// or a <polygon>/<circle>/<ellipse>/<rect>'s own always-closed shape);
// `clzParam` is this import's own generic closed/open default, applied
// only when the shape's own data left it ambiguous - same "the file's
// own repetition/flag decides closedness FOR THIS ONE shape, clzParam is
// only the fallback" convention importGeojson.pde's own
// geojsonEmitLineStringFromPoints() already documents for its own
// format.
void svgEmitPolyline (ArrayList<PVector> pts, boolean closed, int clzParam, String id) {
  float[][] points = new float[pts.size()][3];
  for (int i = 0; i < pts.size(); i++) {
    PVector p = pts.get(i);
    points[i] = new float[]{p.x, p.y, p.z};
  }
  current_ExtraParams = svgIdToExtraParams(id);
  allPolylines.add_Polyline(current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, closed ? 1 : clzParam, points);
  current_ExtraParams = "";
  svgLinesImported++;
}

// `el.getString(attr)` itself isn't confirmed to return "" rather than
// null when the attribute is absent (importDae.pde's own daeAttr()
// identical comment) - every attribute read in this file goes through
// this wrapper instead of calling .getString() directly, to stay safe
// regardless.
String svgAttrOrEmpty (XML el, String name) {
  if (!el.hasAttribute(name)) return "";
  String v = el.getString(name);
  return (v == null) ? "" : v;
}

// This shape's own "fill" attribute (or a "fill:" entry inside its own
// "style" attribute - the only inline-style property this importer ever
// reads, no CSS <style>-sheet/class-selector support), falling back to
// `inheritedFill` (the nearest ancestor's own resolved value) when
// neither is set - this file's own header comment, "Fill vs stroke".
String svgResolveFill (XML el, String inheritedFill) {
  String direct = svgAttrOrEmpty(el, "fill").trim();
  if (direct.length() > 0) return direct;

  String style = svgAttrOrEmpty(el, "style");
  if (style.length() > 0) {
    for (String decl : style.split(";")) {
      String[] kv = decl.split(":", 2);
      if (kv.length == 2 && kv[0].trim().equalsIgnoreCase("fill")) {
        String v = kv[1].trim();
        if (v.length() > 0) return v;
      }
    }
  }

  return inheritedFill;
}

// This shape's own "id", falling back to `inheritedId` (the nearest
// ancestor <g>'s own) when it has none of its own - this file's own
// header comment, "Grouping".
String svgResolveId (XML el, String inheritedId) {
  String direct = svgAttrOrEmpty(el, "id").trim();
  return (direct.length() > 0) ? direct : inheritedId;
}

// ==================== shape -> contour(s) ====================

// One subpath/contour's own point list, already in the element's own
// LOCAL (untransformed) coordinate space - `closed` is this contour's
// own data-driven closedness (a <path> subpath closed with "Z"/"z", or a
// shape whose own type is always closed by definition: <polygon>,
// <rect>, <circle>, <ellipse>). Only meaningful for the stroke/Polyline
// branch (svgWalkElement()'s own comment) - a Face's own ring is always
// structurally closed regardless, so `closed` is never consulted there.
class SvgContour {
  ArrayList<PVector> points;
  boolean closed;

  SvgContour (ArrayList<PVector> points, boolean closed) {
    this.points = points;
    this.closed = closed;
  }
}

ArrayList<SvgContour> svgContoursFromRect (XML el) {
  float x = svgFloatAttr(el, "x", 0);
  float y = svgFloatAttr(el, "y", 0);
  float w = svgFloatAttr(el, "width", 0);
  float h = svgFloatAttr(el, "height", 0);
  // Rounded corners (rx/ry) are NOT supported - this file's own header
  // comment, "v1 scope - elements".

  ArrayList<PVector> pts = new ArrayList<PVector>();
  pts.add(new PVector(x, y));
  pts.add(new PVector(x + w, y));
  pts.add(new PVector(x + w, y + h));
  pts.add(new PVector(x, y + h));

  ArrayList<SvgContour> result = new ArrayList<SvgContour>();
  result.add(new SvgContour(pts, true));
  return result;
}

ArrayList<SvgContour> svgContoursFromCircle (XML el) {
  float cx = svgFloatAttr(el, "cx", 0);
  float cy = svgFloatAttr(el, "cy", 0);
  float r = svgFloatAttr(el, "r", 0);
  return svgEllipseContour(cx, cy, r, r);
}

ArrayList<SvgContour> svgContoursFromEllipse (XML el) {
  float cx = svgFloatAttr(el, "cx", 0);
  float cy = svgFloatAttr(el, "cy", 0);
  float rx = svgFloatAttr(el, "rx", 0);
  float ry = svgFloatAttr(el, "ry", 0);
  return svgEllipseContour(cx, cy, rx, ry);
}

// Fixed chord count for a full 360-degree sweep - the same "fixed
// density, not model-size-dependent" tessellation posture this file's
// own header comment already documents for Bezier curves, just applied
// to a full ellipse instead (importDxf.pde's own arc/circle chording
// takes the identical stance for its own format, just at a different
// fixed density - one chord roughly every 6 degrees there, vs. this
// importer's own SVG_BEZIER_SAMPLES-driven density here, since an
// ellipse/circle is tessellated as 4 quarter-arcs' worth of this same
// per-segment sample count for consistency with every curve this
// importer tessellates).
ArrayList<SvgContour> svgEllipseContour (float cx, float cy, float rx, float ry) {
  int n = max(12, SVG_BEZIER_SAMPLES * 4);
  ArrayList<PVector> pts = new ArrayList<PVector>();
  for (int i = 0; i < n; i++) {
    float t = TWO_PI * i / n;
    pts.add(new PVector(cx + rx * cos(t), cy + ry * sin(t)));
  }
  ArrayList<SvgContour> result = new ArrayList<SvgContour>();
  result.add(new SvgContour(pts, true));
  return result;
}

ArrayList<SvgContour> svgContoursFromLine (XML el) {
  float x1 = svgFloatAttr(el, "x1", 0);
  float y1 = svgFloatAttr(el, "y1", 0);
  float x2 = svgFloatAttr(el, "x2", 0);
  float y2 = svgFloatAttr(el, "y2", 0);

  ArrayList<PVector> pts = new ArrayList<PVector>();
  pts.add(new PVector(x1, y1));
  pts.add(new PVector(x2, y2));

  ArrayList<SvgContour> result = new ArrayList<SvgContour>();
  result.add(new SvgContour(pts, false));
  return result;
}

// Shared by <polyline> (alwaysClosed == false) and <polygon>
// (alwaysClosed == true) - both read the exact same "points" attribute
// shape ("x1,y1 x2,y2 ..."), the only difference between the two
// elements being whether the shape implicitly closes its own loop.
ArrayList<SvgContour> svgContoursFromPoints (XML el, boolean alwaysClosed) {
  String raw = svgAttrOrEmpty(el, "points").trim();
  ArrayList<PVector> pts = new ArrayList<PVector>();
  if (raw.length() > 0) {
    SvgPathScanner sc = new SvgPathScanner(raw);
    while (sc.hasMore()) {
      float x = sc.nextNumber();
      float y = sc.nextNumber();
      if (Float.isNaN(x) || Float.isNaN(y)) break; // malformed trailing data - keep whatever was already read
      pts.add(new PVector(x, y));
    }
  }

  if (pts.size() == 0) return new ArrayList<SvgContour>();

  ArrayList<SvgContour> result = new ArrayList<SvgContour>();
  result.add(new SvgContour(pts, alwaysClosed));
  return result;
}

float svgFloatAttr (XML el, String name, float defaultValue) {
  String v = svgAttrOrEmpty(el, name).trim();
  if (v.length() == 0) return defaultValue;
  try { return Float.parseFloat(v); } catch (Exception e) { return defaultValue; }
}

// ==================== "d" path-data parsing ====================

// Parses one <path> element's own "d" attribute into one or more
// SvgContours, in the path's own LOCAL (untransformed) coordinate space -
// see this file's own header comment, "v1 scope - elements", for exactly
// which commands are supported. An unsupported/malformed command stops
// parsing where it is; whatever subpaths/points were already collected
// are kept and returned.
ArrayList<SvgContour> svgParsePathData (String d) {
  ArrayList<SvgContour> contours = new ArrayList<SvgContour>();
  SvgPathScanner sc = new SvgPathScanner(d);

  float curX = 0, curY = 0;
  float startX = 0, startY = 0;
  float reflX = 0, reflY = 0; // reflected control point for a following S/T command - meaningful only right after a C/S (reflX/reflY) or Q/T (reflX/reflY) command, this file's own comment below
  char lastCommand = 0;
  char cmd = 0;

  ArrayList<PVector> current = null;

  while (sc.hasMore()) {
    char letter = sc.peekCommandLetter();
    if (letter != 0) {
      cmd = letter;
      sc.consumeCommandLetter();
    } else if (cmd == 0) {
      break; // garbage before any command letter at all - nothing to do
    } // else: an implicit repeat of the same command (SVG's own grammar: extra coordinate groups with no new command letter repeat the previous command - except a repeated M, which the spec itself reinterprets as an implicit L, handled below)

    boolean rel = Character.isLowerCase(cmd);
    char upper = Character.toUpperCase(cmd);

    if (upper == 'Z') {
      if (current != null) contours.add(new SvgContour(current, true));
      curX = startX; curY = startY;
      current = null;
      lastCommand = 'Z';
      continue;
    }

    if (upper == 'M') {
      float x = sc.nextNumber(), y = sc.nextNumber();
      if (Float.isNaN(x) || Float.isNaN(y)) break;
      if (rel) { x += curX; y += curY; }
      if (current != null) contours.add(new SvgContour(current, false)); // an earlier subpath left open without its own "Z" - keep it, open, same tolerance every other format's own un-closed polyline already gets
      current = new ArrayList<PVector>();
      curX = x; curY = y; startX = x; startY = y;
      current.add(new PVector(curX, curY));
      lastCommand = 'M';
      cmd = rel ? 'l' : 'L'; // the spec's own "a repeated M coordinate pair is an implicit L" rule - the NEXT loop iteration (no new command letter present) falls straight into the L branch below
      continue;
    }

    if (current == null) {
      current = new ArrayList<PVector>();
      current.add(new PVector(curX, curY));
      startX = curX; startY = curY;
    }

    if (upper == 'L') {
      float x = sc.nextNumber(), y = sc.nextNumber();
      if (Float.isNaN(x) || Float.isNaN(y)) break;
      if (rel) { x += curX; y += curY; }
      curX = x; curY = y;
      current.add(new PVector(curX, curY));
      lastCommand = 'L';
    } else if (upper == 'H') {
      float x = sc.nextNumber();
      if (Float.isNaN(x)) break;
      if (rel) x += curX;
      curX = x;
      current.add(new PVector(curX, curY));
      lastCommand = 'H';
    } else if (upper == 'V') {
      float y = sc.nextNumber();
      if (Float.isNaN(y)) break;
      if (rel) y += curY;
      curY = y;
      current.add(new PVector(curX, curY));
      lastCommand = 'V';
    } else if (upper == 'C') {
      float x1 = sc.nextNumber(), y1 = sc.nextNumber(), x2 = sc.nextNumber(), y2 = sc.nextNumber(), x = sc.nextNumber(), y = sc.nextNumber();
      if (Float.isNaN(x1) || Float.isNaN(y1) || Float.isNaN(x2) || Float.isNaN(y2) || Float.isNaN(x) || Float.isNaN(y)) break;
      if (rel) { x1 += curX; y1 += curY; x2 += curX; y2 += curY; x += curX; y += curY; }
      svgAppendCubic(current, curX, curY, x1, y1, x2, y2, x, y);
      reflX = 2 * x - x2; reflY = 2 * y - y2;
      curX = x; curY = y;
      lastCommand = 'C';
    } else if (upper == 'S') {
      float x2 = sc.nextNumber(), y2 = sc.nextNumber(), x = sc.nextNumber(), y = sc.nextNumber();
      if (Float.isNaN(x2) || Float.isNaN(y2) || Float.isNaN(x) || Float.isNaN(y)) break;
      if (rel) { x2 += curX; y2 += curY; x += curX; y += curY; }
      float x1 = (lastCommand == 'C' || lastCommand == 'S') ? reflX : curX;
      float y1 = (lastCommand == 'C' || lastCommand == 'S') ? reflY : curY;
      svgAppendCubic(current, curX, curY, x1, y1, x2, y2, x, y);
      reflX = 2 * x - x2; reflY = 2 * y - y2;
      curX = x; curY = y;
      lastCommand = 'S';
    } else if (upper == 'Q') {
      float x1 = sc.nextNumber(), y1 = sc.nextNumber(), x = sc.nextNumber(), y = sc.nextNumber();
      if (Float.isNaN(x1) || Float.isNaN(y1) || Float.isNaN(x) || Float.isNaN(y)) break;
      if (rel) { x1 += curX; y1 += curY; x += curX; y += curY; }
      svgAppendQuadratic(current, curX, curY, x1, y1, x, y);
      reflX = 2 * x - x1; reflY = 2 * y - y1;
      curX = x; curY = y;
      lastCommand = 'Q';
    } else if (upper == 'T') {
      float x = sc.nextNumber(), y = sc.nextNumber();
      if (Float.isNaN(x) || Float.isNaN(y)) break;
      if (rel) { x += curX; y += curY; }
      float x1 = (lastCommand == 'Q' || lastCommand == 'T') ? reflX : curX;
      float y1 = (lastCommand == 'Q' || lastCommand == 'T') ? reflY : curY;
      svgAppendQuadratic(current, curX, curY, x1, y1, x, y);
      reflX = 2 * x - x1; reflY = 2 * y - y1;
      curX = x; curY = y;
      lastCommand = 'T';
    } else if (upper == 'A') {
      // Not supported (this file's own header comment) - consume its own
      // 7 numeric arguments so the scanner doesn't misread them as a
      // different command's own, then stop this subpath here.
      sc.nextNumber(); sc.nextNumber(); sc.nextNumber(); sc.nextNumber(); sc.nextNumber(); sc.nextNumber(); sc.nextNumber();
      break;
    } else {
      break; // unrecognized command letter
    }
  }

  if (current != null) contours.add(new SvgContour(current, false)); // a trailing subpath with no closing "Z"

  return contours;
}

void svgAppendCubic (ArrayList<PVector> out, float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3) {
  for (int i = 1; i <= SVG_BEZIER_SAMPLES; i++) {
    float t = i / (float) SVG_BEZIER_SAMPLES;
    float mt = 1 - t;
    float bx = mt * mt * mt * x0 + 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t * t * t * x3;
    float by = mt * mt * mt * y0 + 3 * mt * mt * t * y1 + 3 * mt * t * t * y2 + t * t * t * y3;
    out.add(new PVector(bx, by));
  }
}

void svgAppendQuadratic (ArrayList<PVector> out, float x0, float y0, float x1, float y1, float x2, float y2) {
  for (int i = 1; i <= SVG_BEZIER_SAMPLES; i++) {
    float t = i / (float) SVG_BEZIER_SAMPLES;
    float mt = 1 - t;
    float bx = mt * mt * x0 + 2 * mt * t * x1 + t * t * x2;
    float by = mt * mt * y0 + 2 * mt * t * y1 + t * t * y2;
    out.add(new PVector(bx, by));
  }
}

// A small hand-rolled scanner over a "d"/"points" attribute's own number
// stream - SVG's own number grammar allows numbers packed with no
// separating whitespace at all when unambiguous ("1.5.6" is two numbers,
// "1.5" and ".6"; "100-50" is two numbers, "100" and "-50") - this walks
// the string one character at a time rather than relying on a
// whitespace/comma split, so it reads that packed grammar correctly
// rather than merging adjacent numbers together.
class SvgPathScanner {
  String s;
  int pos;
  int len;

  SvgPathScanner (String data) {
    this.s = (data == null) ? "" : data;
    this.pos = 0;
    this.len = this.s.length();
  }

  void skipSeparators () {
    while (pos < len) {
      char c = s.charAt(pos);
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == ',') pos++;
      else break;
    }
  }

  boolean hasMore () {
    skipSeparators();
    return pos < len;
  }

  // The next path-command letter, WITHOUT consuming it, so the caller
  // can tell "a new command" apart from "an implicit repeat number" -
  // returns the NUL character when the next token is a number instead.
  char peekCommandLetter () {
    skipSeparators();
    if (pos >= len) return 0;
    char c = s.charAt(pos);
    return ("MmLlHhVvCcSsQqTtZzAa".indexOf(c) >= 0) ? c : 0;
  }

  void consumeCommandLetter () {
    pos++; // only ever called right after peekCommandLetter() confirmed one is there
  }

  // Parses one number token per SVG's own grammar (optional sign, digits,
  // optional '.', digits, optional exponent) starting at the current
  // position - returns Float.NaN when no valid number starts here at all
  // (malformed/empty input), without consuming anything in that case.
  float nextNumber () {
    skipSeparators();
    int start = pos;
    int p = pos;
    if (p < len && (s.charAt(p) == '+' || s.charAt(p) == '-')) p++;
    boolean sawDigitOrDot = false;
    while (p < len && Character.isDigit(s.charAt(p))) { p++; sawDigitOrDot = true; }
    if (p < len && s.charAt(p) == '.') {
      p++;
      while (p < len && Character.isDigit(s.charAt(p))) { p++; sawDigitOrDot = true; }
    }
    if (!sawDigitOrDot) return Float.NaN;
    if (p < len && (s.charAt(p) == 'e' || s.charAt(p) == 'E')) {
      int expStart = p;
      p++;
      if (p < len && (s.charAt(p) == '+' || s.charAt(p) == '-')) p++;
      int digitsStart = p;
      while (p < len && Character.isDigit(s.charAt(p))) p++;
      if (p == digitsStart) p = expStart; // "e"/"e-" with no actual exponent digits - not part of the number after all, back out
    }
    pos = p;
    try { return Float.parseFloat(s.substring(start, p)); } catch (Exception e) { return Float.NaN; }
  }
}

// ==================== transform attribute parsing ====================

// Parses one "transform" attribute's own function list ("translate(...)
// rotate(...) scale(...) ...", SVG's own transform-list grammar) into a
// single composed 2x3 affine matrix {a,b,c,d,e,f} meaning
// x' = a*x + c*y + e, y' = b*x + d*y + f (the same a,b,c,d,e,f order the
// spec's own matrix(a,b,c,d,e,f) function uses directly). An empty/
// missing attribute returns the identity matrix.
float[] svgParseTransformAttr (String transformAttr) {
  float[] result = new float[]{1, 0, 0, 1, 0, 0};
  if (transformAttr == null) return result;
  String s = transformAttr.trim();
  if (s.length() == 0) return result;

  int i = 0;
  int n = s.length();
  while (i < n) {
    while (i < n && (Character.isWhitespace(s.charAt(i)) || s.charAt(i) == ',')) i++;
    if (i >= n) break;

    int nameStart = i;
    while (i < n && Character.isLetter(s.charAt(i))) i++;
    String name = s.substring(nameStart, i);
    if (name.length() == 0) break; // malformed - stop, keep whatever was already composed

    while (i < n && Character.isWhitespace(s.charAt(i))) i++;
    if (i >= n || s.charAt(i) != '(') break;
    i++; // skip '('

    int argsStart = i;
    while (i < n && s.charAt(i) != ')') i++;
    if (i >= n) break; // unterminated - malformed, stop here
    String argsStr = s.substring(argsStart, i);
    i++; // skip ')'

    SvgPathScanner sc = new SvgPathScanner(argsStr);
    ArrayList<Float> args = new ArrayList<Float>();
    while (sc.hasMore()) {
      float v = sc.nextNumber();
      if (Float.isNaN(v)) break;
      args.add(v);
    }

    float[] fn = svgTransformFunctionMatrix(name, args);
    if (fn == null) break; // unrecognized function name - stop, keep whatever was already composed

    result = svgComposeMatrix(result, fn);
  }

  return result;
}

// One transform-list function's own matrix, per the SVG spec's own
// definitions - null for an unrecognized name or a wrong argument count
// (treated as malformed, same "stop, don't guess" tolerance every other
// malformed-input case in this importer already takes).
float[] svgTransformFunctionMatrix (String name, ArrayList<Float> args) {
  if (name.equals("matrix") && args.size() == 6) {
    return new float[]{args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5)};
  }
  if (name.equals("translate") && (args.size() == 1 || args.size() == 2)) {
    float tx = args.get(0);
    float ty = (args.size() == 2) ? args.get(1) : 0;
    return new float[]{1, 0, 0, 1, tx, ty};
  }
  if (name.equals("scale") && (args.size() == 1 || args.size() == 2)) {
    float scaleX = args.get(0);
    float scaleY = (args.size() == 2) ? args.get(1) : scaleX;
    return new float[]{scaleX, 0, 0, scaleY, 0, 0};
  }
  if (name.equals("rotate") && (args.size() == 1 || args.size() == 3)) {
    float angleDeg = args.get(0);
    float rad = radians(angleDeg);
    float cosA = cos(rad), sinA = sin(rad);
    float[] rot = new float[]{cosA, sinA, -sinA, cosA, 0, 0};
    if (args.size() == 3) {
      float px = args.get(1), py = args.get(2);
      float[] toOrigin = new float[]{1, 0, 0, 1, -px, -py};
      float[] backOut = new float[]{1, 0, 0, 1, px, py};
      return svgComposeMatrix(backOut, svgComposeMatrix(rot, toOrigin));
    }
    return rot;
  }
  if (name.equals("skewX") && args.size() == 1) {
    return new float[]{1, 0, tan(radians(args.get(0))), 1, 0, 0};
  }
  if (name.equals("skewY") && args.size() == 1) {
    return new float[]{1, tan(radians(args.get(0))), 0, 1, 0, 0};
  }
  return null;
}

// Composes two 2x3 affine matrices as `parent` ∘ `child` - i.e. the
// matrix that applies `child` first, then `parent` (point' =
// parent(child(point))) - the same order a nested
// <g transform="parent"><g transform="child"> structure already implies,
// and the same order this importer accumulates an element's own
// transform onto its ancestors' (svgWalkElement()'s own "combined"
// variable).
float[] svgComposeMatrix (float[] parent, float[] child) {
  float a = parent[0] * child[0] + parent[2] * child[1];
  float b = parent[1] * child[0] + parent[3] * child[1];
  float c = parent[0] * child[2] + parent[2] * child[3];
  float d = parent[1] * child[2] + parent[3] * child[3];
  float e = parent[0] * child[4] + parent[2] * child[5] + parent[4];
  float f = parent[1] * child[4] + parent[3] * child[5] + parent[5];
  return new float[]{a, b, c, d, e, f};
}

// Applies one already-fully-composed 2x3 affine matrix to a raw path-
// data point, then this importer's own unconditional SVG-Y-down-to-this-
// app's-Y-up flip (this file's own header comment, "Coordinates"), then
// the generic cx/cy/cz/sx/sy/sz offset/scale every other importer's own
// equivalent step already applies. Z is always 0 before cz/sz - SVG
// itself carries no native elevation.
PVector svgTransformPoint (float[] m, float x, float y, float cx, float cy, float cz, float sx, float sy, float sz) {
  float mx = m[0] * x + m[2] * y + m[4];
  float my = m[1] * x + m[3] * y + m[5];
  float flippedY = -my;
  return new PVector(cx + sx * mx, cy + sy * flippedY, cz);
}
