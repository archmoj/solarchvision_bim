// Minimal, dependency-free exporter for an ASCII PLY (Polygon File
// Format / Stanford Triangle Format) file - the write-side counterpart
// to importPly.pde, built directly against this app's own allFaces/
// allPolylines/allPoints, the same already-local-planar, no-reverse-
// projection posture exportDxf.pde's/exportStl.pde's own header
// comments already take. Written as the "ascii 1.0" format variant
// only, never either binary one - the same "prefer the text form" choice
// exportStl.pde's own header comment already explains for its own
// format.
//
// Scope - PLY is the richest of the three CAD/mesh exporters in this
// app (DXF, STL, and this one) at carrying this app's own geometry
// back out intact:
//   - every visible Face (3 or more corners) -> one "face" element
//     instance, its own exact corner count and winding written as one
//     list property - no triangulation/fan-splitting needed at all,
//     unlike exportDxf.pde's own 4-corner ceiling or exportStl.pde's own
//     3-corner one, since PLY's own "face" element (importPly.pde's own
//     plyEmitFace()) already reads an arbitrary-length index list
//     directly as one n-gon Face.
//   - every visible Polyline -> a RUN of "edge" element instances, one
//     per consecutive pair of its own points (plus one more closing the
//     loop back to the first point when getClose() says closed and the
//     Polyline has more than 2 points) - PLY's own "edge" element
//     (importPly.pde's own plyEmitEdge()) is always exactly one
//     isolated 2-point segment, with no multi-point chain and no
//     "closed" concept of its own at all, so this is the one place
//     this exporter's own output does NOT round-trip back to the
//     original single Polyline: reimporting (with plyImportCurves
//     turned on - see below) recovers one separate 2-point Polyline per
//     edge instead, the same one-way "this app's own data model keeps
//     no reconstruction link" restraint already documented by
//     exportDxf.pde's own >4-corner Face fallback and exportStl.pde's
//     own >3-corner one. A closed 2-point Polyline (a degenerate loop -
//     there is only one distinct segment to begin with) writes that one
//     edge once, not twice.
//   - a hidden Face/Polyline (getVisibility() <= 0) is skipped, the
//     same filter every other exporter in this app already applies.
//   - no material, layer, or any other per-element attribute is written
//     at all - like STL, base PLY (beyond the small, fixed "vertex"/
//     "face"/"edge" shape this app's own importer reads) has no
//     standard per-element property this app's own round-trip could
//     use for it, the same "nothing to fold a Face's own material/
//     layer into" situation exportStl.pde's own header comment already
//     describes.
//   - unlike every one of this app's OTHER exporters (DXF's 3DFACE/
//     POLYLINE, STL's "facet", every GIS Feature/Placemark/...), which
//     all restate a shape's own corner coordinates independently with
//     no cross-entity sharing at all, PLY's own "vertex"/"face"/"edge"
//     shape is explicitly built around ONE shared, deduplicated whole-
//     file vertex table that every face/edge indexes into - so this is
//     the one exporter in this app that builds an actual index remap
//     (exportPlyVertexRemap(), below) rather than writing coordinates
//     inline every time. A point shared between two touching Faces (or
//     a Face and a Polyline) in this app's own scene - genuinely
//     possible, since this app's own allPoints already supports it -
//     is written to the file exactly once and referenced by index from
//     both, the same real mesh-connectivity PLY's own format is
//     actually meant to carry (and the same "the file's own repetition
//     doesn't have to restate shared geometry" opportunity OBJ's own
//     shared "v" list - exportObj.pde - already takes, just reached
//     here by a direct allFaces/allPolylines walk instead of that
//     file's own whole-scene draw() pipeline).
//
// Reimporting any Polyline's own written "edge" instances needs
// importPly.pde's own plyImportCurves toggle turned on first (off by
// default - that importer's own header comment) - the exact same
// "drafting/curve geometry is opt-in on the way back in" gating every
// other curve-capable importer in this app already applies
// (dxfImportCurves, objImportCurves, glbImportCurves, ...).

