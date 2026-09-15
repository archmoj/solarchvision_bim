float[] SOLARCHVISION_snap_Faces (float[] RxP) {

  if (RxP[0] >= 0) {

    int f = int(RxP[0]);
    float x = RxP[1];
    float y = RxP[2];
    float z = RxP[3];

    if (User3D.create_Snap == 1) { // nearest endpoint

      float nearest_D = FLOAT_undefined;
      float nearest_X = FLOAT_undefined;
      float nearest_Y = FLOAT_undefined;
      float nearest_Z = FLOAT_undefined;

      int mt = allFaces.getMaterial(f);

      int tessellation = allFaces.getTessellation(f);

      int totalNumberOfSubs = 1;
      if (allFaces.getMaterial(f) == 0) {
        tessellation += allFaces.displayTessellation;
      }
      if (tessellation > 0) totalNumberOfSubs = allFaces.nodes[f].length * int(funcs.roundTo(pow(4, tessellation - 1), 1));

      float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];
        base_Vertices[j][0] = allPoints.getX(vNo);
        base_Vertices[j][1] = allPoints.getY(vNo);
        base_Vertices[j][2] = allPoints.getZ(vNo);
      }

      for (int n = 0; n < totalNumberOfSubs; n++) {

        float[][] subFace = funcs.getSubFace(base_Vertices, tessellation, n);

        WIN3D.graphics.beginShape();

        for (int s = 0; s < subFace.length; s++) {

          float d = dist(x, y, z, subFace[s][0], subFace[s][1], subFace[s][2]);

          if (nearest_D > d) {
            nearest_D = d;
            nearest_X = subFace[s][0];
            nearest_Y = subFace[s][1];
            nearest_Z = subFace[s][2];
          }
        }
      }

      if (is_defined(nearest_D)) {
        RxP[1] = nearest_X;
        RxP[2] = nearest_Y;
        RxP[3] = nearest_Z;
      }
    }
  }

  return RxP;
}
