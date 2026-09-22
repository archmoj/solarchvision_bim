import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class WindRoseTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= resize_Image_array ==================================

  @Test
  void resizeImageArray_buildsOnePlaceholderPerDayColumnAndClearsTheRebuildFlag () {
    app.STUDY.j_Start = 0;
    app.STUDY.j_End = 3;
    app.allWindRoses.rebuild_Image_array = true;

    app.allWindRoses.resize_Image_array();

    assertEquals(4, app.allWindRoses.Image.length); // 1 + j_End - j_Start
    assertNotNull(app.allWindRoses.Image[1]);
    assertEquals(2, app.allWindRoses.Image[1].width); // small placeholder image
    assertFalse(app.allWindRoses.rebuild_Image_array);
  }

  // ================= to_XML / from_XML round trip ========================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.allWindRoses.displayImage = true;
    app.allWindRoses.RES = 200;
    app.allWindRoses.renderedRES = 3;
    app.allWindRoses.scale = 55f;

    processing.data.XML root = new processing.data.XML("root");
    app.allWindRoses.to_XML(root);

    solarchvision_bim.WindRose fresh = app.new WindRose();
    fresh.from_XML(root);

    assertTrue(fresh.displayImage);
    assertEquals(200, fresh.RES);
    assertEquals(3, fresh.renderedRES);
    assertEquals(55f, fresh.scale, 0.0001f);
  }
}
