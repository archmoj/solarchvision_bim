import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.data.JSONObject;

// EXTRAPARAMS.SET/EXTRAPARAMS.REMOVE (extraCommands.pde, dispatched from
// runScript.pde) and the dotted-path helpers they're built on
// (extraParamsPath.pde) - the command-line/engine half of
// PARENT_EXTRAPARAMS (uiRollout.pde doesn't have JUnit-reachable tests
// of its own, same as every other Processing-drawn rollout page in this
// app; its row widgets are thin wrappers around exactly the path helpers
// and commands covered here).
class ExtraParamsCommandTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.allActions = new java.util.HashMap<>();
  }

  private int makeFace () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    return app.allFaces.create(new int[]{ p0, p1, p2 });
  }

  // ================= extraParamsSetAtPath ===================================

  @Test
  void setAtPath_createsTopLevelScalarKey () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "name", "Window Panel A");
    assertEquals("Window Panel A", obj.getString("name"));
  }

  @Test
  void setAtPath_upsertsExistingKey () {
    JSONObject obj = new JSONObject();
    obj.setString("name", "Old");
    app.extraParamsSetAtPath(obj, "name", "New");
    assertEquals("New", obj.getString("name"));
  }

  @Test
  void setAtPath_createsIntermediateObjectsAutomatically () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "ifcShape.depth", "0.2");
    assertTrue(obj.getJSONObject("ifcShape").getFloat("depth") - 0.2f < 0.0001f);
  }

  @Test
  void setAtPath_overwritesNonObjectIntermediateSegment_extraparamsAlwaysWins () {
    JSONObject obj = new JSONObject();
    obj.setString("ifcShape", "not an object"); // pre-existing scalar at the path's own intermediate segment
    app.extraParamsSetAtPath(obj, "ifcShape.depth", "0.2");
    assertEquals(0.2f, obj.getJSONObject("ifcShape").getFloat("depth"), 0.0001f);
  }

  @Test
  void setAtPath_bareNumberDecodesAsARealNumber () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "depth", "0.2");
    assertEquals(0.2f, obj.getFloat("depth"), 0.0001f);
  }

  @Test
  void setAtPath_bareBooleanDecodesAsARealBoolean () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "flag", "true");
    assertTrue(obj.getBoolean("flag"));
  }

  @Test
  void setAtPath_quotedStringDecodesStandardJsonEscapes () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "description", "\"South wall\\nupper row\"");
    assertEquals("South wall\nupper row", obj.getString("description"));
  }

  @Test
  void setAtPath_bareUnquotedTextFallsBackToALiteralString () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "name", "Window Panel A"); // unquoted, has spaces - not valid JSON on its own
    assertEquals("Window Panel A", obj.getString("name"));
  }

  @Test
  void setAtPath_bareNullStoresARealExplicitNull_notADeleteSentinel () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "someField", "null");
    assertTrue(obj.hasKey("someField"));
    assertTrue(obj.isNull("someField"));
  }

  @Test
  void setAtPath_bracedObjectDecodesAsANestedObject () {
    JSONObject obj = new JSONObject();
    app.extraParamsSetAtPath(obj, "ifcShape", "{\"a\":1,\"b\":2}");
    assertEquals(1, obj.getJSONObject("ifcShape").getInt("a"));
    assertEquals(2, obj.getJSONObject("ifcShape").getInt("b"));
  }

  // ================= extraParamsRemoveAtPath =================================

  @Test
  void removeAtPath_removesTopLevelKey () {
    JSONObject obj = new JSONObject();
    obj.setString("name", "Window Panel A");
    boolean removed = app.extraParamsRemoveAtPath(obj, "name");
    assertTrue(removed);
    assertFalse(obj.hasKey("name"));
  }

  @Test
  void removeAtPath_removesNestedKey_leavesParentAndSiblingsIntact () {
    JSONObject obj = new JSONObject();
    JSONObject shape = new JSONObject();
    shape.setFloat("depth", 0.2f);
    shape.setString("axisUnit", "[0,0,1]");
    obj.setJSONObject("ifcShape", shape);

    boolean removed = app.extraParamsRemoveAtPath(obj, "ifcShape.depth");

    assertTrue(removed);
    assertFalse(obj.getJSONObject("ifcShape").hasKey("depth"));
    assertTrue(obj.getJSONObject("ifcShape").hasKey("axisUnit")); // sibling untouched
  }

  @Test
  void removeAtPath_missingKey_isANoOp_returnsFalse () {
    JSONObject obj = new JSONObject();
    boolean removed = app.extraParamsRemoveAtPath(obj, "doesNotExist");
    assertFalse(removed);
  }

  @Test
  void removeAtPath_missingIntermediateSegment_isANoOp_doesNotThrow () {
    JSONObject obj = new JSONObject();
    boolean removed = app.extraParamsRemoveAtPath(obj, "doesNotExist.child");
    assertFalse(removed);
  }

  // ================= EXTRAPARAMS.SET command dispatch ========================

  @Test
  void extraparamsSet_noSelection_returnsUsageHint_changesNothing () {
    String hint = app.runScriptLine("EXTRAPARAMS.SET name Window Panel A");
    assertTrue(hint.startsWith("EXTRAPARAMS.SET"));
    assertTrue(hint.contains("selected"));
  }

  @Test
  void extraparamsSet_multipleSelected_isTreatedAsNoSelection () {
    int f0 = makeFace();
    int f1 = makeFace();
    app.Select3D.faceSelection = new int[]{ f0, f1 };

    String hint = app.runScriptLine("EXTRAPARAMS.SET name Window Panel A");

    assertTrue(hint.contains("selected"));
    assertEquals("", app.allFaces.getExtraParams(f0));
    assertEquals("", app.allFaces.getExtraParams(f1));
  }

  @Test
  void extraparamsSet_singleFaceSelected_upsertsScalarKey () {
    int f = makeFace();
    app.Select3D.faceSelection = new int[]{ f };

    String hint = app.runScriptLine("EXTRAPARAMS.SET name Window Panel A");

    assertEquals("", hint);
    assertEquals("Window Panel A", app.allFaces.getExtraParamsObject(f).getString("name"));
  }

  @Test
  void extraparamsSet_nestedPath_setsIntoChildObject () {
    int f = makeFace();
    app.Select3D.faceSelection = new int[]{ f };

    app.runScriptLine("EXTRAPARAMS.SET ifcShape.depth 0.2");

    JSONObject obj = app.allFaces.getExtraParamsObject(f);
    assertEquals(0.2f, obj.getJSONObject("ifcShape").getFloat("depth"), 0.0001f);
  }

  @Test
  void extraparamsSet_rawLineBypass_valueWithQuotesAndEscapedNewlineSurvivesIntact () {
    int f = makeFace();
    app.Select3D.faceSelection = new int[]{ f };

    // tokenizeScriptLine() would strip the quotes and never touch "\n" as
    // two characters anyway, but it WOULD collapse the repeated internal
    // spaces if this command went through the ordinary `parts` dispatch -
    // this is the one thing that bypassing it is actually for.
    app.runScriptLine("EXTRAPARAMS.SET description \"South  wall\\nupper row\"");

    String stored = app.allFaces.getExtraParamsObject(f).getString("description");
    assertEquals("South  wall\nupper row", stored); // double space preserved, \n decoded to a real newline
  }

  @Test
  void extraparamsSet_missingValue_returnsUsageHint_changesNothing () {
    int f = makeFace();
    app.Select3D.faceSelection = new int[]{ f };

    String hint = app.runScriptLine("EXTRAPARAMS.SET name");

    assertEquals("EXTRAPARAMS.SET <key> <value>", hint);
    assertEquals("", app.allFaces.getExtraParams(f));
  }

  @Test
  void extraparamsSet_upsertOverExistingDifferentKey_leavesSiblingsIntact () {
    int f = makeFace();
    app.allFaces.setExtraParams(f, "{\"globalId\":\"abc123\"}");
    app.Select3D.faceSelection = new int[]{ f };

    app.runScriptLine("EXTRAPARAMS.SET name Window Panel A");

    JSONObject obj = app.allFaces.getExtraParamsObject(f);
    assertEquals("abc123", obj.getString("globalId"));
    assertEquals("Window Panel A", obj.getString("name"));
  }

  // ================= EXTRAPARAMS.REMOVE command dispatch =====================

  @Test
  void extraparamsRemove_noSelection_returnsUsageHint () {
    String hint = app.runScriptLine("EXTRAPARAMS.REMOVE name");
    assertTrue(hint.contains("selected"));
  }

  @Test
  void extraparamsRemove_missingArgument_returnsUsageHint () {
    int f = makeFace();
    app.Select3D.faceSelection = new int[]{ f };

    String hint = app.runScriptLine("EXTRAPARAMS.REMOVE");

    assertEquals("EXTRAPARAMS.REMOVE <key>", hint);
  }

  @Test
  void extraparamsRemove_removesKey () {
    int f = makeFace();
    app.allFaces.setExtraParams(f, "{\"name\":\"Window Panel A\"}");
    app.Select3D.faceSelection = new int[]{ f };

    app.runScriptLine("EXTRAPARAMS.REMOVE name");

    assertFalse(app.allFaces.getExtraParamsObject(f).hasKey("name"));
  }

  @Test
  void extraparamsRemove_nestedKey_leavesSiblingAndParentIntact () {
    int f = makeFace();
    app.allFaces.setExtraParams(f, "{\"ifcShape\":{\"depth\":0.2,\"axisUnit\":[0,0,1]}}");
    app.Select3D.faceSelection = new int[]{ f };

    app.runScriptLine("EXTRAPARAMS.REMOVE ifcShape.depth");

    JSONObject obj = app.allFaces.getExtraParamsObject(f);
    assertTrue(obj.hasKey("ifcShape"));
    assertFalse(obj.getJSONObject("ifcShape").hasKey("depth"));
    assertTrue(obj.getJSONObject("ifcShape").hasKey("axisUnit"));
  }

  @Test
  void extraparamsRemove_isCaseInsensitiveLikeEveryOtherCommand () {
    int f = makeFace();
    app.allFaces.setExtraParams(f, "{\"name\":\"Window Panel A\"}");
    app.Select3D.faceSelection = new int[]{ f };

    app.runScriptLine("extraparams.remove name");

    assertFalse(app.allFaces.getExtraParamsObject(f).hasKey("name"));
  }
}
