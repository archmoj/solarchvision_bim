class solarchvision_Select3D {

  private final static String CLASS_STAMP = "Select3D";

  int posVector = 2; // 0:X, 1:Y, 2:Z, 3: All
  int rotVector = 2; // 0:X, 1:Y, 2:Z
  int scaleVector = 2; // 0:X, 1:Y, 2:Z, 3:All

  float posValue = 0;
  float rotValue = 0;
  float scaleValue = 0;

  int alignX = 0;
  int alignY = 0;
  int alignZ = 0;


  boolean displayReferencePivot = true;

  boolean Group_displayPivot = true;
  boolean Group_displayEdges = false;
  boolean Group_displayBox = true;

  boolean Face_displayEdges = true;
  boolean Face_displayVertexCount = false;
  boolean Polyline_displayVertexCount = false;
  boolean Vertex_displayVertices = true;
  boolean Polyline_displayVertices = true;


  boolean Model2D_displayEdges = true;
  boolean Model1D_displayEdges = true;
  boolean Solid_displayEdges = true;
  boolean Section_displayEdges = true;
  boolean Camera_displayEdges = true;
  boolean LandPoint_displayPoints = true;

  int[] LandPoint_ids = new int[0];
  int[] Camera_ids = new int[0];
  int[] Section_ids = new int[0];
  int[] Solid_ids = new int[0];
  int[] Model1D_ids = new int[0];
  int[] Model2D_ids = new int[0];
  int[] Group_ids = new int[0];
  int[] Face_ids = new int[0];
  int[] Vertex_ids = new int[0];
  int[] Polyline_ids = new int[0];

  int[] softSelection_ids = new int[0];
  float[] softSelection_values = new float[0];

  float softPower = 1;
  float softRadius = 2; // 2 = 2m


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

    float[][] hitPoint = new float [this.Face_ids.length][7];

    for (int o = 0; o < this.Face_ids.length; o++) {
      hitPoint[o][0] = FLOAT_undefined;
      hitPoint[o][1] = FLOAT_undefined;
      hitPoint[o][2] = FLOAT_undefined;
      hitPoint[o][3] = FLOAT_undefined;
      hitPoint[o][4] = FLOAT_undefined;
      hitPoint[o][5] = FLOAT_undefined;
      hitPoint[o][6] = FLOAT_undefined;
    }


    for (int o = 0; o < this.Face_ids.length; o++) {

      int f = this.Face_ids[o];

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
              hitPoint[f][0] = X_intersect;
              hitPoint[f][1] = Y_intersect;
              hitPoint[f][2] = Z_intersect;
              hitPoint[f][3] = dist2intersect;
              hitPoint[f][4] = face_norm[0];
              hitPoint[f][5] = face_norm[1];
              hitPoint[f][6] = face_norm[2];
            }

          }
        }
      }
    }

    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int o = 0; o < this.Face_ids.length; o++) {

      if (pre_dist > hitPoint[o][3]) {

        pre_dist = hitPoint[o][3];

        return_point[0] = o;
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


  private boolean update_BoundingBox = true; // internal

  void revise_BoundingBox () {
    this.update_BoundingBox = true;
  }

  void calculate_BoundingBox () {

    this.update_BoundingBox = false;

    int keep_selection_alignX = this.alignX;
    int keep_selection_alignY = this.alignY;
    int keep_selection_alignZ = this.alignZ;

    this.alignX = 0; // apply the centre
    this.alignY = 0; // apply the centre
    this.alignZ = 0; // apply the centre

    int[] theVertices = new int [0];

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      theVertices = this.Camera_ids;
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      theVertices = this.Section_ids;
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      theVertices = this.Solid_ids;
    }

    if ((current_ObjectCategory == ObjectCategory.VERTEX) ||
        (current_ObjectCategory == ObjectCategory.SOFTVERTEX)) {

      theVertices = this.Vertex_ids;
    }
    if (current_ObjectCategory == ObjectCategory.FACE) {
      theVertices = this.get_Face_Vertices();
    }
    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      theVertices = this.get_Polyline_Vertices();
    }
    if (current_ObjectCategory == ObjectCategory.GROUP) {
      theVertices = this.get_Group_Vertices();
    }
    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      theVertices = this.Model2D_ids;
    }
    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      theVertices = this.Model1D_ids;
    }
    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
      theVertices = this.LandPoint_ids;
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

    if (current_ObjectCategory == ObjectCategory.GROUP) {

      if (this.Group_ids.length > 0) {

        for (int o = 0; o < this.Group_ids.length - 1; o++) {

          int OBJ_ID = this.Group_ids[o];

          posX += allGroups.Pivots[OBJ_ID][0] / this.Group_ids.length;
          posY += allGroups.Pivots[OBJ_ID][1] / this.Group_ids.length;
          posZ += allGroups.Pivots[OBJ_ID][2] / this.Group_ids.length;

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

      if (current_ObjectCategory == ObjectCategory.CAMERA) {
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

      if (current_ObjectCategory == ObjectCategory.SECTION) {
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

      if (current_ObjectCategory == ObjectCategory.SOLID) {
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


      if ((current_ObjectCategory == ObjectCategory.GROUP) ||
          (current_ObjectCategory == ObjectCategory.FACE) ||
          (current_ObjectCategory == ObjectCategory.POLYLINE) ||
          (current_ObjectCategory == ObjectCategory.VERTEX) ||
          (current_ObjectCategory == ObjectCategory.SOFTVERTEX)) {

        int n = theVertices[q];

        x = allPoints.getX(n);
        y = allPoints.getY(n);
        z = allPoints.getZ(n);
      }
      if (current_ObjectCategory == ObjectCategory.MODEL2D) {
        int n = theVertices[q];

        x = allModel2Ds.getX(n);
        y = allModel2Ds.getY(n);
        z = allModel2Ds.getZ(n);
      }
      if (current_ObjectCategory == ObjectCategory.MODEL1D) {
        int n = theVertices[q];

        x = allModel1Ds.getX(n);
        y = allModel1Ds.getY(n);
        z = allModel1Ds.getZ(n);
      }
      if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
        int n = theVertices[q];

        int OBJ_ID = n;

        int the_i = OBJ_ID / Land3D.num_columns;
        int the_j = OBJ_ID % Land3D.num_columns;

        x = Land3D.Mesh[the_i][the_j][0];
        y = Land3D.Mesh[the_i][the_j][1];
        z = Land3D.Mesh[the_i][the_j][2];

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



    this.alignX = keep_selection_alignX;
    this.alignY = keep_selection_alignY;
    this.alignZ = keep_selection_alignZ;
  }



  void save_current_BoundingBox () {

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 9; j++) {
        saved_BoundingBox[i][j] = this.BoundingBox[i][j];
      }
    }

    saved_alignX = this.alignX;
    saved_alignY = this.alignY;
    saved_alignZ = this.alignZ;
  }


  void apply_saved_BoundingBox () {

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 9; j++) {
        this.BoundingBox[i][j] = saved_BoundingBox[i][j];
      }
    }

    this.alignX = saved_alignX;
    this.alignY = saved_alignY;
    this.alignZ = saved_alignZ;
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

    //this.alignX = 0;
    //this.alignY = 0;
    //this.alignZ = 0;
  }




  void reset_selectedRefValues () {

    this.posValue = 0;
    this.rotValue = 0;
    this.scaleValue = 0;
  }




  float[] translateInside_ReferencePivot (float a, float b, float c) {


    float rotX = this.BoundingBox[1 + this.alignX][6];
    float rotY = this.BoundingBox[1 + this.alignY][7];
    float rotZ = this.BoundingBox[1 + this.alignZ][8];

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

    x *= this.BoundingBox[1 + this.alignX][3];
    y *= this.BoundingBox[1 + this.alignY][4];
    z *= this.BoundingBox[1 + this.alignZ][5];

    x += this.BoundingBox[1 + this.alignX][0];
    y += this.BoundingBox[1 + this.alignY][1];
    z += this.BoundingBox[1 + this.alignZ][2];

    float[] return_array = {
      x, y, z
    };

    return return_array;
  }



  float[] translateOutside_ReferencePivot (float a, float b, float c) {

    a -= this.BoundingBox[1 + this.alignX][0];
    b -= this.BoundingBox[1 + this.alignY][1];
    c -= this.BoundingBox[1 + this.alignZ][2];

    a /= this.BoundingBox[1 + this.alignX][3];
    b /= this.BoundingBox[1 + this.alignY][4];
    c /= this.BoundingBox[1 + this.alignZ][5];



    float rotX = this.BoundingBox[1 + this.alignX][6];
    float rotY = this.BoundingBox[1 + this.alignY][7];
    float rotZ = this.BoundingBox[1 + this.alignZ][8];

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

    float x = this.BoundingBox[1 + this.alignX][0];
    float y = this.BoundingBox[1 + this.alignY][1];
    float z = this.BoundingBox[1 + this.alignZ][2];

    {
      int keep_selection_alignX = this.alignX;
      int keep_selection_alignY = this.alignY;
      int keep_selection_alignZ = this.alignZ;

      this.alignX = 0; // apply the centre
      this.alignY = 0; // apply the centre
      this.alignZ = 0; // apply the centre

      float[] A = this.translateInside_ReferencePivot(x - posX, y - posY, z - posZ);

      x = A[0];
      y = A[1];
      z = A[2];

      this.alignX = keep_selection_alignX;
      this.alignY = keep_selection_alignY;
      this.alignZ = keep_selection_alignZ;
    }

    float[] return_array = {
      x, y, z
    };

    return return_array;
  }



  void selectPick (float[] RxP) {

    if (addNewSelectionToPreviousSelection == 0) this.deselectAll();


    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {

      int OBJ_ID = int(RxP[0]);

      this.LandPoint_ids = toggleSelection(this.LandPoint_ids, OBJ_ID);
    }


    if (current_ObjectCategory == ObjectCategory.MODEL1D) {

      int OBJ_ID = int(RxP[0]);

      this.Model1D_ids = toggleSelection(this.Model1D_ids, OBJ_ID);
    }


    if (current_ObjectCategory == ObjectCategory.MODEL2D) {

      int OBJ_ID = int(RxP[0]);

      this.Model2D_ids = toggleSelection(this.Model2D_ids, OBJ_ID);
    }


    if (current_ObjectCategory == ObjectCategory.GROUP) {

      int f = int(RxP[0]);

      int OBJ_ID = 0;

      for (int i = 0; i < allGroups.num; i++) {
        if ((allGroups.Faces[i][0] <= f) && (f <= allGroups.Faces[i][1])) {
          OBJ_ID = i;
          break;
        }
      }

      this.Group_ids = toggleSelection(this.Group_ids, OBJ_ID);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {

      int OBJ_ID = int(RxP[0]);

      this.Face_ids = toggleSelection(this.Face_ids, OBJ_ID);
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {

      int OBJ_ID = int(RxP[0]);

      this.Polyline_ids = toggleSelection(this.Polyline_ids, OBJ_ID);
    }


    if (current_ObjectCategory == ObjectCategory.VERTEX) {

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


      this.Vertex_ids = toggleSelection(this.Vertex_ids, OBJ_ID);
    }



    if (current_ObjectCategory == ObjectCategory.SOLID) {

      int OBJ_ID = int(RxP[0]);

      this.Solid_ids = toggleSelection(this.Solid_ids, OBJ_ID);
    }



    if (current_ObjectCategory == ObjectCategory.SECTION) {

      int OBJ_ID = int(RxP[0]);

      this.Section_ids = toggleSelection(this.Section_ids, OBJ_ID);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {

      int OBJ_ID = int(RxP[0]);

      this.Camera_ids = toggleSelection(this.Camera_ids, OBJ_ID);

    }


    SOLARCHVISION_selection_changed();
  }


  void selectRect (float corner1x, float corner1y, float corner2x, float corner2y) {

    if (addNewSelectionToPreviousSelection == 0) this.deselectAll();


    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {

      for (int OBJ_ID = 0; OBJ_ID < Land3D.num_rows * Land3D.num_columns; OBJ_ID++) {

        int i = OBJ_ID / Land3D.num_columns;
        int j = OBJ_ID % Land3D.num_columns;

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        for (int k = 0; k < 1; k++) { // just a loop to make those break commands relevant!

          float x = Land3D.Mesh[i][j][0] * OBJECTS_scale;
          float y = Land3D.Mesh[i][j][1] * OBJECTS_scale;
          float z = -Land3D.Mesh[i][j][2] * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }
        }



        if (include_OBJ_in_newSelection == 1) {

          this.LandPoint_ids = toggleSelection(this.LandPoint_ids, OBJ_ID);
        }
      }
    }



    if (current_ObjectCategory == ObjectCategory.MODEL1D) {

      for (int OBJ_ID = 0; OBJ_ID < allModel1Ds.Faces.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int f = OBJ_ID;

        for (int j = 0; j < allModel1Ds.Faces[f].length; j++) {

          int vNo = allModel1Ds.Faces[f][j];

          float x = allModel1Ds.Vertices[vNo][0] * OBJECTS_scale;
          float y = allModel1Ds.Vertices[vNo][1] * OBJECTS_scale;
          float z = -allModel1Ds.Vertices[vNo][2] * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.Model1D_ids = toggleSelection(this.Model1D_ids, OBJ_ID);
        }
      }
    }



    if (current_ObjectCategory == ObjectCategory.GROUP) {

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

                float x = allPoints.getX(vNo) * OBJECTS_scale;
                float y = allPoints.getY(vNo) * OBJECTS_scale;
                float z = -allPoints.getZ(vNo) * OBJECTS_scale;

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

                float x = allPoints.getX(vNo) * OBJECTS_scale;
                float y = allPoints.getY(vNo) * OBJECTS_scale;
                float z = -allPoints.getZ(vNo) * OBJECTS_scale;

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

          this.Group_ids = toggleSelection(this.Group_ids, OBJ_ID);
        }
      }
    }


    if (current_ObjectCategory == ObjectCategory.FACE) {

      for (int OBJ_ID = 0; OBJ_ID < allFaces.nodes.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        for (int j = 0; j < allFaces.nodes[OBJ_ID].length; j++) {
          int vNo = allFaces.nodes[OBJ_ID][j];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = -allPoints.getZ(vNo) * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
          }

          if (break_loops == 1) break;
        }



        if (include_OBJ_in_newSelection == 1) {

          this.Face_ids = toggleSelection(this.Face_ids, OBJ_ID);
        }
      }
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {

      for (int OBJ_ID = 0; OBJ_ID < allPolylines.nodes.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        for (int j = 0; j < allPolylines.nodes[OBJ_ID].length; j++) {
          int vNo = allPolylines.nodes[OBJ_ID][j];

          float x = allPoints.getX(vNo) * OBJECTS_scale;
          float y = allPoints.getY(vNo) * OBJECTS_scale;
          float z = -allPoints.getZ(vNo) * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
          }

          if (break_loops == 1) break;
        }



        if (include_OBJ_in_newSelection == 1) {

          this.Polyline_ids = toggleSelection(this.Polyline_ids, OBJ_ID);
        }
      }
    }


    if (current_ObjectCategory == ObjectCategory.VERTEX) {

      for (int OBJ_ID = 0; OBJ_ID < allPoints.getLength(); OBJ_ID++) {

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        float x = allPoints.getX(OBJ_ID) * OBJECTS_scale;
        float y = allPoints.getY(OBJ_ID) * OBJECTS_scale;
        float z = -allPoints.getZ(OBJ_ID) * OBJECTS_scale;

        int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
        if (decision != -1) {
          include_OBJ_in_newSelection = decision;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.Vertex_ids = toggleSelection(this.Vertex_ids, OBJ_ID);
        }
      }
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {

      for (int f = 0; f < allModel2Ds.Faces.length; f++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int OBJ_ID = f / allModel2Ds.num_visualFaces;

        //println(f, OBJ_ID);

        for (int j = 0; j < allModel2Ds.Faces[f].length; j++) {

          int vNo = allModel2Ds.Faces[f][j];

          float x = allModel2Ds.Vertices[vNo][0] * OBJECTS_scale;
          float y = allModel2Ds.Vertices[vNo][1] * OBJECTS_scale;
          float z = -allModel2Ds.Vertices[vNo][2] * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          int previousCount = this.Model2D_ids.length;
          this.Model2D_ids = toggleSelection(this.Model2D_ids, OBJ_ID);

          if (this.Model2D_ids.length > previousCount) {
            // skip the same object's drawn faces
            f += allModel2Ds.num_visualFaces - (f % allModel2Ds.num_visualFaces) - 1;
          }
        }
      }
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {

      for (int f = 0; f < allSolids.Faces.length; f++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int OBJ_ID = f / allSolids.num_visualFaces;

        //println(f, OBJ_ID);

        for (int j = 0; j < allSolids.Faces[f].length; j++) {

          int vNo = allSolids.Faces[f][j];

          float x = allSolids.Vertices[vNo][0] * OBJECTS_scale;
          float y = allSolids.Vertices[vNo][1] * OBJECTS_scale;
          float z = -allSolids.Vertices[vNo][2] * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          int previousCount = this.Solid_ids.length;
          this.Solid_ids = toggleSelection(this.Solid_ids, OBJ_ID);

          if (this.Solid_ids.length > previousCount) {
            // skip the same object's drawn faces
            f += allSolids.num_visualFaces - (f % allSolids.num_visualFaces) - 1;
          }
        }
      }
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {

      for (int OBJ_ID = 0; OBJ_ID < allSections.Faces.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int f = OBJ_ID;

        for (int j = 0; j < allSections.Faces[f].length; j++) {

          int vNo = allSections.Faces[f][j];

          float x = allSections.Vertices[vNo][0] * OBJECTS_scale;
          float y = allSections.Vertices[vNo][1] * OBJECTS_scale;
          float z = -allSections.Vertices[vNo][2] * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.Section_ids = toggleSelection(this.Section_ids, OBJ_ID);
        }
      }
    }


    if (current_ObjectCategory == ObjectCategory.CAMERA) {

      for (int OBJ_ID = 0; OBJ_ID < allCameras.Faces.length; OBJ_ID++) {

        int break_loops = 0;

        int include_OBJ_in_newSelection = -1;

        if (mouseButton == RIGHT) include_OBJ_in_newSelection = 0;
        if (mouseButton == LEFT) include_OBJ_in_newSelection = 1;

        int f = OBJ_ID;

        for (int j = 0; j < allCameras.Faces[f].length; j++) {

          int vNo = allCameras.Faces[f][j];

          float x = allCameras.Vertices[vNo][0] * OBJECTS_scale;
          float y = allCameras.Vertices[vNo][1] * OBJECTS_scale;
          float z = -allCameras.Vertices[vNo][2] * OBJECTS_scale;

          int decision = rectTest_vertex(x, y, z, corner1x, corner1y, corner2x, corner2y);
          if (decision != -1) {
            include_OBJ_in_newSelection = decision;
            break_loops = 1;
            break;
          }

          if (break_loops == 1) break;
        }


        if (include_OBJ_in_newSelection == 1) {

          this.Camera_ids = toggleSelection(this.Camera_ids, OBJ_ID);
        }
      }
    }

    SOLARCHVISION_selection_changed();
  }





  void deselect_LandPoints () {
    this.LandPoint_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Vertices () {
    this.Vertex_ids = new int [0];

    this.deselect_softSelection();

    SOLARCHVISION_selection_changed();
  }

  void deselect_softSelection () {
    this.softSelection_ids = new int [0];
    this.softSelection_values = new float [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Faces () {
    this.Face_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Polylines () {
    this.Polyline_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Solids () {
    this.Solid_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Cameras () {
    this.Camera_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Sections () {
    this.Section_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Model1Ds () {
    this.Model1D_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }


  void deselect_Model2Ds () {
    this.Model2D_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }

  void deselect_Groups () {
    this.Group_ids = new int [0];

    SOLARCHVISION_selection_changed();
  }


  void deselectAll () {

    this.deselect_LandPoints();
    this.deselect_Cameras();
    this.deselect_Sections();
    this.deselect_Solids();
    this.deselect_Model1Ds();
    this.deselect_Model2Ds();
    this.deselect_Faces();
    this.deselect_Polylines();
    this.deselect_Vertices();
    this.deselect_Groups();

    SOLARCHVISION_selection_changed();
  }

  void selectAll () {

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
      this.LandPoint_ids = rangeIds(Land3D.num_rows * Land3D.num_columns);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1D_ids = rangeIds(allModel1Ds.num);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2D_ids = rangeIds(allModel2Ds.num);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Group_ids = rangeIds(allGroups.num);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Face_ids = rangeIds(allFaces.nodes.length);
    }

    if (current_ObjectCategory == ObjectCategory.VERTEX) {
      this.Vertex_ids = rangeIds(allPoints.getLength());
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polyline_ids = rangeIds(allPolylines.nodes.length);
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solid_ids = rangeIds(allSolids.DEF.length);
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Section_ids = rangeIds(allSections.num);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Camera_ids = rangeIds(allCameras.num);
    }

    SOLARCHVISION_selection_changed();
  }


  void invertSelection () {

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
      this.LandPoint_ids = invertedIds(this.LandPoint_ids, Land3D.num_rows * Land3D.num_columns);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1D_ids = invertedIds(this.Model1D_ids, allModel1Ds.num);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2D_ids = invertedIds(this.Model2D_ids, allModel2Ds.num);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Group_ids = invertedIds(this.Group_ids, allGroups.num);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Face_ids = invertedIds(this.Face_ids, allFaces.nodes.length);
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polyline_ids = invertedIds(this.Polyline_ids, allPolylines.nodes.length);
    }


    if (current_ObjectCategory == ObjectCategory.VERTEX) {
      this.Vertex_ids = invertedIds(this.Vertex_ids, allPoints.getLength());
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solid_ids = invertedIds(this.Solid_ids, allSolids.DEF.length);
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Section_ids = invertedIds(this.Section_ids, allSections.num);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Camera_ids = invertedIds(this.Camera_ids, allCameras.num);
    }

    SOLARCHVISION_selection_changed();
  }









  void selectLast () {

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Section_ids = lastId(allSections.num);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Camera_ids = lastId(allCameras.num);
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solid_ids = lastId(allSolids.DEF.length);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1D_ids = lastId(allModel1Ds.num);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2D_ids = lastId(allModel2Ds.num);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Group_ids = lastId(allGroups.num);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Face_ids = lastId(allFaces.nodes.length);
    }

    if (current_ObjectCategory == ObjectCategory.VERTEX) {
      this.Vertex_ids = lastId(allPoints.getLength());
    }


    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polyline_ids = lastId(allPolylines.nodes.length);
    }

    SOLARCHVISION_selection_changed();
  }



  float softSelectionFunction (float d_min) {

    float v = 0;

    if (d_min < this.softRadius) {
      v = pow(funcs.cos_ang(90 * d_min / this.softRadius), this.softPower);
    }

    return v;
  }


  void convert_Model1Ds_to_Groups () {
    this.Group_ids = groupsContaining(allGroups.Model1Ds, this.Model1D_ids);
    SOLARCHVISION_selection_changed();
  }

  void convert_Model2Ds_to_Groups () {
    this.Group_ids = groupsContaining(allGroups.Model2Ds, this.Model2D_ids);
    SOLARCHVISION_selection_changed();
  }


  void convert_Solids_to_Groups () {
    this.Group_ids = groupsContaining(allGroups.Solids, this.Solid_ids);
    SOLARCHVISION_selection_changed();
  }

  void convert_Faces_to_Groups () {
    // NOTE: the original repeated this group-membership scan once per node
    // in each face; since the outcome only depends on the face index (not
    // which node triggered it) and dedup already prevents double-adding,
    // that inner loop was redundant. Removed as a behavior-preserving
    // simplification.
    this.Group_ids = groupsContaining(allGroups.Faces, this.Face_ids);
    SOLARCHVISION_selection_changed();
  }

  void convert_Polylines_to_Groups () {
    // See the note in convert_Faces_to_Groups() above - same simplification.
    this.Group_ids = groupsContaining(allGroups.Polylines, this.Polyline_ids);
    SOLARCHVISION_selection_changed();
  }



  void convert_Vertices_to_Groups () {

    boolean[] Group_seen = new boolean[allGroups.num];
    IntList Group_ids_buf = new IntList();

    for (int i = 0; i < this.Vertex_ids.length; i++) {
      int vNo = this.Vertex_ids[i];
      appendGroupsContainingVertex(allFaces.nodes, allGroups.Faces, vNo, Group_seen, Group_ids_buf);
      appendGroupsContainingVertex(allPolylines.nodes, allGroups.Polylines, vNo, Group_seen, Group_ids_buf);
    }

    this.Group_ids = Group_ids_buf.array();

    SOLARCHVISION_selection_changed();
  }


  void convert_Vertices_to_Faces () {
    this.Face_ids = objectsContainingVertices(allFaces.nodes, this.Vertex_ids);
    SOLARCHVISION_selection_changed();
  }


  void convert_Vertices_to_Polylines () {
    this.Polyline_ids = objectsContainingVertices(allPolylines.nodes, this.Vertex_ids);
    SOLARCHVISION_selection_changed();
  }

  void convert_Groups_to_Model1Ds () {
    this.Model1D_ids = rangeUnion(allGroups.Model1Ds, this.Group_ids, allModel1Ds.num);
    SOLARCHVISION_selection_changed();
  }


  void convert_Groups_to_Model2Ds () {
    this.Model2D_ids = rangeUnion(allGroups.Model2Ds, this.Group_ids, allModel2Ds.num);
    SOLARCHVISION_selection_changed();
  }



  void convert_Groups_to_Solids () {
    this.Solid_ids = rangeUnion(allGroups.Solids, this.Group_ids, allSolids.DEF.length);
    SOLARCHVISION_selection_changed();
  }



  void convert_Groups_to_Faces () {
    this.Face_ids = rangeUnion(allGroups.Faces, this.Group_ids, allFaces.nodes.length);
    SOLARCHVISION_selection_changed();
  }


  void convert_Groups_to_Polylines () {
    this.Polyline_ids = rangeUnion(allGroups.Polylines, this.Group_ids, allPolylines.nodes.length);
    SOLARCHVISION_selection_changed();
  }



  void convert_Groups_to_Vertices () {

    boolean[] Vertex_seen = new boolean[allPoints.getLength()];
    IntList Vertex_buf = new IntList();

    for (int i = 0; i < this.Group_ids.length; i++) {
      int OBJ_ID = this.Group_ids[i];
      appendNodesOfRange(allFaces.nodes, allGroups.getStart_Face(OBJ_ID), allGroups.getStop_Face(OBJ_ID), Vertex_seen, Vertex_buf);
      appendNodesOfRange(allPolylines.nodes, allGroups.getStart_Polyline(OBJ_ID), allGroups.getStop_Polyline(OBJ_ID), Vertex_seen, Vertex_buf);
    }

    this.Vertex_ids = Vertex_buf.array();

    SOLARCHVISION_selection_changed();
  }


  void convert_Faces_to_Vertices () {
    this.Vertex_ids = nodesOf(allFaces.nodes, this.Face_ids);
    SOLARCHVISION_selection_changed();
  }


  void convert_Polylines_to_Vertices () {
    this.Vertex_ids = nodesOf(allPolylines.nodes, this.Polyline_ids);
    SOLARCHVISION_selection_changed();
  }




  void convert_Vertex_to_softSelection () {

    int[] keep_selection_Vertex_ids = this.Vertex_ids;

    this.convert_Vertices_to_Groups();

    this.convert_Groups_to_Vertices();

    this.softSelection_ids = new int[this.Vertex_ids.length];
    this.softSelection_values = new float[this.Vertex_ids.length];

    for (int q = 0; q < this.Vertex_ids.length; q++) {

      int n = this.Vertex_ids[q];

      float d_min = FLOAT_undefined;

      for (int p = 0; p < keep_selection_Vertex_ids.length; p++) {

        int m = keep_selection_Vertex_ids[p];

        float d = dist(allPoints.getX(m), allPoints.getY(m), allPoints.getZ(m), allPoints.getX(n), allPoints.getY(n), allPoints.getZ(n));

        if (d_min > d) {
          d_min = d;
        }
      }

      this.softSelection_values[q] = this.softSelectionFunction(d_min);
    }

    this.softSelection_ids = this.Vertex_ids;

    this.Vertex_ids = keep_selection_Vertex_ids;

    SOLARCHVISION_selection_changed();
  }



  void selectNearVertices () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      if (current_ObjectCategory == ObjectCategory.GROUP) {

        this.convert_Groups_to_Vertices();
      }

      if (current_ObjectCategory == ObjectCategory.FACE) {

        this.convert_Faces_to_Vertices();
      }

      if (current_ObjectCategory == ObjectCategory.POLYLINE) {

        this.convert_Polylines_to_Vertices();
      }

      this.Vertex_ids = sort(this.Vertex_ids);

      int[] pre_Selection_Vertex_ids = this.Vertex_ids;

      boolean[] Vertex_seen = new boolean[allPoints.getLength()];
      for (int i = 0; i < this.Vertex_ids.length; i++) {
        Vertex_seen[this.Vertex_ids[i]] = true;
      }
      IntList Vertex_buf = new IntList();
      for (int i = 0; i < this.Vertex_ids.length; i++) {
        Vertex_buf.append(this.Vertex_ids[i]);
      }

      for (int vNo = allPoints.getLength() - 1; vNo >= 0; vNo--) {

        int isNearEnough = -1;

        for (int i = 0; i < pre_Selection_Vertex_ids.length; i++) {

          int q = pre_Selection_Vertex_ids[i];

          if (!Vertex_seen[vNo]) {

            float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

            if (d <= User3D.modify_WeldTreshold) {

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

      this.Vertex_ids = Vertex_buf.array();

      SOLARCHVISION_selection_changed();
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

    this.Vertex_ids = Vertex_buf.array();

    SOLARCHVISION_switch_category(ObjectCategory.VERTEX);
  }









  int[] get_Face_Vertices () {

    IntList FaceVertices = new IntList();
    boolean[] seen = new boolean[allPoints.getLength()];

    for (int o = this.Face_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = this.Face_ids[o];

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

    for (int o = this.Polyline_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = this.Polyline_ids[o];

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

    for (int o = this.Group_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = this.Group_ids[o];

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

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "posVector", this.posVector);
    XML_setInt(parent, "rotVector", this.rotVector);
    XML_setInt(parent, "scaleVector", this.scaleVector);
    XML_setFloat(parent, "posValue", this.posValue);
    XML_setFloat(parent, "rotValue", this.rotValue);
    XML_setFloat(parent, "scaleValue", this.scaleValue);
    XML_setInt(parent, "alignX", this.alignX);
    XML_setInt(parent, "alignY", this.alignY);
    XML_setInt(parent, "alignZ", this.alignZ);

    XML_setBoolean(parent, "Face_displayEdges", this.Face_displayEdges);
    XML_setBoolean(parent, "Face_displayVertexCount", this.Face_displayVertexCount);
    XML_setBoolean(parent, "Polyline_displayVertexCount", this.Polyline_displayVertexCount);
    XML_setBoolean(parent, "Vertex_displayVertices", this.Vertex_displayVertices);
    XML_setBoolean(parent, "Polyline_displayVertices", this.Polyline_displayVertices);
    XML_setBoolean(parent, "Group_displayPivot", this.Group_displayPivot);
    XML_setBoolean(parent, "displayReferencePivot", this.displayReferencePivot);
    XML_setBoolean(parent, "Group_displayEdges", this.Group_displayEdges);
    XML_setBoolean(parent, "Group_displayBox", this.Group_displayBox);
    XML_setBoolean(parent, "Model2D_displayEdges", this.Model2D_displayEdges);
    XML_setBoolean(parent, "Model1D_displayEdges", this.Model1D_displayEdges);
    XML_setBoolean(parent, "Solid_displayEdges", this.Solid_displayEdges);
    XML_setBoolean(parent, "Section_displayEdges", this.Section_displayEdges);
    XML_setBoolean(parent, "Camera_displayEdges", this.Camera_displayEdges);
    XML_setBoolean(parent, "LandPoint_displayPoints", this.LandPoint_displayPoints);

    XML_setFloat(parent, "softPower", this.softPower);
    XML_setFloat(parent, "softRadius", this.softRadius);

    XML_setString(parent, "selected_LandPoints", idsToXML(this.LandPoint_ids));
    XML_setString(parent, "selected_Model1Ds", idsToXML(this.Model1D_ids));
    XML_setString(parent, "selected_Model2Ds", idsToXML(this.Model2D_ids));
    XML_setString(parent, "selected_Groups", idsToXML(this.Group_ids));
    XML_setString(parent, "selected_Faces", idsToXML(this.Face_ids));
    XML_setString(parent, "selected_Polylines", idsToXML(this.Polyline_ids));
    XML_setString(parent, "selected_Solids", idsToXML(this.Solid_ids));
    XML_setString(parent, "selected_Sections", idsToXML(this.Section_ids));
    XML_setString(parent, "selected_Cameras", idsToXML(this.Camera_ids));
    XML_setString(parent, "selected_Points", idsToXML(this.Vertex_ids));
    XML_setString(parent, "softSelection_ids", idsToXML(this.softSelection_ids));
    XML_setString(parent, "softSelection_values", floatsToXML(this.softSelection_values));
  }




  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.posVector = XML_getInt(parent, "posVector");
    this.rotVector = XML_getInt(parent, "rotVector");
    this.scaleVector = XML_getInt(parent, "scaleVector");
    this.posValue = XML_getFloat(parent, "posValue");
    this.rotValue = XML_getFloat(parent, "rotValue");
    this.scaleValue = XML_getFloat(parent, "scaleValue");
    this.alignX = XML_getInt(parent, "alignX");
    this.alignY = XML_getInt(parent, "alignY");
    this.alignZ = XML_getInt(parent, "alignZ");

    this.displayReferencePivot = XML_getBoolean(parent, "displayReferencePivot");
    this.Group_displayPivot = XML_getBoolean(parent, "Group_displayPivot");
    this.Group_displayEdges = XML_getBoolean(parent, "Group_displayEdges");
    this.Group_displayBox = XML_getBoolean(parent, "Group_displayBox");
    this.Face_displayEdges = XML_getBoolean(parent, "Face_displayEdges");
    this.Face_displayVertexCount = XML_getBoolean(parent, "Face_displayVertexCount");
    this.Polyline_displayVertexCount = XML_getBoolean(parent, "Polyline_displayVertexCount");
    this.Vertex_displayVertices = XML_getBoolean(parent, "Vertex_displayVertices");
    this.Polyline_displayVertices = XML_getBoolean(parent, "Polyline_displayVertices");
    this.Model2D_displayEdges = XML_getBoolean(parent, "Model2D_displayEdges");
    this.Model1D_displayEdges = XML_getBoolean(parent, "Model1D_displayEdges");
    this.Solid_displayEdges = XML_getBoolean(parent, "Solid_displayEdges");
    this.Section_displayEdges = XML_getBoolean(parent, "Section_displayEdges");
    this.Camera_displayEdges = XML_getBoolean(parent, "Camera_displayEdges");
    this.LandPoint_displayPoints = XML_getBoolean(parent, "LandPoint_displayPoints");

    this.softPower = XML_getFloat(parent, "softPower");
    this.softRadius = XML_getFloat(parent, "softRadius");

    this.LandPoint_ids = idsFromXML(XML_getString(parent, "selected_LandPoints"));
    this.Model1D_ids = idsFromXML(XML_getString(parent, "selected_Model1Ds"));
    this.Model2D_ids = idsFromXML(XML_getString(parent, "selected_Model2Ds"));
    this.Group_ids = idsFromXML(XML_getString(parent, "selected_Groups"));
    this.Face_ids = idsFromXML(XML_getString(parent, "selected_Faces"));
    this.Polyline_ids = idsFromXML(XML_getString(parent, "selected_Polylines"));
    this.Solid_ids = idsFromXML(XML_getString(parent, "selected_Solids"));
    this.Section_ids = idsFromXML(XML_getString(parent, "selected_Sections"));
    this.Camera_ids = idsFromXML(XML_getString(parent, "selected_Cameras"));
    this.Vertex_ids = idsFromXML(XML_getString(parent, "selected_Points"));
    this.softSelection_ids = idsFromXML(XML_getString(parent, "softSelection_ids"));
    this.softSelection_values = floatsFromXML(XML_getString(parent, "softSelection_values"));
  }

}
