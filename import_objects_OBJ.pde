void SOLARCHVISION_import_objects_OBJ (String FileName, int m, int tes, int lyr, int vsb, int wgt, int clz, float cx, float cy, float cz, float sx, float sy, float sz) {

  if (m == -1) current_Material = 0;
  else current_Material = m;

  int[] importVerticeNumber = {
    0
  };

  String[] FileALL = loadStrings(FileName);

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  String lineSTR;
  String[] input;

  //println("lines = ", FileALL.length);

  float Progress = 0;

  for (int f = 0; f < FileALL.length; f++) {

    if (1 + Progress < 100 * f / float(FileALL.length)) {
      Progress = 100 * f / float(FileALL.length);
      //println("Progress:", int(Progress), "%");
    }

    lineSTR = FileALL[f];
    //println(lineSTR);

    lineSTR = lineSTR.replace("  ", " ");

    String[] parts = split(lineSTR, ' ');

    if (parts[0].toLowerCase().equals("g")) {
      if (m == -1) current_Material = 1 + (current_Material % 8);

      if (addToLastGroup == false) allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    }

    if (parts[0].toLowerCase().equals("v")) {

      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);

      int[] v = {
        allPoints.create(x, y, z)
      };

      importVerticeNumber = concat(importVerticeNumber, v);
    }

    if (parts[0].toLowerCase().equals("f")) {

      //println(parts);

      int FaceDegree = parts.length - 1; // if we don't have space at the end of the line.

      if (parts[FaceDegree].equals("")) {  // if we have 1 space at the end of the line.
        FaceDegree -= 1;
      }

      int[] newFace = new int [FaceDegree];

      for (int n = 0; n < newFace.length; n++) {

        String[] the_numbers = split(parts[n + 1], '/');

        int vertexNumber = int(the_numbers[0]);

        if (vertexNumber > 0) {
          newFace[n] = importVerticeNumber[vertexNumber];
        } else if (vertexNumber < 0) { // for negative numbering
          newFace[n] = allPoints.getLength() - abs(vertexNumber);
        } else { // case 0
        }
      }

      //println(newFace);

      allFaces.create(newFace);
    }
  }

  println("Progress: 100 %");
}
