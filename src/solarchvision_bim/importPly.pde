// Minimal, dependency-free importer for a PLY (Polygon File Format /
// Stanford Triangle Format) file - the same "hand-roll the parser, no
// external library" choice import_objects_OBJ.pde/import_objects_IFC.
// pde/import_objects_GLB.pde/import_objects_STL.pde/import_objects_DXF.
// pde already make for their own formats. PLY's own spec is fully
// public (Stanford, no licensing question at all, unlike DXF's "openly
// published but still proprietary" status).
//
// PLY always starts with a plain-text header (even in a binary file -
// only the DATA section after it differs) declaring, in order, a list
// of "element"s (e.g. "vertex", "face"), each with its own ordered list
// of "property" fields - either a plain scalar (a type and a name) or a
// list (a count type, a value type, and a name - e.g. a face's own
// vertex-index list). plyParseHeader() reads that header once, byte by
// byte (not via loadStrings() - see its own comment for why), building
// plyElements/plyFormat and returning the exact byte offset the DATA
// section starts at; plyImportAscii()/plyImportBinary() (one or the
// other, depending on plyFormat) then walk every element's own declared
// instances in that same order, property by property, exactly as
// declared - the only way to read either variant correctly, since nothing
// in the data section itself names which property is which.
//
// v1 scope, deliberately kept simple - only the two elements, and
// properties, that matter for solid mesh geometry:
//   - "vertex": only its own "x"/"y"/"z" properties (case-insensitive)
//     are read; every other property a vertex might carry (normals,
//     per-vertex color, confidence/quality, texture coordinates, ...) is
//     correctly skipped over (still needed to stay in sync - see
//     plySizeOf()) without being interpreted.
//   - "face": only its own FIRST list property is read, as that face's
//     vertex-index list (whatever its own name happens to be -
//     "vertex_indices" and "vertex_index" are both common in the wild,
//     so this deliberately doesn't match on a specific name at all); any
//     list or scalar properties after it (a rare per-face color, or a
//     second list for e.g. per-corner texture coordinates) are skipped.
//     Each face becomes one single app-native face however many corners
//     its own index list has (3 or more) - the same "whatever n-gon the
//     file itself declares, not forced into triangles" choice
//     import_objects_IFC.pde's own n-gon faces and import_objects_DXF.
//     pde's own 3DFACE/polyface-mesh faces already make.
//   - Any OTHER element (e.g. "edge", or a custom one some tool adds) is
//     skipped entirely, its own instances still correctly walked
//     property by property so the shared byte/line cursor stays in sync
//     for whatever comes after it.
//
// No OBJ "g"/STL "solid"/DXF "layer"-style natural sub-object boundary
// exists in PLY at all - its own element list is just a small, fixed set
// of homogeneous arrays, closer in shape to binary STL's own single
// implicit solid - so the whole imported file is always a single group.

boolean plyImportShowOptionsDialog = false;

// Transform parameters for the CURRENT import_objects_PLY() call - same
// "a few fields shared across one whole import" shape glb_cx/... (import_
// objects_GLB.pde) already uses.
float ply_cx, ply_cy, ply_cz, ply_sx, ply_sy, ply_sz;

String plyFormat = ""; // "ascii" / "binary_little_endian" / "binary_big_endian", read from the header

class PlyProperty {
  boolean isList;
  String countType; // only meaningful when isList
  String valueType; // for a list: its own value type; for a scalar: the property's own type
  String name;
}

class PlyElement {
  String name;
  int count;
  ArrayList<PlyProperty> properties = new ArrayList<PlyProperty>();
}

ArrayList<PlyElement> plyElements = new ArrayList<PlyElement>();

int plyFacesImported = 0;

long ply_totalInstances = 0;
long ply_processedInstances = 0;
float ply_printedProgress = 0;
ProgressWindow ply_progressWindow = null;

