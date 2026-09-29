import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class LayersTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= changeCurrentLayerTo =================================

  @Test
  void changeCurrentLayerTo_updatesCurrentLayerFieldsToMatchTheChosenLayer () {
    app.changeCurrentLayerTo(3); // LAYER_windspd

    solarchvision_bim.LAYER expected = app.allLayers[3];

    assertEquals(3, app.CurrentLayer_id);
    assertEquals(3, app.DevelopLayer_id);
    assertEquals(expected.unit, app.CurrentLayer_unit);
    assertEquals(expected.name, app.CurrentLayer_name);
    assertEquals(expected.descriptions[app.Language_EN], app.CurrentLayer_descriptions[app.Language_EN]);
    assertEquals(expected.descriptions[app.Language_FR], app.CurrentLayer_descriptions[app.Language_FR]);
  }

  @Test
  void changeCurrentLayerTo_alsoUpdatesSTUDYsVerticalScaleFields () {
    app.changeCurrentLayerTo(5); // LAYER_drybulb

    solarchvision_bim.LAYER expected = app.allLayers[5];

    assertEquals(expected.V_scale, app.STUDY.V_scale, 0.0001f);
    assertEquals(expected.V_offset, app.STUDY.V_offset, 0.0001f);
    assertEquals(expected.V_belowLine, app.STUDY.V_belowLine, 0.0001f);
  }

  @Test
  void changeCurrentLayerTo_setsBothDevelopAndCurrentLayerIdToTheSameNewId () {
    app.DevelopLayer_id = 0;
    app.CurrentLayer_id = 0;

    app.changeCurrentLayerTo(9);

    assertEquals(9, app.DevelopLayer_id);
    assertEquals(9, app.CurrentLayer_id);
  }

  @Test
  void changeCurrentLayerTo_switchingTwiceLeavesOnlyTheSecondLayersDataInEffect () {
    app.changeCurrentLayerTo(2);
    app.changeCurrentLayerTo(7);

    solarchvision_bim.LAYER expected = app.allLayers[7];

    assertEquals(7, app.CurrentLayer_id);
    assertEquals(expected.name, app.CurrentLayer_name);
    assertEquals(expected.unit, app.CurrentLayer_unit);
  }

  @Test
  void changeCurrentLayerTo_canSwitchToTheDevelopedPlaceholderLayer () {
    int lastIndex = app.allLayers.length - 1; // LAYER_developed
    app.changeCurrentLayerTo(lastIndex);

    assertEquals(lastIndex, app.CurrentLayer_id);
    assertEquals("", app.CurrentLayer_name);
    assertEquals("", app.CurrentLayer_unit);
  }

  // ================= allLayers table =======================================

  @Test
  void allLayers_hasAUniqueSequentialIdMatchingItsArrayIndex () {
    for (int i = 0; i < app.allLayers.length; i++) {
      assertEquals(i, app.allLayers[i].id);
    }
  }

  @Test
  void allLayers_isNotEmptyAndEndsWithTheDevelopedPlaceholder () {
    assertTrue(app.allLayers.length > 0);

    solarchvision_bim.LAYER last = app.allLayers[app.allLayers.length - 1];
    assertEquals("", last.unit);
    assertEquals("", last.name);
    assertEquals("", last.descriptions[app.Language_EN]);
    assertEquals("", last.descriptions[app.Language_FR]);
  }

  @Test
  void allLayers_everyNonPlaceholderLayerHasBothLanguageDescriptions () {
    for (int i = 0; i < app.allLayers.length - 1; i++) { // last one is the empty placeholder
      solarchvision_bim.LAYER layer = app.allLayers[i];
      assertFalse(layer.descriptions[app.Language_EN].isEmpty(), "index " + i + " missing an EN description");
      assertFalse(layer.descriptions[app.Language_FR].isEmpty(), "index " + i + " missing a FR description");
    }
  }

  // ================= initial state (before any switch) =====================

  @Test
  void initialCurrentLayer_matchesTheFirstEntryInAllLayers () {
    solarchvision_bim.LAYER first = app.allLayers[0];

    assertEquals(0, app.CurrentLayer_id);
    assertEquals(first.unit, app.CurrentLayer_unit);
    assertEquals(first.name, app.CurrentLayer_name);
  }
}
