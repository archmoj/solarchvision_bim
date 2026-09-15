void SOLARCHVISION_import_objects_OBJ (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {
  println("Importing OBJ. Please wait...");

  if (m == -1) current_Material = 0;
  else current_Material = m;

  // OBJ vertex indices are 1-based, so index 0 is an unused placeholder,

  IntList importVerticeNumber = new IntList();
  importVerticeNumber.append(0);

  String[] FileALL = loadStrings(FileName);
  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  float totalLines = FileALL.length; // computed once, not every iteration
  float Progress = 0;
  float printed_Progress = 0;
  StringBuilder barBuffer = new StringBuilder();

  progressBarHeader();

  for (int f = 0; f < FileALL.length; f++) {
    Progress = 100 * f / totalLines;
    int delta = (int) floor(Progress - printed_Progress);
    if (delta >= 1) {
      barBuffer.setLength(0);
      for (int c = 0; c < delta; c++) {
        barBuffer.append('█');
      }
      print(barBuffer.toString()); // one print() call instead of `delta` calls
      printed_Progress = floor(Progress);
    }

    String lineSTR = FileALL[f];

    String[] parts = splitTokens(lineSTR);
    if (parts == null || parts.length == 0) continue; // skip blank lines

    String tag = parts[0];

    if (tag.equalsIgnoreCase("g")) {
      if (m == -1) current_Material = 1 + (current_Material % 8);
      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    } else if (tag.equalsIgnoreCase("v")) {
      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);
      importVerticeNumber.append(allPoints.create(x, -z, y));
    } else if (tag.equalsIgnoreCase("f")) {
      int FaceDegree = parts.length - 1;
      int[] newFace = new int[FaceDegree];
      for (int n = 0; n < newFace.length; n++) {
        String[] the_numbers = split(parts[n + 1], '/');
        int vertexNumber = int(the_numbers[0]);
        if (vertexNumber > 0) {
          newFace[n] = importVerticeNumber.get(vertexNumber);
        } else if (vertexNumber < 0) { // negative (relative) indexing
          newFace[n] = allPoints.getLength() - abs(vertexNumber);
        } // vertexNumber == 0: leave as default (0)
      }
      allFaces.create(newFace);
    }
    // any other tag (vt, vn, usemtl, mtllib, #comment, ...) is intentionally
    // ignored.
  }

  int remaining = (int) floor(100 - printed_Progress);
  barBuffer.setLength(0);
  for (int c = 0; c < remaining; c++) {
    barBuffer.append('█');
  }
  print(barBuffer.toString());
  println();
}
