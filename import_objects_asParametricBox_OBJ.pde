float SOLARCHVISION_import_objects_asParametricBox_OBJ (String FileName, int m, float cx, float cy, float cz, float sx, float sy, float sz) {

  float[][] importVertices = {
    {
    }
  };

  String[] FileALL = loadStrings(FileName);

  importedObjectName = OPESYS.getFilenameFromPath(FileName);

  String lineSTR;
  String[] input;

  //println("lines = ", FileALL.length);

  for (int f = 0; f < FileALL.length; f++) {

    lineSTR = FileALL[f];
    //println(lineSTR);

    lineSTR = lineSTR.replace("  ", " ");

    String[] parts = split(lineSTR, ' ');

    if (parts[0].toLowerCase().equals("v")) {

      float x = cx + sx * float(parts[1]);
      float y = cy + sy * float(parts[2]);
      float z = cz + sz * float(parts[3]);

      float[][] v = {
        {
          x, y, z
        }
      };

      importVertices = (float[][]) concat(importVertices, v);
    }
  }

  float min_X = FLOAT_undefined;
  float max_X = -FLOAT_undefined;
  float min_Y = FLOAT_undefined;
  float max_Y = -FLOAT_undefined;
  float min_Z = FLOAT_undefined;
  float max_Z = -FLOAT_undefined;

  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = importVertices[vNo][0];
    float y = importVertices[vNo][1];
    float z = importVertices[vNo][2];

    if (min_X > x) min_X = x;
    if (max_X < x) max_X = x;
    if (min_Y > y) min_Y = y;
    if (max_Y < y) max_Y = y;
    if (min_Z > z) min_Z = z;
    if (max_Z < z) max_Z = z;
  }

  float cen_X = 0.5 * (min_X + max_X);
  float cen_Y = 0.5 * (min_Y + max_Y);
  float cen_Z = 0.5 * (min_Z + max_Z);

  float R_out = 0;
  float X_out = 0;
  float Y_out = 0;
  float Z_out = 0;

  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = importVertices[vNo][0];
    float y = importVertices[vNo][1];
    float z = importVertices[vNo][2];

    float r = dist(cen_X, cen_Y, cen_Z, x, y, z);

    if (R_out < r) {
      R_out = r;

      X_out = x;
      Y_out = y;
      Z_out = z;
    }
  }

  float T_out = funcs.atan2_ang(Y_out, X_out);

  X_out = 0;
  Y_out = 0;
  Z_out = 0;

  for (int vNo = 1; vNo < importVertices.length; vNo++) {
    float x = (importVertices[vNo][0] - cen_X) * funcs.cos_ang(-T_out) - (importVertices[vNo][1] - cen_Y) * funcs.sin_ang(-T_out);
    float y = (importVertices[vNo][0] - cen_X) * funcs.sin_ang(-T_out) + (importVertices[vNo][1] - cen_Y) * funcs.cos_ang(-T_out);
    float z = importVertices[vNo][2];

    if (X_out < abs(x)) X_out = abs(x);
    if (Y_out < abs(y)) Y_out = abs(y);
    if (Z_out < abs(z)) Z_out = abs(z);
  }

  //Create3D.add_Box_Core(m, cen_X,cen_Y,cen_Z, X_out,Y_out,Z_out, T_out);
  allSolids.create(cen_X, cen_Y, cen_Z, CubePower, CubePower, CubePower, X_out, Y_out, Z_out, 0, 0, T_out, 1);

  return min_Z;
}
