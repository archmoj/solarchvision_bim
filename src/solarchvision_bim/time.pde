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

  // Step 4b of the real-Gregorian-year plan, building on isLeapYear
  // (4a). These are still pure and still have no callers in the app
  // yet - the generic<->real conversion layer (4c) and decoupling
  // solar geometry (4d) are what will actually call them. They are
  // deliberately kept independent of this.lengthOfMonths (the generic
  // calendar's fixed Feb=29 table): a *real* year's February is 28 or
  // 29 days depending on isLeapYear(year), never a fixed 29.

  // Real (non-generic) month length: every month matches the generic
  // lengthOfMonths table except February, which is real-year-aware
  // (28 in a common year, 29 in a leap year) rather than the generic
  // calendar's fixed 29.
  int lengthOfMonthInRealYear (int year_IN, int month_IN) {
    if (month_IN == 2) return this.isLeapYear(year_IN) ? 29 : 28;
    return this.lengthOfMonths[month_IN - 1];
  }

  // A real calendar date is valid exactly when month is 1..12 and day
  // is 1..lengthOfMonthInRealYear(year, month) for that specific real
  // year - this is the "Feb 29 validation" from the plan: it falls
  // directly out of this general check (true only in a leap year)
  // rather than needing its own separate special case.
  boolean isValidRealDate (int year_IN, int month_IN, int day_IN) {
    if (month_IN < 1 || month_IN > 12) return false;
    return day_IN >= 1 && day_IN <= this.lengthOfMonthInRealYear(year_IN, month_IN);
  }

  // 1-based real day-of-year (1..365, or 1..366 in a leap year) for a
  // *valid* real calendar date - callers are expected to have checked
  // isValidRealDate first; behavior for an invalid (year, month, day)
  // is not defined here.
  int dayOfYearInRealYear (int year_IN, int month_IN, int day_IN) {
    int total = day_IN;
    for (int i = 0; i < month_IN - 1; i++) {
      total += this.lengthOfMonthInRealYear(year_IN, i + 1);
    }
    return total;
  }

  // Days since the 1970-01-01 civil (Unix) epoch for a proleptic
  // Gregorian date, via Howard Hinnant's widely-used days_from_civil
  // algorithm (see http://howardhinnant.github.io/date_algorithms.html)
  // - correct for every year this app's real-year field can hold,
  // including the 100/400-year leap exceptions. Deliberately a fully
  // independent derivation of the same leap structure (not composed
  // from lengthOfMonthInRealYear above), used as the base for the
  // weekday arithmetic below.
  long daysFromRealCivilEpoch (int year_IN, int month_IN, int day_IN) {
    int y = year_IN - (month_IN <= 2 ? 1 : 0);
    long era = (y >= 0 ? y : y - 399) / 400;
    long yoe = y - era * 400;                                                     // [0, 399]
    long doy = (153 * (month_IN + (month_IN > 2 ? -3 : 9)) + 2) / 5 + day_IN - 1;  // [0, 365]
    long doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;                             // [0, 146096]
    return era * 146097L + doe - 719468L;
  }

  // 0=Sunday .. 6=Saturday, derived from daysFromRealCivilEpoch above:
  // 1970-01-01 (epoch day 0) was a Thursday, i.e. weekday index 4, so
  // adding 4 and wrapping into 0..6 (Java's % keeps the dividend's
  // sign, hence the extra "+ 7" before the final "% 7" so a date
  // before 1970 still wraps forward rather than coming out negative)
  // gives every other date's weekday.
  int weekdayFromRealDate (int year_IN, int month_IN, int day_IN) {
    long days = this.daysFromRealCivilEpoch(year_IN, month_IN, day_IN);
    return (int) (((days + 4) % 7 + 7) % 7);
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

  // Step 4c of the real-Gregorian-year plan: the explicit, tested
  // conversion layer between a specific real calendar year (built on
  // isLeapYear/isValidRealDate, 4a/4b above) and the generic 0..365,
  // Jan-1-is-0 day-of-year index that convert2Date() above already
  // produces - this is NOT a new index space. convert2Date() is
  // already exactly how the rest of this app keys climate/ensemble
  // storage off a (month, day) pair (see its own callers in
  // loadClimateArchive.pde, loadClimateEngineering.pde,
  // loadClimateTypicalYear.pde, loadEnsembleObservation.pde,
  // loadEnsembleForecast.pde, updateEnsembleObservation.pde,
  // updateStation.pde, react.pde, solarchvision_bim.pde and
  // tropo3D.pde), it just has no year parameter and performs no
  // validation today - so e.g. convert2Date(2, 29) always silently
  // succeeds, in every real year alike, because the generic calendar
  // always has a Feb 29 slot (lengthOfMonths[1] == 29, see above).
  // These two functions are what make that gap explicit and checkable.

  // Inverse of convert2Date(): given a generic 0..365 Jan-1-is-0
  // day-of-year index, returns the {month, day} it corresponds to.
  // Walks the exact same lengthOfMonths table in the exact same order
  // as convert2Date()'s own forward loop (rather than a separately
  // maintained formula), so the two stay in lock-step by construction.
  // Routed through safeDate() first for the same out-of-range wrap
  // behavior as getMonth_fromDate/getDay_fromDate above.
  int[] monthDayFromGenericIndex (int genericIndex_IN) {
    int remaining = this.safeDate(genericIndex_IN);
    for (int i = 0; i < 12; i++) {
      if (remaining < this.lengthOfMonths[i]) {
        return new int[] { i + 1, remaining + 1 };
      }
      remaining -= this.lengthOfMonths[i];
    }
    // unreachable: lengthOfMonths sums to exactly 366 and remaining
    // (from safeDate) is already in [0, 366)
    return new int[] { 12, 31 };
  }

  // Plain data holder for the generic-index -> real-date direction,
  // mirroring Tropo3D.DateTimeUTC's style: a generic index does not
  // always correspond to a real date in a given real year (the Feb 29
  // slot has no real counterpart in a non-leap year - the "undefined/
  // empty for that year" case named in the lengthOfMonths comment
  // above), so this carries an explicit valid flag rather than
  // returning a silently-wrong (year, month, day).
  class RealDate {
    int year, month, day;
    boolean valid;
  }

  // real (year, month, day) -> generic index, with the year-aware
  // validation convert2Date() alone does not do. Every *valid* real
  // date already has a slot in the generic table (the generic
  // calendar's month lengths equal the real ones for every month
  // except February, where the generic table's fixed 29 is a superset
  // of a real Feb's 28 or 29), so once isValidRealDate (4b) passes,
  // this simply delegates to the existing convert2Date(). Returns -1
  // for an invalid real date (most notably Feb 29 in a non-leap year)
  // instead of the silent wrong answer convert2Date() alone would give.
  int genericIndexFromRealDate (int year_IN, int month_IN, int day_IN) {
    if (!this.isValidRealDate(year_IN, month_IN, day_IN)) return -1;
    return this.convert2Date(month_IN, day_IN);
  }

  // generic index -> real (year, month, day) for a specific target
  // real year. See RealDate above for why this can come back invalid.
  RealDate realDateFromGenericIndex (int genericIndex_IN, int year_IN) {
    int[] monthDay = this.monthDayFromGenericIndex(genericIndex_IN);
    RealDate result = new RealDate();
    result.year = year_IN;
    result.month = monthDay[0];
    result.day = monthDay[1];
    result.valid = this.isValidRealDate(year_IN, result.month, result.day);
    return result;
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
