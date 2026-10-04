import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class MouseClickedTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= houseCommandArgs / creatorCommandArgs ===============
  // These build the command string the UITASK.Create House1/2/3 (and
  // Pyramid/Plane, via creatorCommandArgs() alone) branches now pass to
  // runScriptLine() instead of calling Create3D.add_HouseN_Core(...)
  // directly - see mouseClicked.pde's own comment on both for why.

  @Test
  void houseCommandArgs_doublesHalfWidthsIntoTheFullWidthsTheCommandExpects () {
    // House1's own command case treats dx/dy/dz as full widths and
    // halves them internally before calling Create3D.add_House1_Core -
    // so calling it through houseCommandArgs() with rx=ry=rz=2 (an
    // already-half-width, matching what computeCreateParams() actually
    // produces) must land on exactly the same geometry as calling
    // Create3D.add_House1_Core(...) directly with that same rx=ry=rz=2 -
    // not half, not double.
    app.build_allActions();

    app.runScriptLine("House1" + app.houseCommandArgs(0, 0, 0, 2, 2, 3, 4, 0));
    float[][] viaCommand = app.allVertices;

    app.allVertices = new float[0][3];
    app.allFaces.nodes = new int[0][];
    app.Create3D.add_House1_Core(app.User3D.creatorMaterial, app.User3D.creatorTessellation, app.User3D.creatorLayer, app.User3D.creatorVisibility, app.User3D.creatorWeight, app.User3D.creatorClosed, 0, 0, 0, 2, 2, 3, 4, 0);
    float[][] direct = app.allVertices;

    assertEquals(direct.length, viaCommand.length);
    for (int i = 0; i < direct.length; i++) {
      assertArrayEquals(direct[i], viaCommand[i], 0.0001f, "vertex " + i + " should match the direct call exactly");
    }
  }

  @Test
  void creatorCommandArgs_passesTheConfiguredCreatorDefaultsThrough () {
    // The whole point of routing through the command instead of calling
    // Create3D.add_HouseN_Core(...) directly: confirms
    // User3D.creatorVisibility/Weight/Closed actually reach
    // current_Visibility/Weight/Closed, the same globals
    // RunScriptTest.java's house1_vsbWgtClz_areNowRespectedInsteadOfHardcoded
    // checks - this is the other end of that same fix, exercised through
    // mouseClicked.pde's own helper rather than a hand-written command
    // string.
    app.build_allActions();
    app.User3D.creatorVisibility = 0;
    app.User3D.creatorWeight = 3;
    app.User3D.creatorClosed = 1;

    app.runScriptLine("House1" + app.houseCommandArgs(0, 0, 0, 2, 2, 3, 4, 0));

    assertEquals(0, app.current_Visibility);
    assertEquals(3, app.current_Weight);
    assertEquals(1, app.current_Closed);
  }

  // ================= "Solid" command's parameter mapping =================

  // The ObjectCategory.SOLID branch's own local rx/ry/rz (half-widths,
  // same as every other shape branch) land in the "SOLID" command's own
  // sx/sy/sz named parameters, not its rx/ry/rz ones - confirmed against
  // Solids.pde's create(x,y,z,px,py,pz,sx,sy,sz,tx,ty,tz,v) signature
  // directly, not assumed from parameter names matching across the two
  // call sites. DEF[0] stores all 13 raw create() arguments in order, so
  // comparing it directly is a precise check of exactly what reached
  // allSolids.create(...), not just that something was created.
  @Test
  void solidCommand_mapsLocalRxRyRzToTheCommandsOwnSxSySzNotItsRxRyRz () {
    app.build_allActions();

    app.runScriptLine("Solid x=1 y=2 z=3 px=4 py=5 pz=6 sx=7 sy=8 sz=9 rx=0 ry=0 rz=10 v=1");

    assertArrayEquals(new float[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 10, 1}, app.allSolids.DEF[0], 0.0001f);
  }

  // ================= "Camera"/"Section" commands, reached at all =========
  // "solid", "camera" and "section" turned out to each collide with a
  // bare, zero-argument allActions entry (the same class of collision
  // the project's own bypassAllActionsFor comment already documents for
  // "move") - without being listed there, runScriptLine("Camera
  // px=...") silently matched that bare action and switched the current
  // tool instead of ever reaching the parameterized switch-case, with no
  // error at all. Caught only because solidCommand_... above asserted on
  // actual created state rather than just the absence of an error -
  // these two do the same for Camera/Section specifically, now that both
  // are in bypassAllActionsFor.

  @Test
  void cameraCommand_actuallyReachesAllCamerasCreate () {
    app.build_allActions();
    app.allCameras.makeEmpty(0);
    int before = app.allCameras.num;

    String hint = app.runScriptLine("Camera px=1 py=2 pz=3 pt=1.5 rx=4 ry=5 rz=6 rt=7 a=60 t=1");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 1, app.allCameras.num, "a bare tool-switch collision would leave this unchanged");
    int newId = app.allCameras.num - 1;
    assertEquals(1f, app.allCameras.get_posX(newId), 0.0001f);
    assertEquals(2f, app.allCameras.get_posY(newId), 0.0001f);
    assertEquals(3f, app.allCameras.get_posZ(newId), 0.0001f);
    assertEquals(1.5f, app.allCameras.get_posT(newId), 0.0001f);
  }

  @Test
  void sectionCommand_actuallyReachesAllSectionsCreate () {
    app.build_allActions();
    int before = app.allSections.num;

    String hint = app.runScriptLine("Section x=10 y=20 z=30 r=45 u=2 v=3 t=1 i=4 j=4");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 1, app.allSections.num, "a bare tool-switch collision would leave this unchanged");
    int newId = app.allSections.num - 1;
    assertEquals(10f, app.allSections.getX(newId), 0.0001f);
    assertEquals(20f, app.allSections.getY(newId), 0.0001f);
    assertEquals(30f, app.allSections.getZ(newId), 0.0001f);
  }

  // "PARAMETRIC" never had a case in runScriptLine's switch at all until
  // this effort added one (see runScript.pde's own comment on it) - not
  // a bypassAllActionsFor collision like Solid/Camera/Section above, but
  // the same underlying risk applies to any newly-wired command: confirm
  // it reaches Create3D.add_ParametricSurface for real, the same way
  // Create3DTest.java's own addParametricSurface_... test does for the
  // function directly (substantial geometry + the deterministic first
  // corner, since the exact face count depends on floating-point
  // loop-increment behavior this doesn't try to replicate exactly).
  @Test
  void parametricCommand_actuallyReachesAddParametricSurface () {
    app.build_allActions();

    String hint = app.runScriptLine("Parametric m=0 tes=0 lyr=0 x=0 y=0 z=0 dx=2 dy=2 dz=2 n=1 r=0");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertTrue(app.allFaces.nodes.length > 100, "a bare-action collision or an unreached case would leave this empty");
    for (int[] face : app.allFaces.nodes) assertEquals(4, face.length);
  }

  // Confirms every other command this effort newly started calling from
  // mouseClicked.pde actually creates something, not just that it runs
  // without error - the same class of check that caught Solid/Camera/
  // Section's silent bypassAllActionsFor collision above, applied to the
  // rest in one pass rather than individually, now that the specific
  // mechanism is known. allActions.containsKey(...) was already checked
  // directly for each of these names and confirmed false (no collision),
  // so this is a second, independent confirmation on top of that, not a
  // replacement for it.
  @Test
  void theRemainingNewlyWiredCommands_actuallyCreateSomething () {
    app.build_allActions();

    int facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("Box m=0 tes=0 lyr=0 x=0 y=0 z=0 dx=2 dy=2 dz=2 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "Box");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("Octahedron m=0 tes=0 lyr=0 x=0 y=0 z=0 dx=2 dy=2 dz=2 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "Octahedron");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("SuperSphere m=0 tes=0 lyr=0 x=0 y=0 z=0 dx=2 dy=2 dz=2 px=2 py=2 pz=2 deg=3 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "SuperSphere");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("Cylinder m=0 tes=0 lyr=0 x=0 y=0 z=0 dx=2 dy=2 dz=2 deg=8 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "Cylinder");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("Cone m=0 tes=0 lyr=0 x=0 y=0 z=0 dx=2 dy=2 dz=2 deg=8 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "Cone");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("PolygonMesh m=0 tes=0 lyr=0 x=0 y=0 z=0 d=2 deg=6 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "PolygonMesh");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("PolygonHyper m=0 tes=0 lyr=0 x=0 y=0 z=0 d=2 h=2 deg=6 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "PolygonHyper");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("PolygonExtrude m=0 tes=0 lyr=0 x=0 y=0 z=0 d=2 h=2 deg=6 r=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "PolygonExtrude");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("Mesh3 m=0 tes=0 lyr=0 x1=0 y1=0 z1=0 x2=1 y2=0 z2=0 x3=0 y3=1 z3=1");
    assertTrue(app.allFaces.nodes.length > facesBefore, "Mesh3");

    facesBefore = app.allFaces.nodes.length;
    app.runScriptLine("Mesh4 m=0 tes=0 lyr=0 x1=0 y1=0 z1=0 x2=1 y2=0 z2=0 x3=1 y3=1 z3=0 x4=0 y4=1 z4=0");
    assertTrue(app.allFaces.nodes.length > facesBefore, "Mesh4");
  }

  // ================= Solid (SuperOBJ)/Person/Tree2/Tree1 commands ========
  // Same "confirm it actually creates something, not just that it runs
  // without error" discipline as the Solid/Camera/Section/Parametric
  // tests above, applied to the four further substitutions this effort
  // made from UITASK.Create's remaining direct Create3D-adjacent calls
  // (SuperOBJ's own extra allSolids.create, and Person/Plant/Model1Ds).
  // "person" and "solid" are both already confirmed collision cases
  // (hence already in bypassAllActionsFor) - re-verified here through
  // the actual substitution rather than just trusted from that earlier
  // check.

  @Test
  void superOBJsOwnSolidCall_actuallyReachesAllSolidsCreate () {
    app.build_allActions();
    int before = app.allSolids.DEF.length;

    app.runScriptLine("Solid x=1 y=2 z=3 px=4 py=5 pz=6 sx=7 sy=8 sz=9 rx=0 ry=0 rz=10 v=1");

    assertEquals(before + 1, app.allSolids.DEF.length);
    assertArrayEquals(new float[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 10, 1}, app.allSolids.DEF[before], 0.0001f);
  }

  @Test
  void personCommand_actuallyReachesAllModel2DsCreate () {
    app.build_allActions();
    int before = app.allModel2Ds.num;

    String hint = app.runScriptLine("Person m=3 x=1 y=2 z=3");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 1, app.allModel2Ds.num, "a bare tool-switch collision would leave this unchanged");
  }

  @Test
  void tree2Command_actuallyReachesAllModel2DsCreate () {
    app.build_allActions();
    int before = app.allModel2Ds.num;

    String hint = app.runScriptLine("Tree2 m=0 x=1 y=2 z=3 h=5");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 1, app.allModel2Ds.num);
  }

  @Test
  void tree1Command_actuallyReachesAllModel1DsCreate () {
    app.build_allActions();
    int before = app.allModel1Ds.num;

    String hint = app.runScriptLine("Tree1 m=0 seed=1 degree=8 x=1 y=2 z=3 h=10 r=0 tilt=60 twist=137.5 ratio=0.8 base=2.0 trunk=1.0 leaf=0.1");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(before + 1, app.allModel1Ds.num);
  }

  // ================= "Move" command (UITASK.Move drag-to-move) ===========
  // "MOVE" itself already has solid coverage in RunScriptTest.java
  // (move_withArguments_actuallyMovesRatherThanJustSwitchingTheTool,
  // confirming it isn't shadowed by the bare tool-switch action "move"
  // is already in bypassAllActionsFor to avoid). This instead confirms
  // this specific substitution's own d[0]/d[1]/d[2] -> dx/dy/dz string
  // construction is correct - not swapped or misaligned - by checking
  // the actual resulting vertex position, the same way Move3DTest.java's
  // own selection_vertexCategoryDispatchesToVertices does for
  // Move3D.selection(...) directly.
  @Test
  void moveCommand_appliesComputedDeltaToTheSelectedVertex () {
    app.build_allActions();
    app.allVertices = new float[][]{{1, 2, 3}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[]{0};

    float[] d = {4, 5, 6};
    app.runScriptLine("Move dx=" + d[0] + " dy=" + d[1] + " dz=" + d[2]);

    assertArrayEquals(new float[]{5, 7, 9}, app.allVertices[0], 0.0001f);
  }

  // ================= "BeginNewGroup" command ==============================
  // allGroups.beginNewGroup(...) itself has no validity guard at all
  // (GroupsTest.java's own beginNewGroup_appendsARowToEveryArrayUsingCurrentSceneCounts
  // confirms it just appends the 9 values directly), so this just
  // confirms the command passes all 9 through correctly, the same way
  // moveCommand_... above confirms Move's own string construction rather
  // than re-testing Move3D.selection() itself.
  @Test
  void beginNewGroupCommand_passesAllNineValuesThrough () {
    app.build_allActions();

    String hint = app.runScriptLine("BeginNewGroup x=1 y=2 z=3 sx=1 sy=1 sz=1 rx=0 ry=0 rz=45");

    assertNotEquals(app.UnrecognizedCommand, hint);
    assertEquals(1, app.allGroups.num);
    assertArrayEquals(new float[]{1, 2, 3, 1, 1, 1, 0, 0, 45}, app.allGroups.Pivots[0], 0.0001f);
  }

  // ================= small top-level helpers ============================

  @Test
  void selectNewlyCreated_isANoOpWhenNothingWasCreated () {
    boolean[] deselectCalled = {false};
    app.selectNewlyCreated(3, 3, () -> deselectCalled[0] = true, (i) -> fail("should not select anything"));
    assertFalse(deselectCalled[0]);
  }

  @Test
  void selectNewlyCreated_deselectsThenSelectsEveryNewIndex () {
    boolean[] deselectCalled = {false};
    java.util.List<Integer> selected = new java.util.ArrayList<>();

    app.selectNewlyCreated(3, 5, () -> deselectCalled[0] = true, selected::add);

    assertTrue(deselectCalled[0]);
    assertEquals(java.util.Arrays.asList(3, 4), selected);
  }

  @Test
  void stopAllRecording_clearsEveryRecordingFlagAcrossAllThreeWindows () {
    app.STUDY.record_AUTO = true;
    app.STUDY.record_IMG = true;
    app.STUDY.record_PDF = true;
    app.WORLD.record_AUTO = true;
    app.WORLD.record_IMG = true;
    app.WORLD.record_PDF = true;
    app.WIN3D.record_AUTO = true;
    app.WIN3D.record_IMG = true;
    app.FRAME_record_AUTO = true;
    app.FRAME_record_IMG = true;
    app.FRAME_click_IMG = true;
    app.FRAME_drag_IMG = true;

    app.stopAllRecording();

    assertFalse(app.STUDY.record_AUTO);
    assertFalse(app.STUDY.record_IMG);
    assertFalse(app.STUDY.record_PDF);
    assertFalse(app.WORLD.record_AUTO);
    assertFalse(app.WORLD.record_IMG);
    assertFalse(app.WORLD.record_PDF);
    assertFalse(app.WIN3D.record_AUTO);
    assertFalse(app.WIN3D.record_IMG);
    assertFalse(app.FRAME_record_AUTO);
    assertFalse(app.FRAME_record_IMG);
    assertFalse(app.FRAME_click_IMG);
    assertFalse(app.FRAME_drag_IMG);
  }

  @Test
  void setimpactGraphIndex_setsTheModeResetsSetupAndTogglesWindRoses () {
    app.STUDY.impactGraphIndex = 0;
    app.STUDY.plotLayoutIndex = 9;
    app.allWindRoses.displayImage = false;

    app.setimpactGraphIndex(3, true);

    assertEquals(3, app.STUDY.impactGraphIndex);
    assertEquals(0, app.STUDY.plotLayoutIndex);
    assertTrue(app.allWindRoses.displayImage);
  }

  @Test
  void selectAllOfCategory_switchesCategoryThenSelectsEverythingInIt () {
    app.allFaces.nodes = new int[][]{{0}, {0}, {0}};

    app.selectAllOfCategory(app.ObjectCategory.FACE);

    assertEquals(app.ObjectCategory.FACE, app.currentObjectCategory);
    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.faceSelection);
  }

  @Test
  void convertAndSwitch_runsTheConversionThenSwitchesCategory () {
    boolean[] ran = {false};
    app.convertAndSwitch(() -> ran[0] = true, app.ObjectCategory.GROUP);

    assertTrue(ran[0]);
    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory);
  }

  // ================= flipFaceOrientationIfNeeded (extracted)

  @Test
  void flipFaceOrientation_reversesWhenTaskModifyParameterIsAlwaysFlip () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.WIN3D.toolParameterModifier = 1; // always flip

    app.flipFaceOrientationIfNeeded(0);

    assertArrayEquals(new int[]{2, 1, 0}, app.allFaces.nodes[0]);
  }

  @Test
  void flipFaceOrientation_isANoOpForATriangleWithTwoOrFewerNodes () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}};
    app.WIN3D.toolParameterModifier = 1;

    app.flipFaceOrientationIfNeeded(0);

    assertArrayEquals(new int[]{0, 1}, app.allFaces.nodes[0]);
  }

  @Test
  void flipFaceOrientation_directionDependsOnWhichSideOfTheWindingPlaneThePivotIsOn () {
    // Triangle in the XY plane; centroid at (1/3, 1/3, 0). With pivot
    // ABOVE it (+Z), V comes out positive - verified independently in
    // Python before writing this - so toolParameterModifier=2 (flip when
    // V>0) flips, and =3 (flip when V<0) doesn't.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}, {0, 1, 0}};
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 1, 1, 1, 1, 0, 0, 0}, {0, 0, 1, 1, 1, 1, 0, 0, 0}, {0, 0, 1, 1, 1, 1, 0, 0, 0}
    }; // pivot at (0,0,1), directly above the triangle

    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.WIN3D.toolParameterModifier = 2;
    app.flipFaceOrientationIfNeeded(0);
    assertArrayEquals(new int[]{2, 1, 0}, app.allFaces.nodes[0]); // flipped

    app.allFaces.nodes = new int[][]{{0, 1, 2}}; // reset
    app.WIN3D.toolParameterModifier = 3;
    app.flipFaceOrientationIfNeeded(0);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]); // unchanged
  }

  // ========== rotateNodesToStartAtNearestVertex (extracted)

  @Test
  void rotateNodesToStartAtNearestVertex_rotatesSoTheClosestNodeComesFirst () {
    // nodeRow holds real vertex INDICES (0-3), not arbitrary content -
    // the function looks each one up via allPoints.getX/Y/Z, so using
    // placeholder values like {10,20,30,40} throws an
    // ArrayIndexOutOfBoundsException instead of testing anything.
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}, {0, 5, 0}};
    int[] nodeRow = {0, 1, 2, 3};

    // Closest to vertex index 1 (5,0,0).
    app.rotateNodesToStartAtNearestVertex(nodeRow, new float[]{0, 4.9f, 0.1f, 0});

    assertArrayEquals(new int[]{1, 2, 3, 0}, nodeRow);
  }

  @Test
  void rotateNodesToStartAtNearestVertex_isANoOpForTwoOrFewerNodes () {
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}};
    int[] nodeRow = {10, 20};

    app.rotateNodesToStartAtNearestVertex(nodeRow, new float[]{0, 5, 0, 0});

    assertArrayEquals(new int[]{10, 20}, nodeRow);
  }

  @Test
  void rotateNodesToStartAtNearestVertex_mutatesTheArrayInPlaceForBothFacesAndPolylines () {
    // Confirms it's genuinely shared between the two callers, not just
    // structurally similar: passing allFaces.nodes[f] directly mutates
    // the real scene array, same as it would for allPolylines.nodes[f].
    app.allVertices = new float[][]{{0, 0, 0}, {5, 0, 0}, {5, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};

    app.rotateNodesToStartAtNearestVertex(app.allFaces.nodes[0], new float[]{0, 5.1f, -0.1f, 0});

    assertArrayEquals(new int[]{1, 2, 0}, app.allFaces.nodes[0]);
  }

  // ================= StationPicker: pure layout ===========================

  @Test
  void headerRect_sitsAtWorldsTopLeftCornerPaddedIn () {
    app.WORLD.cX = 100;
    app.WORLD.cY = 200;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    float[] r = app.climateTypicalYearPicker.headerRect();

    float pad = 1.6f * app.MessageSize;
    assertEquals(100 + pad, r[0], 0.01f);
    assertEquals(200 + pad, r[1], 0.01f);
    assertEquals(400 - 2 * pad, r[2], 0.01f);
  }

  @Test
  void needsScrollbar_isTrueOnlyWhenThereAreMoreRowsThanFit () {
    app.WORLD.dY = 300; // enough room for several rows

    app.climateTypicalYearPicker.indices = new int[]{1, 2};
    assertFalse(app.climateTypicalYearPicker.needsScrollbar());

    app.climateTypicalYearPicker.indices = new int[100];
    assertTrue(app.climateTypicalYearPicker.needsScrollbar());
  }

  @Test
  void rowAt_findsWhichVisibleRowAScreenPointLandsOnAccountingForScrollOffset () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.climateTypicalYearPicker.indices = new int[]{100, 101, 102, 103, 104};
    app.climateTypicalYearPicker.scrollOffset = 1; // row 0 on screen shows indices[1]

    float[] row0 = app.climateTypicalYearPicker.rowRect(0);
    int hit = app.climateTypicalYearPicker.rowAt(row0[0] + 2, row0[1] + 2);

    assertEquals(1, hit); // absolute index into `indices`, not the visible row number
  }

  @Test
  void rowAt_isMinusOneWhenTheClickLandsOutsideEveryRow () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.climateTypicalYearPicker.indices = new int[]{100};

    assertEquals(-1, app.climateTypicalYearPicker.rowAt(-500, -500));
  }

  // ================= StationPicker: click/wheel/drag handling ============

  @Test
  void handleClick_selectsTheClickedRowThenClosesTheList () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{app.new STATION()};
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearFilename("station_0.epw");
    app.STATION.setClimateTypicalYearFilename("station_0.epw"); // already selected -> select() below is a safe no-op

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[]{0};
    app.climateTypicalYearPicker.mouseLon = 12;
    app.climateTypicalYearPicker.mouseLat = 34;

    float[] row0 = app.climateTypicalYearPicker.rowRect(0);
    app.X_clicked = (int) (row0[0] + 2);
    app.Y_clicked = (int) (row0[1] + 2);

    boolean consumed = app.climateTypicalYearPicker.handleClick();

    assertTrue(consumed);
    assertFalse(app.climateTypicalYearPicker.active); // list closes either way
    assertEquals(0, app.climateTypicalYearPicker.indices.length);
  }

  @Test
  void handleClick_isANoOpWhenThePickerIsNotActive () {
    app.climateTypicalYearPicker.active = false;
    assertFalse(app.climateTypicalYearPicker.handleClick());
  }

  @Test
  void cancel_closesTheListWithoutSelectingAnything () {
    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[]{0, 1, 2};

    assertTrue(app.climateTypicalYearPicker.cancel());

    assertFalse(app.climateTypicalYearPicker.active);
    assertEquals(0, app.climateTypicalYearPicker.indices.length);
  }

  @Test
  void cancel_isANoOpWhenNotActive () {
    app.climateTypicalYearPicker.active = false;
    assertFalse(app.climateTypicalYearPicker.cancel());
  }

  @Test
  void handleWheel_scrollsOnlyWhileActiveAndOverWorldAndThereIsSomethingToScroll () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.X_clicked = 10;
    app.Y_clicked = 10;

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[100]; // enough rows to actually need scrolling
    app.climateTypicalYearPicker.scrollOffset = 0;

    boolean consumed = app.climateTypicalYearPicker.handleWheel(1);

    assertTrue(consumed);
    assertEquals(1, app.climateTypicalYearPicker.scrollOffset);
  }

  @Test
  void handleWheel_doesNotConsumeTheEventWhenNotActive () {
    app.climateTypicalYearPicker.active = false;
    assertFalse(app.climateTypicalYearPicker.handleWheel(1));
  }

  @Test
  void handleTrackClick_pagesTheListWhenClickingAboveTheThumb () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[100];
    app.climateTypicalYearPicker.scrollOffset = 20;

    float[] track = app.climateTypicalYearPicker.scrollTrackRect();
    app.X_clicked = (int) (track[0] + 2);
    // isInside() uses STRICT inequality, so clicking exactly at track[1]
    // (the top edge) fails the "is this click inside the track at all"
    // check entirely - nudge a couple pixels in, still comfortably above
    // the thumb given scrollOffset=20 out of 100 rows.
    app.Y_clicked = (int) (track[1] + 2);

    boolean consumed = app.climateTypicalYearPicker.handleTrackClick();

    assertTrue(consumed);
    assertTrue(app.climateTypicalYearPicker.scrollOffset < 20); // paged up
  }

  // ================= StationPicker: handleMapClick =========================

  @Test
  void handleMapClick_selectsTheSingleNearestStationWhenADifferentDataSourceIsActive () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{app.new STATION()};
    app.climateTypicalYearCoordinates[0].setLatitude(10);
    app.climateTypicalYearCoordinates[0].setLongitude(20);
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearFilename("only_station.epw");

    // A DIFFERENT dataset is active, so even a within-range candidate is
    // selected directly rather than opening climateTypicalYearPicker's own list -
    // that only happens when Climate Typical Year itself is currentDataSource (see the
    // next test).
    app.currentDataSource = app.dataID_climateEngineering;
    app.STATION.setClimateTypicalYearFilename("something_else.epw"); // different, so selection actually applies

    app.climateTypicalYearPicker.handleMapClick(20, 10);

    assertFalse(app.climateTypicalYearPicker.active);
    assertEquals("only_station.epw", app.STATION.getClimateTypicalYearFilename());
  }

  @Test
  void handleMapClick_opensTheListForACandidateWithinRangeOfTheActiveDataSource () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{app.new STATION()};
    app.climateTypicalYearCoordinates[0].setLatitude(10);
    app.climateTypicalYearCoordinates[0].setLongitude(20);
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearFilename("only_station.epw");

    app.currentDataSource = app.dataID_climateTypicalYear; // Climate Typical Year is the active dataset

    app.climateTypicalYearPicker.handleMapClick(20, 10); // well within the picker's own maxDist

    assertTrue(app.climateTypicalYearPicker.active);
    assertArrayEquals(new int[]{0}, app.climateTypicalYearPicker.indices);
  }

  // ================= selectClimateTypicalYearStation (safe cases only) =

  @Test
  void selectClimateTypicalYearStation_isANoOpWhenTheSameStationIsAlreadySelected () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{app.new STATION()};
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearFilename("same.epw");
    app.STATION.setClimateTypicalYearFilename("same.epw");
    app.STATION.setLatitude(1);
    app.STATION.setLongitude(2);

    app.selectClimateTypicalYearStation(0, 99, 99);

    // Early return means STATION's position is untouched.
    assertEquals(1f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(2f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void selectClimateTypicalYearStation_updatesPositionAndFilenameButSkipsReloadWhenNotTheActiveDataSource () {
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{app.new STATION()};
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearFilename("new_station.epw");
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearDownload("http://example.com/new_station.epw");

    app.STATION.setClimateTypicalYearFilename("old_station.epw");
    app.currentDataSource = app.dataID_climateEngineering; // NOT Climate Typical Year - the risky reload block is skipped

    app.selectClimateTypicalYearStation(0, 12.5f, 34.5f);

    assertEquals(12.5f, app.STATION.getLongitude(), 0.0001f);
    assertEquals(34.5f, app.STATION.getLatitude(), 0.0001f);
    assertEquals("new_station.epw", app.STATION.getClimateTypicalYearFilename());
  }

  // ============ computeCreateParams (extracted) ===========

  @Test
  void computeCreateParams_derivesHalfExtentsAndRotationFromUserPreferences () {
    app.User3D.creatorOrientation = 0; // not 360, so this is used directly rather than falling back to WIN3D.rotationZ
    app.User3D.creatorLength = 4;  // positive -> deterministic, no randomize
    app.User3D.creatorWidth = 6;
    app.User3D.creatorHeight = 2;
    app.User3D.creatorSuperellipsoidPowerX = 2;
    app.User3D.creatorSuperellipsoidPowerY = 2;
    app.User3D.creatorSuperellipsoidPowerZ = 2;
    app.User3D.creatorRandomSuperellipsoidPower = 0;
    app.User3D.creatorVolume = 0;
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not excluded from the alignment offset
    app.Select3D.pivotAlignmentX = 0;
    app.Select3D.pivotAlignmentY = 0;
    app.Select3D.pivotAlignmentZ = 0;

    solarchvision_bim.CreateParams p = app.computeCreateParams(new float[]{0, 10, 20, 30});

    assertEquals(10f, p.x, 0.0001f);
    assertEquals(20f, p.y, 0.0001f);
    assertEquals(30f, p.z, 0.0001f);
    assertEquals(0f, p.rot, 0.0001f);
    assertEquals(2f, p.rx, 0.0001f); // half of createLength
    assertEquals(3f, p.ry, 0.0001f); // half of createWidth
    assertEquals(1f, p.rz, 0.0001f); // half of createHeight
    assertEquals(2f, p.px, 0.0001f);
    assertEquals(2f, p.py, 0.0001f);
    assertEquals(2f, p.pz, 0.0001f);
  }

  @Test
  void computeCreateParams_orientation360FallsBackToTheCurrentViewportRotation () {
    app.User3D.creatorOrientation = 360;
    app.WIN3D.rotationZ = 47;
    app.User3D.creatorLength = 1;
    app.User3D.creatorWidth = 1;
    app.User3D.creatorHeight = 1;

    solarchvision_bim.CreateParams p = app.computeCreateParams(new float[]{0, 0, 0, 0});

    assertEquals(47f, p.rot, 0.0001f);
  }

  @Test
  void computeCreateParams_offsetsPositionByHalfExtentsScaledByAlignment () {
    app.User3D.creatorLength = 4; // rx=2
    app.User3D.creatorWidth = 6;  // ry=3
    app.User3D.creatorHeight = 2; // rz=1
    app.currentObjectCategory = app.ObjectCategory.SOLID; // not excluded from this offset
    app.Select3D.pivotAlignmentX = 1;
    app.Select3D.pivotAlignmentY = -1;
    app.Select3D.pivotAlignmentZ = 0;

    solarchvision_bim.CreateParams p = app.computeCreateParams(new float[]{0, 10, 20, 30});

    assertEquals(10 - 2 * 1, p.x, 0.0001f); // x -= rx * pivotAlignmentX
    assertEquals(20 - 3 * -1, p.y, 0.0001f); // y -= ry * pivotAlignmentY
    assertEquals(30f, p.z, 0.0001f); // pivotAlignmentZ=0 -> unchanged
  }

  @Test
  void computeCreateParams_skipsTheAlignmentOffsetForModel1DModel2DTerrainVertexCameraAndSection () {
    app.User3D.creatorLength = 4;
    app.Select3D.pivotAlignmentX = 1; // would shift x if this category weren't excluded

    for (int category : new int[]{
      app.ObjectCategory.MODEL1D, app.ObjectCategory.MODEL2D, app.ObjectCategory.TERRAIN,
      app.ObjectCategory.CAMERA, app.ObjectCategory.SECTION
    }) {
      app.currentObjectCategory = category;
      solarchvision_bim.CreateParams p = app.computeCreateParams(new float[]{0, 10, 20, 30});
      assertEquals(10f, p.x, 0.0001f, "category " + category + " should not be offset");
    }
  }

  @Test
  void computeCreateParams_derivesHeightFromVolumeWhenVolumeIsSet () {
    app.User3D.creatorLength = 4; // rx=2
    app.User3D.creatorWidth = 4;  // ry=2
    app.User3D.creatorHeight = 999; // overridden by the volume calculation below
    app.User3D.creatorSuperellipsoidPowerX = 2;
    app.User3D.creatorSuperellipsoidPowerY = 2;
    app.User3D.creatorSuperellipsoidPowerZ = 2; // A=0.5 for pz==2
    app.User3D.creatorVolume = 32; // rz = 32 / (8*2*2) = 1, then divided by A^(1/3)

    solarchvision_bim.CreateParams p = app.computeCreateParams(new float[]{0, 0, 0, 0});

    float expectedRz = (1f) / (float) Math.pow(0.5, 1.0 / 3.0);
    assertEquals(expectedRz, p.rz, 0.001f);
  }

  @Test
  void computeCreateParams_negativeLengthRandomizesWithinAQuarterToFullOfItsMagnitude () {
    app.User3D.creatorLength = -8; // "randomize" sentinel: 0.5*(-8) = -4 -> rx becomes random(1, 4)

    solarchvision_bim.CreateParams p = app.computeCreateParams(new float[]{0, 0, 0, 0});

    assertTrue(p.rx >= 1f && p.rx <= 4f);
  }

  // ======== computeCameraParamsAtPoint (extracted) ========

  @Test
  void computeCameraParamsAtPoint_derivesPositionFromCamSpaceUnderIdentityRotation () {
    // Verified independently in Python beforehand, reusing the same
    // reverseTransform_3DViewport formula already confirmed in
    // WIN3DTest.java's round-trip test.
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.EyeLevel = 1.5f;

    solarchvision_bim.CameraParams cp = app.computeCameraParamsAtPoint(10, 20, 30);

    assertEquals(-10f, cp.pX, 0.01f);
    assertEquals(20f, cp.pY, 0.01f);
    assertEquals(55.1025f, cp.pZ, 0.01f);
  }

  @Test
  void computeCameraParamsAtPoint_accountsForTheCurrentViewportRotation () {
    app.WIN3D.rotationX = 90;
    app.WIN3D.rotationZ = -45;
    app.EyeLevel = 1.5f;

    solarchvision_bim.CameraParams cp = app.computeCameraParamsAtPoint(10, 20, 30);

    assertEquals(7.0711f, cp.pX, 0.01f);
    assertEquals(31.5f, cp.pY, 0.01f);
    assertEquals(107.8157f, cp.pZ, 0.01f);
  }

  @Test
  void computeCameraParamsAtPoint_leavesWIN3DsOwnStateExactlyAsItWasBeforeTheCall () {
    app.WIN3D.cameraX = 111;
    app.WIN3D.cameraY = 222;
    app.WIN3D.cameraZ = 333;
    app.WIN3D.positionX = 1;
    app.WIN3D.positionY = 2;
    app.WIN3D.positionZ = 3;
    app.WIN3D.rotationX = 4;
    app.WIN3D.rotationY = 5;
    app.WIN3D.rotationZ = 6;
    app.WIN3D.zoom = 77;

    app.computeCameraParamsAtPoint(10, 20, 30);

    assertEquals(111f, app.WIN3D.cameraX, 0.0001f);
    assertEquals(222f, app.WIN3D.cameraY, 0.0001f);
    assertEquals(333f, app.WIN3D.cameraZ, 0.0001f);
    assertEquals(1f, app.WIN3D.positionX, 0.0001f);
    assertEquals(2f, app.WIN3D.positionY, 0.0001f);
    assertEquals(3f, app.WIN3D.positionZ, 0.0001f);
    assertEquals(4f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(5f, app.WIN3D.rotationY, 0.0001f);
    assertEquals(6f, app.WIN3D.rotationZ, 0.0001f);
    assertEquals(77f, app.WIN3D.zoom, 0.0001f);
  }

  @Test
  void computeCameraParamsAtPoint_returnsTheCurrentViewportTypeAndZoom () {
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.zoom = 55;

    solarchvision_bim.CameraParams cp = app.computeCameraParamsAtPoint(0, 0, 0);

    assertEquals(1, cp.type);
    assertEquals(55f, cp.zoom, 0.0001f);
  }

  // ======= computeSectionParams (extracted) ================

  @Test
  void computeSectionParams_horizontalFaceProducesATypeOneSectionAtItsCentroid () {
    // A flat, CCW-wound square in the XY plane at Z=5 - its bounding box
    // is thinnest along Z, so this becomes a horizontal (Type 1) section
    // centered at the face's own centroid. Verified independently in
    // Python beforehand, including the second-pass "is this section
    // built backwards" check - this winding does NOT trigger a flip.
    app.allVertices = new float[][]{{0, 0, 5}, {2, 0, 5}, {2, 2, 5}, {0, 2, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.mouseButton = app.LEFT;

    solarchvision_bim.SectionParams sp = app.computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertTrue(sp.createNew);
    assertEquals(1, sp.Type);
    assertEquals(1f, sp.X, 0.001f);
    assertEquals(1f, sp.Y, 0.001f);
    assertEquals(5f, sp.Z, 0.001f);
    assertEquals(0f, sp.R, 0.001f);
    assertEquals(2f, sp.U, 0.001f);
    assertEquals(2f, sp.V, 0.001f);
  }

  @Test
  void computeSectionParams_verticalFaceProducesATypeTwoSection () {
    // A flat square standing in the XZ plane (constant Y) - thinnest
    // along Y, becoming a vertical (Type 2) section.
    app.allVertices = new float[][]{{0, 0, 0}, {2, 0, 0}, {2, 0, 4}, {0, 0, 4}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.mouseButton = app.LEFT;

    solarchvision_bim.SectionParams sp = app.computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertTrue(sp.createNew);
    assertEquals(2, sp.Type);
    assertEquals(1f, sp.X, 0.001f);
    assertEquals(2f, sp.Y, 0.001f);
    assertEquals(0f, sp.Z, 0.001f);
    assertEquals(2f, sp.U, 0.001f);
    assertEquals(4f, sp.V, 0.001f);
  }

  @Test
  void computeSectionParams_detectsAndCorrectsABackwardsWoundFace () {
    // Same horizontal square as the first test, but wound clockwise
    // instead of counter-clockwise - the second-pass consistency check
    // (comparing the face's own normal against the resulting section
    // plane's normal) now finds them pointing opposite ways and flips
    // the section (R += 180, X and Z negated) to compensate. Confirmed
    // in Python beforehand that this exact winding is what triggers it.
    app.allVertices = new float[][]{{0, 0, 5}, {0, 2, 5}, {2, 2, 5}, {2, 0, 5}};
    app.allFaces.nodes = new int[][]{{0, 1, 2, 3}};
    app.mouseButton = app.LEFT;

    solarchvision_bim.SectionParams sp = app.computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertEquals(1, sp.Type);
    assertEquals(-1f, sp.X, 0.001f);
    assertEquals(1f, sp.Y, 0.001f);
    assertEquals(-5f, sp.Z, 0.001f);
    assertEquals(180f, sp.R, 0.001f);
  }

  @Test
  void computeSectionParams_rightClickAlwaysCreatesAHorizontalSectionAtTheClickPoint () {
    app.mouseButton = app.RIGHT;

    solarchvision_bim.SectionParams sp = app.computeSectionParams(0, new float[]{0, 11, 22, 33});

    assertTrue(sp.createNew);
    assertEquals(1, sp.Type);
    assertEquals(11f, sp.X, 0.0001f);
    assertEquals(22f, sp.Y, 0.0001f);
    assertEquals(33f, sp.Z, 0.0001f);
  }

  @Test
  void computeSectionParams_isANoOpForATwoNodeFaceOnLeftClick () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 0, 0}};
    app.allFaces.nodes = new int[][]{{0, 1}}; // only 2 nodes - too few for a plane
    app.mouseButton = app.LEFT;

    app.allSolidImpacts.X[app.allSolidImpacts.sectionType] = 99;
    app.allSolidImpacts.sectionType = 0;

    solarchvision_bim.SectionParams sp = app.computeSectionParams(0, new float[]{0, 0, 0, 0});

    assertFalse(sp.createNew);
    assertEquals(99f, sp.X, 0.0001f); // left at allSolidImpacts' current default, untouched
  }

  // ======= pickOrAssignFaceProperty (extracted) ===========

  @Test
  void pickOrAssignFaceProperty_isANoOpWhenTheCurrentTaskIsntOneOfTheFiveProperties () {
    app.WIN3D.currentTool = app.UITASK.Move; // not one of the five
    app.WIN3D.toolParameterModifier = 1;
    app.allFaces.options = new int[][]{{9, 9, 9, 9, 9, 9}};
    app.User3D.creatorMaterial = -1;

    app.pickOrAssignFaceProperty(0);

    assertEquals(-1, app.User3D.creatorMaterial); // untouched
  }

  @Test
  void pickOrAssignFaceProperty_pickReadsTheClickedFacesValueIntoTheMatchingDefault () {
    app.WIN3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.toolParameterModifier = 1; // Pick
    app.allFaces.options = new int[][]{{42, 0, 0, 0, 0, 0}};

    app.pickOrAssignFaceProperty(0);

    assertEquals(42, app.User3D.creatorMaterial);
  }

  @Test
  void pickOrAssignFaceProperty_assignSubWritesTheDefaultOntoJustTheClickedFace () {
    app.WIN3D.currentTool = app.UITASK.Weight;
    app.WIN3D.toolParameterModifier = 2; // Assign(sub)
    app.User3D.creatorWeight = 7;
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};

    app.pickOrAssignFaceProperty(0);

    assertEquals(7, app.allFaces.getWeight(0));
    assertEquals(0, app.allFaces.getWeight(1)); // the other face is untouched
  }

  @Test
  void pickOrAssignFaceProperty_assignAllWritesTheDefaultOntoEveryFaceInTheClickedFacesGroup () {
    app.WIN3D.currentTool = app.UITASK.Layer;
    app.WIN3D.toolParameterModifier = 3; // Assign(all)
    app.User3D.creatorLayer = 5;
    app.allFaces.options = new int[][]{
      {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}
    };
    app.allGroups.makeEmpty(0);
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // group spanning faces [0,3) at creation time
    app.allGroups.setStart_Face(0, 0);
    app.allGroups.setStop_Face(0, 2); // faces 0..2 belong to this one group

    app.pickOrAssignFaceProperty(1); // click lands on the middle face of the group

    assertEquals(5, app.allFaces.getLayer(0));
    assertEquals(5, app.allFaces.getLayer(1));
    assertEquals(5, app.allFaces.getLayer(2));
  }

  @Test
  void pickOrAssignFaceProperty_assignAllsWeightCaseUsesSetCloseNotSetWeight () {
    // Documents the pre-existing quirk this extraction preserves
    // verbatim rather than fixing: unlike Pick and Assign(sub) just
    // above it, Assign(all)'s Weight case writes via allFaces.setClose,
    // not setWeight.
    app.WIN3D.currentTool = app.UITASK.Weight;
    app.WIN3D.toolParameterModifier = 3; // Assign(all)
    app.User3D.creatorWeight = 3;
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allGroups.makeEmpty(0);
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0);
    app.allGroups.setStart_Face(0, 0);
    app.allGroups.setStop_Face(0, 0);

    app.pickOrAssignFaceProperty(0);

    assertEquals(0, app.allFaces.getWeight(0)); // NOT written
    assertEquals(3, app.allFaces.getClose(0));   // written instead
  }

  // === pickOrAssignModel2DSeedMaterial (extracted) ========

  @Test
  void pickOrAssignModel2DSeedMaterial_isANoOpWhenTheCurrentTaskIsntSeedMaterial () {
    app.WIN3D.currentTool = app.UITASK.Move;
    app.WIN3D.toolParameterModifier = 1;
    app.allModel2Ds.peopleFileCount = 2;
    app.allModel2Ds.MAP = new int[]{5};
    app.User3D.creatorPlantTypeIndex = -1;

    app.pickOrAssignModel2DSeedMaterial(0);

    assertEquals(-1, app.User3D.creatorPlantTypeIndex); // untouched
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_pickOfAPersonReadsItsTypeIntoCreatePersonType () {
    app.WIN3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.toolParameterModifier = 1; // Pick
    app.allModel2Ds.peopleFileCount = 5;
    app.allModel2Ds.MAP = new int[]{3}; // 3 <= peopleFileCount -> a person

    app.pickOrAssignModel2DSeedMaterial(0);

    assertEquals(3, app.User3D.creatorPersonTypeIndex);
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_pickOfATreeReadsItsOffsetTypeIntoCreatePlantType () {
    app.WIN3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.toolParameterModifier = 1; // Pick
    app.allModel2Ds.peopleFileCount = 5;
    app.allModel2Ds.MAP = new int[]{8}; // 8 > peopleFileCount -> a tree, offset type = 8-5 = 3

    app.pickOrAssignModel2DSeedMaterial(0);

    assertEquals(3, app.User3D.creatorPlantTypeIndex);
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_assignWritesTheCurrentTypePreservingTheInstancesOwnSign () {
    app.WIN3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.toolParameterModifier = 2; // Assign
    app.allModel2Ds.peopleFileCount = 5;
    app.allModel2Ds.MAP = new int[]{-8}; // a tree instance, flipped (negative)
    app.User3D.creatorPlantTypeIndex = 1;

    app.pickOrAssignModel2DSeedMaterial(0);

    assertEquals(-6, app.allModel2Ds.MAP[0]); // -(1 + 5), sign kept negative
  }

  @Test
  void pickOrAssignModel2DSeedMaterial_assignAllIsTreatedTheSameAsAssignSub () {
    app.WIN3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.toolParameterModifier = 3; // Assign(all) - no group distinction for MODEL2D
    app.allModel2Ds.peopleFileCount = 5;
    app.allModel2Ds.MAP = new int[]{2}; // a person instance
    app.User3D.creatorPersonTypeIndex = 4;

    app.pickOrAssignModel2DSeedMaterial(0);

    assertEquals(4, app.allModel2Ds.MAP[0]);
  }

  // ==== pickOrAssignModel1DProperty (extracted) ===========

  @Test
  void pickOrAssignModel1DProperty_pickOfASingleTaskReadsOnlyThatOneField () {
    app.WIN3D.toolParameterModifier = 1; // Pick
    app.WIN3D.currentTool = app.UITASK.BranchTilt;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); // create one instance to pick from
    app.allModel1Ds.setBranchTilt(0, 12.5f);
    app.User3D.creatorModel1DBranchTilt = -1;
    app.User3D.creatorModel1DLeafSize = -1;

    app.pickOrAssignModel1DProperty(0);

    assertEquals(12.5f, app.User3D.creatorModel1DBranchTilt, 0.0001f);
    assertEquals(-1f, app.User3D.creatorModel1DLeafSize, 0.0001f); // untouched: a different task
  }

  @Test
  void pickOrAssignModel1DProperty_assignOfASingleTaskWritesOnlyThatOneField () {
    app.WIN3D.toolParameterModifier = 2; // Assign
    app.WIN3D.currentTool = app.UITASK.TrunkSize;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    app.User3D.creatorModel1DTrunkSize = 6.25f;

    app.pickOrAssignModel1DProperty(0);

    assertEquals(6.25f, app.allModel1Ds.getTrunkSize(0), 0.0001f);
  }

  @Test
  void pickOrAssignModel1DProperty_model1DsPropsPicksAllThreeCoveredFieldsAtOnce () {
    app.WIN3D.toolParameterModifier = 1; // Pick
    app.WIN3D.currentTool = app.UITASK.Model1DsProps;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    app.allModel1Ds.setDegreeMax(0, 4);
    app.allModel1Ds.setTrunkSize(0, 2.5f);
    app.allModel1Ds.setLeafSize(0, 1.5f);

    app.pickOrAssignModel1DProperty(0);

    assertEquals(4, app.User3D.creatorModel1DDegreeMax);
    assertEquals(2.5f, app.User3D.creatorModel1DTrunkSize, 0.0001f);
    assertEquals(1.5f, app.User3D.creatorModel1DLeafSize, 0.0001f);
  }

  @Test
  void pickOrAssignModel1DProperty_isANoOpWhenModifyParameterIsZero () {
    app.WIN3D.toolParameterModifier = 0; // neither Pick nor Assign
    app.WIN3D.currentTool = app.UITASK.BranchTwist;
    app.allModel1Ds.makeEmpty(0);
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    app.allModel1Ds.setBranchTwist(0, 9);
    app.User3D.creatorModel1DBranchTwist = -1;

    app.pickOrAssignModel1DProperty(0);

    assertEquals(-1f, app.User3D.creatorModel1DBranchTwist, 0.0001f); // untouched
  }

  // ========= computeClickRay (extracted) ===================
  // Also de-duplicates: WIN3D.rotateXY_3DViewport_around_LandIntersection()
  // used to have this exact ray setup inlined a second time (confirmed
  // character-for-character identical, modulo `this.` vs `WIN3D.`, before
  // extracting) - it now calls this too.

  @Test
  void computeClickRay_perspectiveAtImageCenterWithNoRotation_matchesHandComputedValue () {
    // Same setup as WIN3DTest's calculateClick3D_atImageCenterWithNoRotation...
    // test, so ray_end is already confirmed there; this only checks the
    // extra ray_start/direction arithmetic layered on top of it.
    app.WIN3D.projectionTypeIndex = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;

    solarchvision_bim.ClickRay ray = app.computeClickRay(0, 0);

    assertArrayEquals(new float[]{0, 0, 10}, ray.start, 0.001f);

    float pntZ = (float) (0.5 / Math.tan(0.5 * Math.PI / 3.0));
    assertArrayEquals(new float[]{0, 0, -pntZ}, ray.direction, 0.001f);
  }

  @Test
  void computeClickRay_dividesTheCameraPositionByObjectsScale () {
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.cameraX = 20;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 0;
    app.overallScale = 2;

    solarchvision_bim.ClickRay ray = app.computeClickRay(0, 0);

    assertEquals(10f, ray.start[0], 0.001f); // 20 / 2
  }

  @Test
  void computeClickRay_perspectiveAlwaysStartsAtTheCameraRegardlessOfClickPosition () {
    // In perspective, every ray shares the same origin (the camera) -
    // only the direction changes with where on screen you clicked.
    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.cameraX = 5;
    app.WIN3D.cameraY = -3;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;

    solarchvision_bim.ClickRay centerRay = app.computeClickRay(0, 0);
    solarchvision_bim.ClickRay offCenterRay = app.computeClickRay(80, -40);

    assertArrayEquals(centerRay.start, offCenterRay.start, 0.0001f);
    assertNotEquals(centerRay.direction[0], offCenterRay.direction[0], 0.0001f);
  }

  @Test
  void computeClickRay_orthographicAtImageCenterStartsExactlyAtTheCamera () {
    // At the image center, ray_end (0,0) equals ray_center (0,0), so
    // the orthographic offset is exactly zero and the start point
    // matches the plain camera position, same as the perspective case.
    app.WIN3D.projectionTypeIndex = 0; // orthographic
    app.WIN3D.scale = 1;
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 1;
    app.WIN3D.cameraY = 2;
    app.WIN3D.cameraZ = 3;
    app.WIN3D.positionX = 7;
    app.WIN3D.positionY = 8;
    app.WIN3D.positionZ = 9;
    app.WIN3D.referenceScale = 100;
    app.WIN3D.zoom = 90;
    app.overallScale = 1;

    solarchvision_bim.ClickRay ray = app.computeClickRay(0, 0);

    assertArrayEquals(new float[]{1, 2, 3}, ray.start, 0.001f);
  }

  @Test
  void computeClickRay_orthographicRaysStayParallelRegardlessOfClickPosition () {
    // The defining property of orthographic projection: unlike
    // perspective, the ray's DIRECTION is the same no matter where on
    // screen you clicked - only its start point shifts.
    app.WIN3D.projectionTypeIndex = 0; // orthographic
    app.WIN3D.scale = 1;
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.WIN3D.positionX = 3;
    app.WIN3D.positionY = 4;
    app.WIN3D.positionZ = 0;
    app.WIN3D.referenceScale = 100;
    app.WIN3D.zoom = 90;
    app.overallScale = 1;

    solarchvision_bim.ClickRay centerRay = app.computeClickRay(0, 0);
    solarchvision_bim.ClickRay offCenterRay = app.computeClickRay(50, -30);

    assertArrayEquals(centerRay.direction, offCenterRay.direction, 0.0001f);
    assertNotEquals(centerRay.start[0], offCenterRay.start[0], 0.0001f); // but the start point does shift
  }

  // ========== getMoveOriginPoint (extracted) ===============

  @Test
  void getMoveOriginPoint_forAGroupReturnsTheSelectionsPivot () {
    // Same BoundingBox/align setup already confirmed directly in
    // Select3DTest's getPivot test - this only checks that the Move
    // handling routes GROUP through getPivot() at all.
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.BoundingBox = new float[][]{
      {0, 0, 0, 1, 1, 1, 0, 0, 0},
      {5, 5, 5, 1, 1, 1, 0, 0, 0},
      {10, 10, 10, 1, 1, 1, 0, 0, 0}
    };
    app.Select3D.pivotAlignmentX = 1;
    app.Select3D.pivotAlignmentY = 1;
    app.Select3D.pivotAlignmentZ = 1;

    float[] origin = app.getMoveOriginPoint();

    assertArrayEquals(new float[]{10, 10, 10}, origin, 0.001f);
  }

  @Test
  void getMoveOriginPoint_forAModel2DReturnsTheLastSelectedInstancesPosition () {
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.allModel2Ds.MAP = new int[]{0, 0, 0}; // 3 instances, values unused by getX/Y/Z
    app.allModel2Ds.XYZS = new float[][]{
      {1, 1, 1, 1}, {2, 2, 2, 1}, {99, 88, 77, 1} // last one should win
    };
    app.Select3D.model2DSelection = new int[]{0, 2}; // last id is 2, not the last array entry

    float[] origin = app.getMoveOriginPoint();

    assertArrayEquals(new float[]{99, 88, 77}, origin, 0.0001f);
  }

  @Test
  void getMoveOriginPoint_forAVertexReturnsThatPointsCoordinates () {
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.allVertices = new float[][]{{0, 0, 0}, {3, 4, 5}};
    app.Select3D.vertexSelection = new int[]{1};

    float[] origin = app.getMoveOriginPoint();

    assertArrayEquals(new float[]{3, 4, 5}, origin, 0.0001f);
  }

  @Test
  void getMoveOriginPoint_isUndefinedForACategoryMoveDoesntHandle () {
    app.currentObjectCategory = app.ObjectCategory.CAMERA; // not one of the five handled

    float[] origin = app.getMoveOriginPoint();

    assertFalse(app.is_defined(origin[0]));
    assertFalse(app.is_defined(origin[1]));
    assertFalse(app.is_defined(origin[2]));
  }

  // ========== computeMoveDelta (extracted) ==================

  @Test
  void computeMoveDelta_withPosVectorThreeMovesFreelyOnAllThreeAxes () {
    app.Select3D.positionVectorIndex = 3; // "All"

    float[] d = app.computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{3, 4, 5}, d, 0.0001f);
  }

  @Test
  void computeMoveDelta_withPosVectorZeroKeepsOnlyX () {
    app.Select3D.positionVectorIndex = 0;

    float[] d = app.computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{3, 0, 0}, d, 0.0001f);
  }

  @Test
  void computeMoveDelta_withPosVectorOneKeepsOnlyY () {
    app.Select3D.positionVectorIndex = 1;

    float[] d = app.computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{0, 4, 0}, d, 0.0001f);
  }

  @Test
  void computeMoveDelta_withPosVectorTwoKeepsOnlyZ () {
    app.Select3D.positionVectorIndex = 2; // positionVectorIndex's own default

    float[] d = app.computeMoveDelta(1, 2, 3, 4, 6, 8);

    assertArrayEquals(new float[]{0, 0, 5}, d, 0.0001f);
  }

  // ====== classifySuperOBJShape (extracted) ================

  @Test
  void classifySuperOBJShape_cubePowerCubePowerTwoIsParametric () {
    app.CubePower = 16;
    assertEquals(app.SUPEROBJ_SHAPE_PARAMETRIC, app.classifySuperOBJShape(16, 16, 2));
  }

  @Test
  void classifySuperOBJShape_twoTwoCubePowerIsSuperCylinder () {
    app.CubePower = 16;
    assertEquals(app.SUPEROBJ_SHAPE_SUPERCYLINDER, app.classifySuperOBJShape(2, 2, 16));
  }

  @Test
  void classifySuperOBJShape_cubePowerCubePowerCubePowerIsBox () {
    app.CubePower = 16;
    assertEquals(app.SUPEROBJ_SHAPE_BOX, app.classifySuperOBJShape(16, 16, 16));
  }

  @Test
  void classifySuperOBJShape_oneOneOneIsOctahedron () {
    assertEquals(app.SUPEROBJ_SHAPE_OCTAHEDRON, app.classifySuperOBJShape(1, 1, 1));
  }

  @Test
  void classifySuperOBJShape_anythingElseFallsBackToSuperSphere () {
    app.CubePower = 16;
    assertEquals(app.SUPEROBJ_SHAPE_SUPERSPHERE, app.classifySuperOBJShape(4, 4, 4));
    assertEquals(app.SUPEROBJ_SHAPE_SUPERSPHERE, app.classifySuperOBJShape(2, 2, 2));
  }

  @Test
  void classifySuperOBJShape_checksInOrderSoCubePowerCubePowerCubePowerNeverMatchesParametricFirst () {
    // pz==CubePower (16) here, not 2 - so this must NOT be classified
    // as Parametric even though px and py both equal CubePower too;
    // guards against a sloppy re-implementation collapsing the first
    // and third branches.
    app.CubePower = 16;
    assertEquals(app.SUPEROBJ_SHAPE_BOX, app.classifySuperOBJShape(16, 16, 16));
  }

  // ============ pick-list dispatcher functions (pre-existing) ============
  // handlePickListTrackClick/handlePickListClick are the two
  // reached from mouseClicked() itself; the other four (Wheel/ScrollDrag/
  // resetPickListDragState/cancelActivePickList) live in this same file
  // for mouseWheel()/mouseDragged()/mouseReleased()/the Esc handler
  // instead, but are simple enough one-line-per-picker loops to cover
  // here alongside their siblings. Each individual StationPicker method
  // they delegate to (handleClick, handleTrackClick, handleWheel, cancel)
  // is already covered directly, above - these tests only confirm the
  // dispatch itself: that the loop finds and defers to whichever picker
  // (if any) is actually active.

  @Test
  void handlePickListClick_delegatesToWhicheverPickerIsActive () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{app.new STATION()};
    app.climateTypicalYearCoordinates[0].setClimateTypicalYearFilename("station_0.epw");
    app.STATION.setClimateTypicalYearFilename("station_0.epw");

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[]{0};

    float[] row0 = app.climateTypicalYearPicker.rowRect(0);
    app.X_clicked = (int) (row0[0] + 2);
    app.Y_clicked = (int) (row0[1] + 2);

    assertTrue(app.handlePickListClick());
    assertFalse(app.climateTypicalYearPicker.active); // confirms it was really climateTypicalYearPicker that handled it
  }

  @Test
  void handlePickListClick_returnsFalseWhenNoPickerIsActive () {
    assertFalse(app.handlePickListClick());
  }

  @Test
  void handlePickListTrackClick_delegatesToWhicheverPickerIsActive () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[100];
    app.climateTypicalYearPicker.scrollOffset = 20;

    float[] track = app.climateTypicalYearPicker.scrollTrackRect();
    app.X_clicked = (int) (track[0] + 2);
    app.Y_clicked = (int) (track[1] + 2);

    assertTrue(app.handlePickListTrackClick());
    assertTrue(app.climateTypicalYearPicker.scrollOffset < 20); // confirms it was really climateTypicalYearPicker that paged
  }

  @Test
  void handlePickListTrackClick_returnsFalseWhenNoPickerIsActive () {
    assertFalse(app.handlePickListTrackClick());
  }

  @Test
  void handlePickListWheel_delegatesToWhicheverPickerIsActive () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;
    app.X_clicked = 10;
    app.Y_clicked = 10;

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[100];
    app.climateTypicalYearPicker.scrollOffset = 0;

    assertTrue(app.handlePickListWheel(1));
    assertEquals(1, app.climateTypicalYearPicker.scrollOffset);
  }

  @Test
  void handlePickListWheel_returnsFalseWhenNoPickerIsActive () {
    assertFalse(app.handlePickListWheel(1));
  }

  @Test
  void handlePickListScrollDrag_delegatesToWhicheverPickerIsDragging () {
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;
    app.WORLD.dX = 400;
    app.WORLD.dY = 300;

    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[100]; // needsScrollbar() -> true
    app.climateTypicalYearPicker.scrollThumbDragging = true; // already mid-drag, skips the "start a new drag" branch
    app.climateTypicalYearPicker.scrollDrag_startMouseY = 100;
    app.climateTypicalYearPicker.scrollDrag_startOffset = 5;
    app.mouseY = 100; // no movement since the drag started

    assertTrue(app.handlePickListScrollDrag());
    assertEquals(5, app.climateTypicalYearPicker.scrollOffset); // unchanged: zero delta
  }

  @Test
  void handlePickListScrollDrag_returnsFalseWhenNoPickerIsActive () {
    assertFalse(app.handlePickListScrollDrag());
  }

  @Test
  void resetPickListDragState_clearsTheDraggingFlagOnEveryPickerNotJustTheActiveOne () {
    app.climateTypicalYearPicker.scrollThumbDragging = true;
    app.climateArchivePicker.scrollThumbDragging = true;

    app.resetPickListDragState();

    assertFalse(app.climateTypicalYearPicker.scrollThumbDragging);
    assertFalse(app.climateArchivePicker.scrollThumbDragging);
  }

  @Test
  void cancelActivePickList_cancelsWhicheverPickerIsActive () {
    app.climateTypicalYearPicker.active = true;
    app.climateTypicalYearPicker.indices = new int[]{0, 1, 2};

    assertTrue(app.cancelActivePickList());

    assertFalse(app.climateTypicalYearPicker.active);
    assertEquals(0, app.climateTypicalYearPicker.indices.length);
  }

  @Test
  void cancelActivePickList_returnsFalseWhenNoPickerIsActive () {
    assertFalse(app.cancelActivePickList());
  }
}
