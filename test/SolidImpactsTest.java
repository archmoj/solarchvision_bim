import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class SolidImpactsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= calculate_Impact_atXYZ_simple ========================

  @Test
  void calculateImpactAtXYZSimple_isAConstantOneWhenThereAreNoSolids () {
    app.allSolids.DEF = new float[0][13];
    assertEquals(1f, app.allSolidImpacts.calculate_Impact_atXYZ_simple(2, 0, 0), 0.0001f);
  }

  @Test
  void calculateImpactAtXYZSimple_combinesDistanceAndThresholdForOneSolid () {
    // A unit sphere (pow=2,2,2, scale=1,1,1, no rotation) with its own
    // "value" (radius threshold) set to 1, evaluated at (2,0,0) - where
    // get_Distance() (verified directly in SolidsTest.java) returns
    // exactly 2. With the default Power=1: d *= d^(Power/1) = d*d = 4;
    // val = 1*(4-1) = 3; the length-1 normalization (pow(x,1)) leaves it
    // unchanged - re-derived independently in Python before writing this.
    app.allSolids.DEF = new float[][]{
      {0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 1} // posXYZ=0, pow=2,2,2, scale=1,1,1, rot=0,0,0, value=1
    };
    app.allSolidImpacts.Power = 1f;

    assertEquals(3f, app.allSolidImpacts.calculate_Impact_atXYZ_simple(2, 0, 0), 0.001f);
  }

  // ================= calculate_Impact_atXYZ_complex ========================

  @Test
  void calculateImpactAtXYZComplex_isZeroWhenWindSpeedIsZero () {
    // With no wind offset, both sampled points are identical, so the
    // "downwind minus upwind" difference is exactly 0 regardless of the
    // scene.
    app.allSolids.DEF = new float[][]{{0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 1}};
    app.allSolidImpacts.WindSpeed = 0;
    app.allSolidImpacts.WindDirection = 180;
    app.allSolidImpacts.Power = 1f;

    assertEquals(0f, app.allSolidImpacts.calculate_Impact_atXYZ_complex(2, 0, 0), 0.0001f);
  }

  @Test
  void calculateImpactAtXYZComplex_isTheDifferenceBetweenTheDownwindAndUpwindValues () {
    // WindDirection=0 -> deltaX=+WindSpeed, deltaY=0, so the "downwind"
    // sample point o=1 is offset by (+1, 0, 0) from (2,0,0) -> (3,0,0).
    // get_Distance(3,0,0)=3, so with Power=1: d=3*3=9, val1=9-1=8.
    // val0 (at (2,0,0), same as the simple-case test above) is 3.
    // Result = val1 - val0 = 8 - 3 = 5 - re-derived independently in
    // Python before writing this.
    app.allSolids.DEF = new float[][]{{0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 1}};
    app.allSolidImpacts.WindSpeed = 1;
    app.allSolidImpacts.WindDirection = 0;
    app.allSolidImpacts.Power = 1f;

    assertEquals(5f, app.allSolidImpacts.calculate_Impact_atXYZ_complex(2, 0, 0), 0.001f);
  }

  // ================= get_Impact_atXYZ dispatch =============================

  @Test
  void getImpactAtXYZ_dispatchesToSimpleOrComplexBasedOnTheComplexFlag () {
    app.allSolids.DEF = new float[][]{{0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 1}};
    app.allSolidImpacts.Power = 1f;

    app.allSolidImpacts.complex = 0;
    assertEquals(
      app.allSolidImpacts.calculate_Impact_atXYZ_simple(2, 0, 0),
      app.allSolidImpacts.get_Impact_atXYZ(2, 0, 0), 0.0001f);

    app.allSolidImpacts.complex = 1;
    app.allSolidImpacts.WindSpeed = 1;
    app.allSolidImpacts.WindDirection = 0;
    assertEquals(
      app.allSolidImpacts.calculate_Impact_atXYZ_complex(2, 0, 0),
      app.allSolidImpacts.get_Impact_atXYZ(2, 0, 0), 0.0001f);
  }

  // ================= calculate_ImpactOnSections =====================

  @Test
  void calculateImpactSelectedSections_isANoOpWhenNothingIsSelected () {
    app.Select3D.sectionSelection = new int[]{};
    // If this reached calculate_Impact_CurrentSection() it would throw
    // on cursor() - reaching the end of this call without an exception
    // IS the assertion here.
    app.allSolidImpacts.calculate_ImpactOnSections();
  }

  // ================= to_XML / from_XML round trip ==========================

  @Test
  void toXMLThenFromXML_roundTripsScalarFields () {
    app.allSolidImpacts.WindSpeed = 8;
    app.allSolidImpacts.WindDirection = 90;
    app.allSolidImpacts.Power = 2;
    app.allSolidImpacts.displayPoints = true;
    app.allSolidImpacts.displayLines = false;
    app.allSolidImpacts.ResX = 100;
    app.allSolidImpacts.ResY = 120;
    app.allSolidImpacts.Grade = 0.05f;
    app.allSolidImpacts.displayImage = false;
    app.allSolidImpacts.sectionType = 1;
    app.allSolidImpacts.positionStep = 2.5f;
    app.allSolidImpacts.Process_subDivisions = 2;
    app.allSolidImpacts.deltaStep = 0.1f;
    app.allSolidImpacts.deltaLines = 0.02f;
    app.allSolidImpacts.MinimumDistance_traceU = 1.5f;
    app.allSolidImpacts.MinimumDistance_traceV = 0.5f;
    app.allSolidImpacts.Z = 1;
    app.allSolidImpacts.RotX = 5;
    app.allSolidImpacts.corners = new float[]{-4.5f, -6.5f, 4.5f, -6.5f, 4.5f, 6.5f, -4.5f, 6.5f};
    app.allSolidImpacts.X = 17;
    app.allSolidImpacts.Y = 21;

    processing.data.XML root = new processing.data.XML("root");
    app.allSolidImpacts.to_XML(root);

    solarchvision_bim.SolidImpacts fresh = app.new SolidImpacts();
    fresh.from_XML(root);

    assertEquals(8f, fresh.WindSpeed, 0.0001f);
    assertEquals(90f, fresh.WindDirection, 0.0001f);
    assertEquals(2f, fresh.Power, 0.0001f);
    assertTrue(fresh.displayPoints);
    assertFalse(fresh.displayLines);
    assertEquals(100, fresh.ResX);
    assertEquals(120, fresh.ResY);
    assertEquals(0.05f, fresh.Grade, 0.0001f);
    assertFalse(fresh.displayImage);
    assertEquals(1, fresh.sectionType);
    assertEquals(1f, fresh.Z, 0.001f);
    assertEquals(5f, fresh.RotX, 0.001f);
    assertEquals(9f, fresh.getSizeX(), 0.001f);
    assertEquals(13f, fresh.getSizeY(), 0.001f);
    assertEquals(17f, fresh.X, 0.001f);
    assertEquals(21f, fresh.Y, 0.001f);
  }
}
