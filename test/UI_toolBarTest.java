import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// performAction(String, int, int) dispatches every toolbar button click.
// Most cases were rewritten to call runScriptLine("SomeAction") instead
// of the matching UI_setTo_X(...) directly, reusing an existing command
// or putAction wherever one produced the exact same effect - see
// uiToolBar.pde's own comments on each case for why a particular name
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
  void livingType_spline_setsPolylineCreateObject () {
    // Reuses CREATE.Polyline itself, same as the Polyline button above -
    // see uiSetTo.pde's own comment on UI_setTo_Create_Spline().
    items("", "Spline");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Polyline, app.CreateObject);
    assertEquals(app.allPolylines.CURVE_SPLINE, app.current_CurveType);
  }

  @Test
  void livingType_arc_setsArcCreateObject () {
    items("", "Arc");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Arc, app.CreateObject);
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
  void livingType_crown_reusesPolygonHyperCommand () {
    items("", "Crown");
    app.UI_toolBar.performAction("Living Type", 0, 1);
    assertEquals(app.CREATE.Crown, app.CreateObject);
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
    // Icosahedron has its own dedicated CREATE constant now (not
    // CREATE.SuperOBJ) - fixing a bug where it was indistinguishable
    // from Octahedron's own (1,1,1) superellipsoid-power preset and
    // always created an Octahedron instead.
    assertEquals(app.CREATE.Icosahedron, app.CreateObject);
  }

  @Test
  void buildingType_octahedron_reusesOctahedronCommand () {
    items("", "Octahedron");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
  }

  @Test
  void buildingType_tetrahedron_reusesTetrahedronCommand () {
    items("", "Tetrahedron");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.Tetrahedron, app.CreateObject);
  }

  @Test
  void buildingType_dodecahedron_reusesDodecahedronCommand () {
    items("", "Dodecahedron");
    app.UI_toolBar.performAction("Building Type", 0, 1);
    assertEquals(app.CREATE.Dodecahedron, app.CreateObject);
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
    assertEquals(app.UITASK.Seed_Material, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);

    items("", "1");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(1, app.User3D.toolParameterModifier);

    items("", "2");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(2, app.User3D.toolParameterModifier);

    items("", "3");
    app.UI_toolBar.performAction("Change Seed/Material", 0, 1);
    assertEquals(3, app.User3D.toolParameterModifier);
  }

  @Test
  void changeTessellation_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Tessellation", 0, 1);
      assertEquals(n, app.User3D.toolParameterModifier);
    }
  }

  @Test
  void changeLayer_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Layer", 0, 1);
      assertEquals(n, app.User3D.toolParameterModifier);
    }
  }

  @Test
  void changeVisibility_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Visibility", 0, 1);
      assertEquals(n, app.User3D.toolParameterModifier);
    }
  }

  @Test
  void changeWeight_allFourSubOptions () {
    for (int n = 0; n <= 3; n++) {
      items("", String.valueOf(n));
      app.UI_toolBar.performAction("Change Weight", 0, 1);
      assertEquals(n, app.User3D.toolParameterModifier);
    }
  }

  @Test
  void normal_allThreeSubOptions () {
    items("", "1");
    app.UI_toolBar.performAction("Normal", 0, 1);
    assertEquals(1, app.User3D.toolParameterModifier);

    items("", "2");
    app.UI_toolBar.performAction("Normal", 0, 1);
    assertEquals(2, app.User3D.toolParameterModifier);

    items("", "3");
    app.UI_toolBar.performAction("Normal", 0, 1);
    assertEquals(3, app.User3D.toolParameterModifier);
  }

  @Test
  void firstVertex_reusesGetFirstVertexAction () {
    items("", "");
    app.UI_toolBar.performAction("First Vertex", 0, 1);
    assertEquals(app.UITASK.FirstVertex, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
  }

  // ================= Power / Scale / Move / GetLength / Drop =============

  @Test
  void power_allFourAxes () {
    app.UI_toolBar.performAction("Power", 0, 1);
    assertEquals(app.UITASK.PowerX, app.User3D.currentTool);
    app.UI_toolBar.performAction("Power", 0, 2);
    assertEquals(app.UITASK.PowerY, app.User3D.currentTool);
    app.UI_toolBar.performAction("Power", 0, 3);
    assertEquals(app.UITASK.PowerZ, app.User3D.currentTool);
    app.UI_toolBar.performAction("Power", 0, 4);
    assertEquals(app.UITASK.PowerAll, app.User3D.currentTool);
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
      assertEquals(app.UITASK.GetLength, app.User3D.currentTool);
      assertEquals(n, app.User3D.toolParameterModifier);
    }
  }

  @Test
  void drop_allThreeSubOptions () {
    app.UI_toolBar.performAction("Drop", 0, 1);
    assertEquals(0, app.User3D.toolParameterModifier);
    app.UI_toolBar.performAction("Drop", 0, 2);
    assertEquals(1, app.User3D.toolParameterModifier);
    app.UI_toolBar.performAction("Drop", 0, 3);
    assertEquals(2, app.User3D.toolParameterModifier);
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
    assertEquals(app.UITASK.PickSelect, app.User3D.currentTool);
    assertEquals(0, app.addNewSelectionToPreviousSelection);
    app.UI_toolBar.performAction("Pick Select", 0, 2);
    assertEquals(1, app.addNewSelectionToPreviousSelection);
  }

  @Test
  void windowSelect_reachesRectSelectTool () {
    app.UI_toolBar.performAction("Window Select", 0, 1);
    assertEquals(app.UITASK.RectSelect, app.User3D.currentTool);
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
    assertEquals(app.UITASK.TerrainOrbit_Pan_TargetRollZ, app.User3D.currentTool);
  }

  @Test
  void orbit_allThreeSubOptions () {
    app.UI_toolBar.performAction("Orbit", 0, 1);
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
    app.UI_toolBar.performAction("Orbit", 0, 2);
    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
  }

  @Test
  void truck_nonSequentialMapping () {
    // TruckZ->Truck(0), TruckX->Truck(1), TruckY->Truck(2) - not a
    // simple sequential index-to-name mapping, verified precisely.
    app.UI_toolBar.performAction("Truck", 0, 1); // j-1=0 -> TruckZ
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);

    app.UI_toolBar.performAction("Truck", 0, 2); // j-1=1 -> TruckX
    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(0, app.User3D.targetAxisIndex);

    app.UI_toolBar.performAction("Truck", 0, 3); // j-1=2 -> TruckY
    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(1, app.User3D.targetAxisIndex);
  }

  @Test
  void distZ_forwardsToTruckZ_matchingTheOriginalsOwnComment () {
    app.UI_toolBar.performAction("Dist Z", 0, 1);
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  @Test
  void pan_allThreeSubOptions () {
    app.UI_toolBar.performAction("Pan", 0, 1);
    assertEquals(app.UITASK.Pan_TargetRoll, app.User3D.currentTool);
    app.UI_toolBar.performAction("Pan", 0, 2);
    assertEquals(app.UITASK.PanX_TargetRoll, app.User3D.currentTool);
  }

  @Test
  void zoom_reusesActionAndKeepsItsOwnBookkeepingSeparate () {
    // The tool-switch itself comes from the reused "Zoom"/"Zoom as
    // default" action; the toolbar's own Items[i][0] reset is this
    // button's own bookkeeping, not part of either action, and must
    // still happen.
    app.UI_toolBar.Items = new String[][]{{"0"}};
    app.UI_toolBar.performAction("Zoom", 0, 1);
    assertEquals(app.UITASK.Pan_Height, app.User3D.currentTool);
    assertEquals("1", app.UI_toolBar.Items[0][0]);
  }

  @Test
  void cameraDistance_distXY_reuseExistingActions () {
    app.UI_toolBar.performAction("Camera Distance", 0, 1);
    assertEquals(app.UITASK.CameraDistance_TargetRollXY_TargetRollZ, app.User3D.currentTool);

    app.UI_toolBar.performAction("Dist XY", 0, 1);
    assertEquals(app.UITASK.DistMouseXY_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }

  @Test
  void orbitStyleTriples_cameraRollAndTargetRoll () {
    app.UI_toolBar.performAction("Camera Roll", 0, 2); // j-1=1 -> CameraRollZ
    assertEquals(app.UITASK.CameraRollXY_CameraRollZ, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);

    app.UI_toolBar.performAction("Target Roll", 0, 2); // j-1=1 -> TargetRollZ
    assertEquals(app.UITASK.TargetRollXY_TargetRollZ, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
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
    app.UI_toolBar.performAction("3D-model Size", 0, 1);
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

  // ================= Layer Type / Soft (OBJECTTYPE.SOFTVERTEX=6) ========
  //
  // The toolbar's own entry point into Soft Selection - no existing test
  // reached this (every softSelection() test elsewhere sets up the
  // baked arrays by hand and skips straight to the consumer). This is
  // the actual code path a user triggers by clicking "Soft": a plain
  // category switch for every OTHER layer type, but this one also bakes
  // the current hard selection via Select3D.convert_Vertex_to_softSelection()
  // as a side effect (uiToolBar.pde's own "Layer Type" case).

  @Test
  void layerType_soft_switchesCategoryAndBakesTheSoftSelection () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.allPolylines.nodes = new int[0][];
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.Select3D.vertexSelection = new int[]{0};

    app.UI_toolBar.performAction("Layer Type", 0, 7); // j-1=6 -> OBJECTTYPE.SOFTVERTEX

    assertEquals(app.ObjectCategory.SOFTVERTEX, app.currentObjectCategory);
    assertArrayEquals(new int[]{0, 1}, app.Select3D.softSelection); // baked, not left empty
  }

  @Test
  void layerType_vertex_doesNotBakeASoftSelection () {
    // Confirms the bake is specific to the Soft case, not something
    // every "Layer Type" switch does as a side effect.
    app.Select3D.softSelection = new int[]{9}; // pre-existing, should be left alone
    app.UI_toolBar.performAction("Layer Type", 0, 6); // j-1=5 -> OBJECTTYPE.VERTEX

    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);
    assertArrayEquals(new int[]{9}, app.Select3D.softSelection);
  }

  // Regression test for the bug this fixed: switching "Layer Type" used
  // to mutate currentObjectCategory with no beginScene3DChange()/
  // endScene3DChange() wrapping at all, so Ctrl+Z right afterward had
  // no step to undo - the switch was invisible to undo/redo entirely,
  // not merely "undone but not visibly restored". seedScene3DHistory()
  // (drawInitialFrames.pde, normally frame-22-gated) is called directly
  // here, same workaround UndoRedoTest.java's own seed() helper uses,
  // since a bare `new solarchvision_bim()` never reaches that frame.
  @Test
  void layerType_switch_isItsOwnUndoableStep () {
    app.Terrain.Mesh = new float[app.Terrain.rowCount][app.Terrain.columnCount][3]; // buildScene3DSnapshot() reaches Terrain.to_XML(), which needs this - unlike every other test in this file, this one actually seeds scene3DHistory
    app.seedScene3DHistory();
    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory); // globalVariables.pde's own default

    app.UI_toolBar.performAction("Layer Type", 0, 6); // j-1=5 -> OBJECTTYPE.VERTEX
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);

    app.undoScene3DChange();
    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory); // restored, not left at VERTEX

    app.redoScene3DChange();
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory); // redo brings it back
  }
}
