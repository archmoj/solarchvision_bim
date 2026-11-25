// Minimal, dependency-free exporter for a DXF file - the write-side
// counterpart to importDxf.pde, and (like every other exporter in this
// app) built directly against this app's own allFaces/allPolylines, not
// a shared "GIS export core" the way exportGeojson.pde's family is -
// DXF is a CAD/drafting interchange format, not a geodetic one, so there
// is no coordinate reverse-projection step at all here: every vertex is
// written exactly as this app's own local XY(Z) meters, the same
// already-local-planar posture exportScr.pde's/exportObj.pde's own
// coordinates already take.
//
// Entity choice per allFaces entry - this file's own mirror of
// importDxf.pde's own "only entities that actually carry solid 3D face
// geometry" scope:
//   - a 3- or 4-point Face -> one 3DFACE entity, DXF's own simplest
//     native way to carry exactly that - and, since this app's own
//     Points/Faces keep no separate notion of "this was really a
//     triangle written with a 4th point repeated" vs. "this really only
//     ever had 3 points" (importDxf.pde's own 3DFACE comment makes the
//     same observation on the way in), a 3-point Face's own 4th-point
//     group codes (13/23/33) are written as the 3rd point's own
//     coordinates repeated, the "more common real-world convention"
//     importDxf.pde's own header comment already documents preferring
//     to read - this is both the more interoperable form for other real
//     DXF readers (some tooling special-cases "4th point group codes
//     entirely absent" as a different/stricter kind of record) and
//     exactly what importDxf.pde's own isTriangle check already expects
//     back, so round-tripping through this app's own importer recovers
//     a true 3-point face either way.
//   - a Face with more than 4 points -> one polyface-mesh POLYLINE
//     entity (group 70 bit 64), DXF's own older, AutoCAD-native indexed-
//     mesh mechanism - but NOT as a single n-gon face record: a
//     polyface mesh's own per-face VERTEX record has only 4 index slots
//     (group codes 71-74), the exact same 3-or-4-point ceiling 3DFACE
//     itself has (importDxf.pde's own dxfHandleVertex() reads at most
//     those same four codes per face record), so an n>4 Face is written
//     as one shared point-list (this Face's own n points, each its own
//     coordinate VERTEX) followed by a FAN of (n-2) triangular face-
//     definition VERTEX records (triangle i = points [0, i, i+1] for
//     i = 1..n-2) referencing that shared list by 1-based index.
//     Reimporting this file through this app's own DXF importer
//     therefore recovers (n-2) separate triangular Faces, not the
//     original single n-gon - this app's own data model keeps no "these
//     N triangles were really one n-gon" link to reconstruct from, the
//     same one-way restraint exportGeojson.pde's own header comment
//     already documents for an extruded solid's own several independent
//     Faces.
//   - a hidden Face/Polyline (getVisibility() <= 0) is skipped entirely,
//     the same "only ever export what's actually visible" filter every
//     other exporter in this app already applies (exportGeojson.pde's
//     own header comment).
//
// Polylines: every allPolylines entry becomes one plain (non-polyface)
// POLYLINE entity - group 70 bit 3 (value 8, "this is a 3D polyline")
// always set, since this app's own polylines can carry an arbitrary Z
// per vertex, unlike DXF's own LWPOLYLINE (a strictly planar entity,
// one shared elevation for every vertex - not used here for exactly
// that reason), plus bit 1 (value 1) when getClose() says closed -
// followed by one VERTEX per point (group 70 value 32, "3D polyline
// vertex", groups 10/20/30 its own coordinates) and a closing SEQEND.
// Every point count from 2 upward is written this same one way - no
// special-cased bare LINE entity for the common 2-point case, since a
// plain POLYLINE with exactly 2 vertices already reads back correctly
// through importDxf.pde's own dxfHandlePolylineStart()/dxfHandleVertex()
// path (gated, like every other drafting-geometry entity on the way
// in, behind that importer's own dxfImportCurves toggle) - one
// mechanism per shape category, the same restraint this app's own other
// exporters already show by not branching into multiple entity/feature
// shapes for what is fundamentally the one geometry kind.
//
// Layer AND material, both folded into one DXF layer name: DXF's own
// per-entity "layer" (group code 8) is the one and only grouping signal
// importDxf.pde's own importer reads at all (that file's own header
// comment: "each entity's own layer... becomes this importer's own
// group/material-cycling boundary") - there is no separate per-entity
// "material"/color channel it reads back the way every GIS exporter's
// own JSON/XML "properties" bag can carry "material" and "layer" as two
// independent round-trippable fields. Rather than silently dropping
// this app's own material number on the way out (or writing it
// somewhere - such as the ACI color group code 62 - this importer
// would never read back, the same "don't invent a channel the paired
// importer doesn't use" restraint DXF import's own header comment
// already takes toward SPLINE/MESH/etc.), both are folded into one
// composite, human-readable DXF layer name string via
// exportDxfLayerName() below: "LAYER_<layer>_MAT_<material>". Reimporting
// this file (with material cycling requested, the same m==-1 convention
// every other importer's own grouping toggle already uses) therefore
// starts a new group at exactly the boundaries where this app's own
// (material, layer) pair actually changed, not just where "layer" alone
// changed - folding both into the one string DXF's own layer mechanism
// offers is what makes that possible, where writing "layer" alone would
// have silently merged two Faces that only ever differed by material.
//
// File structure: a minimal `$ACADVER` HEADER section (declaring `AC1009`,
// DXF's R12 version - the plainest, most universally-read DXF dialect,
// and already the implicit dialect every entity type and group code
// this file writes belongs to) followed directly by the ENTITIES
// section and EOF - no TABLES/BLOCKS/CLASSES/OBJECTS sections at all.
// importDxf.pde's own importer needs none of those (its own header
// comment: only entities actually seen while inside the ENTITIES
// section are dispatched, and TABLES/BLOCKS are skipped outright even
// when present), and real-world DXF readers (AutoCAD included) already
// tolerate a missing TABLES section by falling back to default
// definitions for any layer name they encounter that was never formally
// defined - so, consistent with exportScr.pde's own similarly minimal
// posture, nothing beyond what actually carries geometry is written.
//
// Written as plain group-code/value text lines via a small
// dxfWritePair()-style helper - the same hand-rolled, no-external-
// library choice importDxf.pde's own header comment already documents
// making for its own, read-side half of this exact format.

