class solarchvision_Rotate3D {

  private final static String CLASS_STAMP = "Rotate3D";

  void selection (float x0, float y0, float z0, float r, int the_Vector) {

    r *= PI / 180; // <<<<<<<<

    float[] A = Select3D.translateInside_ReferencePivot(0, 0, 0);
    float[] B = Select3D.translateInside_ReferencePivot(x0, y0, z0);

    x0 = B[0] - A[0];
    y0 = B[1] - A[1];
    z0 = B[2] - A[2];

    if (current_ObjectCategory == ObjectCategory.LANDPOINT) {
      this.LandPoints(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {
      this.softSelection(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.VERTEX) {
      this.Vertices(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.POLYLINE) {
      this.Polylines(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.FACE) {
      this.Faces(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL1D) {
      this.Model1Ds(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.MODEL2D) {
      this.Model2Ds(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.SOLID) {
      this.Solids(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.CAMERA) {
      this.Cameras(x0, y0, z0, r, the_Vector);
    }

    if (current_ObjectCategory == ObjectCategory.SECTION) {
      this.Sections(r);
    }

    if (current_ObjectCategory == ObjectCategory.GROUP) {
      this.Groups(r, the_Vector);
    }
  }


  void softSelection (float x0, float y0, float z0, float r, int the_Vector) {

    for (int q = 0; q < Select3D.softSelection_ids.length; q++) {

      int f = Select3D.softSelection_ids[q];

      float v = Select3D.softSelection_values[q];

      float x = allPoints.getX(f) - x0;
      float y = allPoints.getY(f) - y0;
      float z = allPoints.getZ(f) - z0;

      if (the_Vector == 2) {
        allPoints.setX(f, x0 + (x * cos(r * v) - y * sin(r * v)));
        allPoints.setY(f, y0 + (x * sin(r * v) + y * cos(r * v)));
        allPoints.setZ(f, z0 + (z));
      } else if (the_Vector == 1) {
        allPoints.setX(f, x0 + (z * sin(r * v) + x * cos(r * v)));
        allPoints.setY(f, y0 + (y));
        allPoints.setZ(f, z0 + (z * cos(r * v) - x * sin(r * v)));
      } else if (the_Vector == 0) {
        allPoints.setX(f, x0 + (x));
        allPoints.setY(f, y0 + (y * cos(r * v) - z * sin(r * v)));
        allPoints.setZ(f, z0 + (y * sin(r * v) + z * cos(r * v)));
      }
    }

    SOLARCHVISION_model_changed();
  }



  void LandPoints (float x0, float y0, float z0, float r, int the_Vector) {

    for (int q = 0; q < Select3D.LandPoint_ids.length; q++) {

      int f = Select3D.LandPoint_ids[q];

      int i = f / Land3D.num_columns;
      int j = f % Land3D.num_columns;

      float x = Land3D.Mesh[i][j][0] - x0;
      float y = Land3D.Mesh[i][j][1] - y0;
      float z = Land3D.Mesh[i][j][2] - z0;

      if (the_Vector == 2) {
        Land3D.Mesh[i][j][0] = x0 + (x * cos(r) - y * sin(r));
        Land3D.Mesh[i][j][1] = y0 + (x * sin(r) + y * cos(r));
        Land3D.Mesh[i][j][2] = z0 + (z);
      } else if (the_Vector == 1) {
        Land3D.Mesh[i][j][0] = x0 + (z * sin(r) + x * cos(r));
        Land3D.Mesh[i][j][1] = y0 + (y);
        Land3D.Mesh[i][j][2] = z0 + (z * cos(r) - x * sin(r));
      } else if (the_Vector == 0) {
        Land3D.Mesh[i][j][0] = x0 + (x);
        Land3D.Mesh[i][j][1] = y0 + (y * cos(r) - z * sin(r));
        Land3D.Mesh[i][j][2] = z0 + (y * sin(r) + z * cos(r));
      }
    }

    SOLARCHVISION_model_changed();
  }




  void Vertices (float x0, float y0, float z0, float r, int the_Vector) {

    for (int q = 0; q < Select3D.Vertex_ids.length; q++) {

      int f = Select3D.Vertex_ids[q];

      float x = allPoints.getX(f) - x0;
      float y = allPoints.getY(f) - y0;
      float z = allPoints.getZ(f) - z0;

      if (the_Vector == 2) {
        allPoints.setX(f, x0 + (x * cos(r) - y * sin(r)));
        allPoints.setY(f, y0 + (x * sin(r) + y * cos(r)));
        allPoints.setZ(f, z0 + (z));
      } else if (the_Vector == 1) {
        allPoints.setX(f, x0 + (z * sin(r) + x * cos(r)));
        allPoints.setY(f, y0 + (y));
        allPoints.setZ(f, z0 + (z * cos(r) - x * sin(r)));
      } else if (the_Vector == 0) {
        allPoints.setX(f, x0 + (x));
        allPoints.setY(f, y0 + (y * cos(r) - z * sin(r)));
        allPoints.setZ(f, z0 + (y * sin(r) + z * cos(r)));
      }
    }

    SOLARCHVISION_model_changed();
  }


  void Polylines (float x0, float y0, float z0, float r, int the_Vector) {

    int[] PolylineVertices = Select3D.get_Polyline_Vertices();

    for (int q = 0; q < PolylineVertices.length; q++) {

      int f = PolylineVertices[q];

      float x = allPoints.getX(f) - x0;
      float y = allPoints.getY(f) - y0;
      float z = allPoints.getZ(f) - z0;

      if (the_Vector == 2) {
        allPoints.setX(f, x0 + (x * cos(r) - y * sin(r)));
        allPoints.setY(f, y0 + (x * sin(r) + y * cos(r)));
        allPoints.setZ(f, z0 + (z));
      } else if (the_Vector == 1) {
        allPoints.setX(f, x0 + (z * sin(r) + x * cos(r)));
        allPoints.setY(f, y0 + (y));
        allPoints.setZ(f, z0 + (z * cos(r) - x * sin(r)));
      } else if (the_Vector == 0) {
        allPoints.setX(f, x0 + (x));
        allPoints.setY(f, y0 + (y * cos(r) - z * sin(r)));
        allPoints.setZ(f, z0 + (y * sin(r) + z * cos(r)));
      }
    }

    SOLARCHVISION_model_changed();
  }


  void Faces (float x0, float y0, float z0, float r, int the_Vector) {

    int[] FaceVertices = Select3D.get_Face_Vertices();

    for (int q = 0; q < FaceVertices.length; q++) {

      int f = FaceVertices[q];

      float x = allPoints.getX(f) - x0;
      float y = allPoints.getY(f) - y0;
      float z = allPoints.getZ(f) - z0;

      if (the_Vector == 2) {
        allPoints.setX(f, x0 + (x * cos(r) - y * sin(r)));
        allPoints.setY(f, y0 + (x * sin(r) + y * cos(r)));
        allPoints.setZ(f, z0 + (z));
      } else if (the_Vector == 1) {
        allPoints.setX(f, x0 + (z * sin(r) + x * cos(r)));
        allPoints.setY(f, y0 + (y));
        allPoints.setZ(f, z0 + (z * cos(r) - x * sin(r)));
      } else if (the_Vector == 0) {
        allPoints.setX(f, x0 + (x));
        allPoints.setY(f, y0 + (y * cos(r) - z * sin(r)));
        allPoints.setZ(f, z0 + (y * sin(r) + z * cos(r)));
      }
    }

    SOLARCHVISION_model_changed();
  }


  void Solids (float x0, float y0, float z0, float r, int the_Vector) {

    boolean allSolids_updated = false;

    for (int q = 0; q < Select3D.Solid_ids.length; q++) {

      int f = Select3D.Solid_ids[q];

      float Solid_posX = allSolids.get_posX(f);
      float Solid_posY = allSolids.get_posY(f);
      float Solid_posZ = allSolids.get_posZ(f);


      float x = Solid_posX - x0;
      float y = Solid_posY - y0;
      float z = Solid_posZ - z0;

      if (the_Vector == 2) {
        allSolids.updatePosition(f, x0 + (x * cos(r) - y * sin(r)), y0 + (x * sin(r) + y * cos(r)), z0 + (z));

        allSolids.RotateZ(f, r * 180 / PI);
      } else if (the_Vector == 1) {
        allSolids.updatePosition(f, x0 + (z * sin(r) + x * cos(r)), y0 + (y), z0 + (z * cos(r) - x * sin(r)));

        allSolids.RotateY(f, r * 180 / PI);
      } else if (the_Vector == 0) {
        allSolids.updatePosition(f, x0 + (x), y0 + (y * cos(r) - z * sin(r)), z0 + (y * sin(r) + z * cos(r)));

        allSolids.RotateX(f, r * 180 / PI);
      }

      allSolids_updated = true;
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }


  void Sections (float r) {

    for (int q = 0; q < Select3D.Section_ids.length; q++) {

      int f = Select3D.Section_ids[q];

      allSections.setR(f, allSections.getR(f) + r * 180.0 / PI);
    }

    allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }


  void Cameras (float x0, float y0, float z0, float r, int the_Vector) {

    // swapping y and z vectors to match camera's local coordinate
    if (the_Vector == 2) the_Vector = 1;
    else if (the_Vector == 1) the_Vector = 2;

    for (int q = 0; q < Select3D.Camera_ids.length; q++) {

      int f = Select3D.Camera_ids[q];

      float x = allCameras.get_posX(f) - x0;
      float y = allCameras.get_posY(f) - y0;
      float z = allCameras.get_posZ(f) - z0;

      if (the_Vector == 2) {
        allCameras.set_posX(f, x0 + (x * cos(r) - y * sin(r)));
        allCameras.set_posY(f, y0 + (x * sin(r) + y * cos(r)));
        allCameras.set_posZ(f, z0 + (z));
      } else if (the_Vector == 1) {
        allCameras.set_posX(f, x0 + (z * sin(r) + x * cos(r)));
        allCameras.set_posY(f, y0 + (y));
        allCameras.set_posZ(f, z0 + (z * cos(r) - x * sin(r)));
      } else if (the_Vector == 0) {
        allCameras.set_posX(f, x0 + (x));
        allCameras.set_posY(f, y0 + (y * cos(r) - z * sin(r)));
        allCameras.set_posZ(f, z0 + (y * sin(r) + z * cos(r)));
      }

      if (f == WIN3D.currentCamera) WIN3D.apply_currentCamera();
    }

    SOLARCHVISION_model_changed();
  }



  void Model1Ds (float x0, float y0, float z0, float r, int the_Vector) {

    for (int q = 0; q < Select3D.Model1D_ids.length; q++) {

      int f = Select3D.Model1D_ids[q];

      float x = allModel1Ds.getX(f) - x0;
      float y = allModel1Ds.getY(f) - y0;
      float z = allModel1Ds.getZ(f) - z0;

      if (the_Vector == 2) {
        allModel1Ds.setX(f, x0 + (x * cos(r) - y * sin(r)));
        allModel1Ds.setY(f, y0 + (x * sin(r) + y * cos(r)));
        allModel1Ds.setZ(f, z0 + (z));

        allModel1Ds.setRotation(f, allModel1Ds.getRotation(f) - r); // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      } else if (the_Vector == 1) {
        allModel1Ds.setX(f, x0 + (z * sin(r) + x * cos(r)));
        allModel1Ds.setY(f, y0 + (y));
        allModel1Ds.setZ(f, z0 + (z * cos(r) - x * sin(r)));
      } else if (the_Vector == 0) {
        allModel1Ds.setX(f, x0 + (x));
        allModel1Ds.setY(f, y0 + (y * cos(r) - z * sin(r)));
        allModel1Ds.setZ(f, z0 + (y * sin(r) + z * cos(r)));
      }
    }

    SOLARCHVISION_model_changed();
  }


  void Model2Ds (float x0, float y0, float z0, float r, int the_Vector) {

    for (int q = 0; q < Select3D.Model2D_ids.length; q++) {

      int f = Select3D.Model2D_ids[q];

      float x = allModel2Ds.getX(f) - x0;
      float y = allModel2Ds.getY(f) - y0;
      float z = allModel2Ds.getZ(f) - z0;

      if (the_Vector == 2) {
        allModel2Ds.setX(f, x0 + (x * cos(r) - y * sin(r)));
        allModel2Ds.setY(f, y0 + (x * sin(r) + y * cos(r)));
        allModel2Ds.setZ(f, z0 + (z));
      } else if (the_Vector == 1) {
        allModel2Ds.setX(f, x0 + (z * sin(r) + x * cos(r)));
        allModel2Ds.setY(f, y0 + (y));
        allModel2Ds.setZ(f, z0 + (z * cos(r) - x * sin(r)));
      } else if (the_Vector == 0) {
        allModel2Ds.setX(f, x0 + (x));
        allModel2Ds.setY(f, y0 + (y * cos(r) - z * sin(r)));
        allModel2Ds.setZ(f, z0 + (y * sin(r) + z * cos(r)));
      }
    }

    SOLARCHVISION_model_changed();
  }



  void Groups (float r, int the_Vector) {

    int[] PolymeshVertices = Select3D.get_Group_Vertices();

    for (int q = 0; q < PolymeshVertices.length; q++) {

      int n = PolymeshVertices[q];

      float x = allPoints.getX(n);
      float y = allPoints.getY(n);
      float z = allPoints.getZ(n);

      float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

      x = A[0];
      y = A[1];
      z = A[2];

      {
        float a = x;
        float b = y;
        float c = z;

        if (the_Vector == 2) {
          a = x * cos(r) - y * sin(r);
          b = x * sin(r) + y * cos(r);
          c = z;
        } else if (the_Vector == 1) {
          a = z * sin(r) + x * cos(r);
          b = y;
          c = z * cos(r) - x * sin(r);
        } else if (the_Vector == 0) {
          a = x;
          b = y * cos(r) - z * sin(r);
          c = y * sin(r) + z * cos(r);
        }

        x = a;
        y = b;
        z = c;
      }

      float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

      x = B[0];
      y = B[1];
      z = B[2];

      allPoints.setX(n, x);
      allPoints.setY(n, y);
      allPoints.setZ(n, z);
    }






    boolean allSolids_updated = false;

    for (int o = Select3D.Group_ids.length - 1; o >= 0; o--) {

      int OBJ_ID = Select3D.Group_ids[o];

      {
        float x = allGroups.Pivots[OBJ_ID][0];
        float y = allGroups.Pivots[OBJ_ID][1];
        float z = allGroups.Pivots[OBJ_ID][2];

        float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

        x = A[0];
        y = A[1];
        z = A[2];

        {
          float a = x;
          float b = y;
          float c = z;

          if (the_Vector == 2) {
            a = x * cos(r) - y * sin(r);
            b = x * sin(r) + y * cos(r);
            c = z;
          } else if (the_Vector == 1) {
            a = z * sin(r) + x * cos(r);
            b = y;
            c = z * cos(r) - x * sin(r);
          } else if (the_Vector == 0) {
            a = x;
            b = y * cos(r) - z * sin(r);
            c = y * sin(r) + z * cos(r);
          }

          x = a;
          y = b;
          z = c;
        }

        float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

        x = B[0];
        y = B[1];
        z = B[2];

        allGroups.Pivots[OBJ_ID][0] = x;
        allGroups.Pivots[OBJ_ID][1] = y;
        allGroups.Pivots[OBJ_ID][2] = z;

        if (the_Vector == 2) {
          allGroups.Pivots[OBJ_ID][8] += r * 180.0 / PI;
        } else if (the_Vector == 1) {
          allGroups.Pivots[OBJ_ID][7] += r * 180.0 / PI;
        } else if (the_Vector == 0) {
          allGroups.Pivots[OBJ_ID][6] += r * 180.0 / PI;
        }
      }


      for (int f = allGroups.getStart_Model1D(OBJ_ID); f <= allGroups.getStop_Model1D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel1Ds.num)) {

          float x = allModel1Ds.getX(f);
          float y = allModel1Ds.getY(f);
          float z = allModel1Ds.getZ(f);

          float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

          x = A[0];
          y = A[1];
          z = A[2];

          {
            float a = x;
            float b = y;
            float c = z;

            if (the_Vector == 2) {
              a = x * cos(r) - y * sin(r);
              b = x * sin(r) + y * cos(r);
              c = z;
            } else if (the_Vector == 1) {
              a = z * sin(r) + x * cos(r);
              b = y;
              c = z * cos(r) - x * sin(r);
            } else if (the_Vector == 0) {
              a = x;
              b = y * cos(r) - z * sin(r);
              c = y * sin(r) + z * cos(r);
            }

            x = a;
            y = b;
            z = c;
          }

          float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

          x = B[0];
          y = B[1];
          z = B[2];

          allModel1Ds.setX(f, x);
          allModel1Ds.setY(f, y);
          allModel1Ds.setZ(f, z);


          if (the_Vector == 2) {
            //allModel1Ds.setRotation(f, allModel1Ds.getRotation(f) + r); // <<<<<<<<<
          } else if (the_Vector == 1) {
          } else if (the_Vector == 0) {
          }
        }
      }

      for (int f = allGroups.getStart_Model2D(OBJ_ID); f <= allGroups.getStop_Model2D(OBJ_ID); f++) {
        if ((0 <= f) && (f < allModel2Ds.num)) {

          float x = allModel2Ds.getX(f);
          float y = allModel2Ds.getY(f);
          float z = allModel2Ds.getZ(f);

          float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

          x = A[0];
          y = A[1];
          z = A[2];

          {
            float a = x;
            float b = y;
            float c = z;

            if (the_Vector == 2) {
              a = x * cos(r) - y * sin(r);
              b = x * sin(r) + y * cos(r);
              c = z;
            } else if (the_Vector == 1) {
              a = z * sin(r) + x * cos(r);
              b = y;
              c = z * cos(r) - x * sin(r);
            } else if (the_Vector == 0) {
              a = x;
              b = y * cos(r) - z * sin(r);
              c = y * sin(r) + z * cos(r);
            }

            x = a;
            y = b;
            z = c;
          }

          float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

          x = B[0];
          y = B[1];
          z = B[2];

          allModel2Ds.setX(f, x);
          allModel2Ds.setY(f, y);
          allModel2Ds.setZ(f, z);
        }
      }

      for (int f = allGroups.getStart_Solid(OBJ_ID); f <= allGroups.getStop_Solid(OBJ_ID); f++) {
        if ((0 <= f) && (f < allSolids.DEF.length)) {

          float x = allSolids.get_posX(f);
          float y = allSolids.get_posY(f);
          float z = allSolids.get_posZ(f);

          float[] A = Select3D.translateOutside_ReferencePivot(x, y, z);

          x = A[0];
          y = A[1];
          z = A[2];

          {
            float a = x;
            float b = y;
            float c = z;

            if (the_Vector == 2) {
              a = x * cos(r) - y * sin(r);
              b = x * sin(r) + y * cos(r);
              c = z;
            } else if (the_Vector == 1) {
              a = z * sin(r) + x * cos(r);
              b = y;
              c = z * cos(r) - x * sin(r);
            } else if (the_Vector == 0) {
              a = x;
              b = y * cos(r) - z * sin(r);
              c = y * sin(r) + z * cos(r);
            }

            x = a;
            y = b;
            z = c;
          }

          float[] B = Select3D.translateInside_ReferencePivot(x, y, z);

          x = B[0];
          y = B[1];
          z = B[2];


          allSolids.updatePosition(f, x, y, z);

          // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Note: these rotations could be translated to locals to avoid problems!
          if (the_Vector == 2) {
            allSolids.RotateZ(f, r * 180 / PI);
          } else if (the_Vector == 1) {
            allSolids.RotateY(f, r * 180 / PI);
          } else if (the_Vector == 0) {
            allSolids.RotateX(f, r * 180 / PI);
          }

          allSolids_updated = true;
        }
      }
    }

    if (allSolids_updated) allSolidImpacts.calculate_Impact_selectedSections();

    SOLARCHVISION_model_changed();
  }

}
