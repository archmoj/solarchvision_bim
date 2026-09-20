import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class SolarImpactsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= resize_Image_array ==================================

  @Test
  void resizeImageArray_buildsTwoRowsOnePlaceholderPerDayColumn () {
    app.STUDY.j_Start = 0;
    app.STUDY.j_End = 3;
    app.allSolarImpacts.rebuild_Image_array = true;

    app.allSolarImpacts.resize_Image_array();

    assertEquals(2, app.allSolarImpacts.Image.length);
    assertEquals(4, app.allSolarImpacts.Image[0].length); // 1 + j_End - j_Start
    assertNotNull(app.allSolarImpacts.Image[0][1]);
    assertEquals(2, app.allSolarImpacts.Image[0][1].width); // small placeholder
    assertFalse(app.allSolarImpacts.rebuild_Image_array);
  }

  // ================= calculate_Impact_selectedSections ===================

  @Test
  void calculateImpactSelectedSections_isANoOpWhenNothingIsSelected () {
    app.Select3D.Section_ids = new int[]{};
    // If this reached calculate_Impact_CurrentPreBaked() it would throw
    // on cursor()/loadImage() - reaching the end of this call without an
    // exception IS the assertion here.
    app.allSolarImpacts.calculate_Impact_selectedSections();
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.allSolarImpacts.displayImage = true;
    app.allSolarImpacts.X = 1;
    app.allSolarImpacts.Y = 2;
    app.allSolarImpacts.Z = 3;
    app.allSolarImpacts.R = 45;
    app.allSolarImpacts.U = 100;
    app.allSolarImpacts.V = 200;
    app.allSolarImpacts.RES1 = 50;
    app.allSolarImpacts.RES2 = 60;
    app.allSolarImpacts.sectionType = 2;

    processing.data.XML root = new processing.data.XML("root");
    app.allSolarImpacts.to_XML(root);

    solarchvision_bim.solarchvision_SolarImpacts fresh = app.new solarchvision_SolarImpacts();
    fresh.from_XML(root);

    assertTrue(fresh.displayImage);
    assertEquals(1f, fresh.X, 0.0001f);
    assertEquals(2f, fresh.Y, 0.0001f);
    assertEquals(3f, fresh.Z, 0.0001f);
    assertEquals(45f, fresh.R, 0.0001f);
    assertEquals(100f, fresh.U, 0.0001f);
    assertEquals(200f, fresh.V, 0.0001f);
    assertEquals(50, fresh.RES1);
    assertEquals(60, fresh.RES2);
    assertEquals(2, fresh.sectionType);
  }
}