void exportDxf () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit
  // point below, so nothing further to guard); cleared at this
  // function's own end.
  isFileOperationInProgress = true;

  String dxfFilename = Folder_Export3D + "/" + ProjectName + ".dxf";

  PrintWriter dxfOutput = createWriter(dxfFilename);

  dxfWritePair(dxfOutput, 0, "SECTION");
  dxfWritePair(dxfOutput, 2, "HEADER");
  dxfWritePair(dxfOutput, 9, "$ACADVER");
  dxfWritePair(dxfOutput, 1, "AC1009");
  dxfWritePair(dxfOutput, 0, "ENDSEC");

  dxfWritePair(dxfOutput, 0, "SECTION");
  dxfWritePair(dxfOutput, 2, "ENTITIES");

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if (allFaces.getVisibility(f) <= 0) continue;
    if (allFaces.nodes[f].length < 3) continue;

    String layerName = exportDxfLayerName(allFaces.getMaterial(f), allFaces.getLayer(f));

    if (allFaces.nodes[f].length <= 4) {
      exportDxfWrite3dFace(dxfOutput, allFaces.nodes[f], layerName);
    } else {
      exportDxfWritePolyfaceMesh(dxfOutput, allFaces.nodes[f], layerName);
    }
  }

  for (int p = 0; p < allPolylines.nodes.length; p++) {

    if (allPolylines.getVisibility(p) <= 0) continue;
    if (allPolylines.nodes[p].length < 2) continue;

    String layerName = exportDxfLayerName(allPolylines.getMaterial(p), allPolylines.getLayer(p));

    exportDxfWritePolyline(dxfOutput, allPolylines.nodes[p], allPolylines.getClose(p) == 1, layerName);
  }

  dxfWritePair(dxfOutput, 0, "ENDSEC");
  dxfWritePair(dxfOutput, 0, "EOF");

  dxfOutput.flush();
  dxfOutput.close();

  println("\nFile created:" + dxfFilename);

  isFileOperationInProgress = false;
}

// This file's own header comment, "Layer AND material, both folded
// into one DXF layer name" - the one composite grouping string every
// written entity's own group code 8 uses.
String exportDxfLayerName (int material, int layer) {
  return "LAYER_" + layer + "_MAT_" + material;
}

// A 3- or 4-point Face -> one 3DFACE entity - this file's own header
// comment, "Entity choice per allFaces entry".
void exportDxfWrite3dFace (PrintWriter out, int[] faceNodes, String layerName) {

  dxfWritePair(out, 0, "3DFACE");
  dxfWritePair(out, 8, layerName);

  exportDxfWritePoint(out, faceNodes[0], 10, 20, 30);
  exportDxfWritePoint(out, faceNodes[1], 11, 21, 31);
  exportDxfWritePoint(out, faceNodes[2], 12, 22, 32);

  // A true 3-point Face repeats its own 3rd point's coordinates as the
  // 4th - this file's own header comment explains why.
  int fourthNode = (faceNodes.length >= 4) ? faceNodes[3] : faceNodes[2];
  exportDxfWritePoint(out, fourthNode, 13, 23, 33);
}

