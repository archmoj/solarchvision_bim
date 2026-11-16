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

    assertEquals(3, app.currentLayerId);
    assertEquals(3, app.developLayerId);
    assertEquals(expected.unit, app.CurrentLayer_unit);
    assertEquals(expected.name, app.CurrentLayer_name);
    assertEquals(expected.descriptions[app.Language_EN], app.CurrentLayer_descriptions[app.Language_EN]);
    assertEquals(expected.descriptions[app.Language_FR], app.CurrentLayer_descriptions[app.Language_FR]);
  }

  @Test
  void changeCurrentLayerTo_alsoUpdatesSTUDYsVerticalScaleFields () {
    app.changeCurrentLayerTo(5); // LAYER_drybulb

    solarchvision_bim.LAYER expected = app.allLayers[5];

    assertEquals(expected.verticalUnitScale, app.STUDY.verticalUnitScale, 0.0001f);
    assertEquals(expected.verticalUnitOffset, app.STUDY.verticalUnitOffset, 0.0001f);
    assertEquals(expected.verticalNegativePadding, app.STUDY.verticalNegativePadding, 0.0001f);
  }

  @Test
  void changeCurrentLayerTo_setsBothDevelopAndCurrentLayerIdToTheSameNewId () {
    app.developLayerId = 0;
    app.currentLayerId = 0;

    app.changeCurrentLayerTo(9);

    assertEquals(9, app.developLayerId);
    assertEquals(9, app.currentLayerId);
  }

  @Test
  void changeCurrentLayerTo_switchingTwiceLeavesOnlyTheSecondLayersDataInEffect () {
    app.changeCurrentLayerTo(2);
    app.changeCurrentLayerTo(7);

    solarchvision_bim.LAYER expected = app.allLayers[7];

    assertEquals(7, app.currentLayerId);
    assertEquals(expected.name, app.CurrentLayer_name);
    assertEquals(expected.unit, app.CurrentLayer_unit);
  }

  @Test
  void changeCurrentLayerTo_canSwitchToTheDevelopedPlaceholderLayer () {
    int lastIndex = app.allLayers.length - 1; // LAYER_developed
    app.changeCurrentLayerTo(lastIndex);

    assertEquals(lastIndex, app.currentLayerId);
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

    assertEquals(0, app.currentLayerId);
    assertEquals(first.unit, app.CurrentLayer_unit);
    assertEquals(first.name, app.CurrentLayer_name);
  }

  // ================= LAYER.to_XML / from_XML round trip =====================

  @Test
  void layerToXMLThenFromXML_roundTripsEveryField () {
    solarchvision_bim.LAYER original = app.new LAYER(2.5f, -10, 1, "°C", "Air Temperature", "Température de l'air", "TMP");
    original.id = 4;

    processing.data.XML root = new processing.data.XML("root");
    original.to_XML(root);

    solarchvision_bim.LAYER loaded = app.new LAYER(0, 0, 0, "", "", "", "");
    loaded.id = 4; // from_XML searches the <layer> wrapper's <item> children by id, so id must match first
    loaded.from_XML(root);

    assertEquals(4, loaded.id);
    assertEquals("°C", loaded.unit);
    assertEquals("TMP", loaded.name);
    assertEquals("Air Temperature", loaded.descriptions[app.Language_EN]);
    assertEquals("Température de l'air", loaded.descriptions[app.Language_FR]);
    assertEquals(2.5f, loaded.verticalUnitScale, 0.0001f);
    assertEquals(-10f, loaded.verticalUnitOffset, 0.0001f);
    assertEquals(1f, loaded.verticalNegativePadding, 0.0001f);
  }

  // Regression for the shared-wrapper fix: every LAYER instance's own
  // to_XML() call now appends to the SAME <layer> wrapper (one per
  // call to_XML lands on, reused across instances) instead of each
  // instance minting its own uniquely-named top-level sibling. This
  // proves several layers serialized in sequence - the real
  // saveProject.pde/parseXmlVariables.pde usage - land as one <layer
  // ni="3"><item id="..."/>...</layer>, not three separate top-level
  // elements, and that each round-trips back to the right instance by
  // id.
  @Test
  void toXML_ofSeveralLayers_shareOneWrapperDeclaringTheirCount () {
    solarchvision_bim.LAYER a = app.new LAYER(1, 0, 0, "a", "A", "A_fr", "A");
    a.id = 0;
    solarchvision_bim.LAYER b = app.new LAYER(2, 0, 0, "b", "B", "B_fr", "B");
    b.id = 1;
    solarchvision_bim.LAYER c = app.new LAYER(3, 0, 0, "c", "C", "C_fr", "C");
    c.id = 2;

    processing.data.XML root = new processing.data.XML("root");
    a.to_XML(root);
    b.to_XML(root);
    c.to_XML(root);

    processing.data.XML[] wrappers = root.getChildren("layer");
    assertEquals(1, wrappers.length, "all three instances should share one <layer> wrapper");
    assertEquals(3, wrappers[0].getChildren("item").length);

    solarchvision_bim.LAYER loadedB = app.new LAYER(0, 0, 0, "", "", "", "");
    loadedB.id = 1;
    loadedB.from_XML(root);
    assertEquals("b", loadedB.unit);
    assertEquals("B", loadedB.name);
    assertEquals(2f, loadedB.verticalUnitScale, 0.0001f);
  }
}
