// Single-scenario convenience wrapper around FIND_SCENARIOS_CLOSE_TO_DAILY_STAT()
// below (sampleCount == 1) - kept for any caller that genuinely only wants
// the one closest scenario, and to keep FindScenarioCloseToStatTest.java's
// existing coverage of _FIND_SCENARIO_CLOSE_TO_STAT() (below) meaningful
// without having to unwrap an array there.
int FIND_SCENARIO_CLOSE_TO_DAILY_STAT (int l, int start_k, int end_k, int j, float DATE_ANGLE, int impactTypeIndex) {
  int[] top = FIND_SCENARIOS_CLOSE_TO_DAILY_STAT(1, l, start_k, end_k, j, DATE_ANGLE, impactTypeIndex);
  return (top.length > 0) ? top[0] : -1;
}

// Returns up to sampleCount scenario indices (nk - still the same
// k*daysMergedCount + j_ADD packing every call site already unpacks),
// nearest-first by distance to the requested stat - instead of just the
// single closest one. Picking several and averaging their hourly values
// (see each call site's own comment on how it does that averaging)
// smooths over a single scenario's own noise/extreme conditions, rather
// than letting one unlucky pick's outlier day drive the whole simulation.
// Returns an empty array (never null, never containing -1) when nothing
// is defined to pick from - callers loop over the result instead of
// checking for a single sentinel value.
int[] FIND_SCENARIOS_CLOSE_TO_DAILY_STAT (int sampleCount, int l, int start_k, int end_k, int j, float DATE_ANGLE, int impactTypeIndex) {

  // Min/Max are themselves the extreme - averaging them with their
  // next-nearest neighbors would pull the result back toward the middle
  // of the distribution, defeating the point of picking "the min" or "the
  // max" in the first place. Every other stat (Ave, Middle, a percentile,
  // ...) targets a point THE DISTRIBUTION doesn't single out as uniquely
  // extreme, so averaging a few scenarios close to it is still a sample
  // of "about that typical", not a blunted extreme - only Min/Max don't
  // get that treatment.
  if (l == STAT_N_Min || l == STAT_N_Max) sampleCount = 1;

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
