
void SOLARCHVISION_build_SkySphere (int tessellation) {

  //Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0,0,0, 1, tessellation, 1, 90); // SKY
  //Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 4, 1, 90); // SKY
  Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 3, 1, 90); // SKY

  DiffuseVectors = new float[0][3];

  for (int i = 0; i < skyFaces.length; i++) {

    float x = 0;
    float y = 0;
    float z = 0;

    for (int j = 0; j < skyFaces[i].length; j++) {

      x += skyVertices[skyFaces[i][j]][0] / float(skyFaces[i].length);
      y += skyVertices[skyFaces[i][j]][1] / float(skyFaces[i].length);
      z += skyVertices[skyFaces[i][j]][2] / float(skyFaces[i].length);

      if (z > 0) {
        float[][] new_Vector = {{x, y, z}};
        DiffuseVectors = (float[][]) concat(DiffuseVectors, new_Vector);
      }
    }
  }

}