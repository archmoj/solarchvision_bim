// Minimal, dependency-free exporter for a LAS (the ASPRS "LASer" format)
// file - the write-side counterpart to importLas.pde, and the same
// "hand-roll the bytes, no external library" choice that file (and
// exportScr.pde's own plain AutoCAD-script writer) already make.
//
// Scope: every point currently in allPoints, as one LAS point data
// format 0 record each (X/Y/Z only - the smallest valid LAS point
// record, 20 bytes) - geometry only, nothing else, deliberately
// mirroring import_objects_LAS()'s own "only ever reads X/Y/Z" scope
// (importLas.pde's own header comment) on the way back out. That's the
// WHOLE of allPoints, not just points some face currently references -
// the same "every point in the pool, as-is" interpretation Points.draw()
// (points.pde) already uses for its own "show every point" display
// toggle, since this app's own allPoints array is append-only (deleting
// a face/solid never prunes the points it used) and has no separate
// "this point is still really part of something" bookkeeping to filter
// by - exporting exactly what that existing display feature already
// treats as "the project's whole point cloud" is the one interpretation
// that needs no new bookkeeping invented just for this. Index 0 is a
// real point like any other and is exported like any other - an earlier
// version of this file skipped it, on the mistaken assumption that
// Points.makeEmpty() (points.pde) left it as a non-geometry placeholder;
// it doesn't.
//
// Binary writing: this file's own binWriteU16LE()/binWriteU32LE()/
// binWriteLongLE()/binWriteDoubleLE() are the write-side mirror of
// importGlb.pde's own binReadU16LE()/binReadU32LE()/binReadLongLE()/
// binReadDoubleLE() - kept here rather than added to importGlb.pde's
// own shared read-only pool, since this is the first (and so far only)
// binary EXPORT in the whole app; every other exporter (exportObj.pde/
// exportScr.pde/exportRad.pde) writes plain text via a PrintWriter, so
// there's no existing "shared binary writer" home to add to, and no
// second consumer yet to justify starting one - same "don't
// generalize before a second caller actually needs it" reasoning
// meshPointCloud.pde was deliberately split out FOR, when LAS import
// and point-cloud meshing both genuinely needed the same algorithm.
//
// Header: written as a plain LAS 1.2 Public Header Block (227 bytes,
// point data format 0, no Variable Length Records at all - exactly
// mirroring import_objects_LAS()'s own "doesn't need VLRs, so doesn't
// write/read any" scope) - the oldest, most universally-supported real
// LAS version, so the file this writes opens in anything that reads LAS
// at all, including re-importing it right back into this same app.
//
// Scale/offset: X/Y/Z are stored as plain signed 32-bit integers (LAS's
// own requirement, not a choice this exporter makes - see import
// Las.pde's own matching comment on reading them back), so some scale/
// offset has to turn this app's own float coordinates into integers
// that fit. exportLasComputeScale() (below) starts from 0.001 (sub-
// millimeter precision for a project in meters - the same default real-
// world LAS writers like LAStools/PDAL commonly use) and only ever
// coarsens it, just enough to keep every point's own raw X/Y/Z safely
// inside signed 32-bit range for the project's own actual bounding box -
// correct (if coarser than ideal) for an unusually huge site, and
// identical to the plain 0.001 default for anything realistically
// smaller.

