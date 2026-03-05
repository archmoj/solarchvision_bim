class solarchvision_WindFlow {

  private final static String CLASS_STAMP = "WindFlow";

  boolean displayAll = false;

  int pallet_CLR = 18;
  int pallet_DIR = -1;
  float pallet_MLT = 1;



  void draw (int target_window) {

    boolean proceed = true;

    if (this.displayAll == false) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {
      proceed = false;
    }

    if (proceed) {

      int PAL_type = allWindFlows.pallet_CLR;
      int PAL_direction = allWindFlows.pallet_DIR;
      float PAL_multiplier = allWindFlows.pallet_MLT;



      if (target_window == TypeWindow.OBJ3D) {

        String the_filename = "";

        if (User3D.export_MaterialLibrary) {

          the_filename = "WindFlowPallet.bmp";

          String TEXTURE_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;

          println("Saving texture:", TEXTURE_path);

          int RES1 = User3D.export_PalletResolution;
          int RES2 = User3D.export_PalletResolution / 16;

          PImage pallet_Texture = createImage(RES1, RES2, ARGB);


          pallet_Texture.loadPixels();

          for (int np = 0; np < (RES1 * RES2); np++) {
            int Image_X = np % RES1;
            int Image_Y = np / RES1;

            float _val = (Image_X / (0.5 * RES1)) - 1;

            float _u = 0.5 + 0.5 * _val;

            float[] COL = PAINT.getColorStyle(PAL_type, _u);

            pallet_Texture.pixels[np] = color(COL[1], COL[2], COL[3], COL[0]);
          }

          pallet_Texture.updatePixels();

          pallet_Texture.save(TEXTURE_path);


          mtlOutput.println("newmtl " + "WindFlow");
          mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
          mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
          mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
          mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
          mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
          mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

          mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
          mtlOutput.println("\tTr 1.000"); //  0-1 transparency
          mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter

          //mtlOutput.println("\tmap_Ka " + Subfolder_exportMaps + the_filename); // ambient map
          mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
        }

        num_vertices_added = 0;

        for (int _turn = 1; _turn < 4; _turn++) {

          if (_turn == 3) {
            obj_lastGroupNumber += 1;
            objOutput.println("g WindFlow");

            if (User3D.export_MaterialLibrary) {
              objOutput.println("usemtl WindFlow");
            }
          }

          for (int q = 0; q < allSolidImpacts.Wind_Lines.length; q++) {

            int n1 = allSolidImpacts.Wind_Lines[q][0];
            int n2 = allSolidImpacts.Wind_Lines[q][1];

            float x1 = allSolidImpacts.Wind_Vertices[n1][0];
            float y1 = allSolidImpacts.Wind_Vertices[n1][1];
            float z1 = allSolidImpacts.Wind_Vertices[n1][2];

            float x2 = allSolidImpacts.Wind_Vertices[n2][0];
            float y2 = allSolidImpacts.Wind_Vertices[n2][1];
            float z2 = allSolidImpacts.Wind_Vertices[n2][2];


            float _val = allWindFlows.pallet_MLT * allSolidImpacts.Wind_Vertices[n1][3]; // startpoint value = endpoint value <<<<<<<<<<

            float _u = 0.5 + 0.5 * (PAL_multiplier * _val);
            if (PAL_direction == -1) _u = 1 - _u;
            if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
            if (PAL_direction == 2) _u =  0.5 * _u;

            float the_dist = dist(x1, y1, z1, x2, y2, z2);

            float[] W = {
              x2 - x1, y2 - y1, z2 - z1
            };
            W = funcs.vec3_unit(W);

            float Alpha = funcs.asin_ang(W[2]);
            float Beta = funcs.atan2_ang(W[1], W[0]) + 90;


            if (_turn == 1) {

              SOLARCHVISION_OBJprintVertex(x1, y1, z1);
              SOLARCHVISION_OBJprintVertex(x2, y2, z2);

              for (int i = 0; i < 4; i++) {

                float px = 0.1 * the_dist * cos(i * HALF_PI);
                float py = 0;
                float pz = 0.1 * the_dist * sin(i * HALF_PI);

                float pz_rot = pz;
                float px_rot = px * funcs.cos_ang(Beta) - py * funcs.sin_ang(Beta);
                float py_rot = px * funcs.sin_ang(Beta) + py * funcs.cos_ang(Beta);

                px = px_rot;
                py = py_rot;
                pz = pz_rot;

                px_rot = px;
                py_rot = py * funcs.cos_ang(Alpha) - pz * funcs.sin_ang(Alpha);
                pz_rot = py * funcs.sin_ang(Alpha) + pz * funcs.cos_ang(Alpha);

                px = px_rot;
                py = py_rot;
                pz = pz_rot;

                SOLARCHVISION_OBJprintVertex(x1 + px, y1 + py, z1 + pz);
              }
            }


            if (_turn == 2) {
              for (int i = 0; i < 6; i++) {

                float u1 = 0.5 * (_u + 0.5);

                if (u1 > 0.999) u1 = 0.999;
                if (u1 < 0.001) u1 = 0.001;

                SOLARCHVISION_OBJprintVtexture(u1, 0.5, 0);
              }
            }

            if (_turn == 3) {
              num_vertices_added += 6;

              String n1_txt = nf(obj_lastVertexNumber + num_vertices_added - 5, 0);
              String n2_txt = nf(obj_lastVertexNumber + num_vertices_added - 4, 0);
              String n3_txt = nf(obj_lastVertexNumber + num_vertices_added - 3, 0);
              String n4_txt = nf(obj_lastVertexNumber + num_vertices_added - 2, 0);
              String n5_txt = nf(obj_lastVertexNumber + num_vertices_added - 1, 0);
              String n6_txt = nf(obj_lastVertexNumber + num_vertices_added - 0, 0);

              String m1_txt = nf(obj_lastVtextureNumber + num_vertices_added - 5, 0);
              String m2_txt = nf(obj_lastVtextureNumber + num_vertices_added - 4, 0);
              String m3_txt = nf(obj_lastVtextureNumber + num_vertices_added - 3, 0);
              String m4_txt = nf(obj_lastVtextureNumber + num_vertices_added - 2, 0);
              String m5_txt = nf(obj_lastVtextureNumber + num_vertices_added - 1, 0);
              String m6_txt = nf(obj_lastVtextureNumber + num_vertices_added - 0, 0);

              objOutput.println("f " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
              objOutput.println("f " + n2_txt + "/" + m2_txt + " " + n4_txt + "/" + m4_txt + " " + n5_txt + "/" + m5_txt);
              objOutput.println("f " + n2_txt + "/" + m2_txt + " " + n5_txt + "/" + m5_txt + " " + n6_txt + "/" + m6_txt);
              objOutput.println("f " + n2_txt + "/" + m2_txt + " " + n6_txt + "/" + m6_txt + " " + n3_txt + "/" + m3_txt);

              obj_lastFaceNumber += 4;
            }
          }
        }

        obj_lastVertexNumber += num_vertices_added;
        obj_lastVtextureNumber += num_vertices_added;
      }




      if (target_window == TypeWindow.WIN3D) {


        for (int q = 0; q < allSolidImpacts.Wind_Lines.length; q++) {

          int n1 = allSolidImpacts.Wind_Lines[q][0];
          int n2 = allSolidImpacts.Wind_Lines[q][1];

          float x1 = allSolidImpacts.Wind_Vertices[n1][0];
          float y1 = allSolidImpacts.Wind_Vertices[n1][1];
          float z1 = allSolidImpacts.Wind_Vertices[n1][2];

          float x2 = allSolidImpacts.Wind_Vertices[n2][0];
          float y2 = allSolidImpacts.Wind_Vertices[n2][1];
          float z2 = allSolidImpacts.Wind_Vertices[n2][2];


          float _val = this.pallet_MLT * allSolidImpacts.Wind_Vertices[n1][3]; // startpoint value = endpoint value <<<<<<<<<<

          float _u = 0.5 + 0.5 * (PAL_multiplier * _val);
          if (PAL_direction == -1) _u = 1 - _u;
          if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
          if (PAL_direction == 2) _u =  0.5 * _u;

          float[] COL = PAINT.getColorStyle(PAL_type, _u);

          /*
           WIN3D.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);
           WIN3D.graphics.fill(COL[1], COL[2], COL[3], COL[0]);

           WIN3D.graphics.strokeWeight(1);
           WIN3D.graphics.line(x1 * OBJECTS_scale * WIN3D.scale, -y1 * OBJECTS_scale * WIN3D.scale, z1 * OBJECTS_scale * WIN3D.scale, x2 * OBJECTS_scale * WIN3D.scale, -y2 * OBJECTS_scale * WIN3D.scale, z2 * OBJECTS_scale * WIN3D.scale);

           WIN3D.graphics.strokeWeight(4);
           WIN3D.graphics.line(x1 * OBJECTS_scale * WIN3D.scale, -y1 * OBJECTS_scale * WIN3D.scale, z1 * OBJECTS_scale * WIN3D.scale, 0.5 * (x2 + x1) * OBJECTS_scale * WIN3D.scale, -0.5 * (y2 + y1) * OBJECTS_scale * WIN3D.scale, 0.5 * (z2 + z1) * OBJECTS_scale * WIN3D.scale);
           */


          float the_dist = dist(x1, y1, z1, x2, y2, z2);

          float[] W = {
            x2 - x1, y2 - y1, z2 - z1
          };
          W = funcs.vec3_unit(W);

          float Alpha = funcs.asin_ang(W[2]);
          float Beta = funcs.atan2_ang(W[1], W[0]) + 90;

          WIN3D.graphics.fill(COL[1], COL[2], COL[3], 127);
          WIN3D.graphics.noStroke();

          for (int i = 0; i < 4; i++) {

            WIN3D.graphics.beginShape();

            WIN3D.graphics.vertex(x2 * OBJECTS_scale * WIN3D.scale, -y2 * OBJECTS_scale * WIN3D.scale, z2 * OBJECTS_scale * WIN3D.scale);

            for (int j = 0; j < 2; j++) {

              float px = 0.1 * the_dist * cos((i + j) * HALF_PI);
              float py = 0;
              float pz = 0.1 * the_dist * sin((i + j) * HALF_PI);

              float pz_rot = pz;
              float px_rot = px * funcs.cos_ang(Beta) - py * funcs.sin_ang(Beta);
              float py_rot = px * funcs.sin_ang(Beta) + py * funcs.cos_ang(Beta);

              px = px_rot;
              py = py_rot;
              pz = pz_rot;

              px_rot = px;
              py_rot = py * funcs.cos_ang(Alpha) - pz * funcs.sin_ang(Alpha);
              pz_rot = py * funcs.sin_ang(Alpha) + pz * funcs.cos_ang(Alpha);

              px = px_rot;
              py = py_rot;
              pz = pz_rot;

              WIN3D.graphics.vertex((x1 + px) * OBJECTS_scale * WIN3D.scale, -(y1 + py) * OBJECTS_scale * WIN3D.scale, (z1 + pz) * OBJECTS_scale * WIN3D.scale);
            }

            WIN3D.graphics.endShape(CLOSE);
          }
        }


        WIN3D.graphics.strokeWeight(0);
      }


    }
  }


  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setBoolean(parent, "displayAll", this.displayAll);

    XML_setInt(parent, "pallet_CLR", this.pallet_CLR);
    XML_setInt(parent, "pallet_DIR", this.pallet_DIR);
    XML_setFloat(parent, "pallet_MLT", this.pallet_MLT);

  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.displayAll = XML_getBoolean(parent, "displayAll");

    this.pallet_CLR = XML_getInt(parent, "pallet_CLR");
    this.pallet_DIR = XML_getInt(parent, "pallet_DIR");
    this.pallet_MLT = XML_getFloat(parent, "pallet_MLT");

  }
}