void import_objects_PLY (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  // Same shape as import_objects_OBJ()'s/import_objects_GLB()'s/
  // import_objects_STL()'s/import_objects_DXF()'s own identical blocks -
  // see any one's own comment, or ifcImportShowOptionsDialog's (import_
  // objects_IFC.pde), for why this sits here rather than earlier, and
  // what a cancelled dialog does.
  if (plyImportShowOptionsDialog) {
    plyImportShowOptionsDialog = false;
    if (!axisSwapShowImportOptionsDialog("PLY import options")) return;
  }

  println("Importing PLY. Please wait...");
  showWaitCursor();

  if (m == -1) current_Material = 0;
  else current_Material = m;

  current_Tessellation = tes;
  current_Layer = lyr;
  current_Visibility = vsb;
  current_Weight = wgt;
  current_Closed = clz;

  ply_cx = cx; ply_cy = cy; ply_cz = cz;
  ply_sx = sx; ply_sy = sy; ply_sz = sz;

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

  byte[] raw = loadBytes(FileName);
  if ((raw == null) || (raw.length == 0)) {
    println("\nPLY import: could not read '" + FileName + "'");
    showArrowCursor();
    return;
  }

  int dataStartByteOffset = plyParseHeader(raw);
  if (dataStartByteOffset < 0) {
    println("\nPLY import: '" + FileName + "' doesn't look like a valid PLY file (missing the 'ply' magic line or 'end_header')");
    showArrowCursor();
    return;
  }

  ply_totalInstances = 0;
  for (PlyElement element : plyElements) ply_totalInstances += element.count;
  ply_processedInstances = 0;
  ply_printedProgress = 0;
  plyFacesImported = 0;

  progressBarHeader();

  ply_progressWindow = (showImportProgress && canShowProgressWindow()) ? new ProgressWindow("Importing PLY") : null;
  if (ply_progressWindow != null) ply_progressWindow.setVisible(true);

  try {
    if (plyFormat.equals("ascii")) {
      plyImportAscii(raw, dataStartByteOffset);
    } else if (plyFormat.equals("binary_little_endian")) {
      plyImportBinary(raw, dataStartByteOffset, true);
    } else if (plyFormat.equals("binary_big_endian")) {
      plyImportBinary(raw, dataStartByteOffset, false);
    } else {
      println("\nPLY import: unrecognized format '" + plyFormat + "' (expected ascii, binary_little_endian, or binary_big_endian)");
    }
  } finally {
    if (ply_progressWindow != null) ply_progressWindow.dispose();
    ply_progressWindow = null;
  }

  if (plyFacesImported == 0) {
    println("\nPLY import: no faces were imported - this version only reads the 'vertex' element's own x/y/z and the 'face' element's own first list property (its vertex-index list)");
  }

  int remaining = (int) floor(100 - ply_printedProgress);
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < remaining; c++) barBuffer.append('█');
  print(barBuffer.toString());
  println();

  showArrowCursor();
}

// One console/ProgressWindow update, called once per element instance
// processed (vertex, face, or any skipped element alike) - same
// delta >= 1 throttle glbReportProgress() (import_objects_GLB.pde)
// already uses.
void plyReportProgress () {
  if (control == USER_AUTO) return;

  ply_processedInstances += 1;

  float Progress = (ply_totalInstances > 0) ? (100 * ply_processedInstances / (float) ply_totalInstances) : 100;
  int delta = (int) floor(Progress - ply_printedProgress);
  if (delta >= 1) {
    StringBuilder barBuffer = new StringBuilder();
    for (int c = 0; c < delta; c++) barBuffer.append('█');
    print(barBuffer.toString());
    ply_printedProgress = floor(Progress);
    if (ply_progressWindow != null) ply_progressWindow.updateFraction(Progress / 100.0f);
  }
}