void exportLas (String suffix) {

  String fileBasename = ProjectName + suffix;
  String lasFilename = Folder_Export3D + "/" + fileBasename + ".las";

  int pointCount = allPoints.getLength();

  // The project's own bounding box - required LAS header fields in
  // their own right (Max/Min X/Y/Z), and also exactly what offsetX/Y/Z
  // (below) are built from. Left at (0, 0, 0) on both ends for an empty
  // project (pointCount == 0) - still a complete, valid (if trivial)
  // LAS file gets written either way, the same "write whatever there
  // actually is, no special-cased empty case" precedent exportScr.
  // pde's own exportAutocadScript() already sets for 0 faces/polylines.
  double minX = 0, maxX = 0, minY = 0, maxY = 0, minZ = 0, maxZ = 0;
  if (pointCount > 0) {
    minX = maxX = allPoints.getX(0);
    minY = maxY = allPoints.getY(0);
    minZ = maxZ = allPoints.getZ(0);
    for (int i = 1; i < pointCount; i++) {
      float x = allPoints.getX(i), y = allPoints.getY(i), z = allPoints.getZ(i);
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
      if (z < minZ) minZ = z;
      if (z > maxZ) maxZ = z;
    }
  }

  double scale = exportLasComputeScale(maxX - minX, maxY - minY, maxZ - minZ);
  double offsetX = minX, offsetY = minY, offsetZ = minZ; // the smallest point on each axis maps to raw integer 0 - simplest possible choice, and always safely representable by construction

  byte[] out = new byte[227 + pointCount * 20]; // 227-byte header (see this file's own header comment) + one 20-byte point-format-0 record per point; every byte starts at 0, which already IS the correct value for every field this exporter never explicitly writes (VLR count, legacy per-return counts, every non-geometry point field, ...)

  out[0] = 'L'; out[1] = 'A'; out[2] = 'S'; out[3] = 'F'; // File Signature
  // File Source ID (4-5) / Global Encoding (6-7) / Project ID GUID
  // (8-23): left 0 - none of these are assigned or meaningful for a
  // file this app itself just generated.
  out[24] = 1; out[25] = 2; // Version 1.2 - see this file's own header comment for why

  exportLasWriteAsciiPadded(out, 26, "SOLARCHVISION-BIM", 32); // System Identifier
  exportLasWriteAsciiPadded(out, 58, "SOLARCHVISION-BIM6D", 32); // Generating Software

  // File Creation Day of Year / Year - purely informational metadata
  // LAS readers don't rely on, filled in properly anyway since it costs
  // nothing: today's own real calendar date, not any date the project's
  // own simulated TIME/STUDY might currently be set to.
  // Unqualified Calendar/DAY_OF_YEAR/YEAR - java.util.* is already part
  // of Processing's own default sketch imports (the same reason
  // extraCommands.pde's own parseParams() can write a bare "HashMap"),
  // unlike javax.swing/java.awt (used fully-qualified elsewhere in this
  // app, e.g. fileSelected.pde's own dialogs) which aren't.
  Calendar creationDate = Calendar.getInstance();
  binWriteU16LE(out, 90, creationDate.get(Calendar.DAY_OF_YEAR));
  binWriteU16LE(out, 92, creationDate.get(Calendar.YEAR));

  binWriteU16LE(out, 94, 227); // Header Size
  binWriteU32LE(out, 96, 227); // Offset to point data - right after the header, since no VLRs are ever written (see this file's own header comment)
  binWriteU32LE(out, 100, 0); // Number of Variable Length Records
  out[104] = 0; // Point Data Record Format 0 (X/Y/Z + the smallest set of other fields LAS defines - all left 0, see this file's own header comment on scope)
  binWriteU16LE(out, 105, 20); // Point Data Record Length - format 0's own fixed 20 bytes
  binWriteU32LE(out, 107, pointCount); // Legacy Number of point records - this app has no path that could realistically produce anywhere near the ~4 billion-point ceiling this 32-bit field has, so no LAS-1.4-style 64-bit extended header is written at all; this one field is all a reader needs
  // Legacy Number of points by return (111-130, 5 x u32): left 0 - not
  // meaningful without real return-pulse semantics, the same way
  // import_objects_LAS() never reads it either.

  binWriteDoubleLE(out, 131, scale);
  binWriteDoubleLE(out, 139, scale);
  binWriteDoubleLE(out, 147, scale);
  binWriteDoubleLE(out, 155, offsetX);
  binWriteDoubleLE(out, 163, offsetY);
  binWriteDoubleLE(out, 171, offsetZ);
  binWriteDoubleLE(out, 179, maxX);
  binWriteDoubleLE(out, 187, minX);
  binWriteDoubleLE(out, 195, maxY);
  binWriteDoubleLE(out, 203, minY);
  binWriteDoubleLE(out, 211, maxZ);
  binWriteDoubleLE(out, 219, minZ);

  int pos = 227;
  for (int i = 0; i < pointCount; i++) {
    // Math.round(), not a plain (int) cast: truncating toward 0 would
    // bias every point's own raw X/Y/Z slightly toward offsetX/Y/Z
    // instead of to the file's own real nearest representable value -
    // small per point, but needless, and free to just do correctly.
    int rawX = (int) Math.round((allPoints.getX(i) - offsetX) / scale);
    int rawY = (int) Math.round((allPoints.getY(i) - offsetY) / scale);
    int rawZ = (int) Math.round((allPoints.getZ(i) - offsetZ) / scale);

    binWriteU32LE(out, pos, rawX);
    binWriteU32LE(out, pos + 4, rawY);
    binWriteU32LE(out, pos + 8, rawZ);
    // pos+12..pos+19 (Intensity/return+flags byte/Classification/Scan
    // Angle Rank/User Data/Point Source ID): left 0 - geometry only,
    // see this file's own header comment on scope.

    pos += 20;
  }

  saveBytes(lasFilename, out);

  println("\nFile created:" + lasFilename + " (" + pointCount + " point(s))");
}

