import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;

// Sky3D.writeFaceOBJ() (sky3D.pde) was untested - 160 instructions -
// scoped out of several earlier rounds this session for needing a
// properly-allocated GlobalSolar array (its own u-coordinate comes from
// SHADE.vertexU_Global_Solar() -> get_SkyBucket(), which reads
// GlobalSolar[impactTypeIndex][impactDisplayDay][a][b] directly).
//
// Unlocked here by calling GlobalSolar_resize_array() directly - the
// exact same production allocation calculate_GlobalSolar_array() itself
// uses (SolarArraySmokeTest.java's own target) - which does two things
// a hand-rolled allocation would have to get right independently:
// correctly sizes GlobalSolar itself, and computes Sky3D.inclinationStep/
// orientationStep/inclinationCount/orientationCount from Sky3D.
// calculatedResolution. Those four fields are all 0 by their own bare-
// construction default (no initializer), which would otherwise make
// get_SkyBucket()'s own "(Alpha + 90) / Sky3D.inclinationStep" divide by
// zero.
//
// Rather than hand-deriving get_SkyBucket()'s own geometric bucket-index
// math (a cross product of two edge vectors, normalized, converted to
// inclination/orientation angles) to know exactly which GlobalSolar
// cell a given subFace triangle lands in, every cell in GlobalSolar
// [Impact_ACTIVE][0] is filled with the same constant value below -
// so whichever bucket get_SkyBucket() actually picks, the result is
// identical and already known, sidestepping that derivation entirely
// while still exercising the real function end to end.
class SkyWriteFaceObjTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new StringWriter();

    app.GlobalSolar_resize_array(); // see this file's own header comment on why this, not a hand-rolled allocation
    for (int a = 0; a < app.Sky3D.inclinationCount; a++) {
      for (int b = 0; b < app.Sky3D.orientationCount; b++) {
        // WIN3D.impactTypeIndex/impactDisplayDay's own bare-construction
        // defaults (Impact_ACTIVE, 0).
        app.GlobalSolar[app.Impact_ACTIVE][0][a][b] = 2.5f;
      }
    }

    app.WIN3D.scale = 1; // its own bare-construction default is 0 (uninitialized) - would make every vertex collapse to (0,0,0) otherwise
  }

  // A simple, well-separated triangle - its exact normal/bucket doesn't
  // matter (every bucket holds the same value), just that it's a real,
  // non-degenerate triangle get_SkyBucket()'s own cross product can work
  // with.
  private float[][] triangle () {
    return new float[][]{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
  }

  @Test
  void turn1_writesTheRealVertexLines () {
    app.objOutput = new PrintWriter(captured);

    app.Sky3D.writeFaceOBJ(triangle(), 1, 0, 0, 1f);
    app.objOutput.flush();

    // x/y/z = subFace * Sky3D.radius(50000) * Sky3D.scale(1.1) *
    // WIN3D.scale(1) = subFace * 55000; exporterYaxisUp's own default
    // (1): "v " + (-x) + " " + z + " " + y.
    String expected =
        "v -55000.000000 165000.000000 110000.000000" + EOL +
        "v -220000.000000 330000.000000 275000.000000" + EOL +
        "v -385000.000000 495000.000000 440000.000000" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void turn2_writesTheRealTextureCoordinateLines () {
    app.objOutput = new PrintWriter(captured);

    app.Sky3D.writeFaceOBJ(triangle(), 2, 0, 0, 1f);
    app.objOutput.flush();

    // Every GlobalSolar cell holds 2.5: impactValueToU(2.5, PAL_multiplier=1)
    // with impactTypeIndex's own default (Impact_ACTIVE) -> 0.2*1*2.5 =
    // 0.5; applyPalDirection(0.5, PAL_direction=0) -> 0.5 unchanged
    // (0 matches none of -1/-2/2's own special cases). u1 = 0.5*(0.5+0.5)
    // = 0.5; WIN3D.shadingMode's own default (SHADE.Surface_Materials)
    // isn't Global_Solar/Vertex_Solar, so the "solarShade" override never
    // fires - u1 stays 0.5, already inside constrain()'s [0.001,0.999].
    String expected =
        "vt 0.5000 0.5000 0.0000" + EOL +
        "vt 0.5000 0.5000 0.0000" + EOL +
        "vt 0.5000 0.5000 0.0000" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void turn3_incrementsTheVertexCounter_andDispatchesToWriteSkyPatternObjFace () {
    app.objOutput = new PrintWriter(captured);
    app.num_vertices_added = 0;

    app.Sky3D.writeFaceOBJ(triangle(), 3, 0, 0, 1f);
    app.objOutput.flush();

    assertEquals(3, app.num_vertices_added, "one increment per vertex in the triangle");
    // writeSkyPatternObjFace()'s own real output is already verified
    // directly in ObjVertexWritersTest.java - this just confirms turn 3
    // actually reaches it.
    assertTrue(captured.toString().startsWith("f "));
  }
}