// A Face with more than 4 points -> one polyface-mesh POLYLINE entity,
// its own point list fan-triangulated into (n-2) triangular face-
// definition records - this file's own header comment, "Entity choice
// per allFaces entry".
void exportDxfWritePolyfaceMesh (PrintWriter out, int[] faceNodes, String layerName) {

  int n = faceNodes.length;
  int triangleCount = n - 2;

  dxfWritePair(out, 0, "POLYLINE");
  dxfWritePair(out, 8, layerName);
  dxfWritePair(out, 66, 1); // "entities follow" flag - required on every POLYLINE
  dxfWritePair(out, 70, 64); // bit 64: polyface mesh (importDxf.pde's own dxfHandlePolylineStart())
  dxfWritePair(out, 71, n); // vertex (point-list) count - informational, mirrors real-world writers
  dxfWritePair(out, 72, triangleCount); // face count - informational

  for (int i = 0; i < n; i++) {
    dxfWritePair(out, 0, "VERTEX");
    dxfWritePair(out, 8, layerName);
    dxfWritePair(out, 70, 128); // "polyface mesh vertex" (a point-list coordinate record)
    exportDxfWritePoint(out, faceNodes[i], 10, 20, 30);
  }

  for (int i = 1; i <= triangleCount; i++) {
    dxfWritePair(out, 0, "VERTEX");
    dxfWritePair(out, 8, layerName);
    dxfWritePair(out, 70, 192); // 128 (polyface mesh vertex) + 64 (3D polygon mesh) - a face-definition record
    // A face-definition VERTEX's own 10/20/30 coordinate is never read
    // by anything (importDxf.pde's own dxfHandleVertex() only inspects
    // 71-74 to tell a face-definition record apart from a coordinate
    // one) - written as the origin, the same harmless placeholder every
    // real-world polyface-mesh writer already uses for this record.
    dxfWritePair(out, 10, 0);
    dxfWritePair(out, 20, 0);
    dxfWritePair(out, 30, 0);
    dxfWritePair(out, 71, 1); // 1-based index into the point list above, in writing order
    dxfWritePair(out, 72, i + 1);
    dxfWritePair(out, 73, i + 2);
  }

  dxfWritePair(out, 0, "SEQEND");
}

// Every Polyline, any point count - a plain (non-polyface) 3D POLYLINE
// entity - this file's own header comment, "Polylines".
void exportDxfWritePolyline (PrintWriter out, int[] polylineNodes, boolean closed, String layerName) {

  dxfWritePair(out, 0, "POLYLINE");
  dxfWritePair(out, 8, layerName);
  dxfWritePair(out, 66, 1); // "entities follow" flag - required on every POLYLINE
  dxfWritePair(out, 70, closed ? 9 : 8); // bit 8: 3D polyline; bit 1: closed

  for (int i = 0; i < polylineNodes.length; i++) {
    dxfWritePair(out, 0, "VERTEX");
    dxfWritePair(out, 8, layerName);
    dxfWritePair(out, 70, 32); // "3D polyline vertex"
    exportDxfWritePoint(out, polylineNodes[i], 10, 20, 30);
  }

  dxfWritePair(out, 0, "SEQEND");
}

// One allPoints index -> one point's own x/y/z group-code triple, at
// whichever three group codes the caller's own entity uses for "a
// point" (3DFACE's own 4 corners each use a different triple; VERTEX
// always uses 10/20/30) - formatted with the same User3D.
// exporterPrecisionVertex every other exporter in this app already
// shares (exportScr.pde's/exportObj.pde's own identical nf() calls).
void exportDxfWritePoint (PrintWriter out, int pointIndex, int codeX, int codeY, int codeZ) {
  float x = allPoints.getX(pointIndex);
  float y = allPoints.getY(pointIndex);
  float z = allPoints.getZ(pointIndex);

  dxfWritePair(out, codeX, nf(x, 0, User3D.exporterPrecisionVertex));
  dxfWritePair(out, codeY, nf(y, 0, User3D.exporterPrecisionVertex));
  dxfWritePair(out, codeZ, nf(z, 0, User3D.exporterPrecisionVertex));
}

// One group-code/value line pair - DXF's own whole-file shape
// (importDxf.pde's own header comment: "a flat sequence of 'group
// code'/'value' pairs, each on its own line"), String/int/float
// overloads so every call site above can pass whichever already has the
// value in hand without its own extra str()/nf() wrapping.
void dxfWritePair (PrintWriter out, int code, String value) {
  out.println(code);
  out.println(value);
}

void dxfWritePair (PrintWriter out, int code, int value) {
  out.println(code);
  out.println(value);
}
