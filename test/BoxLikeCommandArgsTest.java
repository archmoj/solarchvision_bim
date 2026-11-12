import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// boxLikeCommandArgs() (mouseClicked.pde) builds the x/y/z/dx/dy/dz/r
// argument string shared by the Box/Octahedron/Cylinder/Cone/Parametric
// UITASK.Create branches - the same shape as houseCommandArgs() (already
// covered via MouseClickedTest.java's houseCommandArgs_.../
// creatorCommandArgs_... tests) minus the extra h/dh height parameter
// only the houses have. It shares creatorCommandArgs() with
// houseCommandArgs(), which is why that part is fully covered elsewhere -
// but boxLikeCommandArgs() itself had no dedicated test and sat at 0%
// coverage. These test its own string-building directly (it's a pure
// function of its parameters plus User3D's creator* fields), the same way
// SaveImageTest.java tests saveImage.pde's stamp helpers.
class BoxLikeCommandArgsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void boxLikeCommandArgs_withDefaultCreatorSettings_buildsTheExpectedCommandString () {
    // User3D's defaults: creatorMaterial 7, creatorTessellation/Layer/
    // Weight/Closed 0, creatorVisibility 1 (user3D.pde).
    assertEquals(
        " m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=1.0 y=2.0 z=3.0 dx=8.0 dy=10.0 dz=12.0 r=45.0",
        app.boxLikeCommandArgs(1, 2, 3, 4, 5, 6, 45));
  }

  @Test
  void boxLikeCommandArgs_doublesHalfWidthsIntoFullWidths_includingNegativeAndZero () {
    // Same half-width -> full-width doubling houseCommandArgs_
    // doublesHalfWidthsIntoTheFullWidthsTheCommandExpects() (MouseClickedTest.java)
    // already pins for the house commands' dx/dy/dz - here for rx/ry/rz
    // of mixed sign/zero, proving it's a plain "2 *", not e.g. abs() first.
    assertEquals(
        " m=7 tes=0 lyr=0 vsb=1 wgt=0 clz=0 x=0.0 y=0.0 z=0.0 dx=-3.0 dy=5.0 dz=0.0 r=-30.0",
        app.boxLikeCommandArgs(0, 0, 0, -1.5f, 2.5f, 0, -30));
  }

  @Test
  void boxLikeCommandArgs_passesThroughCustomCreatorSettings_notJustTheDefaults () {
    app.User3D.creatorMaterial = 3;
    app.User3D.creatorTessellation = 2;
    app.User3D.creatorLayer = 1;
    app.User3D.creatorVisibility = -1;
    app.User3D.creatorWeight = 5;
    app.User3D.creatorClosed = 1;

    assertEquals(
        " m=3 tes=2 lyr=1 vsb=-1 wgt=5 clz=1 x=1.0 y=1.0 z=1.0 dx=2.0 dy=2.0 dz=2.0 r=0.0",
        app.boxLikeCommandArgs(1, 1, 1, 1, 1, 1, 0));
  }

  @Test
  void boxLikeCommandArgs_sharesCreatorCommandArgsAsAPrefix () {
    // Confirms it's built on top of the same shared helper houseCommandArgs()
    // uses (mouseClicked.pde's own comment on boxLikeCommandArgs says as
    // much: "the same shape as houseCommandArgs() above"), rather than
    // duplicating the m=/tes=/lyr=/vsb=/wgt=/clz= prefix inline - so a
    // future change to creatorCommandArgs() can't silently drift the two
    // apart.
    String prefix = app.creatorCommandArgs();

    assertTrue(app.boxLikeCommandArgs(1, 2, 3, 4, 5, 6, 7).startsWith(prefix));
  }

  @Test
  void boxLikeCommandArgs_hasNoHeightParameter_unlikeHouseCommandArgs () {
    // The one structural difference from houseCommandArgs() called out in
    // its own comment ("minus the extra h/dh height parameter only the
    // houses have") - pinned here so an accidental copy-paste of
    // houseCommandArgs()'s " h=" segment into this one would fail loudly.
    String args = app.boxLikeCommandArgs(1, 2, 3, 4, 5, 6, 7);

    assertFalse(args.contains(" h="), "boxLikeCommandArgs() must not include a height parameter");
  }
}
