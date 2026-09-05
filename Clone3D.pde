class solarchvision_Clone3D {

  private final static String CLASS_STAMP = "Clone3D";

  int[] appendRange(int[] existing, int start, int end) {
    if (end <= start) return existing;
    int addCount = end - start;
    int[] result = new int[existing.length + addCount];
    arrayCopy(existing, result); // copies existing.length elements into result
    for (int i = 0; i < addCount; i++) {
      result[existing.length + i] = start + i;
    }
    return result;
  }

  void selection (boolean produce_same_variation) {

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
    }
    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Faces(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polylines(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solids(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Sections(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Cameras(produce_same_variation);
    }
    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Groups(produce_same_variation);
    }
  }

  void Model1Ds (boolean produce_same_variation) {
    int number_of_allModel1Ds_before = allModel1Ds.num;
    for (int o = 0; o < Select3D.Model1D_ids.length; o++) {
      int OBJ_ID = Select3D.Model1D_ids[o];
      float x = allModel1Ds.getX(OBJ_ID);
      float y = allModel1Ds.getY(OBJ_ID);
      float z = allModel1Ds.getZ(OBJ_ID);
      float d = allModel1Ds.getScale(OBJ_ID);
      float rot = allModel1Ds.getRotation(OBJ_ID);
      float tilt = allModel1Ds.getBranchTilt(OBJ_ID);
      float twist = allModel1Ds.getBranchTwist(OBJ_ID);
      float ratio = allModel1Ds.getBranchRatio(OBJ_ID);
      float base = allModel1Ds.getTreeBase(OBJ_ID);
      int n = allModel1Ds.getType(OBJ_ID);
      int dMax = allModel1Ds.getDegreeMax(OBJ_ID);
      int seed = allModel1Ds.getSeed(OBJ_ID);
      float trunkSize = allModel1Ds.getTrunkSize(OBJ_ID);
      float leafSize = allModel1Ds.getLeafSize(OBJ_ID);
      if (produce_same_variation == false) randomSeed(millis());
      allModel1Ds.create(n, seed, dMax, x, y, z, d, rot, tilt, twist, ratio, base, trunkSize, leafSize);
    }
    // selecting new objects
    Select3D.deselect_Model1Ds();
    Select3D.Model1D_ids = appendRange(Select3D.Model1D_ids, number_of_allModel1Ds_before, allModel1Ds.num);
    SOLARCHVISION_selection_changed();
  }

  void Model2Ds (boolean produce_same_variation) {
    int number_of_allModel2Ds_before = allModel2Ds.num;
    for (int o = 0; o < Select3D.Model2D_ids.length; o++) {
      int OBJ_ID = Select3D.Model2D_ids[o];
      float x = allModel2Ds.getX(OBJ_ID);
      float y = allModel2Ds.getY(OBJ_ID);
      float z = allModel2Ds.getZ(OBJ_ID);
      float s = allModel2Ds.getS(OBJ_ID);
      int n = allModel2Ds.MAP[OBJ_ID];
      if (allModel2Ds.isTree(n)) {
        if (produce_same_variation == false) n = 0; // this makes it random
        allModel2Ds.create("TREES", n, x, y, z, s);
      } else {
        if (produce_same_variation == false) n = 0; // this makes it random
        allModel2Ds.create("PEOPLE", n, x, y, z, s);
      }
    }
    // selecting new objects
    Select3D.deselect_Model2Ds();
    Select3D.Model2D_ids = appendRange(Select3D.Model2D_ids, number_of_allModel2Ds_before, allModel2Ds.num);
    SOLARCHVISION_selection_changed();
  }


  void Faces (boolean produce_same_variation) {
    int number_of_Faces_before = allFaces.nodes.length;
    for (int o = 0; o < Select3D.Face_ids.length; o++) {
      int f = Select3D.Face_ids[o];
      int number_of_Vertices_before = allPoints.getLength();
      HashMap<Integer, Integer> vertexIndexMap = new HashMap<Integer, Integer>();
      if ((0 <= f) && (f < allFaces.nodes.length)) {
        IntList newFace_nodes = new IntList();
        int nextNewVertexIndex = 0;
        for (int j = 0; j < allFaces.nodes[f].length; j++) {
          int vNo = allFaces.nodes[f][j];
          Integer vertex_listed = vertexIndexMap.get(vNo);
          if (vertex_listed == null) {
            float x = allPoints.getX(vNo);
            float y = allPoints.getY(vNo);
            float z = allPoints.getZ(vNo);
            allPoints.create(x, y, z);
            vertex_listed = nextNewVertexIndex;
            vertexIndexMap.put(vNo, vertex_listed);
            nextNewVertexIndex++;
          }
          newFace_nodes.append(number_of_Vertices_before + vertex_listed);
        }
        current_Material = allFaces.getMaterial(f);
        current_Tessellation = allFaces.getTessellation(f);
        current_Layer = allFaces.getLayer(f);
        current_Visibility = allFaces.getVisibility(f);
        allFaces.create(newFace_nodes.array());
      }
    }
    // selecting new objects
    int number_of_Faces_after = allFaces.nodes.length;
    Select3D.Face_ids = appendRange(new int[0], number_of_Faces_before, number_of_Faces_after);
    SOLARCHVISION_selection_changed();
  }

  void Polylines (boolean produce_same_variation) {
    int number_of_Polylines_before = allPolylines.nodes.length;
    for (int o = 0; o < Select3D.Polyline_ids.length; o++) {
      int f = Select3D.Polyline_ids[o];
      int number_of_Vertices_before = allPoints.getLength();
      HashMap<Integer, Integer> vertexIndexMap = new HashMap<Integer, Integer>();
      if ((0 <= f) && (f < allPolylines.nodes.length)) {
        IntList newPolyline_nodes = new IntList();
        int nextNewVertexIndex = 0;
        for (int j = 0; j < allPolylines.nodes[f].length; j++) {
          int vNo = allPolylines.nodes[f][j];
          Integer vertex_listed = vertexIndexMap.get(vNo);
          if (vertex_listed == null) {
            float x = allPoints.getX(vNo);
            float y = allPoints.getY(vNo);
            float z = allPoints.getZ(vNo);
            allPoints.create(x, y, z);
            vertex_listed = nextNewVertexIndex;
            vertexIndexMap.put(vNo, vertex_listed);
            nextNewVertexIndex++;
          }
          newPolyline_nodes.append(number_of_Vertices_before + vertex_listed);
        }
        current_Material = allPolylines.getMaterial(f);
        current_Tessellation = allPolylines.getTessellation(f);
        current_Layer = allPolylines.getLayer(f);
        current_Visibility = allPolylines.getVisibility(f);
        current_Weight = allPolylines.getWeight(f);
        current_Closed = allPolylines.getClose(f);
        allPolylines.create(newPolyline_nodes.array());
      }
    }
    // selecting new objects
    int number_of_Polylines_after = allPolylines.nodes.length;
    Select3D.Polyline_ids = appendRange(new int[0], number_of_Polylines_before, number_of_Polylines_after);
    SOLARCHVISION_selection_changed();
  }

  void Solids (boolean produce_same_variation) {
    int number_of_Solid_before = allSolids.DEF.length;
    for (int o = 0; o < Select3D.Solid_ids.length; o++) {
      int OBJ_ID = Select3D.Solid_ids[o];
      float Solid_posX = allSolids.get_posX(OBJ_ID);
      float Solid_posY = allSolids.get_posY(OBJ_ID);
      float Solid_posZ = allSolids.get_posZ(OBJ_ID);
      float Solid_powX = allSolids.get_powX(OBJ_ID);
      float Solid_powY = allSolids.get_powY(OBJ_ID);
      float Solid_powZ = allSolids.get_powZ(OBJ_ID);
      float Solid_scaleX = allSolids.get_scaleX(OBJ_ID);
      float Solid_scaleY = allSolids.get_scaleY(OBJ_ID);
      float Solid_scaleZ = allSolids.get_scaleZ(OBJ_ID);
      float Solid_rotX = allSolids.get_rotX(OBJ_ID);
      float Solid_rotY = allSolids.get_rotY(OBJ_ID);
      float Solid_rotZ = allSolids.get_rotZ(OBJ_ID);
      float Solid_value = allSolids.get_value(OBJ_ID);
      allSolids.create(Solid_posX, Solid_posY, Solid_posZ, Solid_powX, Solid_powY, Solid_powZ, Solid_scaleX, Solid_scaleY, Solid_scaleZ, Solid_rotX, Solid_rotY, Solid_rotZ, Solid_value);
    }
    // selecting new objects
    Select3D.deselect_Solids();
    Select3D.Solid_ids = appendRange(Select3D.Solid_ids, number_of_Solid_before, allSolids.DEF.length);
    SOLARCHVISION_selection_changed();
  }

  void Sections (boolean produce_same_variation) {
    int number_of_Section_before = allSections.num;
    for (int o = 0; o < Select3D.Section_ids.length; o++) {
      int OBJ_ID = Select3D.Section_ids[o];
      float Section_X = allSections.getX(OBJ_ID);
      float Section_Y = allSections.getY(OBJ_ID);
      float Section_Z = allSections.getZ(OBJ_ID);
      float Section_R = allSections.getR(OBJ_ID);
      float Section_U = allSections.getU(OBJ_ID);
      float Section_V = allSections.getV(OBJ_ID);
      int Section_Type = allSections.get_type(OBJ_ID);
      int Section_RES1 = allSections.get_res1(OBJ_ID);
      int Section_RES2 = allSections.get_res2(OBJ_ID);
      allSections.create(Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_Type, Section_RES1, Section_RES2);
    }
    // selecting new objects
    Select3D.deselect_Sections();
    Select3D.Section_ids = appendRange(Select3D.Section_ids, number_of_Section_before, allSections.num);
    SOLARCHVISION_selection_changed();
  }

  void Cameras (boolean produce_same_variation) {
    int number_of_Camera_before = allCameras.num;
    for (int o = 0; o < Select3D.Camera_ids.length; o++) {
      int OBJ_ID = Select3D.Camera_ids[o];
      float Camera_pX = allCameras.get_posX(OBJ_ID);
      float Camera_pY = allCameras.get_posY(OBJ_ID);
      float Camera_pZ = allCameras.get_posZ(OBJ_ID);
      float Camera_pT = allCameras.get_posT(OBJ_ID);
      float Camera_rX = allCameras.get_rotX(OBJ_ID);
      float Camera_rY = allCameras.get_rotY(OBJ_ID);
      float Camera_rZ = allCameras.get_rotZ(OBJ_ID);
      float Camera_rT = allCameras.get_rotT(OBJ_ID);
      float Camera_zoom = allCameras.get_zoom(OBJ_ID);
      int Camera_type = allCameras.get_type(OBJ_ID);
      allCameras.create(Camera_pX, Camera_pY, Camera_pZ, Camera_pT, Camera_rX, Camera_rY, Camera_rZ, Camera_rT, Camera_zoom, Camera_type);
    }
    // selecting new objects
    Select3D.deselect_Cameras();
    Select3D.Camera_ids = appendRange(Select3D.Camera_ids, number_of_Camera_before, allCameras.num);
    SOLARCHVISION_selection_changed();
  }

  void Groups (boolean produce_same_variation) {
    int SOLID_added = 0;
    int number_of_allGroups_before = allGroups.num;
    for (int o = 0; o < Select3D.Group_ids.length; o++) {
      int OBJ_ID = Select3D.Group_ids[o];

      if ((0 <= allGroups.getStart_Face(OBJ_ID)) && (allGroups.getStart_Face(OBJ_ID) <= allGroups.getStop_Face(OBJ_ID))) {
        int number_of_Vertices_before = allPoints.getLength();
        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
        int new_OBJ_ID = allGroups.num - 1;
        for (int j = 0; j < allGroups.Pivots[OBJ_ID].length; j++) {
          allGroups.Pivots[new_OBJ_ID][j] = allGroups.Pivots[OBJ_ID][j];
        }

        if ((0 <= allGroups.getStop_Model1D(OBJ_ID)) && (allGroups.getStart_Model1D(OBJ_ID) <= allGroups.getStop_Model1D(OBJ_ID))) {
          for (int q = allGroups.getStart_Model1D(OBJ_ID); q <= allGroups.getStop_Model1D(OBJ_ID); q++) {
            float x = allModel1Ds.getX(q);
            float y = allModel1Ds.getY(q);
            float z = allModel1Ds.getZ(q);
            float d = allModel1Ds.getScale(q);
            float rot = allModel1Ds.getRotation(q);
            float tilt = allModel1Ds.getBranchTilt(q);
            float twist = allModel1Ds.getBranchTwist(q);
            float ratio = allModel1Ds.getBranchRatio(q);
            float base = allModel1Ds.getBranchRatio(q);
            int n = allModel1Ds.getType(q);
            int dMax = allModel1Ds.getDegreeMax(q);
            int seed = allModel1Ds.getSeed(q);
            float trunkSize = allModel1Ds.getTrunkSize(q);
            float leafSize = allModel1Ds.getLeafSize(q);
            if (produce_same_variation == false) {
              randomSeed(millis());
              rot = floor(random(360));
              seed = int(random(32767));
            }
            allModel1Ds.create(n, seed, dMax, x, y, z, d, rot, tilt, twist, ratio, base, trunkSize, leafSize);
          }
        }

        if ((0 <= allGroups.getStop_Model2D(OBJ_ID)) && (allGroups.getStart_Model2D(OBJ_ID) <= allGroups.getStop_Model2D(OBJ_ID))) {
          for (int q = allGroups.getStart_Model2D(OBJ_ID); q <= allGroups.getStop_Model2D(OBJ_ID); q++) {
            float x = allModel2Ds.getX(q);
            float y = allModel2Ds.getY(q);
            float z = allModel2Ds.getZ(q);
            float s = allModel2Ds.getS(q);
            int n = allModel2Ds.MAP[q];
            if (allModel2Ds.isTree(n)) {
              if (produce_same_variation == false) n = 0; // this makes it random
              allModel2Ds.create("TREES", n, x, y, z, s);
            } else {
              if (produce_same_variation == false) n = 0; // this makes it random
              allModel2Ds.create("PEOPLE", n, x, y, z, s);
            }
          }
        }

        if ((0 <= allGroups.getStop_Solid(OBJ_ID)) && (allGroups.getStart_Solid(OBJ_ID) <= allGroups.getStop_Solid(OBJ_ID))) {
          for (int q = allGroups.getStart_Solid(OBJ_ID); q <= allGroups.getStop_Solid(OBJ_ID); q++) {
            float Solid_posX = allSolids.get_posX(q);
            float Solid_posY = allSolids.get_posY(q);
            float Solid_posZ = allSolids.get_posZ(q);
            float Solid_powX = allSolids.get_powX(q);
            float Solid_powY = allSolids.get_powY(q);
            float Solid_powZ = allSolids.get_powZ(q);
            float Solid_scaleX = allSolids.get_scaleX(q);
            float Solid_scaleY = allSolids.get_scaleY(q);
            float Solid_scaleZ = allSolids.get_scaleZ(q);
            float Solid_rotX = allSolids.get_rotX(q);
            float Solid_rotY = allSolids.get_rotY(q);
            float Solid_rotZ = allSolids.get_rotZ(q);
            float Solid_value = allSolids.get_value(q);
            allSolids.create(Solid_posX, Solid_posY, Solid_posZ, Solid_powX, Solid_powY, Solid_powZ, Solid_scaleX, Solid_scaleY, Solid_scaleZ, Solid_rotX, Solid_rotY, Solid_rotZ, Solid_value);
            SOLID_added += 1;
          }
        }

        HashMap<Integer, Integer> vertexIndexMap = new HashMap<Integer, Integer>();
        int nextNewVertexIndex = 0;
        for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
          if ((0 <= f) && (f < allFaces.nodes.length)) {
            IntList newFace_nodes = new IntList();
            for (int j = 0; j < allFaces.nodes[f].length; j++) {
              int vNo = allFaces.nodes[f][j];
              Integer vertex_listed = vertexIndexMap.get(vNo);
              if (vertex_listed == null) {
                float x = allPoints.getX(vNo);
                float y = allPoints.getY(vNo);
                float z = allPoints.getZ(vNo);
                allPoints.create(x, y, z);
                vertex_listed = nextNewVertexIndex;
                vertexIndexMap.put(vNo, vertex_listed);
                nextNewVertexIndex++;
              }
              newFace_nodes.append(number_of_Vertices_before + vertex_listed);
            }
            current_Material = allFaces.getMaterial(f);
            current_Tessellation = allFaces.getTessellation(f);
            current_Layer = allFaces.getLayer(f);
            current_Visibility = allFaces.getVisibility(f);
            allFaces.create(newFace_nodes.array());
          }
        }
      }

      if ((0 <= allGroups.getStart_Polyline(OBJ_ID)) && (allGroups.getStart_Polyline(OBJ_ID) <= allGroups.getStop_Polyline(OBJ_ID))) {
        int number_of_Vertices_before = allPoints.getLength();
        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
        int new_OBJ_ID = allGroups.num - 1;
        for (int j = 0; j < allGroups.Pivots[OBJ_ID].length; j++) {
          allGroups.Pivots[new_OBJ_ID][j] = allGroups.Pivots[OBJ_ID][j];
        }

        if ((0 <= allGroups.getStop_Model1D(OBJ_ID)) && (allGroups.getStart_Model1D(OBJ_ID) <= allGroups.getStop_Model1D(OBJ_ID))) {
          for (int q = allGroups.getStart_Model1D(OBJ_ID); q <= allGroups.getStop_Model1D(OBJ_ID); q++) {
            float x = allModel1Ds.getX(q);
            float y = allModel1Ds.getY(q);
            float z = allModel1Ds.getZ(q);
            float d = allModel1Ds.getScale(q);
            float rot = allModel1Ds.getRotation(q);
            float tilt = allModel1Ds.getBranchTilt(q);
            float twist = allModel1Ds.getBranchTwist(q);
            float ratio = allModel1Ds.getBranchRatio(q);
            float base = allModel1Ds.getBranchRatio(q);
            int n = allModel1Ds.getType(q);
            int dMax = allModel1Ds.getDegreeMax(q);
            int seed = allModel1Ds.getSeed(q);
            float trunkSize = allModel1Ds.getTrunkSize(q);
            float leafSize = allModel1Ds.getLeafSize(q);
            if (produce_same_variation == false) {
              randomSeed(millis());
              rot = floor(random(360));
              seed = int(random(32767));
            }
            allModel1Ds.create(n, seed, dMax, x, y, z, d, rot, tilt, twist, ratio, base, trunkSize, leafSize);
          }
        }

        if ((0 <= allGroups.getStop_Model2D(OBJ_ID)) && (allGroups.getStart_Model2D(OBJ_ID) <= allGroups.getStop_Model2D(OBJ_ID))) {
          for (int q = allGroups.getStart_Model2D(OBJ_ID); q <= allGroups.getStop_Model2D(OBJ_ID); q++) {
            float x = allModel2Ds.getX(q);
            float y = allModel2Ds.getY(q);
            float z = allModel2Ds.getZ(q);
            float s = allModel2Ds.getS(q);
            int n = allModel2Ds.MAP[q];
            if (allModel2Ds.isTree(n)) {
              if (produce_same_variation == false) n = 0; // this makes it random
              allModel2Ds.create("TREES", n, x, y, z, s);
            } else {
              if (produce_same_variation == false) n = 0; // this makes it random
              allModel2Ds.create("PEOPLE", n, x, y, z, s);
            }
          }
        }

        if ((0 <= allGroups.getStop_Solid(OBJ_ID)) && (allGroups.getStart_Solid(OBJ_ID) <= allGroups.getStop_Solid(OBJ_ID))) {
          for (int q = allGroups.getStart_Solid(OBJ_ID); q <= allGroups.getStop_Solid(OBJ_ID); q++) {
            float Solid_posX = allSolids.get_posX(q);
            float Solid_posY = allSolids.get_posY(q);
            float Solid_posZ = allSolids.get_posZ(q);
            float Solid_powX = allSolids.get_powX(q);
            float Solid_powY = allSolids.get_powY(q);
            float Solid_powZ = allSolids.get_powZ(q);
            float Solid_scaleX = allSolids.get_scaleX(q);
            float Solid_scaleY = allSolids.get_scaleY(q);
            float Solid_scaleZ = allSolids.get_scaleZ(q);
            float Solid_rotX = allSolids.get_rotX(q);
            float Solid_rotY = allSolids.get_rotY(q);
            float Solid_rotZ = allSolids.get_rotZ(q);
            float Solid_value = allSolids.get_value(q);
            allSolids.create(Solid_posX, Solid_posY, Solid_posZ, Solid_powX, Solid_powY, Solid_powZ, Solid_scaleX, Solid_scaleY, Solid_scaleZ, Solid_rotX, Solid_rotY, Solid_rotZ, Solid_value);
            SOLID_added += 1;
          }
        }

        HashMap<Integer, Integer> vertexIndexMapPolyline = new HashMap<Integer, Integer>();
        int nextNewVertexIndexPolyline = 0;
        for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
          if ((0 <= f) && (f < allPolylines.nodes.length)) {
            IntList newPolyline_nodes = new IntList();
            for (int j = 0; j < allPolylines.nodes[f].length; j++) {
              int vNo = allPolylines.nodes[f][j];
              Integer vertex_listed = vertexIndexMapPolyline.get(vNo);
              if (vertex_listed == null) {
                float x = allPoints.getX(vNo);
                float y = allPoints.getY(vNo);
                float z = allPoints.getZ(vNo);
                allPoints.create(x, y, z);
                vertex_listed = nextNewVertexIndexPolyline;
                vertexIndexMapPolyline.put(vNo, vertex_listed);
                nextNewVertexIndexPolyline++;
              }
              newPolyline_nodes.append(number_of_Vertices_before + vertex_listed);
            }
            current_Material = allPolylines.getMaterial(f);
            current_Tessellation = allPolylines.getTessellation(f);
            current_Layer = allPolylines.getLayer(f);
            current_Visibility = allPolylines.getVisibility(f);
            current_Weight = allPolylines.getWeight(f);
            current_Closed = allPolylines.getClose(f);
            allPolylines.create(newPolyline_nodes.array());
          }
        }
      }
    }

    // selecting new objects
    Select3D.deselect_Groups();
    Select3D.Group_ids = appendRange(Select3D.Group_ids, number_of_allGroups_before, allGroups.num);

    if (SOLID_added != 0) allSolidImpacts.calculate_Impact_selectedSections();
    SOLARCHVISION_selection_changed();
  }
}
