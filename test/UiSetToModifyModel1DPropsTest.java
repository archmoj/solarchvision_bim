import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// uiSetTo.pde's 8 Model1D-property tool-mode setters - UI_setTo_Modify_
// DegreeMax/BranchTilt/BranchTwist/BranchRatio/TreeBase/TrunkSize/
// LeafSize/Model1DsProps - each the exact same pure shape
// UiSetToModifyAndViewTest.java's own header comment already describes
// for the rest of the UI_setTo_Modify_*()/UI_setTo_View_*() family:
// User3D.currentTool plus one int field (here, toolParameterModifier -
// n itself, "0:change selection 1:pick from 2:assign to" per each
// function's own comment), not real camera/geometry math. All 8 were at
// 0% coverage - this file is their direct counterpart to that one's
// "Modify_* : *VectorIndex family" section, just for Model1D properties
// instead.
class UiSetToModifyModel1DPropsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void modifyDegreeMax_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_DegreeMax(1);

    assertEquals(app.UITASK.DegreeMax, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyBranchTilt_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_BranchTilt(2);

    assertEquals(app.UITASK.BranchTilt, app.User3D.currentTool);
    assertEquals(2, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyBranchTwist_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_BranchTwist(0);

    assertEquals(app.UITASK.BranchTwist, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyBranchRatio_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_BranchRatio(1);

    assertEquals(app.UITASK.BranchRatio, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyTreeBase_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_TreeBase(2);

    assertEquals(app.UITASK.TreeBase, app.User3D.currentTool);
    assertEquals(2, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyTrunkSize_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_TrunkSize(1);

    assertEquals(app.UITASK.TrunkSize, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyLeafSize_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_LeafSize(2);

    assertEquals(app.UITASK.LeafSize, app.User3D.currentTool);
    assertEquals(2, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyModel1DsProps_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_Model1DsProps(1);

    assertEquals(app.UITASK.Model1DsProps, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
  }

  // ================= each sets a distinct currentTool from the others ========
  // Guards against a copy-paste slip (e.g. two of these accidentally
  // both setting UITASK.BranchTilt) - every one of the 8 commands above
  // must land on its own distinct UITASK constant.

  @Test
  void everyModel1DPropertyTool_isADistinctUITASKConstant () {
    java.util.Set<Integer> tools = new java.util.HashSet<>(java.util.Arrays.asList(
        app.UITASK.DegreeMax, app.UITASK.BranchTilt, app.UITASK.BranchTwist,
        app.UITASK.BranchRatio, app.UITASK.TreeBase, app.UITASK.TrunkSize,
        app.UITASK.LeafSize, app.UITASK.Model1DsProps
    ));

    assertEquals(8, tools.size(), "all 8 UITASK constants must be distinct");
  }
}
