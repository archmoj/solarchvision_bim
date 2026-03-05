class solarchvision_Groups {

  private final static String CLASS_STAMP = "Groups";

  solarchvision_Groups () { // constructor
    makeEmpty(0);
  }

  int num;
  int[][] Polylines;
  int[][] Faces;
  int[][] Solids;
  int[][] Model1Ds;
  int[][] Model2Ds;
  float[][] Pivots;

  void makeEmpty (int n) {

    this.num = n;
    this.Model1Ds = new int [n][2];
    this.Model2Ds = new int [n][2];
    this.Faces = new int [n][2];
    this.Polylines = new int [n][2];
    this.Solids = new int [n][2];
    this.Pivots = new float [n][9];

    if (Select3D != null) {
      Select3D.deselect_Groups();
    }

    SOLARCHVISION_model_changed();
  }



  int getStart_Polyline (int n) {
    return this.Polylines[n][0];
  }

  int getStop_Polyline (int n) {
    return this.Polylines[n][1];
  }

  int getStart_Face (int n) {
    return this.Faces[n][0];
  }

  int getStop_Face (int n) {
    return this.Faces[n][1];
  }

  int getStart_Solid (int n) {
    return this.Solids[n][0];
  }

  int getStop_Solid (int n) {
    return this.Solids[n][1];
  }

  int getStart_Model1D (int n) {
    return this.Model1Ds[n][0];
  }

  int getStop_Model1D (int n) {
    return this.Model1Ds[n][1];
  }

  int getStart_Model2D (int n) {
    return this.Model2Ds[n][0];
  }

  int getStop_Model2D (int n) {
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


  void inserted_nFaces (int n, int fromFace, int howMany) {
    for (int i = n + 1; i < this.num; i++) {
      this.setStart_Face(i, this.getStart_Face(i) + howMany);
      this.setStop_Face(i, this.getStop_Face(i) + howMany);
    }

    this.setStop_Face(n, this.getStop_Face(n) + howMany); // because adding the faces also changes the end pointer of the same object

    for (int k = 0; k < Select3D.Face_ids.length; k++) {
      if (Select3D.Face_ids[k] != 0) {
        if (Select3D.Face_ids[k] > fromFace) {
          Select3D.Face_ids[k] += howMany;
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



    this.num += 1;

    return(this.num - 1);
  }






  void group_Selection (int createNewGroup) { // if this option == 0 then the objects are added to the last group


    boolean run_process = false;

    if (current_ObjectCategory == ObjectCategory.SOLID) run_process = true;
    if (current_ObjectCategory == ObjectCategory.FACE) run_process = true;
    if (current_ObjectCategory == ObjectCategory.POLYLINE) run_process = true;
    if (current_ObjectCategory == ObjectCategory.MODEL2D) run_process = true;
    if (current_ObjectCategory == ObjectCategory.MODEL1D) run_process = true;

    if (run_process) {

      if (createNewGroup == 1) {
        float x = Select3D.BoundingBox[1 + Select3D.alignX][0];
        float y = Select3D.BoundingBox[1 + Select3D.alignX][1];
        float z = Select3D.BoundingBox[1 + Select3D.alignX][2];

        float rot = User3D.create_Orientation;
        if (rot == 360) rot = WIN3D.rotation_Z;

        this.beginNewGroup(x, y, z, 1, 1, 1, 0, 0, rot);
      }


      boolean pre_addToLastGroup = addToLastGroup;
      addToLastGroup = true;

      if (current_ObjectCategory == ObjectCategory.MODEL1D) {

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

          allModel1Ds.create(n, seed, dMax, x, y, z, d, rot, tilt, twist, ratio, base, trunkSize, leafSize);
        }
      }

      if (current_ObjectCategory == ObjectCategory.MODEL2D) {

        for (int o = 0; o < Select3D.Model2D_ids.length; o++) {

          int OBJ_ID = Select3D.Model2D_ids[o];

          float x = allModel2Ds.getX(OBJ_ID);
          float y = allModel2Ds.getY(OBJ_ID);
          float z = allModel2Ds.getZ(OBJ_ID);
          float s = allModel2Ds.getS(OBJ_ID);

          int n = allModel2Ds.MAP[OBJ_ID];
          if (allModel2Ds.isTree(n)) {
            allModel2Ds.create("TREES", n, x, y, z, s);
          } else {
            allModel2Ds.create("PEOPLE", n, x, y, z, s);
          }
        }
      }


      if (current_ObjectCategory == ObjectCategory.SOLID) {

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
      }




      if (current_ObjectCategory == ObjectCategory.FACE) {

        for (int o = 0; o < Select3D.Face_ids.length; o++) {

          int f = Select3D.Face_ids[o];

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

            allFaces.create(newFace_nodes);
          }
        }
      }


      if (current_ObjectCategory == ObjectCategory.POLYLINE) {

        for (int o = 0; o < Select3D.Polyline_ids.length; o++) {

          int f = Select3D.Polyline_ids[o];

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

            allPolylines.create(newPolyline_nodes);
          }
        }
      }



      addToLastGroup = pre_addToLastGroup;


      Delete3D.selection();


      Select3D.Group_ids = new int [1];
      Select3D.Group_ids[0] = this.num - 1;

      SOLARCHVISION_switch_category(ObjectCategory.GROUP);
    }
  }



  void ungroup_Selection () {

    if (current_ObjectCategory == ObjectCategory.GROUP) {

      Select3D.Group_ids = sort(Select3D.Group_ids);


      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

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

    int pre_current_ObjectCategory = current_ObjectCategory;

    SOLARCHVISION_switch_category(ObjectCategory.GROUP);


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

      Select3D.Group_ids = concat(Select3D.Group_ids, emptyGroup);
    }

    Delete3D.selection();

    current_ObjectCategory = pre_current_ObjectCategory;
  }





  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setInt(parent, "ni", this.num);

    for (int i = 0; i < this.num; i++) {
      XML child = parent.addChild("item");
      XML_setInt(child, "id", i);

      XML_setString(child, "Model1Ds",
                    nf(this.getStart_Model1D(i), 0) + "|" +
                    nf(this.getStop_Model1D(i), 0));

      XML_setString(child, "Model2Ds",
                    nf(this.getStart_Model2D(i), 0) + "|" +
                    nf(this.getStop_Model2D(i), 0));

      XML_setString(child, "Faces",
                    nf(this.getStart_Face(i), 0) + "|" +
                    nf(this.getStop_Face(i), 0));

      XML_setString(child, "Polylines",
                    nf(this.getStart_Polyline(i), 0) + "|" +
                    nf(this.getStop_Polyline(i), 0));

      XML_setString(child, "Solids",
                    nf(this.getStart_Solid(i), 0) + "|" +
                    nf(this.getStop_Solid(i), 0));

      String txt = "";
      for (int j = 0; j < 9; j++) {
        txt += nf(this.Pivots[i][j], 0, 4).replace(",", "."); // <<<<
        if (j + 1 < 9) txt += ",";
      }
      XML_setContent(child, txt);

    }
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    int ni = XML_getInt(parent, "ni");

    this.makeEmpty(ni);

    XML[] children = parent.getChildren("item");
    for (int i = 0; i < ni; i++) {

      {
        String[] parts = split(XML_getString(children[i], "Model1Ds"), "|");
        this.setStart_Model1D(i, int(parts[0]));
        this.setStop_Model1D(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "Model2Ds"), "|");
        this.setStart_Model2D(i, int(parts[0]));
        this.setStop_Model2D(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "Faces"), "|");
        this.setStart_Face(i, int(parts[0]));
        this.setStop_Face(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "Polylines"), "|");
        this.setStart_Polyline(i, int(parts[0]));
        this.setStop_Polyline(i, int(parts[1]));
      }

      {
        String[] parts = split(XML_getString(children[i], "Solids"), "|");
        this.setStart_Solid(i, int(parts[0]));
        this.setStop_Solid(i, int(parts[1]));
      }



      String txt = XML_getContent(children[i]);
      String[] parts = split(txt, ",");
      for (int j = 0; j < 9; j++) {
        this.Pivots[i][j] = float(parts[j]);
      }
    }
  }

}
