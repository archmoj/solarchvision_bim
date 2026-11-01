// Decides how many scenarios FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() samples
// for a given stat - replacing what used to be a single global
// SCENARIO_SAMPLE_COUNT every caller passed in regardless of which stat
// it asked for: each stat family gets however many samples actually
// suits the shape of thing it's estimating, instead of one setting
// trying to fit all nine at once.
//
// Must stay in agreement with scenarioSampleWeight()'s own classification
// of these same stats (averagedScenarioValues.pde): that function decides
// how heavily each of these samples counts once picked, and the two only
// make sense together - a stat sampled 3x here but still triangular-
// weighted there would silently get LESS noise damping than intended
// (triangular weighting concentrates most of the influence back onto the
// closest sample again), not more.
int scenarioSampleCount (int l) {

  // Min/Max are themselves the extreme - averaging them with their
  // next-nearest neighbors would pull the result back toward the middle
  // of the distribution, defeating the point of picking "the min" or "the
  // max" in the first place.
  if (l == STAT_N_Min || l == STAT_N_Max) return 1;

  // STAT_N_Ave, and - by the same reasoning - STAT_N_MidLow/Middle/
  // MidHigh ("Leaning Low"/"Well-tempered"/"Leaning High") don't target a
  // single sharp point in the distribution the way a percentile or an
  // extreme does - Ave by definition, the other three by being
  // rank-weighted means over the WHOLE distribution (see NORMAL.pde's
  // own top comment on them) rather than order statistics - so there's
  // much less of a single point for an extra sample to drift away from,
  // and pulling in more samples buys more noise reduction at
  // comparatively little bias cost. These four always use the full
  // 3-sample range.
  if (l == STAT_N_Ave || l == STAT_N_MidLow || l == STAT_N_Middle || l == STAT_N_MidHigh) return 3;

  // Every other stat (M25/M50/M75, the true percentiles/median): the
  // default - enough samples to damp a single scenario's own noise,
  // without so many that distinct, closely-spaced percentile categories
  // start blending into each other. See scenarioSampleWeight()'s own
  // 2:1 weighting (averagedScenarioValues.pde) for how these two
  // samples are then combined.
  return 2;
}

