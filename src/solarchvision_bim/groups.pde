class Groups {

  final static String CLASS_STAMP = "group";

  Groups () { // constructor
    makeEmpty(0);
  }

  int num;
  int[][] Polylines;
  int[][] Faces;
  int[][] Solids;
  int[][] Model1Ds;
  int[][] Model2Ds;
  float[][] Pivots;

  // Opaque, caller-defined JSON metadata, one entry per group - "" is the
  // canonical "nothing here" value (see extraParamsHelpers.pde's own
  // comment, shared with faces.pde/polylines.pde). Parsed lazily, only
  // via getExtraParamsObject()/setExtraParamsObject() below, never during
  // to_XML/from_XML or any structural resize.
  String[] extraParams;

  void makeEmpty (int n) {
    beginScene3DChange();

    this.num = n;
    this.Model1Ds = new int [n][2];
    this.Model2Ds = new int [n][2];
    this.Faces = new int [n][2];
    this.Polylines = new int [n][2];
    this.Solids = new int [n][2];
    this.Pivots = new float [n][9];
    this.extraParams = new String [n];
    java.util.Arrays.fill(this.extraParams, "");

    if (Select3D != null) {
      Select3D.deselect_Groups();
    }

    endScene3DChange();
  }



  int getStart_Polyline (int n) {
    if(this.Polylines.length < 1) return 0;
    return this.Polylines[n][0];
  }

  int getStop_Polyline (int n) {
    if(this.Polylines.length < 1) return -1;
    return this.Polylines[n][1];
  }

  int getStart_Face (int n) {
    if(this.Faces.length < 1) return 0;
    return this.Faces[n][0];
  }

  int getStop_Face (int n) {
    if(this.Faces.length < 1) return -1;
    return this.Faces[n][1];
  }

  int getStart_Solid (int n) {
    if(this.Solids.length < 1) return 0;
    return this.Solids[n][0];
  }

  int getStop_Solid (int n) {
    if(this.Solids.length < 1) return -1;
    return this.Solids[n][1];
  }

  int getStart_Model1D (int n) {
    if(this.Model1Ds.length < 1) return 0;
    return this.Model1Ds[n][0];
  }

  int getStop_Model1D (int n) {
    if(this.Model1Ds.length < 1) return -1;
    return this.Model1Ds[n][1];
  }

  int getStart_Model2D (int n) {
    if(this.Model2Ds.length < 1) return 0;
    return this.Model2Ds[n][0];
  }

  int getStop_Model2D (int n) {
    if(this.Model2Ds.length < 1) return -1;
    return this.Model2Ds[n][1];
  }

  void setStart_Polyline (int n, int t) {
    this.Polylines[n][0] = t;
  }

  void setStop_Polyline (int n, int t) {
    this.Polylines[n][1] = t;
  }

  void setStart_Face (int n, int t) {
    this.Faces[n][0] = t;
  }

  void setStop_Face (int n, int t) {
    this.Faces[n][1] = t;
  }

  void setStart_Solid (int n, int t) {
    this.Solids[n][0] = t;
  }

  void setStop_Solid (int n, int t) {
    this.Solids[n][1] = t;
  }

  void setStart_Model1D (int n, int t) {
    this.Model1Ds[n][0] = t;
  }

  void setStop_Model1D (int n, int t) {
    this.Model1Ds[n][1] = t;
  }

  void setStart_Model2D (int n, int t) {
    this.Model2Ds[n][0] = t;
  }

  void setStop_Model2D (int n, int t) {
    this.Model2Ds[n][1] = t;
  }

  // Defensive against extraParams being shorter than this.num (or null)
  // at the time of the call - never throws, just reads as "no extra
  // params" past the end, same as a genuinely-empty entry would (see
  // faces.pde's own identical getExtraParams()/comment).
  String getExtraParams (int n) {
    if (this.extraParams == null || n < 0 || n >= this.extraParams.length) return "";
    return this.extraParams[n];
  }

  void setExtraParams (int n, String json) {
    this.extraParams[n] = json;
  }

  // Pads (or, in principle, trims) extraParams to exactly this.num's own
  // current length, filling any new/missing entries with "" - same
  // self-healing purpose as faces.pde's own ensureExtraParamsLength().
  void ensureExtraParamsLength () {
    if (this.extraParams != null && this.extraParams.length == this.num) return;
    String[] resized = new String[this.num];
    int copyLen = (this.extraParams == null) ? 0 : min(this.extraParams.length, resized.length);
    for (int i = 0; i < copyLen; i++) resized[i] = this.extraParams[i];
    for (int i = copyLen; i < resized.length; i++) resized[i] = "";
    this.extraParams = resized;
  }

  // Convenience wrappers around extraParamsHelpers.pde's own shared
  // parse/stringify - nothing else in this file should call
  // JSONObject.parse()/extraParamsFromJSONObject() directly.
  JSONObject getExtraParamsObject (int n) {
    return extraParamsToJSONObject(this.getExtraParams(n));
  }

  void setExtraParamsObject (int n, JSONObject obj) {
    this.setExtraParams(n, extraParamsFromJSONObject(obj));
  }

  // Resets every group's own extraParams back to "" (its documented
  // default, above) regardless of selection - see faces.pde's own
  // identical method for the full reasoning.
  void stripAllExtraParams () {
    this.ensureExtraParamsLength();
    for (int n = 0; n < this.extraParams.length; n++) this.extraParams[n] = "";
  }


  void inserted_nFaces (int n, int fromFace, int howMany) {
    for (int i = n + 1; i < this.num; i++) {
      this.setStart_Face(i, this.getStart_Face(i) + howMany);
      this.setStop_Face(i, this.getStop_Face(i) + howMany);
    }

    this.setStop_Face(n, this.getStop_Face(n) + howMany); // because adding the faces also changes the end pointer of the same object

    for (int k = 0; k < Select3D.faceSelection.length; k++) {
      if (Select3D.faceSelection[k] != 0) {
        if (Select3D.faceSelection[k] > fromFace) {
          Select3D.faceSelection[k] += howMany;
        }
      }
    }
  }


  int beginNewGroup (float x, float y, float z, float sx, float sy, float sz, float rx, float ry, float rz) {

    float[][] newObject_Pivots = {
      {
        x, y, z, sx, sy, sz, rx, ry, rz
      }
    };
    this.Pivots = (float[][]) concat(this.Pivots, newObject_Pivots);

    int[][] newObject_allModel1Ds = {
      {
        allModel1Ds.num, -1
      }
    }; // i.e. null because start > end
    this.Model1Ds = (int[][]) concat(this.Model1Ds, newObject_allModel1Ds);

    int[][] newObject_allModel2Ds = {
      {
        allModel2Ds.num, -1
      }
    }; // i.e. null because start > end
    this.Model2Ds = (int[][]) concat(this.Model2Ds, newObject_allModel2Ds);

    int[][] newObject_allSolids = {
      {
        allSolids.DEF.length, -1
      }
    }; // i.e. null because start > end
    this.Solids = (int[][]) concat(this.Solids, newObject_allSolids);

    int[][] newObject_Faces = {
      {
        allFaces.nodes.length, -1
      }
    }; // i.e. null because start > end
    this.Faces = (int[][]) concat(this.Faces, newObject_Faces);

    int[][] newObject_Polylines = {
      {
        allPolylines.nodes.length, -1
      }
    }; // i.e. null because start > end
    this.Polylines = (int[][]) concat(this.Polylines, newObject_Polylines);

    // New-from-scratch group - no source to inherit extraParams from, so
    // it gets this field's own "nothing here" default (""), same as
    // faces.pde's/polylines.pde's own create().
    this.ensureExtraParamsLength(); // so the append below lands at exactly this.num (now stale by one, about to be incremented) - guards the same way every other structural Groups operation does
    this.extraParams = (String[]) concat(this.extraParams, new String[]{ "" });

    this.num += 1;

    return(this.num - 1);
  }






  void group_Selection (int createNewGroup) { // if this option == 0 then the objects are added to the last group


    boolean run_process = false;

    if (currentObjectCategory == ObjectCategory.SOLID) run_process = true;
    if (currentObjectCategory == ObjectCategory.FACE) run_process = true;
    if (currentObjectCategory == ObjectCategory.POLYLINE) run_process = true;
    if (currentObjectCategory == ObjectCategory.MODEL2D) run_process = true;
    if (currentObjectCategory == ObjectCategory.MODEL1D) run_process = true;

    if (run_process) {

      // See isFileOperationInProgress's own comment style elsewhere for
      // why an outer wrap like this matters here specifically: without
      // it, beginNewGroup() above and each category's own clone-via-
      // create() below ran completely outside any beginScene3DChange()/
      // endScene3DChange() pair (create() has no wrap of its own -
      // only makeEmpty() does), so the ONLY recorded undo step was the
      // one Delete3D.selection() below already wraps itself - and that
      // step's own "before" snapshot was taken AFTER the clone already
      // existed. Undoing it restored the deleted original, but never
      // removed the clone (nothing had undone its untracked creation),
      // and never removed the new group either - leaving a duplicate
      // object and a phantom group behind instead of genuinely
      // reversing the whole "Group Selection" action. Confirmed
      // directly against the real compiled app before this fix (see
      // SceneLifecycleTest.java's own former
      // groupSelection_confirmedBug_... test, now corrected to match).
      // Wrapping the whole sequence here - the same nesting pattern
      // deleteAll()/Delete3D.selection() themselves already rely on -
      // makes the inner Delete3D.selection() call below run nested
      // (scene3DChangeDepth already > 0), so only this outer pair
      // actually touches the undo history, with its own "before"
      // snapshot correctly taken before beginNewGroup() or any clone
      // exists.
      beginScene3DChange();

      if (createNewGroup == 1) {
        float x = Select3D.BoundingBox[1 + Select3D.pivotAlignmentX][0];
        float y = Select3D.BoundingBox[1 + Select3D.pivotAlignmentY][1];
        float z = Select3D.BoundingBox[1 + Select3D.pivotAlignmentZ][2];

        float rot = User3D.creatorOrientation;
        if (rot == 360) rot = WIN3D.rotationZ;

        this.beginNewGroup(x, y, z, 1, 1, 1, 0, 0, rot);
      }


      boolean pre_addToLastGroup = addToLastGroup;
      addToLastGroup = true;

      if (currentObjectCategory == ObjectCategory.MODEL1D) {

        for (int o = 0; o < Select3D.model1DSelection.length; o++) {

          int OBJ_ID = Select3D.model1DSelection[o];

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

          // This is a duplicate of OBJ_ID (moved into the new/target
          // group) - its own extraParams is passed straight into
          // create()'s explicit-extraParams overload (model1Ds.pde), same
          // split/merge/duplicate policy as clone3D.pde's cloneModel1D().
          String sourceExtraParams = allModel1Ds.getExtraParams(OBJ_ID);
          allModel1Ds.ensureExtraParamsLength(); // so create()'s own append below lands at exactly allModel1Ds.num - 1, even if f_data/i_data were ever replaced directly without extraParams kept in lockstep (see clone3D.pde's cloneModel1D() - same reason)
          allModel1Ds.create(n, seed, dMax, x, y, z, d, rot, tilt, twist, ratio, base, trunkSize, leafSize, sourceExtraParams);
        }
      }

      if (currentObjectCategory == ObjectCategory.MODEL2D) {

        for (int o = 0; o < Select3D.model2DSelection.length; o++) {

          int OBJ_ID = Select3D.model2DSelection[o];

          float x = allModel2Ds.getX(OBJ_ID);
          float y = allModel2Ds.getY(OBJ_ID);
          float z = allModel2Ds.getZ(OBJ_ID);
          float s = allModel2Ds.getS(OBJ_ID);

          Model2DKind kind = allModel2Ds.Kind[OBJ_ID];
          int n = allModel2Ds.FileIndex[OBJ_ID];
          if (allModel2Ds.Mirror[OBJ_ID]) n = -n;

          // This is a duplicate of OBJ_ID (moved into the new/target
          // group) - its own extraParams is passed straight into
          // create()'s explicit-extraParams overload (model2Ds.pde), same
          // split/merge/duplicate policy as clone3D.pde's cloneModel2D().
          String sourceExtraParams = allModel2Ds.getExtraParams(OBJ_ID);
          allModel2Ds.ensureExtraParamsLength(); // same reason as the MODEL1D branch above
          allModel2Ds.create(kind.tag, n, x, y, z, s, sourceExtraParams);
        }
      }


      if (currentObjectCategory == ObjectCategory.SOLID) {

        for (int o = 0; o < Select3D.solidSelection.length; o++) {

          int OBJ_ID = Select3D.solidSelection[o];

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

          // This is a duplicate of OBJ_ID (moved into the new/target
          // group) - its own extraParams is passed straight into
          // create()'s explicit-extraParams overload (solids.pde), same
          // split/merge/duplicate policy as clone3D.pde's cloneSolid().
          String sourceExtraParams = allSolids.getExtraParams(OBJ_ID);
          allSolids.ensureExtraParamsLength(); // same reason as the MODEL1D branch above
          allSolids.create(Solid_posX, Solid_posY, Solid_posZ, Solid_powX, Solid_powY, Solid_powZ, Solid_scaleX, Solid_scaleY, Solid_scaleZ, Solid_rotX, Solid_rotY, Solid_rotZ, Solid_value, sourceExtraParams);
        }
      }




      if (currentObjectCategory == ObjectCategory.FACE) {

        for (int o = 0; o < Select3D.faceSelection.length; o++) {

          int f = Select3D.faceSelection[o];

          int number_of_Vertices_before = allPoints.getLength();

          int[] PolymeshVertices_OLD = new int [0]; // keeps the list of exiting vertex numbers
          int[] PolymeshVertices_NEW = new int [0]; // keeps the list of new vertex numbers

          if ((0 <= f) && (f < allFaces.nodes.length)) {

            int[] newFace_nodes = {
            };

            for (int j = 0; j < allFaces.nodes[f].length; j++) {
              int vNo = allFaces.nodes[f][j];

              int vertex_listed = -1;

              for (int q = 0; q < PolymeshVertices_OLD.length; q++) {
                if (vNo == PolymeshVertices_OLD[q]) {
                  vertex_listed = q;
                  break;
                }
              }

              if (vertex_listed == -1) {
                int[] newVertexListed = {
                  vNo
                };
                PolymeshVertices_OLD = concat(PolymeshVertices_OLD, newVertexListed);

                float x = allPoints.getX(vNo);
                float y = allPoints.getY(vNo);
                float z = allPoints.getZ(vNo);

                int[] newVertexAdded = {
                  allPoints.create(x, y, z)
                };
                PolymeshVertices_NEW = concat(PolymeshVertices_NEW, newVertexAdded);

                vertex_listed = PolymeshVertices_OLD.length - 1;
              }

              int[] new_vertexItem = {
                number_of_Vertices_before + vertex_listed
              };

              newFace_nodes = concat(newFace_nodes, new_vertexItem);
            }

            current_Material = allFaces.getMaterial(f);
            current_Tessellation = allFaces.getTessellation(f);
            current_Layer = allFaces.getLayer(f);
            current_Visibility = allFaces.getVisibility(f);

            String sourceExtraParams = allFaces.getExtraParams(f);
            allFaces.ensureExtraParamsLength(); // so create()'s own append below lands at exactly allFaces.nodes.length - 1 (see clone3D.pde's cloneFace() - same reason)
            allFaces.create(newFace_nodes);
            // This is a duplicate of f (fresh vertices, same options) -
            // create() alone would default extraParams to "", so this
            // overwrites that with f's own, same policy as clone3D.pde's
            // cloneFace().
            allFaces.setExtraParams(allFaces.nodes.length - 1, sourceExtraParams);
          }
        }
      }


      if (currentObjectCategory == ObjectCategory.POLYLINE) {

        for (int o = 0; o < Select3D.polylineSelection.length; o++) {

          int f = Select3D.polylineSelection[o];

          int number_of_Vertices_before = allPoints.getLength();

          int[] PolymeshVertices_OLD = new int [0]; // keeps the list of exiting vertex numbers
          int[] PolymeshVertices_NEW = new int [0]; // keeps the list of new vertex numbers

          if ((0 <= f) && (f < allPolylines.nodes.length)) {

            int[] newPolyline_nodes = {
            };

            for (int j = 0; j < allPolylines.nodes[f].length; j++) {
              int vNo = allPolylines.nodes[f][j];

              int vertex_listed = -1;

              for (int q = 0; q < PolymeshVertices_OLD.length; q++) {
                if (vNo == PolymeshVertices_OLD[q]) {
                  vertex_listed = q;
                  break;
                }
              }

              if (vertex_listed == -1) {
                int[] newVertexListed = {
                  vNo
                };
                PolymeshVertices_OLD = concat(PolymeshVertices_OLD, newVertexListed);

                float x = allPoints.getX(vNo);
                float y = allPoints.getY(vNo);
                float z = allPoints.getZ(vNo);

                int[] newVertexAdded = {
                  allPoints.create(x, y, z)
                };
                PolymeshVertices_NEW = concat(PolymeshVertices_NEW, newVertexAdded);

                vertex_listed = PolymeshVertices_OLD.length - 1;
              }

              int[] new_vertexItem = {
                number_of_Vertices_before + vertex_listed
              };

              newPolyline_nodes = concat(newPolyline_nodes, new_vertexItem);
            }

            current_Material = allPolylines.getMaterial(f);
            current_Tessellation = allPolylines.getTessellation(f);
            current_Layer = allPolylines.getLayer(f);
            current_Visibility = allPolylines.getVisibility(f);
            current_Weight = allPolylines.getWeight(f);
            current_Closed = allPolylines.getClose(f);
            current_CurveType = allPolylines.getCurveType(f);
            current_IsArc = allPolylines.getIsArc(f);
            if (current_IsArc == 1) current_ArcParams = allPolylines.getArcParams(f);

            String sourceExtraParams = allPolylines.getExtraParams(f);
            allPolylines.ensureExtraParamsLength(); // same reason as the Faces branch above
            allPolylines.create(newPolyline_nodes);
            // Same duplicate-inherits-from-its-one-source policy as
            // clone3D.pde's clonePolyline() - create() alone would
            // default extraParams to "", so this overwrites that with
            // f's own.
            allPolylines.setExtraParams(allPolylines.nodes.length - 1, sourceExtraParams);
          }
        }
      }



      addToLastGroup = pre_addToLastGroup;


      Delete3D.selection();


      Select3D.groupSelection = new int [1];
      Select3D.groupSelection[0] = this.num - 1;

      switch_category(ObjectCategory.GROUP);

      endScene3DChange();
    }
  }



  void ungroup_Selection () {

    if (currentObjectCategory == ObjectCategory.GROUP) {

      Select3D.groupSelection = sort(Select3D.groupSelection);


      for (int o = Select3D.groupSelection.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.groupSelection[o];

        this.Faces[OBJ_ID][0] = 0;
        this.Faces[OBJ_ID][1] = -1;

        this.Polylines[OBJ_ID][0] = 0;
        this.Polylines[OBJ_ID][1] = -1;

        this.Model1Ds[OBJ_ID][0] = 0;
        this.Model1Ds[OBJ_ID][1] = -1;

        this.Model2Ds[OBJ_ID][0] = 0;
        this.Model2Ds[OBJ_ID][1] = -1;

        this.Solids[OBJ_ID][0] = 0;
        this.Solids[OBJ_ID][1] = -1;
      }

      Delete3D.selection();
    }
  }


  void dettachFromGroups_Selection () {

    this.group_Selection(1);
    this.ungroup_Selection();
  }


  void deleteEmptyGroups_Scene () {

    int pre_currentObjectCategory = currentObjectCategory;

    switch_category(ObjectCategory.GROUP);


    Select3D.deselect_Groups();

    for (int OBJ_ID = 0; OBJ_ID < this.num; OBJ_ID++) {

      if ((0 <= this.Faces   [OBJ_ID][0]) && (this.Faces   [OBJ_ID][0] <= this.Faces   [OBJ_ID][1])) continue;
      if ((0 <= this.Polylines  [OBJ_ID][0]) && (this.Polylines  [OBJ_ID][0] <= this.Polylines  [OBJ_ID][1])) continue;
      if ((0 <= this.Model1Ds[OBJ_ID][0]) && (this.Model1Ds[OBJ_ID][0] <= this.Model1Ds[OBJ_ID][1])) continue;
      if ((0 <= this.Model2Ds[OBJ_ID][0]) && (this.Model2Ds[OBJ_ID][0] <= this.Model2Ds[OBJ_ID][1])) continue;
      if ((0 <= this.Solids  [OBJ_ID][0]) && (this.Solids  [OBJ_ID][0] <= this.Solids  [OBJ_ID][1])) continue;

      int[] emptyGroup = {
        OBJ_ID
      };

      Select3D.groupSelection = concat(Select3D.groupSelection, emptyGroup);
    }

    Delete3D.selection();

    currentObjectCategory = pre_currentObjectCategory;
  }


  int findGroupContainingFace (int f) {
    int OBJ_ID = 0;
    for (int i = 0; i < this.num; i++) {
      if ((this.Faces[i][0] <= f) && (f <= this.Faces[i][1])) {
        OBJ_ID = i;
        break;
      }
    }
    return OBJ_ID;
  }


  public void to_XML (XML xml) {

    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setInt(parent, "ni", this.num);

    for (int i = 0; i < this.num; i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);

      XML_setString(child, "model1Ds",
                    nf(this.getStart_Model1D(i), 0) + "|" +
                    nf(this.getStop_Model1D(i), 0));

      XML_setString(child, "model2Ds",
                    nf(this.getStart_Model2D(i), 0) + "|" +
                    nf(this.getStop_Model2D(i), 0));

      XML_setString(child, "faces",
                    nf(this.getStart_Face(i), 0) + "|" +
                    nf(this.getStop_Face(i), 0));

      XML_setString(child, "polylines",
                    nf(this.getStart_Polyline(i), 0) + "|" +
                    nf(this.getStop_Polyline(i), 0));

      XML_setString(child, "solids",
                    nf(this.getStart_Solid(i), 0) + "|" +
                    nf(this.getStop_Solid(i), 0));

      XML_setString(child, "extraParams", this.getExtraParams(i));

      String txt = "";
      for (int j = 0; j < 9; j++) {
        txt += nf(this.Pivots[i][j], 0, 4).replace(",", "."); // <<<<
        if (j + 1 < 9) txt += ",";
      }
      XML_setContent(child, txt);

    }
  }


  public void from_XML (XML xml) {

    XML parent = xml.getChild(this.CLASS_STAMP);

    int ni = XML_getInt(parent, "ni");

    this.makeEmpty(ni);

    XML[] children = parent.getChildren("item");
    for (int i = 0; i < ni; i++) {

      {
        String[] parts = split(XML_getString(children[i], "model1Ds"), "|");
        this.setStart_Model1D(i, int(parts[0]));
        this.setStop_Model1D(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "model2Ds"), "|");
        this.setStart_Model2D(i, int(parts[0]));
        this.setStop_Model2D(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "faces"), "|");
        this.setStart_Face(i, int(parts[0]));
        this.setStop_Face(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "polylines"), "|");
        this.setStart_Polyline(i, int(parts[0]));
        this.setStop_Polyline(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "solids"), "|");
        this.setStart_Solid(i, int(parts[0]));
        this.setStop_Solid(i, int(parts[1]));
      }

      // Falls back to "" (this field's own "nothing here" default) for a
      // save file written before extraParams existed at all - see the
      // 3-arg XML_getString() overload's own comment (xmlHelpers.pde).
      this.setExtraParams(i, XML_getString(children[i], "extraParams", ""));

      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");
      for (int j = 0; j < 9; j++) {
        this.Pivots[i][j] = float(parts[j]);
      }
    }
  }

}