// See this file's own header comment ("Scale/offset") for what this is
// for. Starts at 0.001 and only ever multiplies by 10 (coarser, never
// finer) until every point's own raw X/Y/Z - up to maxSpan/scale away
// from offsetX/Y/Z, the single farthest point on whichever axis has the
// project's own largest extent - safely clears signed 32-bit range with
// real headroom (2,000,000,000, not pushed right up against Integer.
// MAX_VALUE's own 2,147,483,647), not just barely inside it.
double exportLasComputeScale (double spanX, double spanY, double spanZ) {
  double scale = 0.001;
  // Plain comparisons rather than Processing's own max(): that's only
  // overloaded for int/float, not "double" - same reasoning importLas.
  // pde's own pointCount comparison (import_objects_LAS(), importLas.
  // pde) already gives for avoiding it with a wider type.
  double maxSpan = spanX;
  if (spanY > maxSpan) maxSpan = spanY;
  if (spanZ > maxSpan) maxSpan = spanZ;
  while ((maxSpan / scale) > 2000000000.0) scale *= 10;
  return scale;
}

// Writes a plain ASCII string into one of LAS's own fixed-length,
// null-padded text fields (System Identifier/Generating Software, both
// 32 bytes) - truncated if s itself is longer than fieldLength, which
// neither of this file's own 2 calls ever actually is. Padding needs no
// separate code of its own: b (exportLas()'s own out array) already
// starts every byte at 0, exactly LAS's own required pad value, so
// whatever this doesn't overwrite is already correct.
void exportLasWriteAsciiPadded (byte[] b, int off, String s, int fieldLength) {
  byte[] src = s.getBytes(java.nio.charset.StandardCharsets.US_ASCII);
  int n = min(src.length, fieldLength);
  System.arraycopy(src, 0, b, off, n);
}

// Little-endian byte writers - the exact write-side mirror of
// importGlb.pde's own binReadU16LE()/binReadU32LE()/binReadLongLE()/
// binReadDoubleLE() (see this file's own header comment for why these
// live here instead of growing that shared read-only pool).
void binWriteU16LE (byte[] b, int off, int v) {
  b[off] = (byte) (v & 0xFF);
  b[off + 1] = (byte) ((v >> 8) & 0xFF);
}

void binWriteU32LE (byte[] b, int off, int v) {
  b[off] = (byte) (v & 0xFF);
  b[off + 1] = (byte) ((v >> 8) & 0xFF);
  b[off + 2] = (byte) ((v >> 16) & 0xFF);
  b[off + 3] = (byte) ((v >> 24) & 0xFF);
}

void binWriteLongLE (byte[] b, int off, long v) {
  for (int i = 0; i < 8; i++) b[off + i] = (byte) ((v >> (8 * i)) & 0xFF);
}

void binWriteDoubleLE (byte[] b, int off, double v) {
  binWriteLongLE(b, off, Double.doubleToLongBits(v));
}
