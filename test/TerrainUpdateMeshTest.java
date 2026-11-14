import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Terrain.update_mesh()/update_textures() (land3D.pde) were the single
// largest untested subsystem all session - the whole Terrain class was
// essentially 0% covered, confirmed repeatedly (HandleWin3DClickAtTest.java's
// own RIGHT-click test, RotateAroundLandIntersectionTest.java, ...) to
// need a real, non-null Mesh that nothing in this suite had a way to
// build. The repo now bundles real terrain data for exactly this
// purpose: projects/test/terrain/043669998_-079629997/ - 20 real
// elevation XML files (0.xml..19.xml, matching rowCount's own bare-
// construction default of 20, each with columnCount's own default 25
// <result> entries, straight from the Open-Meteo elevation API) and 8
// real ELEV_*.jpg satellite textures from Esri World Imagery (see the
// fixture's own terrain/elevations.md and terrain/textures.md). The
// folder name itself decodes (decodeTerrainFolderName()) to
// 43.669998,-79.629997 - well within findNearbyTerrainFolders()'s own
// 1000m MAX_TERRAIN_REUSE_DISTANCE_METERS of STATION's own bare-
// construction default (Toronto, 43.67,-79.63 - globalVariables.pde's
// own STATION constructor call), so no STATION setup is needed either.
//
// Folder_Project/Folder_Terrain are set here by hand to this fixture,
// not via update_project_folders() - that function hardcodes
// Folder_Project = BaseFolder + "/projects/model-01" internally and
// would silently overwrite whatever Folder_Project this test set first,
// so each Folder_* this test needs is set directly, mirroring that
// function's own derivation formulas (Folder_Terrain = Folder_Project +
// "/terrain") anchored to this project instead. BaseFolder comes from
// System.getProperty("user.dir") rather than app.locateBaseFolder() -
// the same reasoning Earth3DTest.java's own comment gives for its real
// bundled texture (BaseFolder/sketchPath() resolves wherever Processing's
// own CLI build happens to run from, not this checkout; test/run_tests.sh
// only cd's to the repo root first).
class TerrainUpdateMeshTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.BaseFolder = System.getProperty("user.dir");
    app.Folder_Project = app.BaseFolder + "/projects/test";
    app.Folder_Terrain = app.Folder_Project + "/terrain";
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why - loadXML()/loadImage() need this too
  }

  @Test
  void update_mesh_loadsTheRealElevationData_notTheFlatFallback () {
    app.Terrain.update_mesh();

    // Row 0, column 0's own real elevation (166.0, the fixture's own
    // 0.xml) normalizes to exactly 0 (normalizeMeshElevation() anchors
    // the whole mesh on this one cell, and HeightAboveGround's own
    // bare-construction default is 0).
    assertEquals(0f, app.Terrain.Mesh[0][0][2], 0.01f);

    // A real, varied elevation (112-196m across the fixture's own outer
    // rows, per 19.xml) must show up somewhere other than the anchor
    // cell - the flat-mesh fallback would leave every single cell's own
    // Z at exactly 0, so finding a real, non-zero one anywhere is
    // itself proof the real loader ran, not that fallback.
    boolean foundRealElevationVariation = false;
    for (int i = 0; i < app.Terrain.rowCount && !foundRealElevationVariation; i++) {
      for (int j = 0; j < app.Terrain.columnCount; j++) {
        if (Math.abs(app.Terrain.Mesh[i][j][2]) > 0.5f) {
          foundRealElevationVariation = true;
          break;
        }
      }
    }
    assertTrue(foundRealElevationVariation, "real, non-flat elevation data must have been loaded from the fixture");
  }

  @Test
  void update_mesh_alsoLoadsTheRealSatelliteTextures () {
    app.Terrain.update_mesh();

    // The fixture's own terrain/textures.md documents 8, but a 9th
    // ELEV_*.jpg is genuinely present in the folder on disk (confirmed
    // directly, not assumed from that log) - this counts what's
    // actually there.
    assertEquals(9, app.Terrain.Textures_num);
    assertTrue(app.Terrain.displayTexture);
    assertEquals(9, app.Terrain.Textures_map.length);
    for (int i = 0; i < app.Terrain.Textures_map.length; i++) {
      assertTrue(app.Terrain.Textures_map[i].width > 0, "every texture must be a real, successfully-decoded image");
    }
  }
}
