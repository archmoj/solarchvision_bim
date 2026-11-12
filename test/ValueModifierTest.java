import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// ValueModifier (vm, valueModifier.pde) is a long tail of ~150 small,
// near-identical methods - one per UI spinner - 5160 missed instructions
// together in the merged (unit + image) report, none individually huge
// but adding up to the single largest chunk outside the handful of
// giant functions. Each one has the same shape:
//
//   if (created == 0) {
//     putValueAction(command, getter, setter, minGetter, maxGetter,
//                     step, u1, u2, u3, onChanged);
//   } else {
//     out = UI_rollout.Spinner(...); // real drawing - out of scope
//   }
//
// build_allActions() already calls every one of these with created==0
// (via its own final step, UI_rollout.registerSpinnerActions() -
// uiRollout.pde), so that branch's own OUTER structure was already
// reached by any existing test that calls build_allActions() - but the
// getter/setter/min/max lambda bodies putValueAction() registers there
// only actually execute once the resulting named action (e.g. "Impact
// Display Day") is triggered, via runScriptLine() or callAction() - the
// same shape ShadePreviousDayActionTest.java's own "Shade Previous Day"
// test already uses for a different kind of registered action. Nothing
// in either suite apparently ever triggers any of these spinner actions
// by name, which is what each test below actually does.
//
// This covers 3 representative methods (impactDisplayDay: int,
// cameraClipNear: float with no onChange, currentCameraIndex: int with
// a real onChange side effect, react.applyCurrentCamera) to demonstrate
// the pattern, not all ~150 - each one follows the identical shape, so
// the same 3-test recipe (valid value / out-of-range rejection /
// missing-argument rejection) generalizes directly to any of the others.
class ValueModifierTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  // ================= impactDisplayDay (int, no onChange) =====================
  // Bounds: 0..(STUDY.endDay - STUDY.startDay) == 0..12 at STUDY's own
  // bare-construction defaults, step 1.

  @Test
  void impactDisplayDay_withAValidValue_setsIt () {
    app.vm.impactDisplayDay(0); // registers the action

    assertEquals("", app.runScriptLine("Impact Display Day 5"));

    assertEquals(5, app.impactDisplayDay);
  }

  @Test
  void impactDisplayDay_withAnOutOfRangeValue_rejectsIt_leavingTheFieldUnchanged () {
    app.vm.impactDisplayDay(0);
    app.impactDisplayDay = 3;

    app.runScriptLine("Impact Display Day 999"); // max is 12

    assertEquals(3, app.impactDisplayDay, "putValueAction()'s own bounds check must reject this, not clamp it");
  }

  @Test
  void impactDisplayDay_withNoValue_isRejected_leavingTheFieldUnchanged () {
    app.vm.impactDisplayDay(0);
    app.impactDisplayDay = 3;

    app.runScriptLine("Impact Display Day");

    assertEquals(3, app.impactDisplayDay);
  }

  // ================= cameraClipNear (float, no onChange) =====================
  // Bounds: 0.01..100, rounded to the nearest 0.001.

  @Test
  void cameraClipNear_withAValidValue_setsIt () {
    app.vm.cameraClipNear(0);

    app.runScriptLine("Camera Clip Near 5.5");

    assertEquals(5.5f, app.WIN3D.cameraClipNear, 0.0001f);
  }

  @Test
  void cameraClipNear_belowItsMinimum_rejectsIt_leavingTheFieldUnchanged () {
    app.vm.cameraClipNear(0);
    app.WIN3D.cameraClipNear = 1.0f;

    app.runScriptLine("Camera Clip Near 0.001"); // below the 0.01 minimum

    assertEquals(1.0f, app.WIN3D.cameraClipNear, 0.0001f);
  }

  // ================= currentCameraIndex (int, WITH an onChange side effect) ==
  // Bounds: 0..max(0, allCameras.num - 1) - a second real camera is
  // added below so index 1 is actually in range, and so
  // react.applyCurrentCamera (the onChanged callback) has real,
  // different camera data to apply.

  @Test
  void currentCameraIndex_withAValidIndex_setsItAndRunsTheOnChangeCallback () {
    app.allCameras.create(0, 0, 0, 1, 0, 0, 0, 5, 60, 1); // camera index 1
    app.vm.currentCameraIndex(0);

    app.runScriptLine("Current Camera Index 1");

    assertEquals(1, app.WIN3D.currentCameraIndex);
    // react.applyCurrentCamera's own first step - confirms the
    // onChanged callback actually ran, not just the setter.
    assertEquals(app.allCameras.get_rotX(1), app.WIN3D.rotationX, 0.0001f);
  }

  @Test
  void currentCameraIndex_withAnOutOfRangeIndex_rejectsIt () {
    // Only camera 0 exists - max is 0, so index 1 is out of range.
    app.vm.currentCameraIndex(0);
    app.WIN3D.currentCameraIndex = 0;

    app.runScriptLine("Current Camera Index 1");

    assertEquals(0, app.WIN3D.currentCameraIndex);
  }
}
