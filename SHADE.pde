class solarchvision_SHADE {

  private final static String CLASS_STAMP = "SHADE";

  private final static int Surface_Wire       = -1;
  private final static int Surface_Base       = 0;
  private final static int Surface_White      = 1;
  private final static int Surface_Materials  = 2;
  private final static int Global_Solar       = 3;
  private final static int Vertex_Solar       = 4;
  private final static int Vertex_Solid       = 5;
  private final static int Vertex_Elevation   = 6;
  private final static int Options_num        = 7;

  float applyPalDirection (float u, int PAL_direction) {
    if (PAL_direction == -1) return 1 - u;
    if (PAL_direction == -2) return 0.5 - 0.5 * u;
    if (PAL_direction == 2)  return 0.5 * u;
    return u;
  }

  float impactValueToU (float val, float PAL_multiplier) {
    float _u = FLOAT_undefined;
    if (WIN3D.Impact_TYPE == Impact_ACTIVE)  _u = (0.1 * PAL_multiplier * val);
    if (WIN3D.Impact_TYPE == Impact_PASSIVE) _u = 0.5 + 0.5 * (0.1 * PAL_multiplier * val);
    return _u;
  }

  float[] vertexRender_Surface_White (int c) {
    return new float[] { c, c, c, c };
  }

  float[] vertexRender_Surface_Materials (int mt) {
    return new float[] {
      allMaterials.Color[mt][0], allMaterials.Color[mt][1],
      allMaterials.Color[mt][2], allMaterials.Color[mt][3]
    };
  }

  float[] vertexRender_Vertex_Solar (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float _u = this.vertexU_Vertex_Solar(VERTEX_now, VERTEX_prev, VERTEX_next, PAL_type, PAL_direction, PAL_multiplier);
    float[] COL = {0, 0, 0, 0}; // default color for undefined values
    if (is_defined(_u)) {
      COL = PAINT.getColorStyle(PAL_type, _u);
    }
    return COL;
  }

  float vertexU_Vertex_Solar (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float val = this.get_SolarImpact_atXYZ(
      VERTEX_now[0],  VERTEX_now[1],  VERTEX_now[2],
      VERTEX_prev[0], VERTEX_prev[1], VERTEX_prev[2],
      VERTEX_next[0], VERTEX_next[1], VERTEX_next[2]
    );
    float _u = FLOAT_undefined;
    if (is_defined(val)) {
      _u = this.applyPalDirection(this.impactValueToU(val, PAL_multiplier), PAL_direction);
    }
    return _u;
  }

  float get_SolarImpact_atXYZ (float x, float y, float z, float x2, float y2, float z2, float x3, float y3, float z3) {
    float v = FLOAT_undefined;
    int q = this.findID_SolarImpact_atXYZ(x, y, z, x2, y2, z2, x3, y3, z3);
    if (q >= 0) {
      v = VertexSolar_amounts[WIN3D.Impact_TYPE][IMPACTS_displayDay][q];
    }
    return v;
  }

  int findID_SolarImpact_atXYZ (float x, float y, float z, float x2, float y2, float z2, float x3, float y3, float z3) {
    for (int q = 0; q < VertexSolar_XYZ.length; q++) {
      float[] row = VertexSolar_XYZ[q];
      if (row[0] == x  && row[1] == y  && row[2] == z  &&
          row[3] == x2 && row[4] == y2 && row[5] == z2 &&
          row[6] == x3 && row[7] == y3 && row[8] == z3) {
        return q;
      }
    }
    return -1;
  }

  float[] vertexRender_Vertex_Solid (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float _u = this.vertexU_Vertex_Solid(VERTEX_now, PAL_type, PAL_direction, PAL_multiplier);
    return PAINT.getColorStyle(PAL_type, _u);
  }

  float vertexU_Vertex_Solid (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {
    allSolidImpacts.complex = 0;
    float val = allSolidImpacts.get_Impact_atXYZ(VERTEX_now[0], VERTEX_now[1], VERTEX_now[2]);
    float _u = 0.5 + 0.5 * (PAL_multiplier * val);
    return this.applyPalDirection(_u, PAL_direction);
  }

  float[] vertexRender_Vertex_Elevation (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float _u = this.vertexU_Vertex_Elevation(VERTEX_now, PAL_type, PAL_direction, PAL_multiplier);
    return PAINT.getColorStyle(PAL_type, _u);
  }

  float vertexU_Vertex_Elevation (float[] VERTEX_now, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float _u = 0.5 + 0.5 * (PAL_multiplier * VERTEX_now[2]);
    return this.applyPalDirection(_u, PAL_direction);
  }

  float[] vertexRender_Global_Solar (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next, int PAL_type, int PAL_direction, float PAL_multiplier) {
    float _u = this.vertexU_Global_Solar(VERTEX_now, VERTEX_prev, VERTEX_next, PAL_type, PAL_direction, PAL_multiplier);
    float[] COL = {63, 63, 63, 127}; // default color for undefined values
    if (is_defined(_u)) {
      COL = PAINT.getColorStyle(PAL_type, _u);
    }
    return COL;
  }

  int[] get_SkyBucket (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next) {
    PVector U = new PVector(VERTEX_next[0] - VERTEX_now[0], VERTEX_next[1] - VERTEX_now[1], VERTEX_next[2] - VERTEX_now[2]);
    PVector V = new PVector(VERTEX_prev[0] - VERTEX_now[0], VERTEX_prev[1] - VERTEX_now[1], VERTEX_prev[2] - VERTEX_now[2]);
    PVector UV = U.cross(V);

    float[] W = { UV.x, UV.y, UV.z };
    W = funcs.vec3_unit(W);

    float Alpha = funcs.asin_ang(W[2]);
    float Beta  = funcs.atan2_ang(W[1], W[0]) + 90;

    int slopeSteps = int(180 / Sky3D.stp_slp);
    int dirSteps   = int(360 / Sky3D.stp_dir);

    int a = int((Alpha + 90) / Sky3D.stp_slp);
    int b = int(Beta / Sky3D.stp_dir);

    if (a < 0) a += slopeSteps;
    if (b < 0) b += dirSteps;
    if (a > slopeSteps) a -= slopeSteps;
    if (b > dirSteps)   b -= dirSteps;

    return new int[] { a, b };
  }

  float vertexU_Global_Solar (float[] VERTEX_now, float[] VERTEX_prev, float[] VERTEX_next, int PAL_type, int PAL_direction, float PAL_multiplier) {
    int[] bucket = this.get_SkyBucket(VERTEX_now, VERTEX_prev, VERTEX_next);
    float valuesSUM = GlobalSolar[WIN3D.Impact_TYPE][IMPACTS_displayDay][bucket[0]][bucket[1]];

    float _u = FLOAT_undefined;
    if (is_defined(valuesSUM)) {
      _u = this.applyPalDirection(this.impactValueToU(valuesSUM, PAL_multiplier), PAL_direction);
    }
    return _u;
  }

  boolean isSolarImpactShade () {
    return (WIN3D.FacesShade == SHADE.Global_Solar) || (WIN3D.FacesShade == SHADE.Vertex_Solar);
  }

  int get_PAL_type () {
    int PAL_type = 0;
    if (isSolarImpactShade()) {
      if (WIN3D.Impact_TYPE == Impact_ACTIVE)  PAL_type = allFaces.ACTIVE_palette_CLR;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_type = allFaces.PASSIVE_palette_CLR;
    }
    if (WIN3D.FacesShade == SHADE.Vertex_Solid)     PAL_type = allSolids.palette_CLR;
    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) PAL_type = Land3D.palette_CLR;
    return PAL_type;
  }

  int get_PAL_direction () {
    int PAL_direction = 1;
    if (isSolarImpactShade()) {
      if (WIN3D.Impact_TYPE == Impact_ACTIVE)  PAL_direction = allFaces.ACTIVE_palette_DIR;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_direction = allFaces.PASSIVE_palette_DIR;
    }
    if (WIN3D.FacesShade == SHADE.Vertex_Solid)     PAL_direction = allSolids.palette_DIR;
    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) PAL_direction = Land3D.palette_DIR;
    return PAL_direction;
  }

  float get_PAL_multiplier () {
    float PAL_multiplier = 1;
    if (isSolarImpactShade()) {
      if (WIN3D.Impact_TYPE == Impact_ACTIVE)  PAL_multiplier = allFaces.ACTIVE_palette_MLT;
      if (WIN3D.Impact_TYPE == Impact_PASSIVE) PAL_multiplier = allFaces.PASSIVE_palette_MLT;
    }
    if (WIN3D.FacesShade == SHADE.Vertex_Solid)     PAL_multiplier = allSolids.palette_MLT;
    if (WIN3D.FacesShade == SHADE.Vertex_Elevation) PAL_multiplier = Land3D.palette_MLT;
    return PAL_multiplier;
  }

}
