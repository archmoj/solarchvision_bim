import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// Guards against the exact class of bug this file is named after: two
// different commands (in actions.pde and/or ValueModifier.pde) registering
// under the same allActions key. Since allActions is one flat map, a
// collision doesn't fail loudly - the second registration just silently
// overwrites the first, and the earlier command becomes unreachable from
// both the menu and the command line. "Hide Selected Faces" was exactly
// this: two unrelated actions sharing one caption, with the Select3D one
// (registered later) silently shadowing the Modify3D one.
//
// Every check below computes its key(s) the same way putAction() itself
// does (see actions.pde's normalizeActionKey and the "withSpace" fallback
// registration) - applied in code to a string pasted verbatim from the
// source, never a hand-typed lowercase/underscore guess. A typo in a
// hand-converted key silently tests nothing (it just won't be found in
// allActions either way); computing the key from the exact source string
// is the only way these tests actually test what they claim to.
class CommandRegistryTest {

  private static solarchvision_bim app;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  // Mirrors actions.pde's private normalizeActionKey(String) exactly -
  // that method isn't reachable from here (private, different top-level
  // class), but it's a one-line transform, safe to mirror rather than
  // worth changing its visibility for.
  private static String normalizeKey (String caption) {
    return caption.toLowerCase().replace(' ', '_');
  }

  // ================= static source scan: no two commands collide =========
  // Reads the actual .pde source (not the running app), so it fails the
  // moment a collision is introduced - whether or not anything ever
  // exercises the shadowed command at runtime.

  private static final Pattern PUT_ACTION = Pattern.compile(
    "put(?:Value)?Action\\(\\s*\"((?:[^\"\\\\]|\\\\.)*)\""
  );

  // ValueModifier.pde's methods no longer pass a literal string to
  // putValueAction() - they pass the `command` variable declared just
  // above it (see String command = "..."; in each method). That
  // declaration line is the exact source string to read instead.
  private static final Pattern COMMAND_DECLARATION = Pattern.compile(
    "String command = \"((?:[^\"\\\\]|\\\\.)*)\";"
  );

  private static List<String> extractPutActionTitles (String sourcePath) throws IOException {
    String content = Files.readString(Path.of(sourcePath));
    List<String> titles = new ArrayList<>();
    Matcher m = PUT_ACTION.matcher(content);
    while (m.find()) {
      titles.add(m.group(1));
    }
    return titles;
  }

  private static List<String> extractCommandDeclarations (String sourcePath) throws IOException {
    String content = Files.readString(Path.of(sourcePath));
    List<String> titles = new ArrayList<>();
    Matcher m = COMMAND_DECLARATION.matcher(content);
    while (m.find()) {
      titles.add(m.group(1));
    }
    return titles;
  }

  @Test
  void noTwoRegisteredCommandsShareANormalizedKey () throws IOException {
    List<String> titles = new ArrayList<>();
    titles.addAll(extractPutActionTitles("src/solarchvision_bim/actions.pde"));
    titles.addAll(extractCommandDeclarations("src/solarchvision_bim/ValueModifier.pde"));

    assertTrue(titles.size() > 700, "sanity check: expected hundreds of registered " +
      "commands from both files combined, found " + titles.size() + " - did a source " +
      "path, or one of the two extraction patterns, stop matching?");

    // key -> every distinct title that maps to it (dynamic captions built
    // via string concatenation, like "Layout " + nf(layoutIndex, 0), only
    // ever contribute their literal prefix here - the same simplification
    // used to find the Hide Selected Faces bug in the first place).
    Map<String, List<String>> byKey = new LinkedHashMap<>();
    for (String title : titles) {
      String key = normalizeKey(title);
      String withSpace = title.toLowerCase();

      byKey.computeIfAbsent(key, k -> new ArrayList<>()).add(title);
      if (!withSpace.equals(key)) {
        byKey.computeIfAbsent(withSpace, k -> new ArrayList<>()).add(title);
      }
    }

    List<String> problems = new ArrayList<>();
    for (Map.Entry<String, List<String>> entry : byKey.entrySet()) {
      // Deliberately NOT de-duplicated: the bug this guards against was two
      // actions registered under the literal identical string "Hide
      // Selected Faces" - any key receiving more than one registration is
      // a collision, whether the source titles are identical or merely
      // normalize to the same key.
      List<String> registrations = entry.getValue();
      if (registrations.size() > 1) {
        problems.add("\"" + entry.getKey() + "\" <- " + registrations);
      }
    }

    assertTrue(problems.isEmpty(),
      "Found " + problems.size() + " colliding command key(s) - the " +
      "later registration silently shadows the earlier one:\n" +
      String.join("\n", problems));
  }

  // ================= targeted checks for the Select3D.faceDisplayEdges pair ===
  // The exact bug this whole file guards against: confirms both commands
  // are independently reachable now, using their literal source strings.

  @Test
  void hideSelectedFacesEdges_isReachableAndDistinctFromHideSelectedFaces () {
    app.build_allActions();

    assertTrue(app.allActions.containsKey(normalizeKey("Hide Selected Faces Edges")));
    assertTrue(app.allActions.containsKey(normalizeKey("Hide Selected Faces")));
    assertNotEquals(
      app.allActions.get(normalizeKey("Hide Selected Faces Edges")),
      app.allActions.get(normalizeKey("Hide Selected Faces")),
      "these must be two different Actions, not the same one registered twice"
    );
  }

  @Test
  void showSelectedFacesEdges_isReachable () {
    app.build_allActions();

    assertTrue(app.allActions.containsKey(normalizeKey("Show Selected Faces Edges")));
  }

  @Test
  void hideSelectedFacesEdges_actuallyTogglesSelect3DFaceDisplayEdges () {
    app.build_allActions();
    app.Select3D.faceDisplayEdges = true;

    app.allActions.get(normalizeKey("Hide Selected Faces Edges")).run(new String[0]);

    assertFalse(app.Select3D.faceDisplayEdges);
  }

  @Test
  void hideSelectedFaces_actuallyHidesTheSelectedFaceGeometryNotTheEdgesOverlay () {
    // The command that was previously shadowed: confirms it reaches
    // Modify3D's geometry operation, not Select3D.faceDisplayEdges.
    app.build_allActions();
    app.Select3D.faceDisplayEdges = true; // must be left untouched by this command

    assertDoesNotThrow(() -> app.allActions.get(normalizeKey("Hide Selected Faces")).run(new String[0]));

    assertTrue(app.Select3D.faceDisplayEdges, "Hide Selected Faces must not touch the edges-overlay flag");
  }

  // ================= a couple of ValueModifier commands, as a pattern ========
  // Demonstrates the same exact-string principle for putValueAction-based
  // commands: the literal title from ValueModifier.pde's own
  // `String command = "...";` line, normalized in code - never a
  // hand-typed "ensemble_observation_max_days"-style guess.

  @Test
  void ensembleObservationMaxDays_isRegisteredUnderItsExactTitle () {
    app.vm.ensembleObservationMaxDays(0);

    assertTrue(app.allActions.containsKey(normalizeKey("Ensemble Observation Max Days")));
  }

  @Test
  void solidImpactsR_isRegisteredUnderItsExactTitle () {
    // One of the "dynamic Spinner label" methods - the console-command
    // title is still static ("Solid Impacts R"), only the on-screen
    // Spinner caption varies with the current section index.
    app.vm.SolidImpacts_r(0);

    assertTrue(app.allActions.containsKey(normalizeKey("Solid Impacts R")));
  }
}