void exportPly () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit
  // point below, so nothing further to guard); cleared at this
  // function's own end.
  isFileOperationInProgress = true;

  String plyFilename = Folder_Export3D + "/" + ProjectName + ".ply";

  // Collect every visible Face/Polyline once, up front, both to build
  // the shared vertex remap (this file's own header comment) and to
  // know every element's own final count before a single header line
  // is written - PLY's own header declares each element's own count
  // ahead of its data, unlike every line-oriented format this app's
  // other exporters already write, where nothing needs to be known in
  // advance.
  ArrayList<int[]> faces = new ArrayList<int[]>();
  for (int f = 0; f < allFaces.nodes.length; f++) {
    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;
    faces.add(allFaces.nodes[f]);
  }

  ArrayList<int[]> edges = new ArrayList<int[]>(); // each entry: {originalPointIndexA, originalPointIndexB}
  for (int p = 0; p < allPolylines.nodes.length; p++) {
    if (allPolylines.getVisibility(p) <= 0) continue;
    int[] polylineNodes = allPolylines.nodes[p];
    if (polylineNodes.length < 2) continue;

    for (int i = 0; i < polylineNodes.length - 1; i++) {
      edges.add(new int[]{ polylineNodes[i], polylineNodes[i + 1] });
    }
    if ((allPolylines.getClose(p) == 1) && (polylineNodes.length > 2)) {
      edges.add(new int[]{ polylineNodes[polylineNodes.length - 1], polylineNodes[0] });
    }
  }

  // This file's own header comment, "builds an actual index remap" -
  // first-appearance order, walking Faces then Polylines/edges.
  java.util.LinkedHashMap<Integer, Integer> remap = new java.util.LinkedHashMap<Integer, Integer>();
  for (int[] faceNodes : faces) {
    for (int node : faceNodes) exportPlyRemapPoint(remap, node);
  }
  for (int[] edge : edges) {
    exportPlyRemapPoint(remap, edge[0]);
    exportPlyRemapPoint(remap, edge[1]);
  }

  PrintWriter plyOutput = createWriter(plyFilename);

  plyOutput.println("ply");
  plyOutput.println("format ascii 1.0");
  plyOutput.println("comment SOLARCHVISION");
  plyOutput.println("element vertex " + remap.size());
  plyOutput.println("property float x");
  plyOutput.println("property float y");
  plyOutput.println("property float z");
  plyOutput.println("element face " + faces.size());
  plyOutput.println("property list uchar int vertex_indices");
  plyOutput.println("element edge " + edges.size());
  plyOutput.println("property int vertex1");
  plyOutput.println("property int vertex2");
  plyOutput.println("end_header");

  // Written in the same first-appearance order the remap itself was
  // built in, so each original point's own written line number exactly
  // matches the new index every face/edge below references.
  for (Integer originalIndex : remap.keySet()) {
    float x = allPoints.getX(originalIndex);
    float y = allPoints.getY(originalIndex);
    float z = allPoints.getZ(originalIndex);
    plyOutput.println(nf(x, 0, User3D.exporterPrecisionVertex) + " " + nf(y, 0, User3D.exporterPrecisionVertex) + " " + nf(z, 0, User3D.exporterPrecisionVertex));
  }

  for (int[] faceNodes : faces) {
    StringBuilder line = new StringBuilder();
    line.append(faceNodes.length);
    for (int node : faceNodes) {
      line.append(' ').append(remap.get(node));
    }
    plyOutput.println(line.toString());
  }

  for (int[] edge : edges) {
    plyOutput.println(remap.get(edge[0]) + " " + remap.get(edge[1]));
  }

  plyOutput.flush();
  plyOutput.close();

  println("\nFile created:" + plyFilename + " (" + faces.size() + " face(s), " + edges.size() + " edge(s))");

  isFileOperationInProgress = false;
}

// Assigns `originalIndex` the next sequential remapped index the first
// time it's seen, leaving an already-seen index's own mapping
// untouched - this file's own header comment, "builds an actual index
// remap".
void exportPlyRemapPoint (java.util.LinkedHashMap<Integer, Integer> remap, int originalIndex) {
  if (!remap.containsKey(originalIndex)) {
    remap.put(originalIndex, remap.size());
  }
}
