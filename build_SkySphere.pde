void SOLARCHVISION_build_SkySphere (int tessellation) {
  //Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0,0,0, 1, tessellation, 1, 90); // SKY
  //Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 4, 1, 90); // SKY
  Create3D.add_CrystalSphere(0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 3, 1, 90); // SKY

  ArrayList<float[]> diffuseList = new ArrayList<float[]>();

  for (int i = 0; i < skyFaces.length; i++) {
    int[] face = skyFaces[i];
    int n = face.length;
    float invN = 1.0f / n;

    float x = 0, y = 0, z = 0;
    for (int j = 0; j < n; j++) {
      float[] v = skyVertices[face[j]];
      x += v[0] * invN;
      y += v[1] * invN;
      z += v[2] * invN;
    }

    if (z > 0) {
      diffuseList.add(new float[]{x, y, z});
    }
  }

  DiffuseVectors = diffuseList.toArray(new float[diffuseList.size()][3]);
}
