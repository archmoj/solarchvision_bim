class Drop3D {

  final static String CLASS_STAMP = "Drop3D";

  void selection () {
    if (currentObjectCategory == ObjectCategory.MODEL1D) this.Model1Ds();
    else if (currentObjectCategory == ObjectCategory.MODEL2D) this.Model2Ds();
  }

  // Casts one ray from ray_start in ray_direction. WIN3D.toolParameterModifier selects
  // the target: 0 = Terrain, faceParam = allFaces, anything else = no hit.
  float[] castRay (float[] ray_start, float[] ray_direction, int faceParam) {
    if (WIN3D.toolParameterModifier == 0) {
      return Terrain.intersect(ray_start, ray_direction);
    }
    if (WIN3D.toolParameterModifier == faceParam) {
      return allFaces.intersect(ray_start, ray_direction);
    }

    float[] RxP = new float[8];
    RxP[0] = -1; // undefined
    return RxP;
  }

  // Tries dropping (x, y, z) straight down first (parameter 1 selects allFaces there);
  // if that misses, tries straight up instead (parameter 2 selects allFaces there).
  float[] castDrop (float x, float y, float z) {
    float[] ray_start = { x, y, z };

    float[] down = castRay(ray_start, new float[] { 0, 0, -1 }, 1);
    if (down[0] >= 0) return down;

    return castRay(ray_start, new float[] { 0, 0, 1 }, 2); // <<<< going upwards
  }

  void Model1Ds () {
    for (int o = Select3D.Model1DIndices.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.Model1DIndices[o];

      float[] RxP = castDrop(allModel1Ds.getX(OBJ_ID), allModel1Ds.getY(OBJ_ID), allModel1Ds.getZ(OBJ_ID));
      if (RxP[0] >= 0) {
        allModel1Ds.setX(OBJ_ID, RxP[1]);
        allModel1Ds.setY(OBJ_ID, RxP[2]);
        allModel1Ds.setZ(OBJ_ID, RxP[3]);
      }
    }

    model_changed();
  }

  void Model2Ds () {
    for (int o = Select3D.Model2DIndices.length - 1; o >= 0; o--) {
      int OBJ_ID = Select3D.Model2DIndices[o];

      float[] RxP = castDrop(allModel2Ds.getX(OBJ_ID), allModel2Ds.getY(OBJ_ID), allModel2Ds.getZ(OBJ_ID));
      if (RxP[0] >= 0) {
        allModel2Ds.setX(OBJ_ID, RxP[1]);
        allModel2Ds.setY(OBJ_ID, RxP[2]);
        allModel2Ds.setZ(OBJ_ID, RxP[3]);
      }
    }

    model_changed();
  }
}
