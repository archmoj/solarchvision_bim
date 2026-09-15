void ViewFromTheSky (float SKY2D_position_X, float SKY2D_position_Y, float SKY2D_position_Z, float SKY2D_rotation_X, float SKY2D_rotation_Y, float SKY2D_rotation_Z) {

  SKY2D_graphics.beginDraw();

  SKY2D_graphics.background(233);

  SKY2D_graphics.ortho(SKY2D_X_View / -SKY2D_ZOOM, SKY2D_X_View / SKY2D_ZOOM, SKY2D_Y_View / -SKY2D_ZOOM, SKY2D_Y_View / SKY2D_ZOOM, 0.00001, 100000);

  SKY2D_graphics.translate(0.5 * SKY2D_X_View, 0.5 * SKY2D_Y_View, 0); // << IMPORTANT!

  SKY2D_graphics.translate(SKY2D_position_X, SKY2D_position_Y, SKY2D_position_Z);
  SKY2D_graphics.rotateX(SKY2D_rotation_X * PI / 180);
  SKY2D_graphics.rotateY(SKY2D_rotation_Y * PI / 180);
  SKY2D_graphics.rotateZ(SKY2D_rotation_Z * PI / 180);

  SKY2D_graphics.hint(ENABLE_DEPTH_TEST);

  Land3D.draw(TypeWindow.SKY2D);

  for (int f = 0; f < allFaces.nodes.length; f++) {

    int vsb = allFaces.getVisibility(f);

    if (vsb > 0) {

      color c = color(0, 0, 0);

      int mt = allFaces.getMaterial(f);
      c = color(allMaterials.Color[mt][1], allMaterials.Color[mt][2], allMaterials.Color[mt][3], allMaterials.Color[mt][0]);

      SKY2D_graphics.stroke(c);
      SKY2D_graphics.fill(c);

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

        SKY2D_graphics.beginShape();

        for (int s = 0; s < subFace.length; s++) {

          SKY2D_graphics.vertex(subFace[s][0], -subFace[s][1], subFace[s][2]);
        }

        SKY2D_graphics.endShape(CLOSE);
      }
    }
  }

  SKY2D_graphics.endDraw();
}