// One point, carried through cx/cy/cz/sx/sy/sz and importSwapAxisYZ
// (fileSelected.pde, shared with every other importer) the same way
// those already do.
int plyCreatePoint (float x, float y, float z) {
  float finalX, finalY, finalZ;
  if (importSwapAxisYZ) {
    finalX = ply_cx + ply_sx * x;
    finalY = ply_cy + ply_sy * (-z);
    finalZ = ply_cz + ply_sz * y;
  } else {
    finalX = ply_cx + ply_sx * x;
    finalY = ply_cy + ply_sy * y;
    finalZ = ply_cz + ply_sz * z;
  }
  return allPoints.create(finalX, finalY, finalZ);
}

// Byte size of one PLY scalar type - both its "short" names (char,
// uchar, short, ushort, int, uint, float, double) and its fixed-width
// aliases (int8, uint8, int16, uint16, int32, uint32, float32, float64)
// are in real use, so both are recognized. -1 for anything else -
// callers treat that as "stop importing, this file uses something this
// version doesn't recognize" rather than guess and silently desync the
// rest of a binary file's own byte cursor.
int plySizeOf (String type) {
  if (type.equals("char") || type.equals("uchar") || type.equals("int8") || type.equals("uint8")) return 1;
  if (type.equals("short") || type.equals("ushort") || type.equals("int16") || type.equals("uint16")) return 2;
  if (type.equals("int") || type.equals("uint") || type.equals("float") || type.equals("float32") || type.equals("int32") || type.equals("uint32")) return 4;
  if (type.equals("double") || type.equals("float64")) return 8;
  return -1;
}

// Reads `size` bytes at `off` as a plain unsigned integer, widened into
// a long - correct, and all this importer ever needs, for list counts
// and vertex-index values (always non-negative in real files); NOT
// correct for a genuinely negative signed value, which this importer
// never reads one of.
long plyReadUInt (byte[] b, int off, int size, boolean littleEndian) {
  long v = 0;
  if (littleEndian) {
    for (int i = 0; i < size; i++) v |= ((long) (b[off + i] & 0xFF)) << (8 * i);
  } else {
    for (int i = 0; i < size; i++) v = (v << 8) | (b[off + i] & 0xFF);
  }
  return v;
}

// Reads one value of PLY type `type` at `off` as a plain number -
// bit-reinterpreted as float/double for those two types (their only
// sensible reading), or just the plain unsigned integer value widened to
// double for anything else (an x/y/z property declared as an integer
// type would be unusual, but still reads as a real number this way,
// rather than being bit-reinterpreted into nonsense the way reusing the
// float/double path for every type would).
double plyReadNumber (byte[] b, int off, String type, boolean littleEndian) {
  if (type.equals("float") || type.equals("float32")) {
    long bits = plyReadUInt(b, off, 4, littleEndian);
    return Float.intBitsToFloat((int) bits);
  }
  if (type.equals("double") || type.equals("float64")) {
    long bits = plyReadUInt(b, off, 8, littleEndian);
    return Double.longBitsToDouble(bits);
  }
  int size = plySizeOf(type);
  return (double) plyReadUInt(b, off, size, littleEndian);
}

