class solarchvision_Delete3D {

  private final static String CLASS_STAMP = "Delete3D";

  void selection () {

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      Delete3D.selected_Cameras();
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      Delete3D.selected_Sections();
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      Delete3D.selected_Model1Ds();
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      Delete3D.selected_Model2Ds();
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      Delete3D.selected_Solids();
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      Delete3D.selected_Faces();
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      Delete3D.selected_Polylines();
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      Delete3D.selected_Groups();
    }

    if ((current_ObjectCategory == ObjectCategory.VERTEX) ||
        (current_ObjectCategory == ObjectCategory.FACE) ||
        (current_ObjectCategory == ObjectCategory.POLYLINE) ||
        (current_ObjectCategory == ObjectCategory.GROUP)) {

      Delete3D.isolatedVertices_Selection();
    }

    Select3D.deselectAll(); // important to deselect
  }

  void selected_Cameras () {

    Select3D.Camera_ids = sort(Select3D.Camera_ids);

    for (int o = Select3D.Camera_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Camera_ids[o];

      {
        float[][] startList = (float[][]) subset(allCameras.options, 0, OBJ_ID);
        float[][] endList = (float[][]) subset(allCameras.options, OBJ_ID + 1);

        allCameras.options = (float[][]) concat(startList, endList);
      }

      {
        int[] startList = (int[]) subset(allCameras.Type, 0, OBJ_ID);
        int[] endList = (int[]) subset(allCameras.Type, OBJ_ID + 1);

        allCameras.Type = (int[]) concat(startList, endList);
      }

      allCameras.num -= 1;

      if (OBJ_ID == WIN3D.currentCamera) {

        WIN3D.currentCamera = 0;

        SOLARCHVISION_modify_Viewport_Title();
      }
    }

    if (allCameras.num == 0) {
      allCameras.add_first();
    }

    SOLARCHVISION_model_changed();
  }


  void selected_Sections () {

    Select3D.Section_ids = sort(Select3D.Section_ids);

    for (int o = Select3D.Section_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Section_ids[o];

      {
        float[][] startList = (float[][]) subset(allSections.f_data, 0, OBJ_ID);
        float[][] endList = (float[][]) subset(allSections.f_data, OBJ_ID + 1);

        allSections.f_data = (float[][]) concat(startList, endList);
      }

      {
        int[][] startList = (int[][]) subset(allSections.i_data, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allSections.i_data, OBJ_ID + 1);

        allSections.i_data = (int[][]) concat(startList, endList);
      }

      {
        PImage[] startList = (PImage[]) subset(allSections.SolidImpact, 0, OBJ_ID);
        PImage[] endList = (PImage[]) subset(allSections.SolidImpact, OBJ_ID + 1);

        allSections.SolidImpact = (PImage[]) concat(startList, endList);
      }

      {
        PImage[][][] startList = (PImage[][][]) subset(allSections.SolarImpact, 0, OBJ_ID);
        PImage[][][] endList = (PImage[][][]) subset(allSections.SolarImpact, OBJ_ID + 1);

        allSections.SolarImpact = (PImage[][][]) concat(startList, endList);
      }

      allSections.num -= 1;
    }

    SOLARCHVISION_model_changed();
  }





  void selected_Model1Ds () {

    Select3D.Model1D_ids = sort(Select3D.Model1D_ids);

    for (int o = Select3D.Model1D_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Model1D_ids[o];

      for (int q = 0; q < allGroups.num; q++) {

        if ((allGroups.Model1Ds[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Model1Ds[q][1])) {
          if (allGroups.Model1Ds[q][1] >= 0) allGroups.Model1Ds[q][1] -= 1;
        } else if (allGroups.Model1Ds[q][0] > OBJ_ID) {
          if (allGroups.Model1Ds[q][0] >= 0) allGroups.Model1Ds[q][0] -= 1;
          if (allGroups.Model1Ds[q][1] >= 0) allGroups.Model1Ds[q][1] -= 1;
        }
      }


      {
        float[][] startList = (float[][]) subset(allModel1Ds.f_data, 0, OBJ_ID);
        float[][] endList = (float[][]) subset(allModel1Ds.f_data, OBJ_ID + 1);

        allModel1Ds.f_data = (float[][]) concat(startList, endList);
      }

      {
        int[][] startList = (int[][]) subset(allModel1Ds.i_data, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allModel1Ds.i_data, OBJ_ID + 1);

        allModel1Ds.i_data = (int[][]) concat(startList, endList);
      }

      allModel1Ds.num -= 1;
    }

    SOLARCHVISION_model_changed();
  }


  void selected_Model2Ds () {

    Select3D.Model2D_ids = sort(Select3D.Model2D_ids);

    for (int o = Select3D.Model2D_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Model2D_ids[o];

      for (int q = 0; q < allGroups.num; q++) {

        if ((allGroups.Model2Ds[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Model2Ds[q][1])) {
          if (allGroups.Model2Ds[q][1] >= 0) allGroups.Model2Ds[q][1] -= 1;
        } else if (allGroups.Model2Ds[q][0] > OBJ_ID) {
          if (allGroups.Model2Ds[q][0] >= 0) allGroups.Model2Ds[q][0] -= 1;
          if (allGroups.Model2Ds[q][1] >= 0) allGroups.Model2Ds[q][1] -= 1;
        }
      }


      {
        float[][] startList = (float[][]) subset(allModel2Ds.XYZS, 0, OBJ_ID);
        float[][] endList = (float[][]) subset(allModel2Ds.XYZS, OBJ_ID + 1);

        allModel2Ds.XYZS = (float[][]) concat(startList, endList);
      }

      {
        int[] startList = (int[]) subset(allModel2Ds.MAP, 0, OBJ_ID);
        int[] endList = (int[]) subset(allModel2Ds.MAP, OBJ_ID + 1);

        allModel2Ds.MAP = (int[]) concat(startList, endList);
      }

      allModel2Ds.num -= 1;
    }

    SOLARCHVISION_model_changed();
  }


  void selected_Solids () {

    Select3D.Solid_ids = sort(Select3D.Solid_ids);

    for (int o = Select3D.Solid_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Solid_ids[o];

      for (int q = 0; q < allGroups.num; q++) {

        if ((allGroups.Solids[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Solids[q][1])) {
          if (allGroups.Solids[q][1] >= 0) allGroups.Solids[q][1] -= 1;
        } else if (allGroups.Solids[q][0] > OBJ_ID) {
          if (allGroups.Solids[q][0] >= 0) allGroups.Solids[q][0] -= 1;
          if (allGroups.Solids[q][1] >= 0) allGroups.Solids[q][1] -= 1;
        }
      }


      {
        float[][] startList = (float[][]) subset(allSolids.DEF, 0, OBJ_ID);
        float[][] endList = (float[][]) subset(allSolids.DEF, OBJ_ID + 1);

        allSolids.DEF = (float[][]) concat(startList, endList);
      }
    }

    SOLARCHVISION_model_changed();
  }


  void selected_Faces () {

    Select3D.Face_ids = sort(Select3D.Face_ids);

    for (int o = Select3D.Face_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Face_ids[o];

      for (int q = 0; q < allGroups.num; q++) {

        if ((allGroups.Faces[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Faces[q][1])) {
          if (allGroups.Faces[q][1] >= 0) allGroups.Faces[q][1] -= 1;
        } else if (allGroups.Faces[q][0] > OBJ_ID) {
          if (allGroups.Faces[q][0] >= 0) allGroups.Faces[q][0] -= 1;
          if (allGroups.Faces[q][1] >= 0) allGroups.Faces[q][1] -= 1;
        }
      }


      {
        int[][] startList = (int[][]) subset(allFaces.nodes, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allFaces.nodes, OBJ_ID + 1);

        allFaces.nodes = (int[][]) concat(startList, endList);
      }

      {
        int[][] startList = (int[][]) subset(allFaces.options, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allFaces.options, OBJ_ID + 1);

        allFaces.options = (int[][]) concat(startList, endList);
      }
    }

    SOLARCHVISION_model_changed();
  }


  void selected_Polylines () {

    Select3D.Polyline_ids = sort(Select3D.Polyline_ids);

    for (int o = Select3D.Polyline_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Polyline_ids[o];

      for (int q = 0; q < allGroups.num; q++) {

        if ((allGroups.Polylines[q][0] <= OBJ_ID) && (OBJ_ID <= allGroups.Polylines[q][1])) {
          if (allGroups.Polylines[q][1] >= 0) allGroups.Polylines[q][1] -= 1;
        } else if (allGroups.Polylines[q][0] > OBJ_ID) {
          if (allGroups.Polylines[q][0] >= 0) allGroups.Polylines[q][0] -= 1;
          if (allGroups.Polylines[q][1] >= 0) allGroups.Polylines[q][1] -= 1;
        }
      }


      {
        int[][] startList = (int[][]) subset(allPolylines.nodes, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allPolylines.nodes, OBJ_ID + 1);

        allPolylines.nodes = (int[][]) concat(startList, endList);
      }

      {
        int[][] startList = (int[][]) subset(allPolylines.options, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allPolylines.options, OBJ_ID + 1);

        allPolylines.options = (int[][]) concat(startList, endList);
      }
    }

    SOLARCHVISION_model_changed();
  }


  void selected_Groups () {

    /////////////////////////////
    //SOLARCHVISION_hold_project();
    /////////////////////////////

    Select3D.convert_Groups_to_Vertices(); // finding vertices so that we could delete the isolated ones later

    Select3D.Group_ids = sort(Select3D.Group_ids);

    boolean allSolids_updated = false;

    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Group_ids[o];

      int startFace = allGroups.getStart_Face(OBJ_ID);
      int endFace = allGroups.getStop_Face(OBJ_ID);

      {

        if ((0 <= startFace) && (startFace <= endFace)) {

          for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
            for (int j = 0; j < 2; j++) {
              allGroups.Faces[i][j] -= 1 + endFace - startFace;

              if (allGroups.Faces[i][j] < 0) allGroups.Faces[i][j] = 0;
            }
          }
        }

        int[][] startList = (int[][]) subset(allGroups.Faces, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allGroups.Faces, OBJ_ID + 1);

        allGroups.Faces = (int[][]) concat(startList, endList);
      }

      if ((0 <= startFace) && (startFace <= endFace)) {
        {
          int[][] startList = (int[][]) subset(allFaces.nodes, 0, startFace);
          int[][] endList = (int[][]) subset(allFaces.nodes, endFace + 1);

          allFaces.nodes = (int[][]) concat(startList, endList);
        }

        {
          int[][] startList = (int[][]) subset(allFaces.options, 0, startFace);
          int[][] endList = (int[][]) subset(allFaces.options, endFace + 1);

          allFaces.options = (int[][]) concat(startList, endList);
        }
      }


      int startPolyline = allGroups.getStart_Polyline(OBJ_ID);
      int endPolyline = allGroups.getStop_Polyline(OBJ_ID);

      {

        if ((0 <= startPolyline) && (startPolyline <= endPolyline)) {

          for (int i = OBJ_ID + 1; i < allGroups.num; i++) {
            for (int j = 0; j < 2; j++) {
              allGroups.Polylines[i][j] -= 1 + endPolyline - startPolyline;

              if (allGroups.Polylines[i][j] < 0) allGroups.Polylines[i][j] = 0;
            }
          }
        }

        int[][] startList = (int[][]) subset(allGroups.Polylines, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allGroups.Polylines, OBJ_ID + 1);

        allGroups.Polylines = (int[][]) concat(startList, endList);
      }

      if ((0 <= startPolyline) && (startPolyline <= endPolyline)) {
        {
          int[][] startList = (int[][]) subset(allPolylines.nodes, 0, startPolyline);
          int[][] endList = (int[][]) subset(allPolylines.nodes, endPolyline + 1);

          allPolylines.nodes = (int[][]) concat(startList, endList);
        }

        {
          int[][] startList = (int[][]) subset(allPolylines.options, 0, startPolyline);
          int[][] endList = (int[][]) subset(allPolylines.options, endPolyline + 1);

          allPolylines.options = (int[][]) concat(startList, endList);
        }
      }


      int startModel1Ds = allGroups.getStart_Model1D(OBJ_ID);
      int endModel1Ds = allGroups.getStop_Model1D(OBJ_ID);

      {

        if ((0 <= startModel1Ds) && (startModel1Ds <= endModel1Ds)) {

          for (int i = OBJ_ID + 1; i < allGroups.num; i++) {

            for (int j = 0; j < 2; j++) {

              allGroups.Model1Ds[i][j] -= 1 + endModel1Ds - startModel1Ds;

              if (allGroups.Model1Ds[i][j] < 0) allGroups.Model1Ds[i][j] = 0;
            }
          }
        }

        int[][] startList = (int[][]) subset(allGroups.Model1Ds, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allGroups.Model1Ds, OBJ_ID + 1);

        allGroups.Model1Ds = (int[][]) concat(startList, endList);
      }

      if ((0 <= startModel1Ds) && (startModel1Ds <= endModel1Ds)) {

        {
          float[][] startList = (float[][]) subset(allModel1Ds.f_data, 0, startModel1Ds);
          float[][] endList = (float[][]) subset(allModel1Ds.f_data, endModel1Ds + 1);

          allModel1Ds.f_data = (float[][]) concat(startList, endList);
        }

        {
          int[][] startList = (int[][]) subset(allModel1Ds.i_data, 0, startModel1Ds);
          int[][] endList = (int[][]) subset(allModel1Ds.i_data, endModel1Ds + 1);

          allModel1Ds.i_data = (int[][]) concat(startList, endList);
        }

        allModel1Ds.num = allModel1Ds.f_data.length;
      }

      int startModel2Ds = allGroups.getStart_Model2D(OBJ_ID);
      int endModel2Ds = allGroups.getStop_Model2D(OBJ_ID);

      {

        if ((0 <= startModel2Ds) && (startModel2Ds <= endModel2Ds)) {

          for (int i = OBJ_ID + 1; i < allGroups.num; i++) {

            for (int j = 0; j < 2; j++) {

              allGroups.Model2Ds[i][j] -= 1 + endModel2Ds - startModel2Ds;

              if (allGroups.Model2Ds[i][j] < 0) allGroups.Model2Ds[i][j] = 0;
            }
          }
        }

        int[][] startList = (int[][]) subset(allGroups.Model2Ds, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allGroups.Model2Ds, OBJ_ID + 1);

        allGroups.Model2Ds = (int[][]) concat(startList, endList);
      }

      if ((0 <= startModel2Ds) && (startModel2Ds <= endModel2Ds)) {

        {
          float[][] startList = (float[][]) subset(allModel2Ds.XYZS, 0, startModel2Ds);
          float[][] endList = (float[][]) subset(allModel2Ds.XYZS, endModel2Ds + 1);

          allModel2Ds.XYZS = (float[][]) concat(startList, endList);
        }

        {
          int[] startList = (int[]) subset(allModel2Ds.MAP, 0, startModel2Ds);
          int[] endList = (int[]) subset(allModel2Ds.MAP, endModel2Ds + 1);

          allModel2Ds.MAP = (int[]) concat(startList, endList);
        }

        allModel2Ds.num = allModel2Ds.XYZS.length;
      }

      int startSolid = allGroups.getStart_Solid(OBJ_ID);
      int endSolid = allGroups.getStop_Solid(OBJ_ID);

      {
        if ((0 <= startSolid) && (startSolid <= endSolid)) {
          for (int i = OBJ_ID + 1; i < allGroups.num; i++) {

            for (int j = 0; j < 2; j++) {
              allGroups.Solids[i][j] -= 1 + endSolid - startSolid;

              if (allGroups.Solids[i][j] < 0) allGroups.Solids[i][j] = 0;
            }
          }
        }

        int[][] startList = (int[][]) subset(allGroups.Solids, 0, OBJ_ID);
        int[][] endList = (int[][]) subset(allGroups.Solids, OBJ_ID + 1);

        allGroups.Solids = (int[][]) concat(startList, endList);
      }

      if ((0 <= startSolid) && (startSolid <= endSolid)) {

        float[][] startList = (float[][]) subset(allSolids.DEF, 0, startSolid);
        float[][] endList = (float[][]) subset(allSolids.DEF, endSolid + 1);

        allSolids.DEF = (float[][]) concat(startList, endList);

        allSolids_updated = true;
      }


      {
        float[][] startList = (float[][]) subset(allGroups.Pivots, 0, OBJ_ID);
        float[][] endList = (float[][]) subset(allGroups.Pivots, OBJ_ID + 1);

        allGroups.Pivots = (float[][]) concat(startList, endList);
      }

      allGroups.num -= 1;
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }





  void isolatedVertices_Selection () {

    Select3D.Vertex_ids = sort(Select3D.Vertex_ids);

    for (int o = Select3D.Vertex_ids.length - 1; o >= 0; o--) {

      int vNo = Select3D.Vertex_ids[o];

      int found = -1;

      if (found == -1) {
        for (int i = 0; i < allFaces.nodes.length; i++) {
          for (int j = 0; j < allFaces.nodes[i].length; j++) {
            if (allFaces.nodes[i][j] == vNo) {

              found = 1;
            }

            if (found != -1) break;
          }

          if (found != -1) break;
        }
      }

      if (found == -1) {
        for (int i = 0; i < allPolylines.nodes.length; i++) {
          for (int j = 0; j < allPolylines.nodes[i].length; j++) {
            if (allPolylines.nodes[i][j] == vNo) {

              found = 1;
            }

            if (found != -1) break;
          }

          if (found != -1) break;
        }
      }


      if (found == -1) {

        for (int i = 0; i < allFaces.nodes.length; i++) {
          for (int j = 0; j < allFaces.nodes[i].length; j++) {
            if (allFaces.nodes[i][j] > vNo) {

              allFaces.nodes[i][j] -= 1;
            }
          }
        }

        for (int i = 0; i < allPolylines.nodes.length; i++) {
          for (int j = 0; j < allPolylines.nodes[i].length; j++) {
            if (allPolylines.nodes[i][j] > vNo) {

              allPolylines.nodes[i][j] -= 1;
            }
          }
        }

        float[][] startList = (float[][]) subset(allVertices, 0, vNo);
        float[][] endList = (float[][]) subset(allVertices, vNo + 1);

        allVertices = (float[][]) concat(startList, endList);
      }
    }

    Select3D.deselect_Vertices();

    SOLARCHVISION_model_changed();
  }


  void isolatedVertices_Scene () {

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
        {
          float[][] startList = (float[][]) subset(allVertices, 0, vNo);
          float[][] endList = (float[][]) subset(allVertices, vNo + 1);

          allVertices = (float[][]) concat(startList, endList);
        }

        for (int i = 0; i < allFaces.nodes.length; i++) {
          for (int j = 0; j < allFaces.nodes[i].length; j++) {
            if (allFaces.nodes[i][j] > vNo) {

              allFaces.nodes[i][j] -= 1;
            }
          }
        }

        for (int i = 0; i < allPolylines.nodes.length; i++) {
          for (int j = 0; j < allPolylines.nodes[i].length; j++) {
            if (allPolylines.nodes[i][j] > vNo) {

              allPolylines.nodes[i][j] -= 1;
            }
          }
        }
      }


    }

    Select3D.deselect_Vertices();

    SOLARCHVISION_model_changed();
  }

}
