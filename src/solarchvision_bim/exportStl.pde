// Minimal, dependency-free exporter for an ASCII STL file - the write-
// side counterpart to importStl.pde, built directly against this app's
// own allFaces/allPoints, the same already-local-planar, no-reverse-
// projection posture exportDxf.pde's own header comment already takes
// (STL, like DXF, is a CAD/mesh interchange format, not a geodetic one).
// Written as the plain-text ASCII variant only, never binary - STL's
// binary variant exists purely to save space/parse time on a huge mesh,
// and every other text-capable exporter in this app (OBJ, DXF, SCR, the
// whole GeoJSON/KML/CityGML/TopoJSON family) already prefers its own
// format's plain-text form for exactly that "easy to inspect, easy to
// hand-write, no byte-order/size-table bookkeeping" reason - the one
// exception, exportLas.pde, writes binary only because LAS itself has
// no text variant to prefer.
//
// Scope - STL's own format has no concept at all beyond a flat bag of
// independent triangles:
//   - no shared vertex table (unlike importPly.pde's own "face"
//     element, which indexes into one whole-file vertex list) - every
//     triangle restates its own 3 corners' coordinates directly, the
//     same way exportDxf.pde's own 3DFACE entities already do.
//   - no material, layer, or any other per-triangle attribute at all -
//     so, unlike every GIS exporter's own "material"/"layer" properties
//     or exportDxf.pde's own composite layer-name encoding, there is
//     nothing here to fold a Face's own material/layer into; STL simply
//     has no channel to carry either back out.
//   - no line/curve element of any kind - so, unlike every previous
//     exporter in this app (which could always write a Polyline as
//     *something*: a GeoJSON LineString, a DXF POLYLINE, PLY's own
//     "edge" element, ...), STL cannot represent this app's own
//     Polylines at all. They are skipped entirely, with one end-of-
//     export notice printed if any were (this file's own exportStl()).
//   - a Face with more than 3 corners is fan-triangulated from its own
//     first corner into (corners-2) triangles - the same technique
//     exportDxf.pde's own polyface-mesh fallback already uses for a
//     >4-corner Face, just applied starting at 3 corners here instead
//     of 4, since STL's own "facet" is a pure triangle with no larger-
//     polygon variant at all (unlike DXF's own 3DFACE, which can at
//     least hold a quad directly). Reimporting the written file
//     therefore recovers (corners-2) separate triangular Faces, not the
//     original single polygon - the same one-way "this app's own data
//     model keeps no reconstruction link" restraint exportDxf.pde's own
//     header comment already documents for its own, less severe (4-
//     corner) ceiling.
//   - a hidden Face (getVisibility() <= 0) is skipped, the same filter
//     every other exporter in this app already applies.
//
// Each triangle's own "facet normal" is computed here (the cross
// product of its own 2nd-corner-minus-1st and 3rd-corner-minus-1st
// edges, normalized; a degenerate/zero-area triangle writes a bare
// "0 0 0" normal rather than dividing by zero) and written into the
// file - importStl.pde's own header comment notes that its READER never
// trusts a file's own normal (this app always derives its own), but
// other real-world STL consumers (slicers, other viewers) generally do
// rely on it for shading/orientation, so a real, non-placeholder normal
// is written for their benefit even though this app's own importer
// would ignore it either way.
//
// The whole scene becomes one single "solid ... endsolid" block (named
// after ProjectName) - ASCII STL's only notion of a sub-object boundary,
// and the one thing importStl.pde's own ASCII reader actually reacts to
// (cycling material on every "solid" line, regardless of what name
// follows it - see that file's own stlImportAscii()): a single block is
// correct here since this app has no reason to split one export into
// several named solids.

void exportStl () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit
  // point below, so nothing further to guard); cleared at this
  // function's own end.
  isFileOperationInProgress = true;

  String stlFilename = Folder_Export3D + "/" + ProjectName + ".stl";

  PrintWriter stlOutput = createWriter(stlFilename);

  stlOutput.println("solid " + ProjectName);

  int trianglesWritten = 0;

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    int[] faceNodes = allFaces.nodes[f];
    int triangleCount = faceNodes.length - 2;

    for (int i = 1; i <= triangleCount; i++) {
      exportStlWriteTriangle(stlOutput, faceNodes[0], faceNodes[i], faceNodes[i + 1]);
      trianglesWritten += 1;
    }
  }

  stlOutput.println("endsolid " + ProjectName);

  stlOutput.flush();
  stlOutput.close();

  int skippedPolylines = 0;
  for (int p = 0; p < allPolylines.nodes.length; p++) {
    if (allPolylines.getVisibility(p) <= 0) continue;
    if (allPolylines.nodes[p].length < 2) continue;
    skippedPolylines += 1;
  }
  if (skippedPolylines > 0) {
    println("\nSTL export note: " + skippedPolylines + " polyline(s) were not included - STL has no line/curve element at all, see exportStl.pde's own header comment");
  }

  println("\nFile created:" + stlFilename + " (" + trianglesWritten + " triangle(s))");

  isFileOperationInProgress = false;
}

// One triangle -> one "facet normal.../outer loop/vertex*3/endloop/
// endfacet" block - this file's own header comment on the normal.
void exportStlWriteTriangle (PrintWriter out, int p0, int p1, int p2) {

  float x0 = allPoints.getX(p0), y0 = allPoints.getY(p0), z0 = allPoints.getZ(p0);
  float x1 = allPoints.getX(p1), y1 = allPoints.getY(p1), z1 = allPoints.getZ(p1);
  float x2 = allPoints.getX(p2), y2 = allPoints.getY(p2), z2 = allPoints.getZ(p2);

  float ex1 = x1 - x0, ey1 = y1 - y0, ez1 = z1 - z0;
  float ex2 = x2 - x0, ey2 = y2 - y0, ez2 = z2 - z0;

  float nx = ey1 * ez2 - ez1 * ey2;
  float ny = ez1 * ex2 - ex1 * ez2;
  float nz = ex1 * ey2 - ey1 * ex2;

  float len = sqrt(nx * nx + ny * ny + nz * nz);
  if (len > 0.000001) {
    nx /= len; ny /= len; nz /= len;
  } else {
    nx = 0; ny = 0; nz = 0; // degenerate/zero-area triangle - no well-defined normal
  }

  out.println("facet normal " + nf(nx, 0, User3D.exporterPrecisionVertex) + " " + nf(ny, 0, User3D.exporterPrecisionVertex) + " " + nf(nz, 0, User3D.exporterPrecisionVertex));
  out.println("outer loop");
  out.println("vertex " + nf(x0, 0, User3D.exporterPrecisionVertex) + " " + nf(y0, 0, User3D.exporterPrecisionVertex) + " " + nf(z0, 0, User3D.exporterPrecisionVertex));
  out.println("vertex " + nf(x1, 0, User3D.exporterPrecisionVertex) + " " + nf(y1, 0, User3D.exporterPrecisionVertex) + " " + nf(z1, 0, User3D.exporterPrecisionVertex));
  out.println("vertex " + nf(x2, 0, User3D.exporterPrecisionVertex) + " " + nf(y2, 0, User3D.exporterPrecisionVertex) + " " + nf(z2, 0, User3D.exporterPrecisionVertex));
  out.println("endloop");
  out.println("endfacet");
}