// Scans `raw` for PLY's own text header (always ASCII/UTF-8, regardless
// of the file's declared ascii/binary DATA format - only the data
// section after "end_header" differs) - returns the byte offset right
// after "end_header"'s own line terminator (where the data section
// begins), or -1 if the leading "ply" line or "end_header" itself wasn't
// found. Reads the header byte-by-byte (not via loadStrings(), the
// pattern every other text-based importer here uses) specifically so the
// exact byte offset the data starts at is known precisely - the only way
// to find a BINARY file's own data section at all, since there's no
// line-based structure to fall back on there once the header ends.
int plyParseHeader (byte[] raw) {
  plyElements.clear();
  plyFormat = "";

  int pos = 0;
  boolean firstLine = true;
  PlyElement currentElement = null;

  while (pos < raw.length) {
    int lineStart = pos;
    while ((pos < raw.length) && (raw[pos] != '\n')) pos += 1;
    int lineEnd = pos; // exclusive, not counting '\n'
    if (pos < raw.length) pos += 1; // consume the '\n' itself

    int trimmedEnd = lineEnd;
    if ((trimmedEnd > lineStart) && (raw[trimmedEnd - 1] == '\r')) trimmedEnd -= 1; // tolerate CRLF line endings too

    String line = new String(raw, lineStart, trimmedEnd - lineStart, java.nio.charset.StandardCharsets.UTF_8).trim();

    if (firstLine) {
      firstLine = false;
      if (!line.equals("ply")) return -1;
      continue;
    }

    if (line.length() == 0) continue;

    String[] tokens = splitTokens(line);
    if ((tokens == null) || (tokens.length == 0)) continue;

    String kw = tokens[0];

    if (kw.equals("format")) {
      if (tokens.length >= 2) plyFormat = tokens[1];
    } else if (kw.equals("element")) {
      if (tokens.length >= 3) {
        currentElement = new PlyElement();
        currentElement.name = tokens[1];
        currentElement.count = int(tokens[2]);
        plyElements.add(currentElement);
      }
    } else if (kw.equals("property")) {
      if ((currentElement != null) && (tokens.length >= 3)) {
        PlyProperty prop = new PlyProperty();
        if (tokens[1].equals("list") && (tokens.length >= 5)) {
          prop.isList = true;
          prop.countType = tokens[2];
          prop.valueType = tokens[3];
          prop.name = tokens[4];
        } else {
          prop.isList = false;
          prop.valueType = tokens[1];
          prop.name = tokens[2];
        }
        currentElement.properties.add(prop);
      }
    } else if (kw.equals("end_header")) {
      return pos; // pos already advanced past this line's own newline
    }
    // "comment"/"obj_info" and anything else: ignored
  }

  return -1; // no "end_header" found
}

void plyImportAscii (byte[] raw, int dataStartByteOffset) {
  String dataText = new String(raw, dataStartByteOffset, raw.length - dataStartByteOffset, java.nio.charset.StandardCharsets.UTF_8);
  String[] lines = split(dataText, '\n');

  // allPoints index for every "vertex" instance, in file order - a face's
  // own index list is always a plain 0-based index into this same,
  // single, whole-file vertex list.
  IntList vertexGlobalIndex = new IntList();

  int lineIdx = 0;

  for (PlyElement element : plyElements) {
    boolean isVertex = element.name.equals("vertex");
    boolean isFace = element.name.equals("face");

    for (int n = 0; n < element.count; n++) {
      plyReportProgress();

      if (lineIdx >= lines.length) {
        println("\nPLY import: data ends before the header's own element/property counts expected it to - stopping early");
        return;
      }

      String[] tokens = splitTokens(trim(lines[lineIdx]));
      lineIdx += 1;
      if (tokens == null) tokens = new String[0];

      int tokenIdx = 0;
      float x = 0, y = 0, z = 0;
      IntList faceIndices = null;

      for (PlyProperty prop : element.properties) {
        if (prop.isList) {
          if (tokenIdx >= tokens.length) break;
          int count = int(tokens[tokenIdx]);
          tokenIdx += 1;

          if (isFace && (faceIndices == null)) {
            faceIndices = new IntList();
            for (int k = 0; k < count; k++) {
              if (tokenIdx >= tokens.length) break;
              faceIndices.append(int(tokens[tokenIdx]));
              tokenIdx += 1;
            }
          } else {
            tokenIdx += count; // a non-face list, or this face's 2nd+ list property - skipped
          }
        } else {
          if (tokenIdx >= tokens.length) break;
          String tok = tokens[tokenIdx];
          tokenIdx += 1;

          if (isVertex) {
            if (prop.name.equalsIgnoreCase("x")) x = float(tok);
            else if (prop.name.equalsIgnoreCase("y")) y = float(tok);
            else if (prop.name.equalsIgnoreCase("z")) z = float(tok);
          }
        }
      }

      if (isVertex) {
        vertexGlobalIndex.append(plyCreatePoint(x, y, z));
      } else if (isFace) {
        plyEmitFace(faceIndices, vertexGlobalIndex);
      }
    }
  }
}

