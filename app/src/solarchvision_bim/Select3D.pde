class Select3D {

  final static String CLASS_STAMP = "Select3D";

  int positionVectorIndex = 2; // 0:X, 1:Y, 2:Z, 3: All
  int rotationVectorIndex = 2; // 0:X, 1:Y, 2:Z
  int scaleVectorIndex = 2; // 0:X, 1:Y, 2:Z, 3:All

  float position = 0;
  float rotation = 0;
  float scale = 0;

  int pivotAlignmentX = 0;
  int pivotAlignmentY = 0;
  int pivotAlignmentZ = 0;


  boolean pivotDisplayReference = true;

  boolean groupDisplayPivot = true;
  boolean groupDisplayEdges = false;
  boolean groupDisplayBox = true;

  boolean faceDisplayEdges = true;
  boolean faceDisplayVertexIndices = false;
  boolean polylineDisplayVertexIndices = false;
  boolean vertexDisplayMarkers = true;
  boolean polylineDisplayVertices = true;


  boolean model2DDisplayBounds = true;
  boolean model1DDisplayBounds = true;
  boolean solidDisplayEdges = true;
  boolean sectionDisplayEdges = true;
  boolean cameraDisplayFrustum = true;
  boolean terrainDisplayVertices = true;

  int[] terrainVertexIndices = new int[0];
  int[] CameraIndices = new int[0];
  int[] SectionIndices = new int[0];
  int[] SolidIndices = new int[0];
  int[] Model1DIndices = new int[0];
  int[] Model2DIndices = new int[0];
  int[] GroupIndices = new int[0];
  int[] FaceIndices = new int[0];
  int[] VertexIndices = new int[0];
  int[] PolylineIndices = new int[0];

  int[] softSelectionIndices = new int[0];
  float[] softSelection_values = new float[0];

  float softSelectionFalloffPower = 1;
  float softSelectionFalloffRadius = 2; // 2 = 2m


  float[][] BoundingBox = {
    {
      0, 0, 0, 1, 1, 1, 0, 0, 0
    }
    , {
      0, 0, 0, 1, 1, 1, 0, 0, 0
    }
    , {
      0, 0, 0, 1, 1, 1, 0, 0, 0
    }
  }; // [min|mid|max]





  int[] appendId (int[] arr, int id) {
    int[] out = new int[arr.length + 1];
    arrayCopy(arr, out, arr.length);
    out[arr.length] = id;
    return out;
  }

  int[] removeIdAt (int[] arr, int index) {
    int[] out = new int[arr.length - 1];
    arrayCopy(arr, 0, out, 0, index);
    arrayCopy(arr, index + 1, out, index, arr.length - index - 1);
    return out;
  }

  // Toggles OBJ_ID in/out of an id list according to
  // addNewSelectionToPreviousSelection (0: replace, 1: add, -1: subtract),
  // and returns the resulting array.
  int[] toggleSelection (int[] ids, int OBJ_ID) {

    int found_at = -1;
    int use_it = 0; // 0:nothing 1:add -1:subtract

    if (addNewSelectionToPreviousSelection == 0) use_it = 1;
    if (addNewSelectionToPreviousSelection == 1) use_it = 1;
    if (addNewSelectionToPreviousSelection == -1) use_it = 0;

    if (addNewSelectionToPreviousSelection != 0) {

      for (int o = ids.length - 1; o >= 0; o--) {
        if (ids[o] == OBJ_ID) {
          found_at = o;
          if (addNewSelectionToPreviousSelection == 1) {
            use_it = 0;
          }
          if (addNewSelectionToPreviousSelection == -1) {
            use_it = -1;
          }
          break;
        }
      }
    }

    if (use_it == -1) return removeIdAt(ids, found_at);
    if (use_it == 1) return appendId(ids, OBJ_ID);
    return ids;
  }

  // Returns {0, 1, ..., n-1}. Used by selectAll() to select every object of
  // the current category.
  int[] rangeIds (int n) {
    int[] ids = new int[max(n, 0)];
    for (int i = 0; i < ids.length; i++) ids[i] = i;
    return ids;
  }

  // Returns the ids from 0 up to (but not including) total that are NOT
  // present in `selected`. Used by invertSelection().
  int[] invertedIds (int[] selected, int total) {
    int[] sortedSelected = sort(selected);
    IntList inverted = new IntList();
    int j = 0;
    for (int i = 0; i < total; i++) {
      while (j < sortedSelected.length && sortedSelected[j] < i) j++;
      boolean isSelected = (j < sortedSelected.length && sortedSelected[j] == i);
      if (!isSelected) inverted.append(i);
    }
    return inverted.array();
  }

  // Returns {} if total <= 0, otherwise {total - 1}. Used by selectLast()
  // to select the most recently created object of the current category.
  int[] lastId (int total) {
    if (total > 0) {
      int[] ids = {total - 1};
      return ids;
    }
    return new int[0];
  }

  String idsToXML (int[] ids) {
    String txt = "";
    int ni = ids.length;
    for (int i = 0; i < ni; i++) {
      txt += nf(ids[i], 0);
      if (i < ni - 1) txt += "|";
    }
    return txt;
  }

  int[] idsFromXML (String txt) {
    if (txt.equals("")) return new int[0];
    String[] parts = split(txt, "|");
    int[] ids = new int[parts.length];
    for (int i = 0; i < parts.length; i++) {
      ids[i] = int(parts[i]);
    }
    return ids;
  }

  String floatsToXML (float[] values) {
    String txt = "";
    int ni = values.length;
    for (int i = 0; i < ni; i++) {
      txt += nf(values[i], 0, 4).replace("|", "."); // <<<<
      if (i < ni - 1) txt += "|";
    }
    return txt;
  }

  float[] floatsFromXML (String txt) {
    if (txt.equals("")) return new float[0];
    String[] parts = split(txt, "|");
    float[] values = new float[parts.length];
    for (int i = 0; i < parts.length; i++) {
      values[i] = float(parts[i]);
    }
    return values;
  }

  // Appends every index in [start, stop] (inclusive) not already marked in
  // `seen`, in ascending order.
  void appendIndicesInRange (int start, int stop, boolean[] seen, IntList buf) {
    for (int f = start; f <= stop; f++) {
      if (!seen[f]) {
        seen[f] = true;
        buf.append(f);
      }
    }
  }

  // Returns the deduplicated union, over every group in `groupIds`, of that
  // group's [start, stop] range in `rangeTable`. Used by
  // convert_Groups_to_Model1Ds/Model2Ds/Solids/Faces/Polylines().
  int[] rangeUnion (int[][] rangeTable, int[] groupIds, int totalCount) {
    boolean[] seen = new boolean[totalCount];
    IntList buf = new IntList();
    for (int i = 0; i < groupIds.length; i++) {
      int OBJ_ID = groupIds[i];
      appendIndicesInRange(rangeTable[OBJ_ID][0], rangeTable[OBJ_ID][1], seen, buf);
    }
    return buf.array();
  }

  // Appends the id of every group in `rangeTable` whose range contains `f`.
  void appendGroupsContaining (int[][] rangeTable, int f, boolean[] seen, IntList buf) {
    for (int OBJ_ID = 0; OBJ_ID < allGroups.num; OBJ_ID++) {
      if ((rangeTable[OBJ_ID][0] <= f) && (f <= rangeTable[OBJ_ID][1])) {
        if (!seen[OBJ_ID]) {
          seen[OBJ_ID] = true;
          buf.append(OBJ_ID);
        }
      }
    }
  }

  // Returns the deduplicated ids of every group in `rangeTable` whose range
  // contains at least one of `sourceIds`. Used by
  // convert_Model1Ds_to_Groups, convert_Model2Ds_to_Groups,
  // convert_Solids_to_Groups, convert_Faces_to_Groups, and
  // convert_Polylines_to_Groups.
  int[] groupsContaining (int[][] rangeTable, int[] sourceIds) {
    boolean[] seen = new boolean[allGroups.num];
    IntList buf = new IntList();
    for (int i = 0; i < sourceIds.length; i++) {
      appendGroupsContaining(rangeTable, sourceIds[i], seen, buf);
    }
    return buf.array();
  }

  // For a single vertex, scans `nodeTable` (allFaces.nodes /
  // allPolylines.nodes) in ascending order for objects that reference it,
  // and for each match appends every group in `rangeTable` whose range
  // contains that object's index. Used by convert_Vertices_to_Groups(),
  // which calls this once per vertex (for Faces, then for Polylines) to
  // preserve the original method's per-vertex traversal order exactly.
  void appendGroupsContainingVertex (int[][] nodeTable, int[][] rangeTable, int vNo, boolean[] seen, IntList buf) {
    for (int f = 0; f < nodeTable.length; f++) {
      for (int j = 0; j < nodeTable[f].length; j++) {
        if (nodeTable[f][j] == vNo) {
          appendGroupsContaining(rangeTable, f, seen, buf);
        }
      }
    }
  }

  // Appends every vertex id referenced by objects [start, stop] (inclusive)
  // in `nodeTable`. Used by convert_Groups_to_Vertices(), which calls this
  // once per group (for Faces, then for Polylines) to preserve the
  // original method's per-group traversal order exactly.
  void appendNodesOfRange (int[][] nodeTable, int start, int stop, boolean[] seen, IntList buf) {
    for (int f = start; f <= stop; f++) {
      for (int j = 0; j < nodeTable[f].length; j++) {
        int vNo = nodeTable[f][j];
        if (!seen[vNo]) {
          seen[vNo] = true;
          buf.append(vNo);
        }
      }
    }
  }

  // Returns the deduplicated union of every vertex id referenced by the
  // given object ids in `nodeTable`. Used by convert_Faces_to_Vertices()
  // and convert_Polylines_to_Vertices().
  int[] nodesOf (int[][] nodeTable, int[] objectIds) {
    boolean[] seen = new boolean[allPoints.getLength()];
    IntList buf = new IntList();
    for (int i = 0; i < objectIds.length; i++) {
      int f = objectIds[i];
      for (int j = 0; j < nodeTable[f].length; j++) {
        int vNo = nodeTable[f][j];
        if (!seen[vNo]) {
          seen[vNo] = true;
          buf.append(vNo);
        }
      }
    }
    return buf.array();
  }

  // Returns the deduplicated ids of the objects in `nodeTable` that
  // reference at least one of `vertexIds`, preserving the original
  // "for each vertex, scan objects in ascending order" traversal (and
  // therefore ordering) of convert_Vertices_to_Faces()/
  // convert_Vertices_to_Polylines().
  int[] objectsContainingVertices (int[][] nodeTable, int[] vertexIds) {
    boolean[] seen = new boolean[nodeTable.length];
    IntList buf = new IntList();
    for (int i = 0; i < vertexIds.length; i++) {
      int vNo = vertexIds[i];
      for (int f = 0; f < nodeTable.length; f++) {
        if (seen[f]) continue;
        for (int j = 0; j < nodeTable[f].length; j++) {
          if (nodeTable[f][j] == vNo) {
            seen[f] = true;
            buf.append(f);
            break;
          }
        }
      }
    }
    return buf.array();
  }

  int rectTest_vertex (float x, float y, float z, float corner1x, float corner1y, float corner2x, float corner2y) {

    float[] Image_XYZ = WIN3D.calculate_Perspective_Internally(x, y, z);

    if (Image_XYZ[2] > 0) { // it also illuminates undefined Z values whereas negative value passed in the Calculate function.
      if (isInside(Image_XYZ[0], Image_XYZ[1], corner1x, corner1y, corner2x, corner2y)) {
        if (mouseButton == RIGHT) return 1;
      } else {
        if (mouseButton == LEFT) return 0;
      }
    } else {
      if (mouseButton == LEFT) return 0;
    }
    return -1;
  }

  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.FaceIndices.length][8];

    for (int o = 0; o < this.FaceIndices.length; o++) {
      java.util.Arrays.fill(hitPoint[o], FLOAT_undefined);
    }


    for (int o = 0; o < this.FaceIndices.length; o++) {

      int f = this.FaceIndices[o];

      if (f > 0) {

        int n = allFaces.nodes[f].length;

        if (n > 2) {

          int vsb = allFaces.getVisibility(f);

          if (vsb > 0) {

            float X_intersect = FLOAT_undefined;
            float Y_intersect = FLOAT_undefined;
            float Z_intersect = FLOAT_undefined;
            float dist2intersect = FLOAT_undefined;
            float[] face_norm = {0,0,0};

            boolean InPoly = false;

            if (n == 3) {

              float[] A = allPoints.getPosition(allFaces.nodes[f][0]);
              float[] B = allPoints.getPosition(allFaces.nodes[f][1]);
              float[] C = allPoints.getPosition(allFaces.nodes[f][2]);

              float[] AC = funcs.vec3_diff(A, C);
              float[] BA = funcs.vec3_diff(B, A);

              face_norm = funcs.vec3_cross(AC, BA);

              float face_offset = (
                (A[0] + B[0] + C[0]) * face_norm[0] +
                (A[1] + B[1] + C[1]) * face_norm[1] +
                (A[2] + B[2] + C[2]) * face_norm[2]
              ) / 3.0;

              float R = -funcs.vec3_dot(ray_dir, face_norm);

              if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
                dist2intersect = FLOAT_huge;
              }
              else {
                dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

                //if (dist2intersect > 0) {
                if (dist2intersect > FLOAT_tiny) {

                  X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
                  Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
                  Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

                  float[] P = {X_intersect, Y_intersect, Z_intersect};

                  InPoly = funcs.isInside_Triangle(P, A, B, C);

                }
              }
            }
            else {

              int[] tmpFace = new int[n];
              float[] G = {
                0, 0, 0
              };
              for (int j = 0; j < n; j++) {
                tmpFace[j] = allFaces.nodes[f][j];
                G[0] += allPoints.getX(tmpFace[j]) / float(n);
                G[1] += allPoints.getY(tmpFace[j]) / float(n);
                G[2] += allPoints.getZ(tmpFace[j]) / float(n);
              }

              for (int j = 0; j < n; j++) {

                int j_next = (j + 1) % n;

                float[] A = {
                  allPoints.getX(allFaces.nodes[f][j]),
                  allPoints.getY(allFaces.nodes[f][j]),
                  allPoints.getZ(allFaces.nodes[f][j])
                };

                float[] B = {
                  allPoints.getX(allFaces.nodes[f][j_next]),
                  allPoints.getY(allFaces.nodes[f][j_next]),
                  allPoints.getZ(allFaces.nodes[f][j_next])
                };

                float[] AG = funcs.vec3_diff(A, G);
                float[] BG = funcs.vec3_diff(B, G);

                face_norm = funcs.vec3_cross(AG, BG);

                float face_offset = (1.0 / 3.0) * ((A[0] + B[0] + G[0]) * face_norm[0] +
                                                   (A[1] + B[1] + G[1]) * face_norm[1] +
                                                   (A[2] + B[2] + G[2]) * face_norm[2]);

                float R = -funcs.vec3_dot(ray_dir, face_norm);

                if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
                  dist2intersect = FLOAT_huge;
                }
                else {
                  dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

                  //if (dist2intersect > 0) {
                  if (dist2intersect > FLOAT_tiny) {

                    X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
                    Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
                    Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

                    float[] P = {X_intersect, Y_intersect, Z_intersect};

                    InPoly = funcs.isInside_Triangle(P, A, B, G);

                  }
                }

                if (InPoly) break;
              }
            }

            if (InPoly) {
              hitPoint[o][0] = X_intersect;
              hitPoint[o][1] = Y_intersect;
              hitPoint[o][2] = Z_intersect;
              hitPoint[o][3] = dist2intersect;
              hitPoint[o][4] = face_norm[0];
              hitPoint[o][5] = face_norm[1];
              hitPoint[o][6] = face_norm[2];
              hitPoint[o][7] = f;
            }

          }
        }
      }
    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int o = 0; o < this.FaceIndices.length; o++) {

      if (pre_dist > hitPoint[o][3]) {

        pre_dist = hitPoint[o][3];

        return_point[0] = hitPoint[o][7];
        return_point[1] = hitPoint[o][0];
        return_point[2] = hitPoint[o][1];
        return_point[3] = hitPoint[o][2];
        return_point[4] = hitPoint[o][3];
        return_point[5] = hitPoint[o][4];
        return_point[6] = hitPoint[o][5];
        return_point[7] = hitPoint[o][6];

      }

    }

    return return_point;
  }


  boolean update_BoundingBox = true; // internal

  void revise_BoundingBox () {
    this.update_BoundingBox = true;
  }

  void calculate_BoundingBox () {

    this.update_BoundingBox = false;

    int keep_selection_pivotAlignmentX = this.pivotAlignmentX;
    int keep_selection_pivotAlignmentY = this.pivotAlignmentY;
    int keep_selection_pivotAlignmentZ = this.pivotAlignmentZ;

    this.pivotAlignmentX = 0; // apply the centre
    this.pivotAlignmentY = 0; // apply the centre
    this.pivotAlignmentZ = 0; // apply the centre

    int[] theVertices = new int [0];

    if (currentObjectCategory == ObjectCategory.CAMERA) {
      theVertices = this.CameraIndices;
    }

    if (currentObjectCategory == ObjectCategory.SECTION) {
      theVertices = this.SectionIndices;
    }

    if (currentObjectCategory == ObjectCategory.SOLID) {
      theVertices = this.SolidIndices;
    }

    if ((currentObjectCategory == ObjectCategory.VERTEX) ||
        (currentObjectCategory == ObjectCategory.SOFTVERTEX)) {

      theVertices = this.VertexIndices;
    }
    if (currentObjectCategory == ObjectCategory.FACE) {
      theVertices = this.get_Face_Vertices();
    }
    if (currentObjectCategory == ObjectCategory.POLYLINE) {
      theVertices = this.get_Polyline_Vertices();
    }
    if (currentObjectCategory == ObjectCategory.GROUP) {
      theVertices = this.get_Group_Vertices();
    }
    if (currentObjectCategory == ObjectCategory.MODEL2D) {
      theVertices = this.Model2DIndices;
    }
    if (currentObjectCategory == ObjectCategory.MODEL1D) {
      theVertices = this.Model1DIndices;
    }
    if (currentObjectCategory == ObjectCategory.TERRAIN) {
      theVertices = this.terrainVertexIndices;
    }

    float posX = 0;
    float posY = 0;
    float posZ = 0;

    float scaleX = 1;
    float scaleY = 1;
    float scaleZ = 1;

    float rotX = 0;
    float rotY = 0;
    float rotZ = 0;

    if (currentObjectCategory == ObjectCategory.GROUP) {

      if (this.GroupIndices.length > 0) {

        for (int o = 0; o < this.GroupIndices.length; o++) {

          int OBJ_ID = this.GroupIndices[o];

          posX += allGroups.Pivots[OBJ_ID][0] / this.GroupIndices.length;
          posY += allGroups.Pivots[OBJ_ID][1] / this.GroupIndices.length;
          posZ += allGroups.Pivots[OBJ_ID][2] / this.GroupIndices.length;

        }
      }
    }


    for (int i = 0; i < 3; i++) {
      float ratio = 0.5 * i;
      this.BoundingBox[i][0] = posX;
      this.BoundingBox[i][1] = posY;
      this.BoundingBox[i][2] = posZ;

      this.BoundingBox[i][3] = scaleX;
      this.BoundingBox[i][4] = scaleY;
      this.BoundingBox[i][5] = scaleZ;

      this.BoundingBox[i][6] = rotX;
      this.BoundingBox[i][7] = rotY;
      this.BoundingBox[i][8] = rotZ;
    }


    float posX_min = FLOAT_undefined;
    float posY_min = FLOAT_undefined;
    float posZ_min = FLOAT_undefined;

    float posX_max = -FLOAT_undefined;
    float posY_max = -FLOAT_undefined;
    float posZ_max = -FLOAT_undefined;



    for (int q = 0; q < theVertices.length; q++) {

      float x = 0;
      float y = 0;
      float z = 0;

      if (currentObjectCategory == ObjectCategory.CAMERA) {
        int n = theVertices[q];

        if (n < allCameras.num) {

          float Camera_pX = allCameras.get_posX(n);
          float Camera_pY = allCameras.get_posY(n);
          float Camera_pZ = allCameras.get_posZ(n);
          float Camera_pT = allCameras.get_posT(n);
          float Camera_rX = allCameras.get_rotX(n);
          float Camera_rY = allCameras.get_rotY(n);
          float Camera_rZ = allCameras.get_rotZ(n);
          float Camera_rT = allCameras.get_rotT(n);
          float Camera_zoom = allCameras.get_zoom(n);
          int   Camera_type = allCameras.get_type(n);

          float[][] ImageVertex = allCameras.getCorners(Camera_type, Camera_pX, Camera_pY, Camera_pZ, Camera_pT, Camera_rX, Camera_rY, Camera_rZ, Camera_rT, Camera_zoom);

          // the first vertex is the Camera point
          x = ImageVertex[0][0];
          y = ImageVertex[0][1];
          z = ImageVertex[0][2];
        }
      }

      if (currentObjectCategory == ObjectCategory.SECTION) {
        int n = theVertices[q];

        if (n < allSections.num) {

          float Section_X = allSections.getX(n);
          float Section_Y = allSections.getY(n);
          float Section_Z = allSections.getZ(n);
          float Section_R = allSections.getR(n);
          float Section_U = allSections.getU(n);
          float Section_V = allSections.getV(n);

          int Section_Type = allSections.get_type(n);
          int Section_RES1 = allSections.get_res1(n);
          int Section_RES2 = allSections.get_res2(n);

          float[][] ImageVertex = allSections.getCorners(Section_Type, Section_X, Section_Y, Section_Z, Section_R, Section_U, Section_V, Section_RES1, Section_RES2);

          // the first vertex is the center of Section plane
          x = ImageVertex[0][0];
          y = ImageVertex[0][1];
          z = ImageVertex[0][2];
        }
      }

      if (currentObjectCategory == ObjectCategory.SOLID) {
        int n = theVertices[q];

        if (n < allSolids.DEF.length) {

          float Solid_posX = allSolids.get_posX(n);
          float Solid_posY = allSolids.get_posY(n);
          float Solid_posZ = allSolids.get_posZ(n);
          float Solid_powX = allSolids.get_powX(n);
          float Solid_powY = allSolids.get_powY(n);
          float Solid_powZ = allSolids.get_powZ(n);
          float Solid_scaleX = allSolids.get_scaleX(n);
          float Solid_scaleY = allSolids.get_scaleY(n);
          float Solid_scaleZ = allSolids.get_scaleZ(n);
          float Solid_rotX = allSolids.get_rotX(n);
          float Solid_rotY = allSolids.get_rotY(n);
          float Solid_rotZ = allSolids.get_rotZ(n);
          float Solid_value = allSolids.get_value(n);

          float[][] ImageVertex = allSolids.getCorners(0, Solid_posX, Solid_posY, Solid_posZ, Solid_powX, Solid_powY, Solid_powZ, Solid_scaleX, Solid_scaleY, Solid_scaleZ, Solid_rotX, Solid_rotY, Solid_rotZ, Solid_value);

          // the first vertex is the center of Solid plane
          x = ImageVertex[0][0];
          y = ImageVertex[0][1];
          z = ImageVertex[0][2];
        }
      }


      if ((currentObjectCategory == ObjectCategory.GROUP) ||
          (currentObjectCategory == ObjectCategory.FACE) ||
          (currentObjectCategory == ObjectCategory.POLYLINE) ||
          (currentObjectCategory == ObjectCategory.VERTEX) ||
          (currentObjectCategory == ObjectCategory.SOFTVERTEX)) {

        int n = theVertices[q];

        x = allPoints.getX(n);
        y = allPoints.getY(n);
        z = allPoints.getZ(n);
      }
      if (currentObjectCategory == ObjectCategory.MODEL2D) {
        int n = theVertices[q];

        x = allModel2Ds.getX(n);
        y = allModel2Ds.getY(n);
        z = allModel2Ds.getZ(n);
      }
      if (currentObjectCategory == ObjectCategory.MODEL1D) {
        int n = theVertices[q];

        x = allModel1Ds.getX(n);
        y = allModel1Ds.getY(n);
        z = allModel1Ds.getZ(n);
      }
      if (currentObjectCategory == ObjectCategory.TERRAIN) {
        int n = theVertices[q];

        int OBJ_ID = n;

        int the_i = OBJ_ID / Terrain.columnCount;
        int the_j = OBJ_ID % Terrain.columnCount;

        x = Terrain.Mesh[the_i][the_j][0];
        y = Terrain.Mesh[the_i][the_j][1];
        z = Terrain.Mesh[the_i][the_j][2];

      }




      float[] A = this.translateOutside_ReferencePivot(x, y, z);

      x = A[0];
      y = A[1];
      z = A[2];


      if (posX_min > x) posX_min = x;
      if (posY_min > y) posY_min = y;
      if (posZ_min > z) posZ_min = z;

      if (posX_max < x) posX_max = x;
      if (posY_max < y) posY_max = y;
      if (posZ_max < z) posZ_max = z;
    }

    if (is_defined(posX_min) &&
        is_defined(posY_min) &&
        is_defined(posZ_min) &&
        is_defined(-posX_max) &&
        is_defined(-posY_max) &&
        is_defined(-posZ_max)) {

      float dx = posX;
      float dy = posY;
      float dz = posZ;

      posX_min += dx;
      posY_min += dy;
      posZ_min += dz;

      posX_max += dx;
      posY_max += dy;
      posZ_max += dz;

      for (int i = 0; i < 3; i++) {
        float ratio = 0.5 * i;
        this.BoundingBox[i][0] = (1 - ratio) * posX_min + ratio * posX_max;
        this.BoundingBox[i][1] = (1 - ratio) * posY_min + ratio * posY_max;
        this.BoundingBox[i][2] = (1 - ratio) * posZ_min + ratio * posZ_max;

        this.BoundingBox[i][3] = scaleX;
        this.BoundingBox[i][4] = scaleY;
        this.BoundingBox[i][5] = scaleZ;

        this.BoundingBox[i][6] = rotX;
        this.BoundingBox[i][7] = rotY;
        this.BoundingBox[i][8] = rotZ;
      }
    }



    this.pivotAlignmentX = keep_selection_pivotAlignmentX;
    this.pivotAlignmentY = keep_selection_pivotAlignmentY;
    this.pivotAlignmentZ = keep_selection_pivotAlignmentZ;
  }



  void save_current_BoundingBox () {

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 9; j++) {
        saved_BoundingBox[i][j] = this.BoundingBox[i][j];
      }
    }

    saved_pivotAlignmentX = this.pivotAlignmentX;
    saved_pivotAlignmentY = this.pivotAlignmentY;
    saved_pivotAlignmentZ = this.pivotAlignmentZ;
  }


  void apply_saved_BoundingBox () {

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 9; j++) {
        this.BoundingBox[i][j] = saved_BoundingBox[i][j];
      }
    }

    this.pivotAlignmentX = saved_pivotAlignmentX;
    this.pivotAlignmentY = saved_pivotAlignmentY;
    this.pivotAlignmentZ = saved_pivotAlignmentZ;
  }


  void apply_origin_ReferenceBox () {

    for (int i = 0; i < 3; i++) {
      this.BoundingBox[i][0] = 0;
      this.BoundingBox[i][1] = 0;
      this.BoundingBox[i][2] = 0;
      this.BoundingBox[i][3] = 1;
      this.BoundingBox[i][4] = 1;
      this.BoundingBox[i][5] = 1;
      this.BoundingBox[i][6] = 0;
      this.BoundingBox[i][7] = 0;
      this.BoundingBox[i][8] = 0;
    }

    //this.pivotAlignmentX = 0;
    //this.pivotAlignmentY = 0;
    //this.pivotAlignmentZ = 0;
  }




  void reset_selectedRefValues () {

    this.position = 0;
    this.rotation = 0;
    this.scale = 0;
  }




  float[] translateInside_ReferencePivot (float a, float b, float c) {


    float rotX = this.BoundingBox[1 + this.pivotAlignmentX][6];
    float rotY = this.BoundingBox[1 + this.pivotAlignmentY][7];
    float rotZ = this.BoundingBox[1 + this.pivotAlignmentZ][8];

    float y1 = b * funcs.cos_ang(rotX) - c * funcs.sin_ang(rotX);
    float z1 = b * funcs.sin_ang(rotX) + c * funcs.cos_ang(rotX);
    float x1 = a;

    a = x1;
    b = y1;
    c = z1;

    float z2 = c * funcs.cos_ang(rotY) - a * funcs.sin_ang(rotY);
    float x2 = c * funcs.sin_ang(rotY) + a * funcs.cos_ang(rotY);
    float y2 = b;

    a = x2;
    b = y2;
    c = z2;

    float x = a * funcs.cos_ang(rotZ) - b * funcs.sin_ang(rotZ);
    float y = a * funcs.sin_ang(rotZ) + b * funcs.cos_ang(rotZ);
    float z = c;

    x *= this.BoundingBox[1 + this.pivotAlignmentX][3];
    y *= this.BoundingBox[1 + this.pivotAlignmentY][4];
    z *= this.BoundingBox[1 + this.pivotAlignmentZ][5];

    x += this.BoundingBox[1 + this.pivotAlignmentX][0];
    y += this.BoundingBox[1 + this.pivotAlignmentY][1];
    z += this.BoundingBox[1 + this.pivotAlignmentZ][2];

    float[] return_array = {
      x, y, z
    };

    return return_array;
  }



  float[] translateOutside_ReferencePivot (float a, float b, float c) {

    a -= this.BoundingBox[1 + this.pivotAlignmentX][0];
    b -= this.BoundingBox[1 + this.pivotAlignmentY][1];
    c -= this.BoundingBox[1 + this.pivotAlignmentZ][2];

    a /= this.BoundingBox[1 + this.pivotAlignmentX][3];
    b /= this.BoundingBox[1 + this.pivotAlignmentY][4];
    c /= this.BoundingBox[1 + this.pivotAlignmentZ][5];



    float rotX = this.BoundingBox[1 + this.pivotAlignmentX][6];
    float rotY = this.BoundingBox[1 + this.pivotAlignmentY][7];
    float rotZ = this.BoundingBox[1 + this.pivotAlignmentZ][8];

    float x1 = a * funcs.cos_ang(-rotZ) - b * funcs.sin_ang(-rotZ);
    float y1 = a * funcs.sin_ang(-rotZ) + b * funcs.cos_ang(-rotZ);
    float z1 = c;

    a = x1;
    b = y1;
    c = z1;

    float z2 = c * funcs.cos_ang(-rotY) - a * funcs.sin_ang(-rotY);
    float x2 = c * funcs.sin_ang(-rotY) + a * funcs.cos_ang(-rotY);
    float y2 = b;

    a = x2;
    b = y2;
    c = z2;

    float y = b * funcs.cos_ang(-rotX) - c * funcs.sin_ang(-rotX);
    float z = b * funcs.sin_ang(-rotX) + c * funcs.cos_ang(-rotX);
    float x = a;


    float[] return_array = {
      x, y, z
    };

    return return_array;
  }




  float[] getPivot () {

    float posX = this.BoundingBox[1][0];
    float posY = this.BoundingBox[1][1];
    float posZ = this.BoundingBox[1][2];

    float x = this.BoundingBox[1 + this.pivotAlignmentX][0];
    float y = this.BoundingBox[1 + this.pivotAlignmentY][1];
    float z = this.BoundingBox[1 + this.pivotAlignmentZ][2];

    {
      int keep_selection_pivotAlignmentX = this.pivotAlignmentX;
      int keep_selection_pivotAlignmentY = this.pivotAlignmentY;
      int keep_selection_pivotAlignmentZ = this.pivotAlignmentZ;

      this.pivotAlignmentX = 0; // apply the centre
      this.pivotAlignmentY = 0; // apply the centre
      this.pivotAlignmentZ = 0; // apply the centre

      float[] A = this.translateInside_ReferencePivot(x - posX, y - posY, z - posZ);

      x = A[0];
      y = A[1];
      z = A[2];

      this.pivotAlignmentX = keep_selection_pivotAlignmentX;
      this.pivotAlignmentY = keep_selection_pivotAlignmentY;
      this.pivotAlignmentZ = keep_selection_pivotAlignmentZ;
    }

    float[] return_array = {
      x, y, z
    };

    return return_array;
  }



  void selectPick (float[] RxP) {

    if (addNewSelectionToPreviousSelection == 0) this.deselectAll();

    if (RxP[0] < 0) { // hit nothing: leave the (just-cleared) selection as is
      selection_changed();
      return;
    }

    if (currentObjectCategory == ObjectCategory.TERRAIN) {

      int OBJ_ID = int(RxP[0]);

      this.terrainVertexIndices = toggleSelection(this.terrainVertexIndices, OBJ_ID);
    }


    if (currentObjectCategory == ObjectCategory.MODEL1D) {

      int OBJ_ID = int(RxP[0]);

      this.Model1DIndices = toggleSelection(this.Model1DIndices, OBJ_ID);
    }


    if (currentObjectCategory == ObjectCategory.MODEL2D) {

      int OBJ_ID = int(RxP[0]);

      this.Model2DIndices = toggleSelection(this.Model2DIndices, OBJ_ID);
    }


    if (currentObjectCategory == ObjectCategory.GROUP) {

      int f = int(RxP[0]);

      int OBJ_ID = 0;

      for (int i = 0; i < allGroups.num; i++) {
        if ((allGroups.Faces[i][0] <= f) && (f <= allGroups.Faces[i][1])) {
          OBJ_ID = i;
          break;
        }
      }

      this.GroupIndices = toggleSelection(this.GroupIndices, OBJ_ID);
    }

    if (currentObjectCategory == ObjectCategory.FACE) {

      int OBJ_ID = int(RxP[0]);

      this.FaceIndices = toggleSelection(this.FaceIndices, OBJ_ID);
    }

    if (currentObjectCategory == ObjectCategory.POLYLINE) {

      int OBJ_ID = int(RxP[0]);

      this.PolylineIndices = toggleSelection(this.PolylineIndices, OBJ_ID);
    }


    if (currentObjectCategory == ObjectCategory.VERTEX) {

      int f = int(RxP[0]);

      int OBJ_ID = 0;
      float min_dist = FLOAT_undefined;

      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];

        float x = allPoints.getX(vNo);
        float y = allPoints.getY(vNo);
        float z = allPoints.getZ(vNo);

        float now_dist = dist(x, y, z, RxP[1], RxP[2], RxP[3]);

        if (min_dist > now_dist) {
          min_dist = now_dist;
          OBJ_ID = vNo;
        }
      }


      this.VertexIndices = toggleSelection(this.VertexIndices, OBJ_ID);
    }



    if (currentObjectCategory == ObjectCategory.SOLID) {

      int OBJ_ID = int(RxP[0]);

      this.SolidIndices = toggleSelection(this.SolidIndices, OBJ_ID);
    }



    if (currentObjectCategory == ObjectCategory.SECTION) {

      int OBJ_ID = int(RxP[0]);

      this.SectionIndices = toggleSelection(this.SectionIndices, OBJ_ID);
    }

    if (currentObjectCategory == ObjectCategory.CAMERA) {

      int OBJ_ID = int(RxP[0]);

      this.CameraIndices = toggleSelection(this.CameraIndices, OBJ_ID);

    }


    selection_changed();
  }


  void selectRect (float corner1x, float corner1y, float corner2x, float corner2y) {

    if (addNewSelectionToPreviousSelection == 0) this.deselectAll();


    if (currentObjectCategory == ObjectCategory.TERRAIN) {

      for (int OBJ_ID = 0; OBJ_ID < Terrain.rowCount * Terrain.columnCount; OBJ_ID++) {

        int i = OBJ_ID / Terrain.columnCount;
        int j = OBJ_ID % Terrain.columnCount;

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        for (int k = 0; k < 1; k++) { // just a loop to make those break commands relevant!

          float x = Terrain.Mesh[i][j][0] * overallScale;
          float y = Terrain.Mesh[i][j][1] * overallScale;
          float z = Terrain.Mesh[i][j][2] * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }
        }



        if (include_OBJ_in_newSelection == 1) {

          this.terrainVertexIndices = toggleSelection(this.terrainVertexIndices, OBJ_ID);
        }
      }
    }



    if (currentObjectCategory == ObjectCategory.MODEL1D) {

      for (int OBJ_ID = 0; OBJ_ID < allModel1Ds.Faces.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int f = OBJ_ID;

        for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

          int vNo = allModel1Ds.Faces[f][j];

          float x = allModel1Ds.Vertices[vNo][0] * overallScale;
          float y = allModel1Ds.Vertices[vNo][1] * overallScale;
          float z = allModel1Ds.Vertices[vNo][2] * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.Model1DIndices = toggleSelection(this.Model1DIndices, OBJ_ID);
        }
      }
    }



    if (currentObjectCategory == ObjectCategory.GROUP) {

      for (int OBJ_ID = 0; OBJ_ID < allGroups.num; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (allGroups.getStart_Face(OBJ_ID) <= allGroups.getStop_Face(OBJ_ID)) {

          if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
          if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

          for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {
            if ((0 <= f) && (f < allFaces.nodes.length)) {

              for (int j = 0; j < allFaces.nodes[f].length; j++) {
                int vNo = allFaces.nodes[f][j];

                float x = allPoints.getX(vNo) * overallScale;
                float y = allPoints.getY(vNo) * overallScale;
                float z = allPoints.getZ(vNo) * overallScale;

                int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
                if (decision != -1) {
                  include_OBJ_in_newSelection = decision;
                  break_loops = 1;
                }

                if (break_loops == 1) break;
              }

              if (break_loops == 1) break;
            }
          }
        }

        if (allGroups.getStart_Polyline(OBJ_ID) <= allGroups.getStop_Polyline(OBJ_ID)) {

          if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
          if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

          for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {
            if ((0 <= f) && (f < allPolylines.nodes.length)) {

              for (int j = 0; j < allPolylines.nodes[f].length; j++) {
                int vNo = allPolylines.nodes[f][j];

                float x = allPoints.getX(vNo) * overallScale;
                float y = allPoints.getY(vNo) * overallScale;
                float z = allPoints.getZ(vNo) * overallScale;

                int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
                if (decision != -1) {
                  include_OBJ_in_newSelection = decision;
                  break_loops = 1;
                }

                if (break_loops == 1) break;
              }

              if (break_loops == 1) break;
            }
          }
        }

        if (include_OBJ_in_newSelection == 1) {

          this.GroupIndices = toggleSelection(this.GroupIndices, OBJ_ID);
        }
      }
    }


    if (currentObjectCategory == ObjectCategory.FACE) {

      for (int OBJ_ID = 0; OBJ_ID < allFaces.nodes.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        for (int j = 0; j < allFaces.nodes[OBJ_ID].length; j++) {
          int vNo = allFaces.nodes[OBJ_ID][j];

          float x = allPoints.getX(vNo) * overallScale;
          float y = allPoints.getY(vNo) * overallScale;
          float z = allPoints.getZ(vNo) * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
          }

          if (break_loops == 1) break;
        }



        if (include_OBJ_in_newSelection == 1) {

          this.FaceIndices = toggleSelection(this.FaceIndices, OBJ_ID);
        }
      }
    }

    if (currentObjectCategory == ObjectCategory.POLYLINE) {

      for (int OBJ_ID = 0; OBJ_ID < allPolylines.nodes.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        for (int j = 0; j < allPolylines.nodes[OBJ_ID].length; j++) {
          int vNo = allPolylines.nodes[OBJ_ID][j];

          float x = allPoints.getX(vNo) * overallScale;
          float y = allPoints.getY(vNo) * overallScale;
          float z = allPoints.getZ(vNo) * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
          }

          if (break_loops == 1) break;
        }



        if (include_OBJ_in_newSelection == 1) {

          this.PolylineIndices = toggleSelection(this.PolylineIndices, OBJ_ID);
        }
      }
    }


    if (currentObjectCategory == ObjectCategory.VERTEX) {

      for (int OBJ_ID = 0; OBJ_ID < allPoints.getLength(); OBJ_ID++) {

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        float x = allPoints.getX(OBJ_ID) * overallScale;
        float y = allPoints.getY(OBJ_ID) * overallScale;
        float z = allPoints.getZ(OBJ_ID) * overallScale;

        int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
        if (decision != -1) {
          include_OBJ_in_newSelection = decision;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.VertexIndices = toggleSelection(this.VertexIndices, OBJ_ID);
        }
      }
    }

    if (currentObjectCategory == ObjectCategory.MODEL2D) {

      for (int f = 0; f < allModel2Ds.Faces.length; f++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int OBJ_ID = f / allModel2Ds.num_visualFaces;

        //println(f, OBJ_ID);

        for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

          int vNo = allModel2Ds.Faces[f][j];

          float x = allModel2Ds.Vertices[vNo][0] * overallScale;
          float y = allModel2Ds.Vertices[vNo][1] * overallScale;
          float z = allModel2Ds.Vertices[vNo][2] * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          int previousCount = this.Model2DIndices.length;
          this.Model2DIndices = toggleSelection(this.Model2DIndices, OBJ_ID);

          if (this.Model2DIndices.length > previousCount) {
            // skip the same object's drawn faces
            f += allModel2Ds.num_visualFaces - (f % allModel2Ds.num_visualFaces) - 1;
          }
        }
      }
    }

    if (currentObjectCategory == ObjectCategory.SOLID) {

      for (int f = 0; f < allSolids.Faces.length; f++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int OBJ_ID = f / allSolids.num_visualFaces;

        //println(f, OBJ_ID);

        for (int j = 0; j < allSolids.Faces[f].length; j++) {

          int vNo = allSolids.Faces[f][j];

          float x = allSolids.Vertices[vNo][0] * overallScale;
          float y = allSolids.Vertices[vNo][1] * overallScale;
          float z = allSolids.Vertices[vNo][2] * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          int previousCount = this.SolidIndices.length;
          this.SolidIndices = toggleSelection(this.SolidIndices, OBJ_ID);

          if (this.SolidIndices.length > previousCount) {
            // skip the same object's drawn faces
            f += allSolids.num_visualFaces - (f % allSolids.num_visualFaces) - 1;
          }
        }
      }
    }

    if (currentObjectCategory == ObjectCategory.SECTION) {

      for (int OBJ_ID = 0; OBJ_ID < allSections.Faces.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int f = OBJ_ID;

        for (int j = 0; j < allSections.Faces[f].length; j++) {

          int vNo = allSections.Faces[f][j];

          float x = allSections.Vertices[vNo][0] * overallScale;
          float y = allSections.Vertices[vNo][1] * overallScale;
          float z = allSections.Vertices[vNo][2] * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.SectionIndices = toggleSelection(this.SectionIndices, OBJ_ID);
        }
      }
    }


    if (currentObjectCategory == ObjectCategory.CAMERA) {

      for (int OBJ_ID = 0; OBJ_ID < allCameras.Faces.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int f = OBJ_ID;

        for (int j = 0; j < allCameras.Faces[f].length; j++) {

          int vNo = allCameras.Faces[f][j];

          float x = allCameras.Vertices[vNo][0] * overallScale;
          float y = allCameras.Vertices[vNo][1] * overallScale;
          float z = allCameras.Vertices[vNo][2] * overallScale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.CameraIndices = toggleSelection(this.CameraIndices, OBJ_ID);
        }
      }
    }

    selection_changed();
  }





  void deselectTerrainVertices () {
    this.terrainVertexIndices = new int [0];

    selection_changed();
  }

  void deselect_Vertices () {
    this.VertexIndices = new int [0];

    this.deselect_softSelection();

    selection_changed();
  }

  void deselect_softSelection () {
    this.softSelectionIndices = new int [0];
    this.softSelection_values = new float [0];

    selection_changed();
  }

  void deselect_Faces () {
    this.FaceIndices = new int [0];

    selection_changed();
  }

  void deselect_Polylines () {
    this.PolylineIndices = new int [0];

    selection_changed();
  }

  void deselect_Solids () {
    this.SolidIndices = new int [0];

    selection_changed();
  }

  void deselect_Cameras () {
    this.CameraIndices = new int [0];

    selection_changed();
  }

  void deselect_Sections () {
    this.SectionIndices = new int [0];

    selection_changed();
  }

  void deselect_Model1Ds () {
    this.Model1DIndices = new int [0];

    selection_changed();
  }


  void deselect_Model2Ds () {
    this.Model2DIndices = new int [0];

    selection_changed();
  }

  void deselect_Groups () {
    this.GroupIndices = new int [0];

    selection_changed();
  }


  void deselectAll () {

    this.deselectTerrainVertices();
    this.deselect_Cameras();
    this.deselect_Sections();
    this.deselect_Solids();
    this.deselect_Model1Ds();
    this.deselect_Model2Ds();
    this.deselect_Faces();
    this.deselect_Polylines();
    this.deselect_Vertices();
    this.deselect_Groups();

    selection_changed();
  }

  void selectAll () {

    if (currentObjectCategory == ObjectCategory.TERRAIN) {
      this.terrainVertexIndices = rangeIds(Terrain.rowCount * Terrain.columnCount);
    }

    if (currentObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1DIndices = rangeIds(allModel1Ds.num);
    }

    if (currentObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2DIndices = rangeIds(allModel2Ds.num);
    }

    if (currentObjectCategory == ObjectCategory.GROUP) {
      this.GroupIndices = rangeIds(allGroups.num);
    }

    if (currentObjectCategory == ObjectCategory.FACE) {
      this.FaceIndices = rangeIds(allFaces.nodes.length);
    }

    if (currentObjectCategory == ObjectCategory.VERTEX) {
      this.VertexIndices = rangeIds(allPoints.getLength());
    }

    if (currentObjectCategory == ObjectCategory.POLYLINE) {
      this.PolylineIndices = rangeIds(allPolylines.nodes.length);
    }

    if (currentObjectCategory == ObjectCategory.SOLID) {
      this.SolidIndices = rangeIds(allSolids.DEF.length);
    }

    if (currentObjectCategory == ObjectCategory.SECTION) {
      this.SectionIndices = rangeIds(allSections.num);
    }

    if (currentObjectCategory == ObjectCategory.CAMERA) {
      this.CameraIndices = rangeIds(allCameras.num);
    }

    selection_changed();
  }


  void invertSelection () {

    if (currentObjectCategory == ObjectCategory.TERRAIN) {
      this.terrainVertexIndices = invertedIds(this.terrainVertexIndices, Terrain.rowCount * Terrain.columnCount);
    }

    if (currentObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1DIndices = invertedIds(this.Model1DIndices, allModel1Ds.num);
    }

    if (currentObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2DIndices = invertedIds(this.Model2DIndices, allModel2Ds.num);
    }

    if (currentObjectCategory == ObjectCategory.GROUP) {
      this.GroupIndices = invertedIds(this.GroupIndices, allGroups.num);
    }

    if (currentObjectCategory == ObjectCategory.FACE) {
      this.FaceIndices = invertedIds(this.FaceIndices, allFaces.nodes.length);
    }

    if (currentObjectCategory == ObjectCategory.POLYLINE) {
      this.PolylineIndices = invertedIds(this.PolylineIndices, allPolylines.nodes.length);
    }


    if (currentObjectCategory == ObjectCategory.VERTEX) {
      this.VertexIndices = invertedIds(this.VertexIndices, allPoints.getLength());
    }

    if (currentObjectCategory == ObjectCategory.SOLID) {
      this.SolidIndices = invertedIds(this.SolidIndices, allSolids.DEF.length);
    }

    if (currentObjectCategory == ObjectCategory.SECTION) {
      this.SectionIndices = invertedIds(this.SectionIndices, allSections.num);
    }

    if (currentObjectCategory == ObjectCategory.CAMERA) {
      this.CameraIndices = invertedIds(this.CameraIndices, allCameras.num);
    }

    selection_changed();
  }









  void selectLast () {

    if (currentObjectCategory == ObjectCategory.SECTION) {
      this.SectionIndices = lastId(allSections.num);
    }

    if (currentObjectCategory == ObjectCategory.CAMERA) {
      this.CameraIndices = lastId(allCameras.num);
    }

    if (currentObjectCategory == ObjectCategory.SOLID) {
      this.SolidIndices = lastId(allSolids.DEF.length);
    }

    if (currentObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1DIndices = lastId(allModel1Ds.num);
    }

    if (currentObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2DIndices = lastId(allModel2Ds.num);
    }

    if (currentObjectCategory == ObjectCategory.GROUP) {
      this.GroupIndices = lastId(allGroups.num);
    }

    if (currentObjectCategory == ObjectCategory.FACE) {
      this.FaceIndices = lastId(allFaces.nodes.length);
    }

    if (currentObjectCategory == ObjectCategory.VERTEX) {
      this.VertexIndices = lastId(allPoints.getLength());
    }


    if (currentObjectCategory == ObjectCategory.POLYLINE) {
      this.PolylineIndices = lastId(allPolylines.nodes.length);
    }

    selection_changed();
  }



  float softSelectionFunction (float d_min) {

    float v = 0;

    if (d_min < this.softSelectionFalloffRadius) {
      v = pow(funcs.cos_ang(90 * d_min / this.softSelectionFalloffRadius), this.softSelectionFalloffPower);
    }

    return v;
  }


  void convert_Model1Ds_to_Groups () {
    this.GroupIndices = groupsContaining(allGroups.Model1Ds, this.Model1DIndices);
    selection_changed();
  }

  void convert_Model2Ds_to_Groups () {
    this.GroupIndices = groupsContaining(allGroups.Model2Ds, this.Model2DIndices);
    selection_changed();
  }


  void convert_Solids_to_Groups () {
    this.GroupIndices = groupsContaining(allGroups.Solids, this.SolidIndices);
    selection_changed();
  }

  void convert_Faces_to_Groups () {
    // NOTE: the original repeated this group-membership scan once per node
    // in each face; since the outcome only depends on the face index (not
    // which node triggered it) and dedup already prevents double-adding,
    // that inner loop was redundant. Removed as a behavior-preserving
    // simplification.
    this.GroupIndices = groupsContaining(allGroups.Faces, this.FaceIndices);
    selection_changed();
  }

  void convert_Polylines_to_Groups () {
    // See the note in convert_Faces_to_Groups() above - same simplification.
    this.GroupIndices = groupsContaining(allGroups.Polylines, this.PolylineIndices);
    selection_changed();
  }



  void convert_Vertices_to_Groups () {

    boolean[] Group_seen = new boolean[allGroups.num];
    IntList GroupIndices_buf = new IntList();

    for (int i = 0; i < this.VertexIndices.length; i++) {
      int vNo = this.VertexIndices[i];
      appendGroupsContainingVertex(allFaces.nodes, allGroups.Faces, vNo, Group_seen, GroupIndices_buf);
      appendGroupsContainingVertex(allPolylines.nodes, allGroups.Polylines, vNo, Group_seen, GroupIndices_buf);
    }

    this.GroupIndices = GroupIndices_buf.array();

    selection_changed();
  }


  void convert_Vertices_to_Faces () {
    this.FaceIndices = objectsContainingVertices(allFaces.nodes, this.VertexIndices);
    selection_changed();
  }


  void convert_Vertices_to_Polylines () {
    this.PolylineIndices = objectsContainingVertices(allPolylines.nodes, this.VertexIndices);
    selection_changed();
  }

  void convert_Groups_to_Model1Ds () {
    this.Model1DIndices = rangeUnion(allGroups.Model1Ds, this.GroupIndices, allModel1Ds.num);
    selection_changed();
  }


  void convert_Groups_to_Model2Ds () {
    this.Model2DIndices = rangeUnion(allGroups.Model2Ds, this.GroupIndices, allModel2Ds.num);
    selection_changed();
  }



  void convert_Groups_to_Solids () {
    this.SolidIndices = rangeUnion(allGroups.Solids, this.GroupIndices, allSolids.DEF.length);
    selection_changed();
  }



  void convert_Groups_to_Faces () {
    this.FaceIndices = rangeUnion(allGroups.Faces, this.GroupIndices, allFaces.nodes.length);
    selection_changed();
  }


  void convert_Groups_to_Polylines () {
    this.PolylineIndices = rangeUnion(allGroups.Polylines, this.GroupIndices, allPolylines.nodes.length);
    selection_changed();
  }



  void convert_Groups_to_Vertices () {

    boolean[] Vertex_seen = new boolean[allPoints.getLength()];
    IntList Vertex_buf = new IntList();

    for (int i = 0; i < this.GroupIndices.length; i++) {
      int OBJ_ID = this.GroupIndices[i];
      appendNodesOfRange(allFaces.nodes, allGroups.getStart_Face(OBJ_ID), allGroups.getStop_Face(OBJ_ID), Vertex_seen, Vertex_buf);
      appendNodesOfRange(allPolylines.nodes, allGroups.getStart_Polyline(OBJ_ID), allGroups.getStop_Polyline(OBJ_ID), Vertex_seen, Vertex_buf);
    }

    this.VertexIndices = Vertex_buf.array();

    selection_changed();
  }


  void convert_Faces_to_Vertices () {
    this.VertexIndices = nodesOf(allFaces.nodes, this.FaceIndices);
    selection_changed();
  }


  void convert_Polylines_to_Vertices () {
    this.VertexIndices = nodesOf(allPolylines.nodes, this.PolylineIndices);
    selection_changed();
  }




  void convert_Vertex_to_softSelection () {

    int[] keep_selection_VertexIndices = this.VertexIndices;

    this.convert_Vertices_to_Groups();

    this.convert_Groups_to_Vertices();

    this.softSelectionIndices = new int[this.VertexIndices.length];
    this.softSelection_values = new float[this.VertexIndices.length];

    for (int q = 0; q < this.VertexIndices.length; q++) {

      int n = this.VertexIndices[q];

      float d_min = FLOAT_undefined;

      for (int p = 0; p < keep_selection_VertexIndices.length; p++) {

        int m = keep_selection_VertexIndices[p];

        float d = dist(allPoints.getX(m), allPoints.getY(m), allPoints.getZ(m), allPoints.getX(n), allPoints.getY(n), allPoints.getZ(n));

        if (d_min > d) {
          d_min = d;
        }
      }

      this.softSelection_values[q] = this.softSelectionFunction(d_min);
    }

    this.softSelectionIndices = this.VertexIndices;

    this.VertexIndices = keep_selection_VertexIndices;

    selection_changed();
  }



  void selectNearVertices () {

    if ((currentObjectCategory == ObjectCategory.GROUP) ||
        (currentObjectCategory == ObjectCategory.FACE) ||
        (currentObjectCategory == ObjectCategory.VERTEX)) {

      if (currentObjectCategory == ObjectCategory.GROUP) {

        this.convert_Groups_to_Vertices();
      }

      if (currentObjectCategory == ObjectCategory.FACE) {

        this.convert_Faces_to_Vertices();
      }

      if (currentObjectCategory == ObjectCategory.POLYLINE) {

        this.convert_Polylines_to_Vertices();
      }

      this.VertexIndices = sort(this.VertexIndices);

      int[] pre_Selection_VertexIndices = this.VertexIndices;

      boolean[] Vertex_seen = new boolean[allPoints.getLength()];
      for (int i = 0; i < this.VertexIndices.length; i++) {
        Vertex_seen[this.VertexIndices[i]] = true;
      }
      IntList Vertex_buf = new IntList();
      for (int i = 0; i < this.VertexIndices.length; i++) {
        Vertex_buf.append(this.VertexIndices[i]);
      }

      for (int vNo = allPoints.getLength() - 1; vNo >= 0; vNo--) {

        int isNearEnough = -1;

        for (int i = 0; i < pre_Selection_VertexIndices.length; i++) {

          int q = pre_Selection_VertexIndices[i];

          if (!Vertex_seen[vNo]) {

            float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

            if (d <= User3D.modifierWeldThreshold) {

              isNearEnough = 1;

              break;
            }
          }
        }


        if (isNearEnough == 1) {
          Vertex_seen[vNo] = true;
          Vertex_buf.append(vNo);
        }
      }

      this.VertexIndices = Vertex_buf.array();

      selection_changed();
    }
  }


  void isolatedVertices_Scene () {

    IntList Vertex_buf = new IntList();

    for (int vNo = allPoints.getLength() - 1; vNo >= 0; vNo--) {

      int found = -1;

      if (found == -1) {
        for (int i = 0; i < allFaces.nodes.length; i++) {
          for (int j = 0; j < allFaces.nodes[i].length; j++) {
            if (allFaces.nodes[i][j] == vNo) {
              found = 1;
            }
          }
        }
      }

      if (found == -1) {
        for (int i = 0; i < allPolylines.nodes.length; i++) {
          for (int j = 0; j < allPolylines.nodes[i].length; j++) {
            if (allPolylines.nodes[i][j] == vNo) {
              found = 1;
            }
          }
        }
      }

      if (found == -1) {
        Vertex_buf.append(vNo);
      }
    }

    this.VertexIndices = Vertex_buf.array();

    switch_category(ObjectCategory.VERTEX);
  }









  int[] get_Face_Vertices () {

    IntList FaceVertices = new IntList();
    boolean[] seen = new boolean[allPoints.getLength()];

    for (int o = this.FaceIndices.length - 1; o >= 0; o--) {

      int OBJ_ID = this.FaceIndices[o];

      int f = OBJ_ID;

      for (int j = 0; j < allFaces.nodes[f].length; j++) {
        int vNo = allFaces.nodes[f][j];

        if (!seen[vNo]) {
          seen[vNo] = true;
          FaceVertices.append(vNo);
        }
      }
    }

    return FaceVertices.array();
  }


  int[] get_Polyline_Vertices () {

    IntList PolylineVertices = new IntList();
    boolean[] seen = new boolean[allPoints.getLength()];

    for (int o = this.PolylineIndices.length - 1; o >= 0; o--) {

      int OBJ_ID = this.PolylineIndices[o];

      int f = OBJ_ID;

      for (int j = 0; j < allPolylines.nodes[f].length; j++) {
        int vNo = allPolylines.nodes[f][j];

        if (!seen[vNo]) {
          seen[vNo] = true;
          PolylineVertices.append(vNo);
        }
      }
    }

    return PolylineVertices.array();
  }



  int[] get_Group_Vertices () {

    IntList PolymeshVertices = new IntList();
    boolean[] seen = new boolean[allPoints.getLength()];

    for (int o = this.GroupIndices.length - 1; o >= 0; o--) {

      int OBJ_ID = this.GroupIndices[o];

      for (int f = allGroups.getStart_Face(OBJ_ID); f <= allGroups.getStop_Face(OBJ_ID); f++) {

        if ((0 <= f) && (f < allFaces.nodes.length)) {
          for (int j = 0; j < allFaces.nodes[f].length; j++) {

            int vNo = allFaces.nodes[f][j];

            if (!seen[vNo]) {
              seen[vNo] = true;
              PolymeshVertices.append(vNo);
            }
          }
        }
      }



      for (int f = allGroups.getStart_Polyline(OBJ_ID); f <= allGroups.getStop_Polyline(OBJ_ID); f++) {

        if ((0 <= f) && (f < allPolylines.nodes.length)) {
          for (int j = 0; j < allPolylines.nodes[f].length; j++) {

            int vNo = allPolylines.nodes[f][j];

            if (!seen[vNo]) {
              seen[vNo] = true;
              PolymeshVertices.append(vNo);
            }
          }
        }
      }
    }

    return PolymeshVertices.array();
  }



  public void to_XML (XML xml) {

    //printlnSaving(this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "positionVectorIndex", this.positionVectorIndex);
    XML_setInt(parent, "rotationVectorIndex", this.rotationVectorIndex);
    XML_setInt(parent, "scaleVectorIndex", this.scaleVectorIndex);
    XML_setFloat(parent, "position", this.position);
    XML_setFloat(parent, "rotation", this.rotation);
    XML_setFloat(parent, "scale", this.scale);
    XML_setInt(parent, "pivotAlignmentX", this.pivotAlignmentX);
    XML_setInt(parent, "pivotAlignmentY", this.pivotAlignmentY);
    XML_setInt(parent, "pivotAlignmentZ", this.pivotAlignmentZ);

    XML_setBoolean(parent, "faceDisplayEdges", this.faceDisplayEdges);
    XML_setBoolean(parent, "faceDisplayVertexIndices", this.faceDisplayVertexIndices);
    XML_setBoolean(parent, "polylineDisplayVertexIndices", this.polylineDisplayVertexIndices);
    XML_setBoolean(parent, "vertexDisplayMarkers", this.vertexDisplayMarkers);
    XML_setBoolean(parent, "polylineDisplayVertices", this.polylineDisplayVertices);
    XML_setBoolean(parent, "groupDisplayPivot", this.groupDisplayPivot);
    XML_setBoolean(parent, "pivotDisplayReference", this.pivotDisplayReference);
    XML_setBoolean(parent, "groupDisplayEdges", this.groupDisplayEdges);
    XML_setBoolean(parent, "groupDisplayBox", this.groupDisplayBox);
    XML_setBoolean(parent, "model2DDisplayBounds", this.model2DDisplayBounds);
    XML_setBoolean(parent, "model1DDisplayBounds", this.model1DDisplayBounds);
    XML_setBoolean(parent, "solidDisplayEdges", this.solidDisplayEdges);
    XML_setBoolean(parent, "sectionDisplayEdges", this.sectionDisplayEdges);
    XML_setBoolean(parent, "cameraDisplayFrustum", this.cameraDisplayFrustum);
    XML_setBoolean(parent, "terrainDisplayVertices", this.terrainDisplayVertices);

    XML_setFloat(parent, "softSelectionFalloffPower", this.softSelectionFalloffPower);
    XML_setFloat(parent, "softSelectionFalloffRadius", this.softSelectionFalloffRadius);

    XML_setString(parent, "selectedTerrainVertices", idsToXML(this.terrainVertexIndices));
    XML_setString(parent, "selected_Model1Ds", idsToXML(this.Model1DIndices));
    XML_setString(parent, "selected_Model2Ds", idsToXML(this.Model2DIndices));
    XML_setString(parent, "selected_Groups", idsToXML(this.GroupIndices));
    XML_setString(parent, "selected_Faces", idsToXML(this.FaceIndices));
    XML_setString(parent, "selected_Polylines", idsToXML(this.PolylineIndices));
    XML_setString(parent, "selected_Solids", idsToXML(this.SolidIndices));
    XML_setString(parent, "selected_Sections", idsToXML(this.SectionIndices));
    XML_setString(parent, "selected_Cameras", idsToXML(this.CameraIndices));
    XML_setString(parent, "selected_Points", idsToXML(this.VertexIndices));
    XML_setString(parent, "softSelectionIndices", idsToXML(this.softSelectionIndices));
    XML_setString(parent, "softSelection_values", floatsToXML(this.softSelection_values));
  }




  public void from_XML (XML xml) {

    //println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.positionVectorIndex = XML_getInt(parent, "positionVectorIndex");
    this.rotationVectorIndex = XML_getInt(parent, "rotationVectorIndex");
    this.scaleVectorIndex = XML_getInt(parent, "scaleVectorIndex");
    this.position = XML_getFloat(parent, "position");
    this.rotation = XML_getFloat(parent, "rotation");
    this.scale = XML_getFloat(parent, "scale");
    this.pivotAlignmentX = XML_getInt(parent, "pivotAlignmentX");
    this.pivotAlignmentY = XML_getInt(parent, "pivotAlignmentY");
    this.pivotAlignmentZ = XML_getInt(parent, "pivotAlignmentZ");

    this.pivotDisplayReference = XML_getBoolean(parent, "pivotDisplayReference");
    this.groupDisplayPivot = XML_getBoolean(parent, "groupDisplayPivot");
    this.groupDisplayEdges = XML_getBoolean(parent, "groupDisplayEdges");
    this.groupDisplayBox = XML_getBoolean(parent, "groupDisplayBox");
    this.faceDisplayEdges = XML_getBoolean(parent, "faceDisplayEdges");
    this.faceDisplayVertexIndices = XML_getBoolean(parent, "faceDisplayVertexIndices");
    this.polylineDisplayVertexIndices = XML_getBoolean(parent, "polylineDisplayVertexIndices");
    this.vertexDisplayMarkers = XML_getBoolean(parent, "vertexDisplayMarkers");
    this.polylineDisplayVertices = XML_getBoolean(parent, "polylineDisplayVertices");
    this.model2DDisplayBounds = XML_getBoolean(parent, "model2DDisplayBounds");
    this.model1DDisplayBounds = XML_getBoolean(parent, "model1DDisplayBounds");
    this.solidDisplayEdges = XML_getBoolean(parent, "solidDisplayEdges");
    this.sectionDisplayEdges = XML_getBoolean(parent, "sectionDisplayEdges");
    this.cameraDisplayFrustum = XML_getBoolean(parent, "cameraDisplayFrustum");
    this.terrainDisplayVertices = XML_getBoolean(parent, "terrainDisplayVertices");

    this.softSelectionFalloffPower = XML_getFloat(parent, "softSelectionFalloffPower");
    this.softSelectionFalloffRadius = XML_getFloat(parent, "softSelectionFalloffRadius");

    this.terrainVertexIndices = idsFromXML(XML_getString(parent, "selectedTerrainVertices"));
    this.Model1DIndices = idsFromXML(XML_getString(parent, "selected_Model1Ds"));
    this.Model2DIndices = idsFromXML(XML_getString(parent, "selected_Model2Ds"));
    this.GroupIndices = idsFromXML(XML_getString(parent, "selected_Groups"));
    this.FaceIndices = idsFromXML(XML_getString(parent, "selected_Faces"));
    this.PolylineIndices = idsFromXML(XML_getString(parent, "selected_Polylines"));
    this.SolidIndices = idsFromXML(XML_getString(parent, "selected_Solids"));
    this.SectionIndices = idsFromXML(XML_getString(parent, "selected_Sections"));
    this.CameraIndices = idsFromXML(XML_getString(parent, "selected_Cameras"));
    this.VertexIndices = idsFromXML(XML_getString(parent, "selected_Points"));
    this.softSelectionIndices = idsFromXML(XML_getString(parent, "softSelectionIndices"));
    this.softSelection_values = floatsFromXML(XML_getString(parent, "softSelection_values"));
  }

}
