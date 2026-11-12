import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// The PIVOT command (extraCommands.pde) sets Select3D.pivotAlignmentX/Y/Z
// from one or more space-separated minX/midX/maxX/minY/midY/maxY/minZ/
// midZ/maxZ tokens (matched case-insensitively), each via one of
// UI_setTo_View_PivotX/Y/Z(n) (uiSetTo.pde) - pure field assignment
// (Select3D.pivotAlignmentX/Y/Z = n) plus UI_rollout.revise()/
// view_changed(), both already established as headlessly safe elsewhere
// in this suite. Was at 0% coverage.
class PivotCommandTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  // ================= one axis at a time =====================================

  @Test
  void minX_setsPivotAlignmentXToMinusOne () {
    assertEquals("", app.runScriptLine("PIVOT minX"));
    assertEquals(-1, app.Select3D.pivotAlignmentX);
  }

  @Test
  void midX_setsPivotAlignmentXToZero () {
    app.Select3D.pivotAlignmentX = -999;

    assertEquals("", app.runScriptLine("PIVOT midX"));

    assertEquals(0, app.Select3D.pivotAlignmentX);
  }

  @Test
  void maxX_setsPivotAlignmentXToOne () {
    assertEquals("", app.runScriptLine("PIVOT maxX"));
    assertEquals(1, app.Select3D.pivotAlignmentX);
  }

  @Test
  void minY_setsPivotAlignmentYToMinusOne () {
    assertEquals("", app.runScriptLine("PIVOT minY"));
    assertEquals(-1, app.Select3D.pivotAlignmentY);
  }

  @Test
  void midY_setsPivotAlignmentYToZero () {
    app.Select3D.pivotAlignmentY = -999;

    assertEquals("", app.runScriptLine("PIVOT midY"));

    assertEquals(0, app.Select3D.pivotAlignmentY);
  }

  @Test
  void maxY_setsPivotAlignmentYToOne () {
    assertEquals("", app.runScriptLine("PIVOT maxY"));
    assertEquals(1, app.Select3D.pivotAlignmentY);
  }

  @Test
  void minZ_setsPivotAlignmentZToMinusOne () {
    assertEquals("", app.runScriptLine("PIVOT minZ"));
    assertEquals(-1, app.Select3D.pivotAlignmentZ);
  }

  @Test
  void midZ_setsPivotAlignmentZToZero () {
    app.Select3D.pivotAlignmentZ = -999;

    assertEquals("", app.runScriptLine("PIVOT midZ"));

    assertEquals(0, app.Select3D.pivotAlignmentZ);
  }

  @Test
  void maxZ_setsPivotAlignmentZToOne () {
    assertEquals("", app.runScriptLine("PIVOT maxZ"));
    assertEquals(1, app.Select3D.pivotAlignmentZ);
  }

  // ================= several tokens in one call ==============================

  @Test
  void multipleTokensInOneCall_setAllThreeAxesTogether () {
    assertEquals("", app.runScriptLine("PIVOT minX midY maxZ"));

    assertEquals(-1, app.Select3D.pivotAlignmentX);
    assertEquals(0, app.Select3D.pivotAlignmentY);
    assertEquals(1, app.Select3D.pivotAlignmentZ);
  }

  @Test
  void laterTokensOverrideEarlierOnesForTheSameAxis () {
    assertEquals("", app.runScriptLine("PIVOT minX maxX"));

    assertEquals(1, app.Select3D.pivotAlignmentX, "maxX, the later token, must win");
  }

  // ================= case-insensitivity ======================================

  @Test
  void tokensAreMatchedCaseInsensitively () {
    assertEquals("", app.runScriptLine("PIVOT MINX MIDY MAXZ"));

    assertEquals(-1, app.Select3D.pivotAlignmentX);
    assertEquals(0, app.Select3D.pivotAlignmentY);
    assertEquals(1, app.Select3D.pivotAlignmentZ);
  }

  // ================= no arguments ============================================

  @Test
  void withNoArguments_returnsAUsageHintAndChangesNothing () {
    assertEquals("PIVOT minX midY maxZ or other variations", app.runScriptLine("PIVOT"));

    assertEquals(0, app.Select3D.pivotAlignmentX);
    assertEquals(0, app.Select3D.pivotAlignmentY);
    assertEquals(0, app.Select3D.pivotAlignmentZ);
  }

  // ================= an unrecognized token ====================================

  @Test
  void anUnrecognizedToken_isSilentlyIgnored_stillReturningABlankHint () {
    // Unlike the no-argument case above, an unrecognized token among a
    // present argument list isn't an error - the if/else-if chain simply
    // never matches it, so parts.length > 1 is still true and the
    // command returns successfully with nothing changed.
    assertEquals("", app.runScriptLine("PIVOT bogus"));

    assertEquals(0, app.Select3D.pivotAlignmentX);
    assertEquals(0, app.Select3D.pivotAlignmentY);
    assertEquals(0, app.Select3D.pivotAlignmentZ);
  }
}