// Returns up to as many scenario indices (nk - still the same
// k*daysMergedCount + j_ADD packing every call site already unpacks) as
// scenarioSampleCount(l) (below) decides for this stat, nearest-first by
// distance to it - instead of just the single closest one. Picking
// several and averaging their hourly values (see each call site's own
// comment on how it does that averaging) smooths over a single
// scenario's own noise/extreme conditions, rather than letting one
// unlucky pick's outlier day drive the whole simulation. Returns an
// empty array (never null, never containing -1) when nothing is defined
// to pick from - callers loop over the result instead of checking for a
// single sentinel value.
int[] FIND_SCENARIOS_CLOSE_TO_DAILY_STAT (int l, int start_k, int end_k, int j, float DATE_ANGLE, int impactTypeIndex) {

  int sampleCount = scenarioSampleCount(l);

  int count_k = 1 + end_k - start_k;
  if (count_k < 0) count_k = 0;

  final int daysMergedCount = STUDY.daysMergedCount;
  final int total = count_k * daysMergedCount;

  boolean needEFF = (impactTypeIndex == Impact_PASSIVE);

  int layerDirId = needEFF ? LAYER_direffect.id : LAYER_dirnorrad.id;
  int layerDifId = needEFF ? LAYER_difeffect.id : LAYER_difhorrad.id;

  float[] valuesSUM = new float[total];
  float[] valuesNUM = new float[total]; // already 0-initialized by Processing/Java
  java.util.Arrays.fill(valuesSUM, FLOAT_undefined);

  float lat = STATION.getLatitude();
  float[] allSunZ = new float[24];
  for (int i = 0; i < 24; i++) {
    float[] SunR = funcs.SunPosition(lat, DATE_ANGLE, i);
    allSunZ[i] = SunR[3];
  }

  float baseJ = j * STUDY.dayIncrement + TIME.beginDay + 365 - int(funcs.roundTo(0.5 * daysMergedCount, 1));

  int[] nowJ = new int[daysMergedCount];
  for (int j_ADD = 0; j_ADD < daysMergedCount; j_ADD++) {
    int now_j = int(baseJ + j_ADD) % 365;
    if (now_j >= 365) now_j %= 365;
    if (now_j < 0) now_j = (now_j + 365) % 365;
    nowJ[j_ADD] = now_j;
  }

  for (int j_ADD = 0; j_ADD < daysMergedCount; j_ADD++) {
    int now_j = nowJ[j_ADD];

    for (int i = 0; i < 24; i++) {
      float z = allSunZ[i];

      if(z <= 0) continue;

      for (int k = 0; k < count_k; k++) {
        int now_k = k + start_k;
        int idx = k * daysMergedCount + j_ADD;

        float Pdir = getValue_currentDataSource(i, now_j, now_k, layerDirId);
        if (is_undefined(Pdir)) continue;

        float Pdif = getValue_currentDataSource(i, now_j, now_k, layerDifId);
        if (is_undefined(Pdif)) continue;

        boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, STUDY.temporalFilterSetting, STUDY.skyScenarioSetting, i, now_j, now_k);
        if (!isMemberCounted) continue;

        if (is_undefined(valuesSUM[idx])) {
          valuesSUM[idx] = 0;
        }
        valuesSUM[idx] += 0.001 * ((Pdir * z) + Pdif); // total horizontal radiation/effect
        valuesNUM[idx] += 1;
      }
    }
  }

  int lSelected = l;
  if (impactTypeIndex == Impact_PASSIVE) {
    // flip these to make them user friendly i.e.
    // high temperature scenario >> high,
    // low temperature scenario >> low
         if(l == STAT_N_MidLow) lSelected = STAT_N_MidHigh;
    else if(l == STAT_N_MidHigh) lSelected = STAT_N_MidLow;
    else if(l == STAT_N_M25) lSelected = STAT_N_M75;
    else if(l == STAT_N_M75) lSelected = STAT_N_M25;
    else if(l == STAT_N_Min) lSelected = STAT_N_Max;
    else if(l == STAT_N_Max) lSelected = STAT_N_Min;
  }

  return _FIND_SCENARIOS_CLOSE_TO_STAT(valuesSUM, lSelected, sampleCount);
}

// Single-scenario convenience wrapper around _FIND_SCENARIOS_CLOSE_TO_STAT()
// below (sampleCount == 1) - see FindScenarioCloseToStatTest.java for its
// existing, directly-tested behavior (exact-match short-circuit, stable
// first-index-wins tie-break, -1 when nothing is defined), all of which
// _FIND_SCENARIOS_CLOSE_TO_STAT() reproduces exactly for sampleCount == 1.
int _FIND_SCENARIO_CLOSE_TO_STAT (float[] values, int l) {
  int[] top = _FIND_SCENARIOS_CLOSE_TO_STAT(values, l, 1);
  return (top.length > 0) ? top[0] : -1;
}

// Returns up to sampleCount indices of `values`, nearest-first by distance
// to NORMAL(values)[l] - the same search _FIND_SCENARIO_CLOSE_TO_STAT()
// above does for just the single closest index, generalized to however
// many of the sampleCount nearest a caller wants to average across
// instead. Only indices with a defined value are eligible. A stable sort
// by distance keeps ties in their original index order - the same
// "equal distance never replaces the current pick" tie-break the old
// strict `diff < dist` loop used - so sampleCount == 1 always returns the
// identical single index _FIND_SCENARIO_CLOSE_TO_STAT() would.
int[] _FIND_SCENARIOS_CLOSE_TO_STAT (float[] values, int l, int sampleCount) {
  float normal = NORMAL(values)[l];
  int n = values.length;

  if (!is_defined(normal) || sampleCount <= 0) return new int[0];

  java.util.ArrayList<Integer> definedIdx = new java.util.ArrayList<Integer>();
  for (int i = 0; i < n; i++) {
    if (is_defined(values[i])) definedIdx.add(i);
  }

  final float[] finalValues = values;
  final float finalNormal = normal;
  definedIdx.sort((a, b) -> Float.compare(abs(finalNormal - finalValues[a]), abs(finalNormal - finalValues[b])));

  int outCount = min(sampleCount, definedIdx.size());
  int[] out = new int[outCount];
  for (int s = 0; s < outCount; s++) out[s] = definedIdx.get(s);
  return out;
}
