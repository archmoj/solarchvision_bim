class TIME {

  final static String CLASS_STAMP = "time";

  int modelRun = 0; //12;

  int hour = this.modelRun; //hour();
  int year = year();
  int month = month(); //1;
  int day = day(); //21;

  int beginDay;
  float date;

  final int interval = 1; //dT


  final String[][] WORDS = {
    {
      "", ""
    }
    ,
    {
      "at hour", "à l'heure"
    }
    ,
    {
      "day", "jour"
    }
    ,
    {
      "month", "mois"
    }
    ,
    {
      "year", "année"
    }
    ,
    {
      "date", "date"
    }
  };


  final String[][] namesOfMonths = {
    {
      "January", "janvier"
    }
    ,
    {
      "February", "février"
    }
    ,
    {
      "March", "mars"
    }
    ,
    {
      "April", "avril"
    }
    ,
    {
      "May", "mai"
    }
    ,
    {
      "June", "juin"
    }
    ,
    {
      "July", "juillet"
    }
    ,
    {
      "August", "août"
    }
    ,
    {
      "September", "septembre"
    }
    ,
    {
      "October", "octobre"
    }
    ,
    {
      "November", "novembre"
    }
    ,
    {
      "December", "décembre"
    }
  };

  // Feb is fixed at 29, not a real-year-aware 28/29 - this is a single
  // generic 366-day calendar used for every real year alike (leap or
  // not), not a per-year Gregorian one. A Feb-29 slot that a given real
  // (non-leap) year's source data never fills in simply stays
  // undefined/empty for that year - see e.g. load_climateArchive() -
  // rather than colliding with and silently overwriting Mar 1's slot,
  // which is what a 365-slot calendar did before this.
  final int[] lengthOfMonths = {
    31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
  };

  int[] monthFromDate = new int [366];
  int[] dayFromDate = new int [366];
  String[] MM = new String [366];
  String[] MMDD = new String [366];
  String[][] dayOfYear = new String [366][numberOfLanguages];

  int safeDate(float date_IN) {
    return floor(0.001 + (366 + date_IN) % 366);
  }

  // Step 4a of the real-Gregorian-year plan: this.year already exists
  // (see the field above and its spinner in valueModifier.pde / XML
  // round-trip below) but today it is purely a decorative/lookup-key
  // tag - it is passed to the ensemble-observation/forecast fetch
  // functions and used in saved-image/file names, and nothing checks
  // it for validity or ties it to this.month/this.day, which are
  // instead derived from the generic 366-day calendar via updateDate()
  // and never consult this.year at all. isLeapYear() is pure groundwork
  // for that gap: the standard Gregorian rule, with no side effects and
  // no callers yet, so it changes no existing behavior. Real-year leap
  // arithmetic (deriving an actual real-year day-of-year/weekday from
  // it, and validating e.g. a Feb 29 pick against it) is step 4b; the
  // conversion between this and the generic 366-slot index is step 4c.
  boolean isLeapYear (int year_IN) {
    return (year_IN % 4 == 0 && year_IN % 100 != 0) || (year_IN % 400 == 0);
  }

  int getMonth_fromDate(float date_IN) {
     return this.monthFromDate[safeDate(date_IN)];
  }

  int getDay_fromDate(float date_IN) {
     return this.dayFromDate[safeDate(date_IN)];
  }

  String getDayText(float date_IN) {
    return this.dayOfYear[safeDate(date_IN)][activeLanguage];
  }

  String getMMDD(float date_IN) {
    return this.MMDD[safeDate(date_IN)];
  }

  String getMM(float date_IN) {
    return this.MM[safeDate(date_IN)];
  }

  TIME () { // constructor
    this.createCalendar();
  }

  // k starts at 285 so the first assignment below (Jan 1) lands at table
  // index 286, which is also lengthOfMonths-independent (it's always
  // "days from Mar 21 to Dec 31 inclusive", 306 - 20 = 286, with
  // February's own length appearing on both sides of that subtraction
  // and cancelling out) - so table index 0 always lands on Mar 21
  // (the generic-calendar equinox reference every DATE_ANGLE site in
  // this app is built from) whether lengthOfMonths[1] is 28 or 29.
  void createCalendar () {
    int k = 285;

    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < this.lengthOfMonths[i]; j++) {
        k += 1;
        if (k == 366) k = 0;

        this.monthFromDate[k] = i + 1;
        this.dayFromDate[k] = j + 1;

        this.MM[k] = nf(i + 1, 2);
        this.MMDD[k] = nf(i + 1, 2) + nf(j + 1, 2);

        for (int l = 0; l < numberOfLanguages; l++) {
          this.dayOfYear[k][l] = this.namesOfMonths[i][l] + " " + nf(j + 1, 0);
        }
      }
    }
  }

  // NOTE: not called anywhere in this app (confirmed by grep - only
  // its own test exercises it) and NOT updated for the 365->366 change
  // below, so its own "% 365" and its 5 inserted-day thresholds (a
  // degrees-to-days approximation for the old 365-day generic year)
  // are now stale relative to the rest of this class. Left alone
  // rather than guessing new thresholds for dead code; revisit
  // (recalibrate for 366, or remove) if something ever actually calls
  // this.
  int convert2Day (int Date_Angle) {
    int DAY = (Date_Angle + 360) % 360;
    if (DAY >=  31) DAY++;
    if (DAY >=  62) DAY++;
    if (DAY >=  93) DAY++;
    if (DAY >= 124) DAY++;
    if (DAY >= 155) DAY++;
    DAY = DAY % 365;
    return DAY;
  }

  int convert2Date (int month, int day) {
    int k = 0;
    for (int i = 0; i < (month - 1); i++) {
      for (int j = 0; j < this.lengthOfMonths[i]; j++) {
        k += 1;
        if (k == 366) k = 0;
      }
    }
    k += day - 1;

    k = k % 366;
    return k;
  }


  void updateDate () {
    this.month = this.getMonth_fromDate(this.date);
    this.day = this.getDay_fromDate(this.date);
    this.hour = int(24 * (this.date - int(this.date)));
  }


  public void to_XML (XML xml) {

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "modelRun", this.modelRun);
    XML_setInt(parent, "year", this.year);
    XML_setInt(parent, "month", this.month);
    XML_setInt(parent, "day", this.day);
    XML_setInt(parent, "hour", this.hour);
    XML_setInt(parent, "beginDay", this.beginDay);
    XML_setFloat(parent, "date", this.date);
  }


  public void from_XML (XML xml) {

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.modelRun = XML_getInt(parent, "modelRun");
    this.year = XML_getInt(parent, "year");
    this.month = XML_getInt(parent, "month");
    this.day = XML_getInt(parent, "day");
    this.hour = XML_getInt(parent, "hour");
    this.beginDay = XML_getInt(parent, "beginDay");
    this.date = XML_getFloat(parent, "date");

    sync_SHADE_DATE_ANGLE();
  }

}
