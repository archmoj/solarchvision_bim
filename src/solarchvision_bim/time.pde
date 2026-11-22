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

  // Step 4f of the real-Gregorian-year plan: the Day/Month/Year UI
  // spinners (valueModifier.pde) are three independent controls - Day
  // 1..31, Month 1..12, Year 1953..2100 - with no cross-validation
  // against each other, so changing any one of them can leave this.day
  // pointing past the end of this.month in this.year (Feb 29 after
  // Year moves to a common year; day 31 after Month moves to a 30-day
  // month). Left unclamped, that invalid (year, month, day) used to
  // only ever reach the generic-calendar convert2Date() path (which
  // treats Feb 29 as always valid, Table A's own fixed slot for it) or
  // a download/filename lookup that just fails to find a file - but
  // since step 4e wired sync_SHADE_DATE_ANGLE() to real epoch-day
  // arithmetic, the same invalid date now silently overflows into the
  // next month instead (daysFromRealCivilEpoch/realDateFromEpochDay
  // have no concept of "invalid", only of "day N of a y/m-less
  // sequence") - e.g. 2025-02-29 silently becomes 2025-03-01, with
  // nothing visible to the user. Only Month/Year ever need no clamp of
  // their own: both already have their own correct range (1..12,
  // 1953..2100) regardless of the other two fields, so the only
  // possible invalidity this app's own date model can produce is a Day
  // too large for the (now possibly different) Month/Year - clamping
  // Day down to the real last day of that month, same as how an
  // ordinary calendar widget behaves, is this function's whole job.
  // Called from every place that sets year/month/day (the immediate
  // GUI-driven setters in valueModifier.pde, and react.applyTimeChange
  // - the once-per-frame, source-agnostic path that also covers a
  // command-line SET command or a loaded project file) rather than
  // from inside day()/month()/year() themselves, so a caller that only
  // intends to read the current value never has a side effect sprung
  // on it.
  void clampDayToValidRealDate () {
    int validLength = this.lengthOfMonthInRealYear(this.year, this.month);
    if (this.day > validLength) {
      this.day = validLength;
    }
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

  // Inverse of daysFromRealCivilEpoch above (Howard Hinnant's own
  // civil_from_days, http://howardhinnant.github.io/date_algorithms.html) -
  // every epoch day number, positive or negative, maps back to exactly
  // one proleptic-Gregorian real date, so unlike RealDate's other
  // producer (realDateFromGenericIndex, which can land on a Feb 29 that
  // doesn't exist in a non-leap target year) the result here is always
  // valid. Added for step 4e's planning-mode stepper: advancing a real
  // date by N real days is daysFromRealCivilEpoch() + N, then this -
  // true calendar-day arithmetic rather than generic-calendar (% 366)
  // wraparound, so a step that crosses Dec31->Jan1 advances the year by
  // itself, and a step through where a non-leap year's Feb 29 would be
  // simply has no such day to land on, landing on Mar 1 (stepping
  // forward) or Feb 28 (stepping backward) automatically.
  RealDate realDateFromEpochDay (long epochDay_IN) {
    long z = epochDay_IN + 719468L;
    long era = (z >= 0 ? z : z - 146096) / 146097;
    long doe = z - era * 146097L;                                 // [0, 146096]
    long yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365; // [0, 399]
    long y = yoe + era * 400;
    long doy = doe - (365 * yoe + yoe / 4 - yoe / 100);            // [0, 365]
    long mp = (5 * doy + 2) / 153;                                 // [0, 11]
    long d = doy - (153 * mp + 2) / 5 + 1;                         // [1, 31]
    long m = mp + (mp < 10 ? 3 : -9);                              // [1, 12]
    y = y + (m <= 2 ? 1 : 0);

    RealDate result = new RealDate();
    result.year = (int) y;
    result.month = (int) m;
    result.day = (int) d;
    result.valid = true;
    return result;
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

  // Step 4d of the real-Gregorian-year plan: the actual Kepler/
  // eccentricity accuracy fix. Third version of this function (after
  // a linear interpolation, then a traditional-Persian-pattern walk
  // with a 29/30 flex slot), rewritten again after discussing the
  // physics: the Sun sits at one focus of Earth's elliptical orbit,
  // not at its center, so by Kepler's second law (equal areas swept
  // in equal times) Earth moves faster near perihelion (~early Jan)
  // and slower near aphelion (~early Jul) - the Sun's true ecliptic
  // longitude does NOT advance uniformly with calendar time. The
  // traditional Persian (Solar Hijri) calendar compensates for this
  // with longer (31-day) months in the slow half of the year and
  // shorter (29/30-day) months in the fast half, so each month is
  // (approximately) an equal 30 degree step in the Sun's true
  // position - which is why every DATE_ANGLE site in this app
  // (sync_SHADE_DATE_ANGLE() in shadeViewport3D.pde, and the many
  // "(360 * ((286 + j) % 366) / 366.0)" sites in
  // calculateGlobalSolarArray.pde, calculateVertexSolarArray.pde,
  // postProcessClimaticSolarForecast.pde, postProcessSolarsUsingCloud.pde,
  // postProcessDevelopData.pde and sun3D.pde) is anchored at the Mar
  // 21 equinox in the first place; lengthOfMonths (Table A) above is
  // only the ordinary Gregorian pattern re-walked from Mar 21 though,
  // not the month-length asymmetry that anchor was meant to go with.
  //
  // solarchvisionMonthLength (Table B) below is this app's own month
  // table, not the real Persian calendar's (hence the name, chosen
  // deliberately over "persianMonthLength" so it is never mistaken
  // for matching the traditional calendar's actual structure, which
  // it does not): rather than the traditional six-31s/five-30s/one-
  // flex-slot pattern, every position here is plainly 31 or 30, with
  // the count of 31s depending on whether this equinox-year is leap
  // (6) or common (5) - chosen specifically so EVERY position reaches
  // its own 30 degree target with zero drift (see solarchvisionMonthLength's
  // own comment below for why a flex slot cannot do that, and
  // dateAngleFromRealDate's own comment for the integer day-stepping
  // this is built for). It exists alongside Table A, not in place of
  // it: Table A keeps doing exactly what it already does (real-date
  // validation in lengthOfMonthInRealYear/isValidRealDate above, and
  // every climate-mode DATE_ANGLE site, which aggregates over the
  // whole generic 366-slot statistical year and has no one real year
  // to anchor a Table-B conversion to anyway). Table B exists purely
  // to drive this one function, for "planning mode" (a single
  // selected real date) once it is wired in - still a separate, open
  // decision (see dateAngleFromRealDate's own comment below), not
  // resolved by adding Table B itself.

  // Table B: this app's own month-length pattern, walked from the
  // Mar-21 equinox (position 0), NOT indexed by Gregorian month like
  // lengthOfMonths (Table A) above, and NOT the traditional Persian
  // calendar's own six-31s/five-30s/one-flex-slot pattern (see the
  // comment above). Every position is plainly 31 or 30 days - never
  // 29 - with the first "threshold" positions getting 31 (the slow,
  // aphelion half) and the rest getting 30 (the fast, perihelion
  // half). threshold is 6 for a leap equinox-year (6x31 + 6x30 = 366)
  // and 5 for a common one (5x31 + 7x30 = 365): this is the unique
  // choice, for each year length, that makes every position exactly
  // 31 or 30 with none left over as an odd 29-day remainder. That
  // matters because of how dateAngleFromRealDate below steps day by
  // day: a 31-day position absorbs its one extra day with zero drift
  // (its own last day simply repeats the day before, see below), and
  // a 30-day position needs no adjustment at all - but a 29-day
  // position (the traditional calendar's own flex slot, this
  // function's previous version) has neither property, since nothing
  // in that stepping scheme can ever supply a day it is short of. By
  // never using a 29-day position in the first place, every single
  // position - not just eleven of twelve - lands exactly on its own
  // 30 degree boundary with no exception, in both leap and common
  // years (verified in TIMETest.java). The one trade made for that:
  // the slow/fast boundary itself shifts by about a month depending
  // on leap status, rather than sitting at a fixed calendar position
  // every year the way the traditional calendar's does.
  //
  // year_IN here must be the real year whose February actually falls
  // inside the particular equinox-year being asked about (what
  // dateAngleFromRealDate below calls terminalYear) - NOT necessarily
  // the same as the year written on the target date itself for a
  // March-December date, whose equinox-year extends into the
  // following calendar year. Passing the wrong one silently shifts
  // this threshold and every boundary after it by a day; see
  // dateAngleFromRealDate's own comment for exactly why and how it
  // computes the correct one.
  int solarchvisionMonthLength (int positionFromEquinox_IN, int year_IN) {
    int threshold = this.isLeapYear(year_IN) ? 6 : 5;
    return positionFromEquinox_IN < threshold ? 31 : 30;
  }

  // Computes DATE_ANGLE for a real (year, month, day) as a whole
  // integer degree, stepping +1 degree per real calendar day, with
  // one exception: the last day of a 31-day solarchvisionMonthLength
  // (Table B) position repeats the previous day's value instead of
  // advancing, rather than this function's two earlier versions
  // (uniform linear interpolation, then a fractional walk within each
  // Table-B position) which both returned fractional degrees on
  // ordinary days. A whole-integer result lets this value be used
  // directly against the integer-keyed DATE_ANGLE caches and the
  // exact-15-degree-step pre-render loop already elsewhere in this
  // app (win3DCache_SHADE_DATE_ANGLE in sun3D.pde/moon3D.pde, and
  // castShadowsCurrentSection.pde's own "for (int DATE_ANGLE = 0;
  // DATE_ANGLE < 360; DATE_ANGLE += 15)") without needing
  // interpolation between cached values. Because Table B never uses a
  // 29-day position (see solarchvisionMonthLength's own comment
  // above), this stepping has no exception left anywhere: every
  // Table-B position - 31-day or 30-day alike - reaches its own exact
  // 30 degree boundary with zero drift, so this function's result
  // always lands on an exact multiple of 30 at every position
  // boundary and advances by exactly 1 every other day (verified in
  // TIMETest.java for both a leap and a common equinox-year).
  //
  // terminalYear below is this function's fix for a real bug in its
  // own two earlier versions: both blindly used isLeapYear(year_IN)
  // to decide this equinox-year's own length and (now) Table B's
  // threshold, but the equinox-year a March-December date belongs to
  // extends into the FOLLOWING calendar year and does not end until
  // the following year's own Feb/Mar - so it is the following year's
  // leap status that actually governs it, not year_IN's own (for
  // example the equinox-year starting 2024-03-21, even though 2024 is
  // itself a leap year, is only 365 real days long, because its own
  // terminal February is Feb 2025, a common year - confirmed against
  // real calendar arithmetic before writing this). For a Jan/Feb date
  // year_IN already *is* the terminal year, so terminalYear reduces
  // to year_IN exactly in that case and nothing changes there.
  //
  // Step 4e wires this into the one planning-mode call site this was
  // held back for: sync_SHADE_DATE_ANGLE() (shadeViewport3D.pde) now
  // calls this directly off a real date, rather than building
  // SHADE_DATE_ANGLE from the old generic-calendar formula. That real
  // date comes from impactDayToRealDate() there, which steps TIME's own
  // (year, month, day) anchor by true epoch-day arithmetic
  // (daysFromRealCivilEpoch/realDateFromEpochDay above) instead of
  // impactDayToDayOfYear()'s generic-calendar (% 366) wraparound - so a
  // step crossing Dec31->Jan1 advances TIME.year on its own, and a step
  // through where a non-leap year's Feb 29 would fall simply has no
  // such day to land on. impactDayToDayOfYear() itself is unchanged and
  // still used elsewhere (e.g. tropo3D.pde), still on the old generic
  // index - only SHADE_DATE_ANGLE's own derivation moved off it.
  // Table A / the generic 366-wide calendar otherwise continues
  // exactly as before: climate-mode aggregation has no single real
  // year to anchor a Table-B conversion to, so every other DATE_ANGLE
  // site in the app is deliberately left on the old formula.
  float dateAngleFromRealDate (int year_IN, int month_IN, int day_IN) {
    int terminalYear = month_IN >= 3 ? year_IN + 1 : year_IN; // see this function's own comment above for why

    int realYearLength = this.isLeapYear(terminalYear) ? 366 : 365;

    int dayOfYear = this.dayOfYearInRealYear(year_IN, month_IN, day_IN);
    int equinoxDayOfYear = this.dayOfYearInRealYear(year_IN, 3, 21); // same fixed Mar-21 anchor every existing DATE_ANGLE site uses - not the true astronomical equinox; year_IN (not terminalYear) is correct here, since both sides of this subtraction are literal calendar dates within year_IN itself

    int realDaysFromEquinox = ((dayOfYear - equinoxDayOfYear) % realYearLength + realYearLength) % realYearLength;

    int remaining = realDaysFromEquinox;
    for (int position = 0; position < 12; position++) {
      int positionLength = this.solarchvisionMonthLength(position, terminalYear);
      if (remaining < positionLength) {
        return 30 * position + min(remaining, 29);
      }
      remaining -= positionLength;
    }
    // unreachable: the 12 Table B positions sum to exactly
    // realYearLength (see solarchvisionMonthLength's own comment
    // above), and remaining (from the modulo above) is already <
    // realYearLength
    return 330;
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

    this.clampDayToValidRealDate(); // step 4f: a hand-edited or corrupted project file could hold an invalid (year, month, day) combo directly
    sync_SHADE_DATE_ANGLE();
  }

}
