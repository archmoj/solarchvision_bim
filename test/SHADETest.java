import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Every method here is pure computation (no fill()/stroke()/text() or other
// rendering calls), unlike most of the WIN3D/UI_* classes this suite is
// otherwise careful about. get_SkyBucket()/vertexU_Global_Solar() and
// vertexU_Vertex_Solid() pull in PVector cross products and
// allSolidImpacts/GlobalSolar array setup that's easy to get subtly wrong
// without deeper knowledge of those data shapes, so they're left for a
// follow-up rather than guessed at here.
class SHADETest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= impactValueToU ========================================

  @Test
  void impactValueToU_activeImpact_usesASimpleLinearFormula () {
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    float u = app.SHADE.impactValueToU(2, 3); // 0.1 * 3 * 2
    assertEquals(0.6f, u, 0.0001f);
  }

  @Test
  void impactValueToU_passiveImpact_usesAnOffsetFormula () {
    app.WIN3D.impactTypeIndex = app.Impact_PASSIVE;
    float u = app.SHADE.impactValueToU(2, 3); // 0.5 + 0.5 * (0.1 * 3 * 2)
    assertEquals(0.8f, u, 0.0001f);
  }

  // ================= vertexRender_Surface_White / _Materials ===============

  @Test
  void vertexRenderSurfaceWhite_repeatsTheSameGrayInAllFourChannels () {
    float[] col = app.SHADE.vertexRender_Surface_White(200);
    assertArrayEquals(new float[]{200, 200, 200, 200}, col, 0.0001f);
  }

  @Test
  void vertexRenderSurfaceMaterials_returnsTheFixedColorForMaterialZero () {
    float[] col = app.SHADE.vertexRender_Surface_Materials(0);
    assertArrayEquals(new float[]{255, 255, 127, 0}, col, 0.0001f);
  }

  // ================= findID_SolarImpact_atXYZ / get_SolarImpact_atXYZ ======

  @Test
  void findIDSolarImpactAtXYZ_returnsTheMatchingRowIndex () {
    app.VertexSolar_XYZ = new float[][] {
      {1, 2, 3, 4, 5, 6, 7, 8, 9},
      {0, 0, 0, 0, 0, 0, 0, 0, 0}
    };

    int id = app.SHADE.findID_SolarImpact_atXYZ(0, 0, 0, 0, 0, 0, 0, 0, 0);

    assertEquals(1, id);
  }

  @Test
  void findIDSolarImpactAtXYZ_returnsMinusOneWhenNoRowMatches () {
    app.VertexSolar_XYZ = new float[][] { {1, 2, 3, 4, 5, 6, 7, 8, 9} };

    int id = app.SHADE.findID_SolarImpact_atXYZ(9, 9, 9, 9, 9, 9, 9, 9, 9);

    assertEquals(-1, id);
  }

  @Test
  void getSolarImpactAtXYZ_returnsTheStoredAmountForAMatchingVertex () {
    app.VertexSolar_XYZ = new float[][] { {1, 2, 3, 4, 5, 6, 7, 8, 9} };
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.impactDisplayDay = 0;
    app.VertexSolar_amounts = new float[][][] { { {42} }, { {0} } }; // [impactTypeIndex][displayDay][q]

    float v = app.SHADE.get_SolarImpact_atXYZ(1, 2, 3, 4, 5, 6, 7, 8, 9);

    assertEquals(42f, v, 0.0001f);
  }

  @Test
  void getSolarImpactAtXYZ_returnsUndefinedWhenNoVertexMatches () {
    app.VertexSolar_XYZ = new float[0][9];

    float v = app.SHADE.get_SolarImpact_atXYZ(1, 2, 3, 4, 5, 6, 7, 8, 9);

    assertFalse(app.is_defined(v));
  }

  // ================= vertexU_Vertex_Elevation ===============================

  @Test
  void vertexUVertexElevation_computesFromZWithNoDirectionChange () {
    float[] v = {0, 0, 4};
    // 0.5 + 0.5 * (0.5 * 4) = 1.5, PAL_direction 1 leaves it unchanged
    float u = app.SHADE.vertexU_Vertex_Elevation(v, 0, 1, 0.5f);
    assertEquals(1.5f, u, 0.0001f);
  }

  @Test
  void vertexUVertexElevation_appliesTheInvertedDirection () {
    float[] v = {0, 0, 4};
    // base is 1.5 as above, PAL_direction -1 maps it to 1 - 1.5
    float u = app.SHADE.vertexU_Vertex_Elevation(v, 0, -1, 0.5f);
    assertEquals(-0.5f, u, 0.0001f);
  }

  // ================= isSolarImpactShade ====================================

  @Test
  void isSolarImpactShade_trueForGlobalSolar () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    assertTrue(app.SHADE.isSolarImpactShade());
  }

  @Test
  void isSolarImpactShade_trueForVertexSolar () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solar;
    assertTrue(app.SHADE.isSolarImpactShade());
  }

  @Test
  void isSolarImpactShade_falseForAnyOtherShadeMode () {
    app.WIN3D.shadingMode = app.SHADE.Surface_Materials;
    assertFalse(app.SHADE.isSolarImpactShade());
  }

  // ================= get_PAL_type / direction / multiplier =================

  @Test
  void getPALType_usesTheActivePaletteForSolarShadeAndActiveImpact () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.allFaces.activeColorscaleIndex = 19;

    assertEquals(19, app.SHADE.get_PAL_type());
  }

  @Test
  void getPALType_usesThePassivePaletteForSolarShadeAndPassiveImpact () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solar;
    app.WIN3D.impactTypeIndex = app.Impact_PASSIVE;
    app.allFaces.passiveColorscaleIndex = 1;

    assertEquals(1, app.SHADE.get_PAL_type());
  }

  @Test
  void getPALType_usesTheSolidsPaletteForVertexSolidShade () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solid;
    app.allSolids.colorScaleIndex = 17;

    assertEquals(17, app.SHADE.get_PAL_type());
  }

  @Test
  void getPALType_usesTheTerrainPaletteForVertexElevationShade () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Elevation;
    app.Terrain.colorScaleIndex = 3;

    assertEquals(3, app.SHADE.get_PAL_type());
  }

  @Test
  void getPALType_isZeroForAPlainSurfaceShadeMode () {
    app.WIN3D.shadingMode = app.SHADE.Surface_White;
    assertEquals(0, app.SHADE.get_PAL_type());
  }

  @Test
  void getPALDirection_usesTheActivePaletteForSolarShadeAndActiveImpact () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.allFaces.activeColorscaleDirection = 1;

    assertEquals(1, app.SHADE.get_PAL_direction());
  }

  @Test
  void getPALDirection_usesTheSolidsPaletteForVertexSolidShade () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solid;
    app.allSolids.colorScaleDirection = -1;

    assertEquals(-1, app.SHADE.get_PAL_direction());
  }

  @Test
  void getPALDirection_defaultsToOneForAPlainSurfaceShadeMode () {
    app.WIN3D.shadingMode = app.SHADE.Surface_White;
    assertEquals(1, app.SHADE.get_PAL_direction());
  }

  @Test
  void getPALMultiplier_usesTheActivePaletteForSolarShadeAndActiveImpact () {
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;
    app.WIN3D.impactTypeIndex = app.Impact_ACTIVE;
    app.allFaces.activeColorscaleFactor = 1;

    assertEquals(1f, app.SHADE.get_PAL_multiplier(), 0.0001f);
  }

  @Test
  void getPALMultiplier_usesTheSolidsPaletteForVertexSolidShade () {
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solid;
    app.allSolids.colorScaleFactor = 0.5f;

    assertEquals(0.5f, app.SHADE.get_PAL_multiplier(), 0.0001f);
  }

  @Test
  void getPALMultiplier_defaultsToOneForAPlainSurfaceShadeMode () {
    app.WIN3D.shadingMode = app.SHADE.Surface_White;
    assertEquals(1f, app.SHADE.get_PAL_multiplier(), 0.0001f);
  }
}
