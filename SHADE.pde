class solarchvision_SHADE {

  private final static String CLASS_STAMP = "SHADE";

  private final static int Surface_Wire = -1;
  private final static int Surface_Base = 0;
  private final static int Surface_White = 1;
  private final static int Surface_Materials = 2;
  private final static int Global_Solar = 3;
  private final static int Vertex_Solar = 4;
  private final static int Vertex_Solid = 5;
  private final static int Vertex_Elevation = 6;

  private final static int Options_num = 7;



  float[] vertexRender_Surface_White (int c) {

    float[] COL = {
      c, c, c, c
    };

    return COL;
  }

  float[] vertexRender_Surface_Materials (int mt) {

    float[] COL = {
      allMaterials.Color[mt][0], allMaterials.Color[mt][1], allMaterials.Color[mt][2], allMaterials.Color[mt][3]
    };

    return COL;
  }


  float[] vertexRender_Vertex_Solar (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {

    float _u = this.vertexU_Vertex_Solar(VERTEX_now, PAL_type, PAL_direction, PAL_multiplier);

    float[] COL = {0,0,0,0}; // default color for undefined values

    if (is_defined(_u)) {
      COL = PAINT.getColorStyle(PAL_type, _u);
    }

    return COL;
  }


  float vertexU_Vertex_Solar (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {

    float val = this.get_SolarImpact_atXYZ(VERTEX_now[0], VERTEX_now[1], VERTEX_now[2]);

    float _u = FLOAT_undefined;

    if (is_defined(val)) {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * val);
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * val);

      if (PAL_direction == -1) _u = 1 - _u;
      if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_direction == 2) _u =  0.5 * _u;
    }

    return _u;
  }


  float get_SolarImpact_atXYZ (float x, float y, float z) {

    float v = FLOAT_undefined;

    int q = this.findID_SolarImpact_atXYZ(x, y, z);

    if (q >= 0) {
      v = VertexSolar_amounts[WIN3D.Impact_TYPE][IMPACTS_displayDay][q];
    }

    return v;
  }


  int findID_SolarImpact_atXYZ (float x, float y, float z) {

    int n = -1;

    for (int q = 0; q < VertexSolar_XYZ.length; q++) {

      if (x == VertexSolar_XYZ[q][0]) {
      if (y == VertexSolar_XYZ[q][1]) {
      if (z == VertexSolar_XYZ[q][2]) {
        n = q;
        break;
      }
      }
      }
    }

    return n;
  }





  float[] vertexRender_Vertex_Solid (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {

    float _u = this.vertexU_Vertex_Solid(VERTEX_now, PAL_type, PAL_direction, PAL_multiplier);

    float[] COL = PAINT.getColorStyle(PAL_type, _u);

    return COL;
  }


  float vertexU_Vertex_Solid (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {

    allSolidImpacts.complex = 0;
    float val = allSolidImpacts.get_Impact_atXYZ(VERTEX_now[0], VERTEX_now[1], VERTEX_now[2]);

    float _u = 0.5 + 0.5 * (PAL_multiplier * val);

    if (PAL_direction == -1) _u = 1 - _u;
    if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
    if (PAL_direction == 2) _u =  0.5 * _u;

    return _u;
  }


  float[] vertexRender_Vertex_Elevation (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {

    float _u = this.vertexU_Vertex_Elevation(VERTEX_now, PAL_type, PAL_direction, PAL_multiplier);

    float[] COL = PAINT.getColorStyle(PAL_type, _u);

    return COL;
  }

  float vertexU_Vertex_Elevation (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {

    float _u = 0.5 + 0.5 * (PAL_multiplier * VERTEX_now[2]);

    if (PAL_direction == -1) _u = 1 - _u;
    if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
    if (PAL_direction == 2) _u =  0.5 * _u;

    return _u;
  }


  float[] vertexRender_Global_Solar (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next, int PAL_type, int PAL_direction, float PAL_multiplier) {

    float _u = this.vertexU_Global_Solar(VERTEX_now, VERTEX_prev, VERTEX_next, PAL_type, PAL_direction, PAL_multiplier);

    float[] COL = {63,63,63,127}; // default color for undefined values

    if (is_defined(_u)) {
      COL = PAINT.getColorStyle(PAL_type, _u);
    }

    return COL;
  }

  float vertexU_Global_Solar (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next, int PAL_type, int PAL_direction, float PAL_multiplier) {

    PVector U = new PVector(VERTEX_next[0] - VERTEX_now[0], VERTEX_next[1] - VERTEX_now[1], VERTEX_next[2] - VERTEX_now[2]);
    PVector V = new PVector(VERTEX_prev[0] - VERTEX_now[0], VERTEX_prev[1] - VERTEX_now[1], VERTEX_prev[2] - VERTEX_now[2]);
    PVector UV = U.cross(V);
    float[] W = {
      UV.x, UV.y, UV.z
    };
    W = funcs.vec3_unit(W);

    float Alpha = funcs.asin_ang(W[2]);
    float Beta = funcs.atan2_ang(W[1], W[0]) + 90;

    int a = int((Alpha + 90) / Sky3D.stp_slp);
    int b = int(Beta / Sky3D.stp_dir);

    if (a < 0) a += int(180 / Sky3D.stp_slp);
    if (b < 0) b += int(360 / Sky3D.stp_dir);
    if (a > int(180 / Sky3D.stp_slp)) a -= int(180 / Sky3D.stp_slp);
    if (b > int(360 / Sky3D.stp_dir)) b -= int(360 / Sky3D.stp_dir);

    float valuesSUM = GlobalSolar[WIN3D.Impact_TYPE][IMPACTS_displayDay][a][b];

    float _u = FLOAT_undefined;

    if (is_defined(valuesSUM)) {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) _u = (0.1 * PAL_multiplier * valuesSUM);
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * valuesSUM);

      if (PAL_direction == -1) _u = 1 - _u;
      if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
      if (PAL_direction == 2) _u =  0.5 * _u;
    }

    return _u;
  }



  int get_PAL_type () {

    int PAL_type = 0;

    if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
        (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) PAL_type = allFaces.ACTIVE_palette_CLR;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_type = allFaces.PASSIVE_palette_CLR;
    }

    if (WIN3D.FacesShade == SHADE.Vertex_Solid) {
      PAL_type = allSolids.palette_CLR;
    }

    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) {
      PAL_type = Land3D.palette_CLR;
    }

    return PAL_type;
  }


  int get_PAL_direction () {

    int PAL_direction = 1;

    if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
        (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) PAL_direction = allFaces.ACTIVE_palette_DIR;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_direction = allFaces.PASSIVE_palette_DIR;
    }

    if (WIN3D.FacesShade == SHADE.Vertex_Solid) {
      PAL_direction = allSolids.palette_DIR;
    }

    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) {
      PAL_direction = Land3D.palette_DIR;
    }

    return PAL_direction;
  }


  float get_PAL_multiplier () {

    float PAL_multiplier = 1;

    if ((WIN3D.FacesShade == SHADE.Global_Solar) ||
        (WIN3D.FacesShade == SHADE.Vertex_Solar)) {

      if (WIN3D.Impact_TYPE == Impact_ACTIVE) PAL_multiplier = allFaces.ACTIVE_palette_MLT;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_multiplier = allFaces.PASSIVE_palette_MLT;
    }

    if (WIN3D.FacesShade == SHADE.Vertex_Solid) {
      PAL_multiplier = allSolids.palette_MLT;
    }

    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) {
      PAL_multiplier = Land3D.palette_MLT;
    }

    return PAL_multiplier;
  }


}
