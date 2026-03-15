class solarchvision_Modify3D {

  private final static String CLASS_STAMP = "Modify3D";



  void selectVertices_fromCurrentSelection () {

    if (current_ObjectCategory == ObjectCategory.GROUP) {

      Select3D.convert_Groups_to_Vertices();
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {

      Select3D.convert_Faces_to_Vertices();
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {

      Select3D.convert_Polylines_to_Vertices();
    }

    Select3D.Vertex_ids = sort(Select3D.Vertex_ids);

  }






  void selectFacesAndGroups_fromCurrentSelection () {

    if (current_ObjectCategory == ObjectCategory.GROUP) {

      Select3D.Group_ids = sort(Select3D.Group_ids);

      Select3D.convert_Groups_to_Faces();

      Select3D.Face_ids = sort(Select3D.Face_ids);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {

      Select3D.Face_ids = sort(Select3D.Face_ids);

      Select3D.convert_Faces_to_Groups();

      Select3D.Group_ids = sort(Select3D.Group_ids);

    }
  }



  void repositionVertices_Selection () {

    if (current_ObjectCategory == ObjectCategory.VERTEX) {

      Select3D.calculate_BoundingBox();

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        allPoints.setX(vNo, Select3D.BoundingBox[1][0]); // center
        allPoints.setY(vNo, Select3D.BoundingBox[1][1]); // center
        allPoints.setZ(vNo, Select3D.BoundingBox[1][2]); // center
      }

      Select3D.calculate_BoundingBox();
    }
  }


  void weldSceneVertices_Selection (float max_distance) {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      this.selectVertices_fromCurrentSelection();

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        int found = -1;

        if (found != -1) {
          for (int i = 0; i < allFaces.nodes.length; i++) {
            for (int j = 0; j < allFaces.nodes[i].length; j++) {

              int q = allFaces.nodes[i][j];

              if (q > vNo) { // it is faster than (q != vNo)

                float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

                if (d <= max_distance) {

                  allFaces.nodes[i][j] = vNo;

                  found = q;
                }
              }
            }
          }
        }

        if (found != -1) {
          for (int i = 0; i < allPolylines.nodes.length; i++) {
            for (int j = 0; j < allPolylines.nodes[i].length; j++) {

              int q = allPolylines.nodes[i][j];

              if (q > vNo) { // it is faster than (q != vNo)

                float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

                if (d <= max_distance) {

                  allPolylines.nodes[i][j] = vNo;

                  found = q;
                }
              }
            }
          }
        }

        if (found != -1) {

          int q = found;

          {
            float[][] startList = (float[][]) subset(allVertices, 0, q);
            float[][] endList = (float[][]) subset(allVertices, q + 1);

            allVertices = (float[][]) concat(startList, endList);
          }

          for (int i = 0; i < allFaces.nodes.length; i++) {
            for (int j = 0; j < allFaces.nodes[i].length; j++) {
              if (allFaces.nodes[i][j] > q) {

                allFaces.nodes[i][j] -= 1;
              }
            }
          }

          for (int i = 0; i < allPolylines.nodes.length; i++) {
            for (int j = 0; j < allPolylines.nodes[i].length; j++) {
              if (allPolylines.nodes[i][j] > q) {

                allPolylines.nodes[i][j] -= 1;
              }
            }
          }
        }
      }

      Select3D.deselect_Vertices();
    }
  }




  void weldObjectsVertices_Selection (float max_distance) {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      this.selectVertices_fromCurrentSelection();

      Select3D.convert_Vertices_to_Faces();
      Select3D.convert_Vertices_to_Polylines();

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        int found = -1;

        for (int m = o - 1; m >= 0; m--) {

          int q = Select3D.Vertex_ids[m];

          float d = dist(allPoints.getX(q), allPoints.getY(q), allPoints.getZ(q), allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));

          if (d <= max_distance) {

            for (int i = 0; i < Select3D.Face_ids.length; i++) {
              int f = Select3D.Face_ids[i];

              for (int j = 0; j < allFaces.nodes[f].length; j++) {
                if (allFaces.nodes[f][j] == q) {

                  allFaces.nodes[f][j] = vNo;

                  found = q;
                }
              }
            }

            for (int i = 0; i < Select3D.Polyline_ids.length; i++) {
              int f = Select3D.Polyline_ids[i];

              for (int j = 0; j < allPolylines.nodes[f].length; j++) {
                if (allPolylines.nodes[f][j] == q) {

                  allPolylines.nodes[f][j] = vNo;

                  found = q;
                }
              }
            }
          }
        }

        if (found != -1) {

          int q = found;

          {
            float[][] startList = (float[][]) subset(allVertices, 0, q);
            float[][] endList = (float[][]) subset(allVertices, q + 1);

            allVertices = (float[][]) concat(startList, endList);
          }

          for (int i = 0; i < allFaces.nodes.length; i++) {
            for (int j = 0; j < allFaces.nodes[i].length; j++) {
              if (allFaces.nodes[i][j] > q) {

                allFaces.nodes[i][j] -= 1;
              }
            }
          }

          for (int i = 0; i < allPolylines.nodes.length; i++) {
            for (int j = 0; j < allPolylines.nodes[i].length; j++) {
              if (allPolylines.nodes[i][j] > q) {

                allPolylines.nodes[i][j] -= 1;
              }
            }
          }
        }
      }

      Select3D.deselect_Vertices();
    }
  }



  void offsetVertices_Selection (int _type, float _amount) {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      this.selectVertices_fromCurrentSelection();

      float[][] Vertex_offsetValues = new float [Select3D.Vertex_ids.length][3];
      int[] Vertex_offsetNum = new int [Select3D.Vertex_ids.length];

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {
        Vertex_offsetValues[o][0] = 0;
        Vertex_offsetValues[o][1] = 0;
        Vertex_offsetValues[o][2] = 0;

        Vertex_offsetNum[o] = 0;
      }

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        for (int f = 0; f < allFaces.nodes.length; f++) {
          for (int j = 0; j < allFaces.nodes[f].length; j++) {

            if (allFaces.nodes[f][j] == vNo) {

              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                base_Vertices[s][0] = allPoints.getX(allFaces.nodes[f][s]);
                base_Vertices[s][1] = allPoints.getY(allFaces.nodes[f][s]);
                base_Vertices[s][2] = allPoints.getZ(allFaces.nodes[f][s]);
              }

              for (int s = 0; s < base_Vertices.length; s++) {

                int s_next = (s + 1) % base_Vertices.length;
                int s_prev = (s + base_Vertices.length - 1) % base_Vertices.length;

                PVector U = new PVector(base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2]);
                PVector V = new PVector(base_Vertices[s_prev][0] - base_Vertices[s][0], base_Vertices[s_prev][1] - base_Vertices[s][1], base_Vertices[s_prev][2] - base_Vertices[s][2]);
                PVector UV = new PVector(0, 0, 0);

                if (_type == 0) UV = U.cross(V);
                if (_type == 1) UV = PVector.add(U, V);

                float[] W = {
                  UV.x, UV.y, UV.z
                };
                W = funcs.vec3_unit(W);

                Vertex_offsetValues[o][0] += W[0] * _amount;
                Vertex_offsetValues[o][1] += W[1] * _amount;
                Vertex_offsetValues[o][2] += W[2] * _amount;

                Vertex_offsetNum[o] += 1;
              }
            }
          }
        }

        for (int f = 0; f < allPolylines.nodes.length; f++) {
          for (int j = 0; j < allPolylines.nodes[f].length; j++) {

            if (allPolylines.nodes[f][j] == vNo) {

              float[][] base_Vertices = new float [allPolylines.nodes[f].length][3];

              for (int s = 0; s < allPolylines.nodes[f].length; s++) {

                base_Vertices[s][0] = allPoints.getX(allPolylines.nodes[f][s]);
                base_Vertices[s][1] = allPoints.getY(allPolylines.nodes[f][s]);
                base_Vertices[s][2] = allPoints.getZ(allPolylines.nodes[f][s]);
              }

              for (int s = 0; s < base_Vertices.length; s++) {

                int s_next = (s + 1) % base_Vertices.length;
                int s_prev = (s + base_Vertices.length - 1) % base_Vertices.length;

                PVector U = new PVector(base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2]);
                PVector V = new PVector(base_Vertices[s_prev][0] - base_Vertices[s][0], base_Vertices[s_prev][1] - base_Vertices[s][1], base_Vertices[s_prev][2] - base_Vertices[s][2]);
                PVector UV = new PVector(0, 0, 0);

                if (_type == 0) UV = U.cross(V);
                if (_type == 1) UV = PVector.add(U, V);

                float[] W = {
                  UV.x, UV.y, UV.z
                };
                W = funcs.vec3_unit(W);

                Vertex_offsetValues[o][0] += W[0] * _amount;
                Vertex_offsetValues[o][1] += W[1] * _amount;
                Vertex_offsetValues[o][2] += W[2] * _amount;

                Vertex_offsetNum[o] += 1;
              }
            }
          }
        }


        if (Vertex_offsetNum[o] != 0) {
          Vertex_offsetValues[o][0] /= float(Vertex_offsetNum[o]);
          Vertex_offsetValues[o][1] /= float(Vertex_offsetNum[o]);
          Vertex_offsetValues[o][2] /= float(Vertex_offsetNum[o]);
        }
      }


      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        allPoints.move(vNo, Vertex_offsetValues[o][0],
                            Vertex_offsetValues[o][1],
                            Vertex_offsetValues[o][2]);
      }

      SOLARCHVISION_selection_changed();
    }
  }







  void separateVertices_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      this.selectVertices_fromCurrentSelection();

      for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

        int vNo = Select3D.Vertex_ids[o];

        for (int i = 0; i < allFaces.nodes.length; i++) {
          for (int j = 0; j < allFaces.nodes[i].length; j++) {

            if (allFaces.nodes[i][j] == vNo) {

              allFaces.nodes[i][j] = allPoints.create(allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
            }
          }
        }

        for (int i = 0; i < allPolylines.nodes.length; i++) {
          for (int j = 0; j < allPolylines.nodes[i].length; j++) {

            if (allPolylines.nodes[i][j] == vNo) {

              allPolylines.nodes[i][j] = allPoints.create(allPoints.getX(vNo), allPoints.getY(vNo), allPoints.getZ(vNo));
            }
          }
        }
      }


      Select3D.deselect_Vertices();
    }
  }




  int[] remove_item_from_primary_list (int q, int[] primary_list) {
    // to avoid processing the faces twice they should be deleted from the list.
    for (int i = q + 1; i < primary_list.length; i++) {
      primary_list[i] -= 1;
    }
    int[] startList = (int[]) subset(primary_list, 0, q);
    int[] endList = (int[]) subset(primary_list, q + 1);
    primary_list = (int[]) concat(startList, endList);

    return primary_list;
  }





  void insertCornerOpennings_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

            int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
            int[][] midList_Faces_nodes = (int[][]) subset(allFaces.nodes, f, 1);
            int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


            int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
            int[][] midList_Faces_options = (int[][]) subset(allFaces.options, f, 1);
            int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

            {
              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {

                base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);

              }

              float[] G_face = {
                0, 0, 0
              };

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {
                  G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                }
              }

              float[][] new_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {

                  new_Vertices[i][j] = pow(User3D.modify_OpenningArea, 0.5) * base_Vertices[i][j] + (1 - pow(User3D.modify_OpenningArea, 0.5)) * G_face[j];
                }
              }

              int[] new_Vertex_ids = new int [allFaces.nodes[f].length];

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                new_Vertex_ids[s] = allPoints.create(new_Vertices[s][0], new_Vertices[s][1], new_Vertices[s][2]);
              }

              current_Material = allFaces.getMaterial(f);
              current_Tessellation = allFaces.getTessellation(f);
              current_Layer = allFaces.getLayer(f);
              current_Visibility = allFaces.getVisibility(f);

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_next = (s + 1) % allFaces.nodes[f].length;

                int[][] newFace_nodes = {
                  {
                    new_Vertex_ids[s], allFaces.nodes[f][s], allFaces.nodes[f][s_next], new_Vertex_ids[s_next]
                  }
                };
                int[][] newFace_options = {
                  {
                    current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                  }
                };

                midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);
              }


              { // modifying the base face to shape the openning
                for (int s = 0; s < allFaces.nodes[f].length; s++) {
                  allFaces.nodes[f][s] = new_Vertex_ids[s];
                }
              }
            }

            startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
            startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

            allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
            allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }

      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }


  void insertParallelOpennings_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            allGroups.inserted_nFaces(OBJ_ID, f, 2 * allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

            int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
            int[][] midList_Faces_nodes = (int[][]) subset(allFaces.nodes, f, 1);
            int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


            int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
            int[][] midList_Faces_options = (int[][]) subset(allFaces.options, f, 1);
            int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

            {
              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {

                base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
              }

              float[] G_face = {
                0, 0, 0
              };

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {
                  G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                }
              }


              float[][] new_A_EdgeVertices = new float [allFaces.nodes[f].length][3];
              float[][] new_B_EdgeVertices = new float [allFaces.nodes[f].length][3];
              float[][] new_CenterVertices = new float [allFaces.nodes[f].length][3];

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;
                int s_next = (s + 1) % allFaces.nodes[f].length;

                for (int j = 0; j < 3; j++) {

                  new_A_EdgeVertices[s][j] = User3D.modify_OpenningDeviation * base_Vertices[s][j] + (1 - User3D.modify_OpenningDeviation) * 0.5 * (base_Vertices[s_prev][j] + base_Vertices[s][j]);
                  new_B_EdgeVertices[s][j] = User3D.modify_OpenningDeviation * base_Vertices[s][j] + (1 - User3D.modify_OpenningDeviation) * 0.5 * (base_Vertices[s_next][j] + base_Vertices[s][j]);

                  new_CenterVertices[s][j] = pow(User3D.modify_OpenningArea, 0.5) * base_Vertices[s][j] + (1 - pow(User3D.modify_OpenningArea, 0.5)) * G_face[j];
                }
              }

              int[] new_A_EdgeVertex_ids = new int [allFaces.nodes[f].length]; // on the edge (1/3)
              int[] new_B_EdgeVertex_ids = new int [allFaces.nodes[f].length]; // on the other edge (2/3)
              int[] new_CenterVertex_ids = new int [allFaces.nodes[f].length]; // in the center

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                new_A_EdgeVertex_ids[s] = allPoints.create(new_A_EdgeVertices[s][0], new_A_EdgeVertices[s][1], new_A_EdgeVertices[s][2]);
                new_B_EdgeVertex_ids[s] = allPoints.create(new_B_EdgeVertices[s][0], new_B_EdgeVertices[s][1], new_B_EdgeVertices[s][2]);
                new_CenterVertex_ids[s] = allPoints.create(new_CenterVertices[s][0], new_CenterVertices[s][1], new_CenterVertices[s][2]);
              }



              current_Material = allFaces.getMaterial(f);
              current_Tessellation = allFaces.getTessellation(f);
              current_Layer = allFaces.getLayer(f);
              current_Visibility = allFaces.getVisibility(f);

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_next = (s + 1) % allFaces.nodes[f].length;

                {
                  int[][] newFace_nodes = {
                    {
                      allFaces.nodes[f][s], new_B_EdgeVertex_ids[s], new_CenterVertex_ids[s], new_A_EdgeVertex_ids[s]
                    }
                  };
                  int[][] newFace_options = {
                    {
                      current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                    }
                  };

                  midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                  midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);
                }

                {
                  int[][] newFace_nodes = {
                    {
                      new_B_EdgeVertex_ids[s], new_A_EdgeVertex_ids[s_next], new_CenterVertex_ids[s_next], new_CenterVertex_ids[s]
                    }
                  };
                  int[][] newFace_options = {
                    {
                      current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                    }
                  };

                  midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                  midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);
                }
              }


              { // modifying the base face to shape the openning
                for (int s = 0; s < allFaces.nodes[f].length; s++) {
                  allFaces.nodes[f][s] = new_CenterVertex_ids[s];
                }
              }
            }

            startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
            startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

            allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
            allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }



  void insertRotatedOpennings_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

            int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
            int[][] midList_Faces_nodes = (int[][]) subset(allFaces.nodes, f, 1);
            int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


            int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
            int[][] midList_Faces_options = (int[][]) subset(allFaces.options, f, 1);
            int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

            {
              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {

                base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
              }

              float[] G_face = {
                0, 0, 0
              };

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {
                  G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                }
              }

              float[][] new_EdgeVertices = new float [allFaces.nodes[f].length][3];
              float[][] new_CenterVertices = new float [allFaces.nodes[f].length][3];

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;

                for (int j = 0; j < 3; j++) {

                  new_EdgeVertices[s][j] = User3D.modify_OpenningDeviation * base_Vertices[s][j] + (1 - User3D.modify_OpenningDeviation) * base_Vertices[s_prev][j];

                  new_CenterVertices[s][j] = pow(User3D.modify_OpenningArea, 0.5) * new_EdgeVertices[s][j] + (1 - pow(User3D.modify_OpenningArea, 0.5)) * G_face[j];
                }
              }

              int[] new_EdgeVertex_ids = new int [allFaces.nodes[f].length]; // on the edge
              int[] new_CenterVertex_ids = new int [allFaces.nodes[f].length]; // in the center

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                new_EdgeVertex_ids[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
                new_CenterVertex_ids[s] = allPoints.create(new_CenterVertices[s][0], new_CenterVertices[s][1], new_CenterVertices[s][2]);
              }



              current_Material = allFaces.getMaterial(f);
              current_Tessellation = allFaces.getTessellation(f);
              current_Layer = allFaces.getLayer(f);
              current_Visibility = allFaces.getVisibility(f);

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_next = (s + 1) % allFaces.nodes[f].length;

                int[][] newFace_nodes = {
                  {
                    new_EdgeVertex_ids[s], allFaces.nodes[f][s], new_EdgeVertex_ids[s_next], new_CenterVertex_ids[s_next], new_CenterVertex_ids[s]
                  }
                };
                int[][] newFace_options = {
                  {
                    current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                  }
                };

                midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);
              }


              { // modifying the base face to match new center face
                for (int s = 0; s < allFaces.nodes[f].length; s++) {
                  allFaces.nodes[f][s] = new_CenterVertex_ids[s];
                }
              }
            }

            startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
            startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

            allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
            allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }


  void insertEdgeOpennings_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length); // because adding the faces also changes the end pointer of the same object

            int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
            int[][] midList_Faces_nodes = (int[][]) subset(allFaces.nodes, f, 1);
            int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


            int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
            int[][] midList_Faces_options = (int[][]) subset(allFaces.options, f, 1);
            int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

            {
              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {

                base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
              }

              float[] G_face = {
                0, 0, 0
              };

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {
                  G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                }
              }

              float[][] new_EdgeVertices = new float [allFaces.nodes[f].length][3];

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;

                for (int j = 0; j < 3; j++) {

                  new_EdgeVertices[s][j] = User3D.modify_OpenningDeviation * base_Vertices[s][j] + (1 - User3D.modify_OpenningDeviation) * base_Vertices[s_prev][j];
                }
              }

              int[] new_EdgeVertex_ids = new int [allFaces.nodes[f].length]; // on the edge

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                new_EdgeVertex_ids[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
              }



              current_Material = allFaces.getMaterial(f);
              current_Tessellation = allFaces.getTessellation(f);
              current_Layer = allFaces.getLayer(f);
              current_Visibility = allFaces.getVisibility(f);

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_next = (s + 1) % allFaces.nodes[f].length;

                int[][] newFace_nodes = {
                  {
                    new_EdgeVertex_ids[s], allFaces.nodes[f][s], new_EdgeVertex_ids[s_next]
                  }
                };
                int[][] newFace_options = {
                  {
                    current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                  }
                };

                midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);
              }


              { // modifying the base face to match new center face
                for (int s = 0; s < allFaces.nodes[f].length; s++) {
                  allFaces.nodes[f][s] = new_EdgeVertex_ids[s];
                }
              }
            }

            startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
            startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

            allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
            allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }



  void tessellateRowsColumns_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            if (allFaces.nodes[f].length == 4) {

              allGroups.inserted_nFaces(OBJ_ID, f, User3D.modify_TessellateColumns * User3D.modify_TessellateRows - 1); // because adding the faces also changes the end pointer of the same object

              int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
              int[][] midList_Faces_nodes = new int [0][0];
              int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


              int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
              int[][] midList_Faces_options = new int [0][0];
              int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

              {
                float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

                for (int i = 0; i < allFaces.nodes[f].length; i++) {

                  base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                  base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                  base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
                }



                float[][] new_EdgeVertices = new float [(User3D.modify_TessellateColumns + 1) * (User3D.modify_TessellateRows + 1)][3];

                for (int i = 0; i <= User3D.modify_TessellateColumns; i++) {

                  for (int j = 0; j <= User3D.modify_TessellateRows; j++) {

                    int s = i * (User3D.modify_TessellateRows + 1) + j;

                    for (int k = 0; k < 3; k++) {

                      float u = i / float(User3D.modify_TessellateColumns);
                      float v = j / float(User3D.modify_TessellateRows);

                      new_EdgeVertices[s][k] = funcs.bilinear(base_Vertices[0][k], base_Vertices[1][k], base_Vertices[2][k], base_Vertices[3][k], u, v);
                    }
                  }
                }

                int[] new_EdgeVertex_ids = new int [(User3D.modify_TessellateColumns + 1) * (User3D.modify_TessellateRows + 1)]; // on the edge

                for (int i = 0; i <= User3D.modify_TessellateColumns; i++) {

                  for (int j = 0; j <= User3D.modify_TessellateRows; j++) {

                    int s = i * (User3D.modify_TessellateRows + 1) + j;

                    if ((i == 0) && (j == 0)) {
                      new_EdgeVertex_ids[s] = allFaces.nodes[f][0];
                    } else if ((i == User3D.modify_TessellateColumns) && (j == 0)) {
                      new_EdgeVertex_ids[s] = allFaces.nodes[f][1];
                    } else if ((i == User3D.modify_TessellateColumns) && (j == User3D.modify_TessellateRows)) {
                      new_EdgeVertex_ids[s] = allFaces.nodes[f][2];
                    } else if ((i == 0) && (j == User3D.modify_TessellateRows)) {
                      new_EdgeVertex_ids[s] = allFaces.nodes[f][3];
                    } else {
                      new_EdgeVertex_ids[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
                    }
                  }
                }


                current_Material = allFaces.getMaterial(f);
                current_Tessellation = allFaces.getTessellation(f);
                current_Layer = allFaces.getLayer(f);
                current_Visibility = allFaces.getVisibility(f);

                for (int i = 0; i < User3D.modify_TessellateColumns; i++) {

                  for (int j = 0; j < User3D.modify_TessellateRows; j++) {

                    int s = i * User3D.modify_TessellateRows + j;  // number of face

                    // number of vertices
                    int s00 = i * (User3D.modify_TessellateRows + 1) + j;
                    int s01 = s00 + 1;
                    int s10 = s00 + (User3D.modify_TessellateRows + 1);
                    int s11 = s00 + (User3D.modify_TessellateRows + 1) + 1;

                    int[][] newFace_nodes = {
                      {
                        new_EdgeVertex_ids[s00], new_EdgeVertex_ids[s10], new_EdgeVertex_ids[s11], new_EdgeVertex_ids[s01]
                      }
                    };
                    int[][] newFace_options = {
                      {
                        current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                      }
                    };

                    midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                    midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);

                    if (s > 0) { // the first tessellated face was replaced by the base face... so only add other items
                      int[] newFace_nodes_number = {
                        f + s
                      };
                      Select3D.Face_ids = (int[]) concat(Select3D.Face_ids, newFace_nodes_number);
                    }
                  }
                }
              }

              startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
              startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

              allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
              allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

              primary_list = this.remove_item_from_primary_list(q, primary_list);
            }
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }



  void tessellateRectangular_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length - 1); // because adding the faces also changes the end pointer of the same object

            int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
            int[][] midList_Faces_nodes = new int [0][0];
            int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


            int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
            int[][] midList_Faces_options = new int [0][0];
            int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

            {
              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {

                base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
              }

              float[] G_face = {
                0, 0, 0
              };

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {
                  G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                }
              }

              float[][] new_EdgeVertices = new float [allFaces.nodes[f].length][3];

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;

                for (int j = 0; j < 3; j++) {
                  new_EdgeVertices[s][j] = 0.5 * base_Vertices[s][j] + 0.5 * base_Vertices[s_prev][j];
                }
              }

              int[] new_EdgeVertex_ids = new int [allFaces.nodes[f].length]; // on the edge

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                new_EdgeVertex_ids[s] = allPoints.create(new_EdgeVertices[s][0], new_EdgeVertices[s][1], new_EdgeVertices[s][2]);
              }

              int new_CenterVertex_number = 0; // at the center
              new_CenterVertex_number = allPoints.create(G_face[0], G_face[1], G_face[2]);


              current_Material = allFaces.getMaterial(f);
              current_Tessellation = allFaces.getTessellation(f);
              current_Layer = allFaces.getLayer(f);
              current_Visibility = allFaces.getVisibility(f);

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_next = (s + 1) % allFaces.nodes[f].length;

                int[][] newFace_nodes = {
                  {
                    new_EdgeVertex_ids[s], allFaces.nodes[f][s], new_EdgeVertex_ids[s_next], new_CenterVertex_number
                  }
                };
                int[][] newFace_options = {
                  {
                    current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                  }
                };

                midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);

                if (s > 0) { // the first tessellated face was replaced by the base face... so only add other items
                  int[] newFace_nodes_number = {
                    f + s
                  };
                  Select3D.Face_ids = (int[]) concat(Select3D.Face_ids, newFace_nodes_number);
                }
              }
            }

            startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
            startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

            allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
            allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }



  void tessellateTriangular_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length - 1); // because adding the faces also changes the end pointer of the same object

            int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
            int[][] midList_Faces_nodes = new int [0][0];
            int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


            int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
            int[][] midList_Faces_options = new int [0][0];
            int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

            {
              float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

              for (int i = 0; i < allFaces.nodes[f].length; i++) {

                base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
              }

              float[] G_face = {
                0, 0, 0
              };

              for (int i = 0; i < allFaces.nodes[f].length; i++) {
                for (int j = 0; j < 3; j++) {
                  G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                }
              }


              int new_CenterVertex_number = 0; // at the center
              new_CenterVertex_number = allPoints.create(G_face[0], G_face[1], G_face[2]);


              current_Material = allFaces.getMaterial(f);
              current_Tessellation = allFaces.getTessellation(f);
              current_Layer = allFaces.getLayer(f);
              current_Visibility = allFaces.getVisibility(f);

              for (int s = 0; s < allFaces.nodes[f].length; s++) {

                int s_next = (s + 1) % allFaces.nodes[f].length;

                int[][] newFace_nodes = {
                  {
                    allFaces.nodes[f][s], allFaces.nodes[f][s_next], new_CenterVertex_number
                  }
                };
                int[][] newFace_options = {
                  {
                    current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                  }
                };

                midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);

                if (s > 0) { // the first tessellated face was replaced by the base face... so only add other items
                  int[] newFace_nodes_number = {
                    f + s
                  };
                  Select3D.Face_ids = (int[]) concat(Select3D.Face_ids, newFace_nodes_number);
                }
              }
            }

            startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
            startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

            allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
            allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }


  void forceTriangulateFaces_Selection () {

    // this function is the copy of above function (this.tessellateTriangular_Selection)
    // but only processed the faces with degrees above 3.

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          if (allFaces.nodes[f].length > 3) { // <<<<<<<<<<< the condition to perform the process

            int startFace = allGroups.getStart_Face(OBJ_ID);
            int endFace = allGroups.getStop_Face(OBJ_ID);

            if ((startFace <= f) && (f <= endFace)) {

              allGroups.inserted_nFaces(OBJ_ID, f, allFaces.nodes[f].length - 1); // because adding the faces also changes the end pointer of the same object

              int[][] startList_Faces_nodes = (int[][]) subset(allFaces.nodes, 0, f);
              int[][] midList_Faces_nodes = new int [0][0];
              int[][] endList_Faces_nodes = (int[][]) subset(allFaces.nodes, f + 1);


              int[][] startList_Faces_options = (int[][]) subset(allFaces.options, 0, f);
              int[][] midList_Faces_options = new int [0][0];
              int[][] endList_Faces_options = (int[][]) subset(allFaces.options, f + 1);

              {
                float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

                for (int i = 0; i < allFaces.nodes[f].length; i++) {

                  base_Vertices[i][0] = allPoints.getX(allFaces.nodes[f][i]);
                  base_Vertices[i][1] = allPoints.getY(allFaces.nodes[f][i]);
                  base_Vertices[i][2] = allPoints.getZ(allFaces.nodes[f][i]);
                }

                float[] G_face = {
                  0, 0, 0
                };

                for (int i = 0; i < allFaces.nodes[f].length; i++) {
                  for (int j = 0; j < 3; j++) {
                    G_face[j] += base_Vertices[i][j] / float(allFaces.nodes[f].length);
                  }
                }


                int new_CenterVertex_number = 0; // at the center
                new_CenterVertex_number = allPoints.create(G_face[0], G_face[1], G_face[2]);


                current_Material = allFaces.getMaterial(f);
                current_Tessellation = allFaces.getTessellation(f);
                current_Layer = allFaces.getLayer(f);
                current_Visibility = allFaces.getVisibility(f);

                for (int s = 0; s < allFaces.nodes[f].length; s++) {

                  int s_next = (s + 1) % allFaces.nodes[f].length;

                  int[][] newFace_nodes = {
                    {
                      allFaces.nodes[f][s], allFaces.nodes[f][s_next], new_CenterVertex_number
                    }
                  };
                  int[][] newFace_options = {
                    {
                      current_Material, current_Tessellation, current_Layer, current_Visibility, current_Weight, current_Closed
                    }
                  };

                  midList_Faces_nodes = (int[][]) concat(midList_Faces_nodes, newFace_nodes);
                  midList_Faces_options = (int[][]) concat(midList_Faces_options, newFace_options);

                  if (s > 0) { // the first tessellated face was replaced by the base face... so only add other items
                    int[] newFace_nodes_number = {
                      f + s
                    };
                    Select3D.Face_ids = (int[]) concat(Select3D.Face_ids, newFace_nodes_number);
                  }
                }
              }

              startList_Faces_nodes = (int[][]) concat(startList_Faces_nodes, midList_Faces_nodes);
              startList_Faces_options = (int[][]) concat(startList_Faces_options, midList_Faces_options);

              allFaces.nodes = (int[][]) concat(startList_Faces_nodes, endList_Faces_nodes);
              allFaces.options = (int[][]) concat(startList_Faces_options, endList_Faces_options);
            }

            primary_list = this.remove_item_from_primary_list(q, primary_list);
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }



  void optimizeFace_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            float[][] base_Vertices = new float [allFaces.nodes[f].length][3];

            for (int s = 0; s < allFaces.nodes[f].length; s++) {
              int vNo = allFaces.nodes[f][s];

              base_Vertices[s][0] = allPoints.getX(vNo);
              base_Vertices[s][1] = allPoints.getY(vNo);
              base_Vertices[s][2] = allPoints.getZ(vNo);
            }

            float[][] new_Vertices = funcs.optimizeVertices(base_Vertices);

            int[] newList = new int[0];
            // finding ids of new vertices in old vertices
            for (int k = 0; k < new_Vertices.length; k++) {
              for (int s = 0; s < base_Vertices.length; s++) {
                if (funcs.arePointsClose(new_Vertices[k], base_Vertices[s])) {
                  int[] newItem = {allFaces.nodes[f][s]};
                  newList = (int []) concat(newList, newItem);
                  break;
                }
              }
            }
            allFaces.nodes[f] = newList;
          }

        }
      }


      SOLARCHVISION_selection_changed();
    }
  }



  void extrudeFaceEdges_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      int[] primary_list = Select3D.Face_ids;

      Select3D.deselect_Faces();

      for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

        int OBJ_ID = Select3D.Group_ids[o];

        allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);

        for (int q = primary_list.length - 1; q >= 0; q--) {

          int f = primary_list[q];

          int startFace = allGroups.getStart_Face(OBJ_ID);
          int endFace = allGroups.getStop_Face(OBJ_ID);

          if ((startFace <= f) && (f <= endFace)) {

            float[][] base_Vertices = new float [allFaces.nodes[f].length][3];
            float[][] top_Vertices = new float [allFaces.nodes[f].length][3];

            for (int s = 0; s < allFaces.nodes[f].length; s++) {
              int vNo = allFaces.nodes[f][s];

              base_Vertices[s][0] = allPoints.getX(vNo);
              base_Vertices[s][1] = allPoints.getY(vNo);
              base_Vertices[s][2] = allPoints.getZ(vNo);

              top_Vertices[s][0] = allPoints.getX(vNo);
              top_Vertices[s][1] = allPoints.getY(vNo);
              top_Vertices[s][2] = allPoints.getZ(vNo);
            }

            for (int s = 0; s < allFaces.nodes[f].length; s++) {

              int s_next = (s + 1) % allFaces.nodes[f].length;
              int s_prev = (s + allFaces.nodes[f].length - 1) % allFaces.nodes[f].length;

              PVector U = new PVector(base_Vertices[s_next][0] - base_Vertices[s][0], base_Vertices[s_next][1] - base_Vertices[s][1], base_Vertices[s_next][2] - base_Vertices[s][2]);
              PVector V = new PVector(base_Vertices[s_prev][0] - base_Vertices[s][0], base_Vertices[s_prev][1] - base_Vertices[s][1], base_Vertices[s_prev][2] - base_Vertices[s][2]);
              PVector UV = U.cross(V);
              float[] W = {
                UV.x, UV.y, UV.z
              };
              W = funcs.vec3_unit(W);

              top_Vertices[s][0] += W[0] * User3D.modify_OpenningDepth;
              top_Vertices[s][1] += W[1] * User3D.modify_OpenningDepth;
              top_Vertices[s][2] += W[2] * User3D.modify_OpenningDepth;
            }

            int[] base_Vertex_ids = new int [allFaces.nodes[f].length];
            int[] top_Vertex_ids = new int [allFaces.nodes[f].length];

            for (int s = 0; s < allFaces.nodes[f].length; s++) {

              base_Vertex_ids[s] = allPoints.create(base_Vertices[s][0], base_Vertices[s][1], base_Vertices[s][2]);
              top_Vertex_ids[s] = allPoints.create(top_Vertices[s][0], top_Vertices[s][1], top_Vertices[s][2]);
            }

            for (int s = 0; s < allFaces.nodes[f].length; s++) {

              int s_next = (s + 1) % allFaces.nodes[f].length;

              if (User3D.modify_OpenningDepth < 0) { // reverse direction for negative extrude heights
                int[][] newFace_nodes = {
                  {
                    base_Vertex_ids[s], top_Vertex_ids[s], top_Vertex_ids[s_next], base_Vertex_ids[s_next]
                  }
                };
                allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes);
              } else {
                int[][] newFace_nodes = {
                  {
                    base_Vertex_ids[s], base_Vertex_ids[s_next], top_Vertex_ids[s_next], top_Vertex_ids[s]
                  }
                };
                allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes);
              }

              int[][] newFace_options = {
                {
                  allFaces.getMaterial(f), allFaces.getTessellation(f), allFaces.getLayer(f), allFaces.getVisibility(f), allFaces.getWeight(f), allFaces.getClose(f)
                }
              };
              allFaces.options =  (int[][]) concat(allFaces.options, newFace_options);
            }

            { // adding the cap
              int[][] newFace_nodes = {
                top_Vertex_ids
              };
              allFaces.nodes = (int[][]) concat(allFaces.nodes, newFace_nodes);

              int[][] newFace_options = {
                {
                  allFaces.getMaterial(f), allFaces.getTessellation(f), allFaces.getLayer(f), allFaces.getVisibility(f), allFaces.getWeight(f), allFaces.getClose(f)
                }
              };
              allFaces.options =  (int[][]) concat(allFaces.options, newFace_options);

              int[] lastFace = {
                allFaces.nodes.length - 1
              };

              Select3D.Face_ids = (int[]) concat(Select3D.Face_ids, lastFace);
            }

            allGroups.Faces[allGroups.num - 1][1] = allFaces.nodes.length - 1;
          }
        }
      }


      SOLARCHVISION_selection_changed();
    }
  }



  void autoNormalFaces_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE)) {

      this.selectFacesAndGroups_fromCurrentSelection();

      for (int o = 0; o < Select3D.Face_ids.length; o++) {

        int f = Select3D.Face_ids[o];

        int n = allFaces.nodes[f].length;

        if (n > 2) {
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

          PVector AG = new PVector(allPoints.getX(tmpFace[0]) - G[0], allPoints.getY(tmpFace[0]) - G[1], allPoints.getZ(tmpFace[0]) - G[2]);
          PVector BG = new PVector(allPoints.getX(tmpFace[1]) - G[0], allPoints.getY(tmpFace[1]) - G[1], allPoints.getZ(tmpFace[1]) - G[2]);

          PVector GAxGB = AG.cross(BG);

          float[] ray_start = {G[0], G[1], G[2]};
          float[] ray_direction = {GAxGB.x, GAxGB.y, GAxGB.z};

          float[] RxP = Select3D.intersect(ray_start, ray_direction);

          if (RxP[0] >= 0) {

            for (int j = 0; j < n; j++) {
              allFaces.nodes[f][j] = tmpFace[n - j - 1];
            }
          }
        }
      }


      SOLARCHVISION_switch_category(ObjectCategory.FACE);
    }
  }







  void flatten_LandPoints () {

    for (int q = 0; q < Select3D.LandPoint_ids.length; q++) {

      int f = Select3D.LandPoint_ids[q];

      int i = f / Land3D.num_columns;
      int j = f % Land3D.num_columns;

      Land3D.Mesh[i][j][2] = 0;

    }

    SOLARCHVISION_selection_changed();
  }



  void changeVisibilityFaces_Selection (int new_vsb) {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      if (current_ObjectCategory == ObjectCategory.GROUP) {

        Select3D.convert_Groups_to_Faces();
      }

      if (current_ObjectCategory == ObjectCategory.VERTEX) {

        Select3D.convert_Vertices_to_Faces();
      }

      for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Face_ids[o];

        allFaces.setVisibility(f, new_vsb);

      }
    }

    SOLARCHVISION_model_changed();
  }


  void changeVisibilityFaces_Scene (int new_vsb) {

    for (int f = allFaces.nodes.length - 1; f >= 0; f--) {
      allFaces.setVisibility(f, new_vsb);
    }

    SOLARCHVISION_model_changed();
  }


  void reverseVisibilityFaces_Scene () {

    for (int f = allFaces.nodes.length - 1; f >= 0; f--) {

      int vsb = allFaces.getVisibility(f);
      int new_vsb = vsb;

      if (vsb == 0) new_vsb = 1;
      else if (vsb == 1) new_vsb = 0;

      allFaces.setVisibility(f, new_vsb);
    }

    SOLARCHVISION_model_changed();
  }


  void changeVisibilityPolylines_Selection (int new_vsb) {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      if (current_ObjectCategory == ObjectCategory.GROUP) {

        Select3D.convert_Groups_to_Polylines();
      }

      if (current_ObjectCategory == ObjectCategory.VERTEX) {

        Select3D.convert_Vertices_to_Polylines();
      }

      for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {

        int f = Select3D.Polyline_ids[o];

        allPolylines.setVisibility(f, new_vsb);

      }
    }

    SOLARCHVISION_model_changed();
  }


  void changeVisibilityPolylines_Scene (int new_vsb) {

    for (int f = allPolylines.nodes.length - 1; f >= 0; f--) {
      allPolylines.setVisibility(f, new_vsb);
    }

    SOLARCHVISION_model_changed();
  }


  void reverseVisibilityPolylines_Scene () {

    for (int f = allPolylines.nodes.length - 1; f >= 0; f--) {

      int vsb = allPolylines.getVisibility(f);
      int new_vsb = vsb;

      if (vsb == 0) new_vsb = 1;
      else if (vsb == 1) new_vsb = 0;

      allPolylines.setVisibility(f, new_vsb);
    }

    SOLARCHVISION_model_changed();
  }

  void isolate_Selection () {

    if ((current_ObjectCategory == ObjectCategory.GROUP) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.VERTEX)) {

      this.changeVisibilityFaces_Scene(0);
      this.changeVisibilityFaces_Selection(1);

      this.changeVisibilityPolylines_Scene(0);
      this.changeVisibilityPolylines_Selection(1);
    }
  }

}