void plyImportBinary (byte[] raw, int dataStartByteOffset, boolean littleEndian) {
  int pos = dataStartByteOffset;

  IntList vertexGlobalIndex = new IntList(); // same role as plyImportAscii()'s own

  for (PlyElement element : plyElements) {
    boolean isVertex = element.name.equals("vertex");
    boolean isFace = element.name.equals("face");

    for (int n = 0; n < element.count; n++) {
      plyReportProgress();

      float x = 0, y = 0, z = 0;
      IntList faceIndices = null;
      boolean truncatedOrUnsupported = false;

      for (PlyProperty prop : element.properties) {
        if (prop.isList) {
          int countSize = plySizeOf(prop.countType);
          int valueSize = plySizeOf(prop.valueType);
          if ((countSize < 0) || (valueSize < 0) || (pos + countSize > raw.length)) { truncatedOrUnsupported = true; break; }

          int count = (int) plyReadUInt(raw, pos, countSize, littleEndian);
          pos += countSize;

          if (isFace && (faceIndices == null)) {
            faceIndices = new IntList();
            for (int k = 0; k < count; k++) {
              if (pos + valueSize > raw.length) { truncatedOrUnsupported = true; break; }
              faceIndices.append((int) plyReadUInt(raw, pos, valueSize, littleEndian));
              pos += valueSize;
            }
          } else {
            // Computed and bounds-checked as a long, not plain int
            // multiplication, before being added to pos: a corrupted
            // file's garbage count value could otherwise overflow
            // count * valueSize as an int before this ever gets the
            // chance to notice it runs past the end of raw.
            long skipBytes = (long) count * valueSize;
            if (pos + skipBytes > raw.length) { truncatedOrUnsupported = true; break; }
            pos += (int) skipBytes; // safe to narrow: already checked pos + skipBytes <= raw.length, itself a valid (so, int-range) array length
          }
        } else {
          int valueSize = plySizeOf(prop.valueType);
          if ((valueSize < 0) || (pos + valueSize > raw.length)) { truncatedOrUnsupported = true; break; }

          if (isVertex) {
            double v = plyReadNumber(raw, pos, prop.valueType, littleEndian);
            if (prop.name.equalsIgnoreCase("x")) x = (float) v;
            else if (prop.name.equalsIgnoreCase("y")) y = (float) v;
            else if (prop.name.equalsIgnoreCase("z")) z = (float) v;
          }
          pos += valueSize;
        }
      }

      if (truncatedOrUnsupported) {
        println("\nPLY import: truncated binary data, or a property type this version doesn't recognize - stopping early");
        return;
      }

      if (isVertex) {
        vertexGlobalIndex.append(plyCreatePoint(x, y, z));
      } else if (isFace) {
        plyEmitFace(faceIndices, vertexGlobalIndex);
      }
    }
  }
}

// Builds one app-native face from a face element instance's own already-
// read index list (whatever length - 3 or more - it declared), mapping
// each 0-based PLY vertex index through vertexGlobalIndex (the
// allPoints index actually created for it, in file order) - shared by
// plyImportAscii()/plyImportBinary() so this lookup/bounds-checking
// logic exists exactly once.
void plyEmitFace (IntList faceIndices, IntList vertexGlobalIndex) {
  if ((faceIndices == null) || (faceIndices.size() < 3)) return;

  int[] face = new int[faceIndices.size()];
  for (int k = 0; k < face.length; k++) {
    int vi = faceIndices.get(k);
    if ((vi < 0) || (vi >= vertexGlobalIndex.size())) return; // out-of-range index - skip this face rather than build it from a wrong/nonexistent point
    face[k] = vertexGlobalIndex.get(vi);
  }

  allFaces.create(face);
  plyFacesImported += 1;
}
