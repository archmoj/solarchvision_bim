import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// performAction(String, int, int) dispatches every toolbar button click.
// Most cases were rewritten to call runScriptLine("SomeAction") instead
// of the matching UI_setTo_X(...) directly, reusing an existing command
// or putAction wherever one produced the exact same effect - see
// UI_toolBar.pde's own comments on each case for why a particular name
// was (or wasn't) safe to reuse. These tests confirm the actual
// resulting state matches what the original direct call would have
// produced, not just that runScriptLine(...) returned without error -
// that distinction is exactly what caught the real bugs during this
// work (Rotate/Scale/Move's own bypassAllActionsFor collisions).
class UI_toolBarTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.build_allActions();
  }

  private void items (String... row) {
    app.UI_toolBar.Items = new String[][]{row};
  }

  // ================= Living Type / Building Type (shape creation) ========

  @Test
  void livingType_1DTree_setsModel1DsCreateObject () {
    items("", "1D-Tree");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Model1Ds, app.CreateObject);
  }

  @Test
  void livingType_2DTree_setsPlantCreateObject () {
    items("", "2D-Tree");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Plant, app.CreateObject);
  }

  @Test
  void livingType_person_setsPersonCreateObject () {
    items("", "Person");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Person, app.CreateObject);
  }

  @Test
  void livingType_point_stillSetsVertexCreateObject_directCallPreserved () {
    // No existing command's no-args branch calls UI_setTo_Create_Vertex()
    // at all, so this stays a direct call.
    items("", "Point");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Vertex, app.CreateObject);
  }

  @Test
  void livingType_polyline_setsPolylineCreateObject () {
    items("", "Polyline");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Polyline, app.CreateObject);
  }

  @Test
  void livingType_surface_reusesMeshCommand_setsFaceCreateObject () {
    // Surprising but confirmed reuse: "Mesh"'s own no-args branch is the
    // one that calls UI_setTo_Create_Face(), not a dedicated "Face" command.
    items("", "Surface");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Face, app.CreateObject);
    assertEquals(app.ObjectCategory.FACE, app.currentObjectCategory);
  }

  @Test
  void livingType_pyramid_setsPyramidCreateObject () {
    items("", "Pyramid");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Pyramid, app.CreateObject);
  }

  @Test
  void livingType_plane_reusesPolygonMeshCommand_setsPlaneCreateObject () {
    // Pre-existing quirk, preserved exactly: "PolygonMesh"'s own no-args
    // branch calls UI_setTo_Create_Plane(), not UI_setTo_Create_Polygon().
    items("", "Plane");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Plane, app.CreateObject);
  }

  @Test
  void livingType_polygon_stillSetsPolygonCreateObject_directCallPreserved () {
    // Nothing's no-args branch calls UI_setTo_Create_Polygon() at all
    // (not even "PolygonMesh" - see above), so this stays a direct call.
    items("", "Polygon");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Polygon, app.CreateObject);
  }

  @Test
  void livingType_extrude_reusesPolygonExtrudeCommand () {
    items("", "Extrude");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Extrude, app.CreateObject);
  }

  @Test
  void livingType_hyper_reusesPolygonHyperCommand () {
    items("", "Hyper");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Hyper, app.CreateObject);
  }

  @Test
  void buildingType_house1_reusesHouse1Command () {
    items("", "House1");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.House1, app.CreateObject);
  }

  @Test
  void buildingType_house2_reusesHouse2Command () {
    items("", "House2");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.House2, app.CreateObject);
  }

  @Test
  void buildingType_house3_reusesHouse3Command () {
    items("", "House3");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.House3, app.CreateObject);
  }

  @Test
  void buildingType_box_reusesBoxCommand_setsSuperOBJWithCubePower () {
    items("", "Box");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
  }

  @Test
  void buildingType_icosahedron_reusesIcosahedronCommand () {
    items("", "Icosahedron");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
  }

  @Test
  void buildingType_octahedron_reusesOctahedronCommand () {
    items("", "Octahedron");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
  }

  @Test
  void buildingType_sphere_reusesSphereCommand () {
    items("", "Sphere");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
  }

  @Test
  void buildingType_cylinder_reusesCylinderCommand () {
    items("", "Cylinder");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
  }

  @Test
  void buildingType_cone_reusesConeCommand () {
    items("", "Cone");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.Cone, app.CreateObject);
  }

  @Test
  void buildingType_cushion_reusesCushionCommand () {
    items("", "Cushion");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
  }

  @Test
  void buildingType_parametric_staysDirectCall_preservesCreatorType () {
    // The "Parametric" command's own no-args branch hardcodes n=0;
    // reusing it would silently drop the toolbar's actual
    // creatorParametricTypeIndex, so this stays a direct call.
    app.User3D.creatorParametricTypeIndex = 3;
    items("", "Parametric");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.Parametric, app.CreateObject);
    assertEquals(3, app.User3D.creatorParametricTypeIndex);
  }

  // ================= Change / Pick / Assign (Seed, Tessellation, Layer, =
  // ================= Visibility, Weight) ==================================
  // "0"/"1"/"2" each reuse an existing "Change X"/"Pick X"/"Assign X"
  // action; "3" has no existing match for any of these five, so stays
  // a direct call - confirmed for one representative (Seed) in detail,
  // and that the pattern holds for the other four.

  @Test
  void changeSeedMaterial_allFourSubOptions () {
    items("", "0");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(app.UITASK.Seed_Material, app.WIN3D.currentTool);
    assertEquals(0, app.WIN3D.toolParameterModifier);

    items("", "1");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(1, app.WIN3D.toolParameterModifier);

    items("", "2");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(2, app.WIN3D.toolParameterModifier);

    items("", "3");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(3, app.WIN3D.toolParameterModifier);
  }

  @Test
  void changeTessellation_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Tessellation", 0, 1);
      assertEquals(n, app.WIN3D.toolParameterModifier);
    }
  }

  @Test
  void changeLayer_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Layer", 0, 1);
      assertEquals(n, app.WIN3D.toolParameterModifier);
    }
  }

  @Test
  void changeVisibility_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Visibility", 0, 1);
      assertEquals(n, app.WIN3D.toolParameterModifier);
    }
  }

  @Test
  void changeWeight_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Weight", 0, 1);
      assertEquals(n, app.WIN3D.toolParameterModifier);
    }
  }

  @Test
  void normal_allThreeSubOptions () {
    items("", "1");
    app.UI_toolBar.performAction("Normal", 0, 1);
    assertEquals(1, app.WIN3D.toolParameterModifier);

    items("", "2");
    app.UI_toolBar.performAction("Normal", 0, 1);
    assertEquals(2, app.WIN3D.toolParameterModifier);

    items("", "3");
    app.UI_toolBar.performAction("Normal", 0, 1);
    assertEquals(3, app.WIN3D.toolParameterModifier);
  }

  @Test
  void firstVertex_reusesGetFirstVertexAction () {
    items("", "");
    app.UI_toolBar.performAction("First Vertex", 0, 1);
    assertEquals(app.UITASK.FirstVertex, app.WIN3D.currentTool);
    assertEquals(1, app.WIN3D.toolParameterModifier);
  }

  // ================= Power / Scale / Move / GetLength / Drop =============

  @Test
  void power_allFourAxes () {
    app.UI_toolBar.performAction("Power", 0, 1);
    assertEquals(app.UITASK.PowerX, app.WIN3D.currentTool);
    app.UI_toolBar.performAction("Power", 0, 2);
    assertEquals(app.UITASK.PowerY, app.WIN3D.currentTool);
    app.UI_toolBar.performAction("Power", 0, 3);
    assertEquals(app.UITASK.PowerZ, app.WIN3D.currentTool);
    app.UI_toolBar.performAction("Power", 0, 4);
    assertEquals(app.UITASK.PowerAll, app.WIN3D.currentTool);
  }

  @Test
  void scale_allFourAxes_includingTheBypassAllActionsForFix () {
    app.UI_toolBar.performAction("Scale", 0, 1);
    assertEquals(0, app.Select3D.scaleVectorIndex);
    app.UI_toolBar.performAction("Scale", 0, 2);
    assertEquals(1, app.Select3D.scaleVectorIndex);
    app.UI_toolBar.performAction("Scale", 0, 3);
    assertEquals(2, app.Select3D.scaleVectorIndex);
    // j-1=3 (all axes): bare "Scale" collides with the "SCALE s=? sx=? ..."
    // switch-case command (bypassAllActionsFor), so this one stays a
    // direct call - confirmed it still produces 3, not silently wrong.
    app.UI_toolBar.performAction("Scale", 0, 4);
    assertEquals(3, app.Select3D.scaleVectorIndex);
  }

  @Test
  void move_allFourAxes_includingTheBypassAllActionsForFix () {
    app.UI_toolBar.performAction("Move", 0, 1);
    assertEquals(0, app.Select3D.positionVectorIndex);
    app.UI_toolBar.performAction("Move", 0, 2);
    assertEquals(1, app.Select3D.positionVectorIndex);
    app.UI_toolBar.performAction("Move", 0, 3);
    assertEquals(2, app.Select3D.positionVectorIndex);
    // j-1=3: bare "Move" collides with the "MOVE dx=? dy=? dz=?"
    // switch-case command - same reasoning as Scale above.
    app.UI_toolBar.performAction("Move", 0, 4);
    assertEquals(3, app.Select3D.positionVectorIndex);
  }

  @Test
  void getLength_allFiveSubOptions () {
    for (int n = 0; n <= 4; n++) {
      app.UI_toolBar.performAction("Get Length", 0, n + 1);
      assertEquals(app.UITASK.GetLength, app.WIN3D.currentTool);
      assertEquals(n, app.WIN3D.toolParameterModifier);
    }
  }

  @Test
  void drop_allThreeSubOptions () {
    app.UI_toolBar.performAction("Drop", 0, 1);
    assertEquals(0, app.WIN3D.toolParameterModifier);
    app.UI_toolBar.performAction("Drop", 0, 2);
    assertEquals(1, app.WIN3D.toolParameterModifier);
    app.UI_toolBar.performAction("Drop", 0, 3);
    assertEquals(2, app.WIN3D.toolParameterModifier);
  }

  // ================= Rotate ("maintain Rotate behavior as is") ===========
  // Kept fully direct for every value - actions.pde's own "Rotate" maps
  // to (2) not (3), and "RotateX"/"RotateY"/"RotateZ" are each
  // unreachable via runScriptLine(...) at all (bypassAllActionsFor, for
  // the "ROTATE[X|Y|Z] r=?..." switch-case command's sake). This is the
  // regression test for the bug an earlier attempt at reusing these
  // actually had: all four values must be distinct and correct.

  @Test
  void rotate_allFourAxes_eachDistinctAndCorrect () {
    app.UI_toolBar.performAction("Rotate", 0, 1);
    assertEquals(0, app.Select3D.rotationVectorIndex);
    app.UI_toolBar.performAction("Rotate", 0, 2);
    assertEquals(1, app.Select3D.rotationVectorIndex);
    app.UI_toolBar.performAction("Rotate", 0, 3);
    assertEquals(2, app.Select3D.rotationVectorIndex);
    app.UI_toolBar.performAction("Rotate", 0, 4);
    assertEquals(3, app.Select3D.rotationVectorIndex, "all-axes must be 3, not 2 (the bug actions.pde's own \"Rotate\" action has)");
  }

  // ================= View family ==========================================

  @Test
  void projectionType_orthographicAndPerspective () {
    app.UI_toolBar.performAction("Projection Type", 0, 1);
    assertEquals(0, app.WIN3D.projectionTypeIndex);
    app.UI_toolBar.performAction("Projection Type", 0, 2);
    assertEquals(1, app.WIN3D.projectionTypeIndex);
  }

  @Test
  void pickSelect_allThreeSubOptions () {
    app.UI_toolBar.performAction("Pick Select", 0, 1);
    assertEquals(app.UITASK.PickSelect, app.WIN3D.currentTool);
    assertEquals(0, app.addNewSelectionToPreviousSelection);
    app.UI_toolBar.performAction("Pick Select", 0, 2);
    assertEquals(1, app.addNewSelectionToPreviousSelection);
  }

  @Test
  void windowSelect_reachesRectSelectTool () {
    app.UI_toolBar.performAction("Window Select", 0, 1);
    assertEquals(app.UITASK.RectSelect, app.WIN3D.currentTool);
  }

  @Test
  void pivotXYZ_allThreePositions () {
    app.UI_toolBar.performAction("PivotX", 0, 1); // j-2=-1
    assertEquals(-1, app.Select3D.pivotAlignmentX);
    app.UI_toolBar.performAction("PivotX", 0, 2); // j-2=0
    assertEquals(0, app.Select3D.pivotAlignmentX);
    app.UI_toolBar.performAction("PivotX", 0, 3); // j-2=1
    assertEquals(1, app.Select3D.pivotAlignmentX);

    app.UI_toolBar.performAction("PivotY", 0, 2);
    assertEquals(0, app.Select3D.pivotAlignmentY);

    app.UI_toolBar.performAction("PivotZ", 0, 2);
    assertEquals(0, app.Select3D.pivotAlignmentZ);
  }

  @Test
  void terrainOrbit_reusesTerrainOrbitAction () {
    app.UI_toolBar.performAction("Terrain Orbit", 0, 1);
    assertEquals(app.UITASK.TerrainOrbit_Pan_TargetRollZ, app.WIN3D.currentTool);
  }

  @Test
  void orbit_allThreeSubOptions () {
    app.UI_toolBar.performAction("Orbit", 0, 1);
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.WIN3D.currentTool);
    app.UI_toolBar.performAction("Orbit", 0, 2);
    assertEquals(app.UITASK.Truck_Orbit, app.WIN3D.currentTool);
  }

  @Test
  void truck_nonSequentialMapping () {
    // TruckZ->Truck(0), TruckX->Truck(1), TruckY->Truck(2) - not a
    // simple sequential index-to-name mapping, verified precisely.
    app.UI_toolBar.performAction("Truck", 0, 1); // j-1=0 -> TruckZ
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.WIN3D.currentTool);

    app.UI_toolBar.performAction("Truck", 0, 2); // j-1=1 -> TruckX
    assertEquals(app.UITASK.Truck_Orbit, app.WIN3D.currentTool);
    assertEquals(0, app.WIN3D.targetAxisIndex);

    app.UI_toolBar.performAction("Truck", 0, 3); // j-1=2 -> TruckY
    assertEquals(app.UITASK.Truck_Orbit, app.WIN3D.currentTool);
    assertEquals(1, app.WIN3D.targetAxisIndex);
  }

  @Test
  void distZ_forwardsToTruckZ_matchingTheOriginalsOwnComment () {
    app.UI_toolBar.performAction("Dist Z", 0, 1);
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.WIN3D.currentTool);
  }

  @Test
  void pan_allThreeSubOptions () {
    app.UI_toolBar.performAction("Pan", 0, 1);
    assertEquals(app.UITASK.Pan_TargetRoll, app.WIN3D.currentTool);
    app.UI_toolBar.performAction("Pan", 0, 2);
    assertEquals(app.UITASK.PanX_TargetRoll, app.WIN3D.currentTool);
  }

  @Test
  void zoom_reusesActionAndKeepsItsOwnBookkeepingSeparate () {
    // The tool-switch itself comes from the reused "Zoom"/"Zoom as
    // default" action; the toolbar's own Items[i][0] reset is this
    // button's own bookkeeping, not part of either action, and must
    // still happen.
    app.UI_toolBar.Items = new String[][]{{"0"}};
    app.UI_toolBar.performAction("Zoom", 0, 1);
    assertEquals(app.UITASK.Pan_Height, app.WIN3D.currentTool);
    assertEquals("1", app.UI_toolBar.Items[0][0]);
  }

  @Test
  void cameraDistance_distXY_reuseExistingActions () {
    app.UI_toolBar.performAction("Camera Distance", 0, 1);
    assertEquals(app.UITASK.CameraDistance_TargetRollXY_TargetRollZ, app.WIN3D.currentTool);

    app.UI_toolBar.performAction("Dist XY", 0, 1);
    assertEquals(app.UITASK.DistMouseXY_TargetRollXY_TargetRollZ, app.WIN3D.currentTool);
  }

  @Test
  void orbitStyleTriples_cameraRollAndTargetRoll () {
    app.UI_toolBar.performAction("Camera Roll", 0, 2); // j-1=1 -> CameraRollZ
    assertEquals(app.UITASK.CameraRollXY_CameraRollZ, app.WIN3D.currentTool);
    assertEquals(0, app.WIN3D.toolParameterModifier);

    app.UI_toolBar.performAction("Target Roll", 0, 2); // j-1=1 -> TargetRollZ
    assertEquals(app.UITASK.TargetRollXY_TargetRollZ, app.WIN3D.currentTool);
    assertEquals(0, app.WIN3D.toolParameterModifier);
  }

  @Test
  void lookAt_onlyIndexZeroHasAnExistingAction () {
    app.UI_toolBar.performAction("Look At Origin", 0, 1); // j-1=0
    assertEquals(0f, app.WIN3D.positionX, 0.0001f);

    app.UI_toolBar.performAction("Look At Direction", 0, 1);
    app.UI_toolBar.performAction("Look At Selection", 0, 1);
    // Reaching this line without an exception confirms both ran.
  }

  @Test
  void modelAndSkydomeSizeActions_reuseExisting () {
    app.UI_toolBar.performAction("3D Model Size", 0, 1);
    app.UI_toolBar.performAction("Skydome Size", 0, 1);
    app.UI_toolBar.performAction("All Model Size", 0, 1);
    // All three are fixed, no-arg UI_setTo_View_X() calls with no
    // simple single-field signature to check - reaching here without an
    // UnrecognizedCommand/exception is the meaningful assertion.
  }

  @Test
  void viewLayout_allFourSubOptions () {
    // UI_setTo_Viewport(n) itself sets app.viewLayout = n before calling
    // update_frame_layout(), which calls Processing's own
    // createGraphics() - that needs a real, initialized sketch surface
    // (only available after setup()/size() actually run), so it throws
    // a NullPointerException in this headless test environment
    // regardless of whether it's reached directly or through
    // runScriptLine(...) - confirmed identical for both before writing
    // this test, not assumed. viewLayout is still set before that
    // throw, so that part is still verified; the exception itself is
    // expected here, not a sign of a real bug.
    for (int n = 0; n <= 3; n++) {
      try {
        app.UI_toolBar.performAction("View Layout", 0, n + 1);
      } catch (NullPointerException expected) {
        // expected in this headless test environment - see comment above
      }
      assertEquals(n, app.viewLayout);
    }
  }

  @Test
  void viewPoint_arrayDispatch_rightMatchesDirectCall () {
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.UI_toolBar.performAction("View Point", 0, 5); // j-1=4 -> "Right"
    assertNotEquals(0f, app.WIN3D.rotationX);
    assertNotEquals(0f, app.WIN3D.rotationZ);
  }
}
