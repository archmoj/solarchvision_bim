import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Points (Points.pde), reached through the
// pre-constructed `app.allPoints` field. Note this class operates on
// the GLOBAL `allVertices` array directly (not a field of its own), so
// assertions here check `app.allVertices` as much as the getters do.
//
// NOT covered: draw() - pure rendering (WIN3D.graphics line-drawing for
// point markers), nothing to verify without a live graphics context.
//
// A fresh `app` per test since these mutate shared scene state.
class PointsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void makeEmpty_resetsAllVerticesToTheGivenLength () {
    app.allPoints.makeEmpty(3);
    assertEquals(3, app.allVertices.length);
    assertEquals(3, app.allVertices[0].length); // x, y, z
  }

  @Test
  void gettersAndSetters_roundTripEachCoordinate () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.allPoints.setX(0, 1);
    app.allPoints.setY(0, 2);
    app.allPoints.setZ(0, 3);

    assertEquals(1f, app.allPoints.getX(0), 0.0001f);
    assertEquals(2f, app.allPoints.getY(0), 0.0001f);
    assertEquals(3f, app.allPoints.getZ(0), 0.0001f);
    assertArrayEquals(new float[]{1, 2, 3}, app.allPoints.getPosition(0), 0.0001f);
  }

  @Test
  void move_addsTheOffsetToTheExistingPosition () {
    app.allVertices = new float[][]{{1, 1, 1}};
    app.allPoints.move(0, 2, 3, 4);
    assertArrayEquals(new float[]{3, 4, 5}, app.allVertices[0], 0.0001f);
  }

  @Test
  void getLength_matchesAllVerticesLength () {
    app.allVertices = new float[5][3];
    assertEquals(5, app.allPoints.getLength());
  }

  @Test
  void create_appendsAPointAndReturnsItsNewIndex () {
    app.allVertices = new float[][]{{0, 0, 0}};
    int newId = app.allPoints.create(1, 2, 3);

    assertEquals(1, newId);
    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{1, 2, 3}, app.allVertices[1], 0.0001f);
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsEveryPointAndDisplayAll () {
    // Unlike Faces/Groups/Select3D, solarchvision_Points has no data
    // fields of its own - it operates directly on the shared global
    // `allVertices` - so a "fresh instance" wouldn't add any isolation
    // here; from_XML's own `allVertices = new float[ni][3]` already
    // fully overwrites whatever was there before, regardless of which
    // instance calls it.
    app.allVertices = new float[][]{{1.25f, 2.5f, 3.75f}, {-1, -2, -3}};
    app.allPoints.displayAll = true;

    processing.data.XML root = new processing.data.XML("root");
    app.allPoints.to_XML(root);

    app.allVertices = new float[0][3]; // clear it first, to prove from_XML rebuilds it
    app.allPoints.from_XML(root);

    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{1.25f, 2.5f, 3.75f}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{-1, -2, -3}, app.allVertices[1], 0.0001f);
    assertTrue(app.allPoints.displayAll);
  }
}
