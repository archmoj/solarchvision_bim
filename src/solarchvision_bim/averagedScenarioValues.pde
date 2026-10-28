// Rank-based weight for the rank-th (0-indexed, nearest-first - exactly
// the order FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() already returns and every
// call site's sampleNowK[]/sampleNowJ[] decomposition already preserves)
// of sampleCount sampled scenarios: sampleCount, sampleCount-1, ..., 1 -
// the closest sample counts for the most, tapering down to the farthest
// counting for the least, rather than every sample counting equally. The
// closest-to-the-stat sample is still the best single estimate of "the
// stat"; the 2nd/3rd-closest are there to damp its own noise, not to pull
// the result toward the average of the group. For sampleCount == 2 this
// is exactly a 2:1 weighting; for 3 it's 3:2:1; for 1 it's trivially a
// weight of 1 (unweighted - identical to the old single-scenario pick).
//
// Weighted, not a plain average, is a deliberate bias-vs-variance choice:
// a plain average of 2 samples has the lowest possible variance for a
// 2-sample estimator (equal weights minimize noise), but it also treats
// the 2nd-closest sample as just as trustworthy an estimate of "the
// stat" as the closest one, which it isn't by construction - it only got
// picked for being the NEXT closest. A plain average quietly pulls the
// result toward whichever scenario happens to be 2nd-closest, which
// matters most exactly where it's least wanted: distinct stat categories
// that sit close together in a small ensemble (e.g. M25/M50/M75) can
// start blending into each other. 2:1 weighting costs a modest amount of
// extra variance (~11% more than equal weights' theoretical minimum) to
// stay closer to the actually-requested stat - and, just as importantly,
// it keeps SCENARIO_SAMPLE_COUNT behaving consistently as it's raised:
// 1 (unweighted) -> 2 (2:1) -> 3 (3:2:1) is the same rule at every step,
// rather than a plain average at one sample count and a different kind
// of estimator at another.
//
// STAT_N_Ave is the one exception, and uses a plain (equal-weight)
// average instead. The bias argument above only holds when "the stat"
// is a specific point the distribution singles out - a particular
// percentile, the middle, an extreme - where a sample picked for being
// slightly farther from that point really is a slightly worse estimate
// of it. The average has no such single point to drift away from: every
// defined value in the whole pool is already an equally legitimate
// contributor to it by definition, so the 2nd/3rd-closest-to-the-mean
// samples aren't "worse" estimates of the mean than the closest one, and
// weighting them down would just reintroduce the single-sample noise
// this whole feature exists to damp, for no bias benefit in return. l
// (not lSelected - FIND_SCENARIOS_CLOSE_TO_DAILY_STAT()'s own
// active/passive flip never touches STAT_N_Ave, so the two always agree
// here) is the caller's own STUDY.impactLayerIndex, passed through
// unchanged from whichever FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() call
// produced the samples being weighted.
float scenarioSampleWeight (int rank, int sampleCount, int l) {
  if (l == STAT_N_Ave) return 1;
  return sampleCount - rank;
}

// Shared by every FIND_SCENARIOS_CLOSE_TO_DAILY_STAT() call site: once a
// day's allNk array of sampled scenarios has been decomposed into parallel
// sampleNowK[]/sampleNowJ[] arrays (one (now_k, now_j) pair per sample -
// each call site still does that decomposition itself, since the exact
// now_j formula/day-wrap helper differs slightly site to site), these read
// and average that day's hourly values across however many of the samples
// actually have usable data for a given hour - instead of a single
// scenario's own (possibly noisy/extreme) hourly value. Averaging more
// than one close-to-the-stat scenario smooths over exactly that kind of
// single-scenario noise, rather than letting one unlucky pick's outlier
// day drive the whole simulation.

// The common case (5 of this function's 6 current call sites): all four
// energy layers (direct/diffuse radiation, direct/diffuse effect) for one
// hour, weight-averaged across samples via scenarioSampleWeight() above. A
// sample only contributes if ALL FOUR of its layers are defined AND it
// passes the isMemberCounted filter (called once per sample, not once per
// layer - filter() can itself loop across all 24 hours in filter_DAILY
// mode, so evaluating it four times over for every sample/hour would be
// purely wasted work). A sample that's skipped this way drops out of the
// weighted sum entirely - its weight is never distributed to the samples
// that do qualify - so e.g. a qualifying 2nd-closest sample alone (the
// closest having no data this hour) is used at its own full weight, not
// stretched to stand in for 100% of the result. Returns {R_dir, R_dif,
// E_dir, E_dif} (already *0.001-scaled, like every call site already
// scaled its own single-scenario Pa/Pb/Pc/Pd), or null when NONE of the
// samples have usable data for this hour - the same "nothing to use this
// hour" outcome a single-scenario pick already produces when its own
// values are undefined or filtered out, just not giving up until every
// sample has been tried.
float[] averagedScenarioHourlyValues (int i, int[] sampleNowK, int[] sampleNowJ, int l) {
  int sampleCount = sampleNowK.length;

  float sumRdir = 0;
  float sumRdif = 0;
  float sumEdir = 0;
  float sumEdif = 0;
  float weightSum = 0;

  for (int s = 0; s < sampleCount; s++) {
    int now_k = sampleNowK[s];
    int now_j = sampleNowJ[s];

    float Pa = getValue_currentDataSource(i, now_j, now_k, LAYER_dirnorrad.id);
    float Pb = getValue_currentDataSource(i, now_j, now_k, LAYER_difhorrad.id);
    float Pc = getValue_currentDataSource(i, now_j, now_k, LAYER_direffect.id);
    float Pd = getValue_currentDataSource(i, now_j, now_k, LAYER_difeffect.id);

    if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) continue;

    boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, STUDY.temporalFilterSetting, STUDY.skyScenarioSetting, i, now_j, now_k);
    if (!isMemberCounted) continue;

    float weight = scenarioSampleWeight(s, sampleCount, l);
    sumRdir += weight * 0.001 * Pa;
    sumRdif += weight * 0.001 * Pb;
    sumEdir += weight * 0.001 * Pc;
    sumEdif += weight * 0.001 * Pd;
    weightSum += weight;
  }

  if (weightSum == 0) return null;

  return new float[] { sumRdir / weightSum, sumRdif / weightSum, sumEdir / weightSum, sumEdif / weightSum };
}

// The narrower case (Sun3D.pde's sun-path coloring, its first call site):
// a single raw layer value, weight-averaged across samples via
// scenarioSampleWeight() above, with no isMemberCounted filter applied at
// all - matching that one call site's own existing behavior, which never
// checked that filter either (it only ever gated on is_undefined()).
// Returns FLOAT_undefined, not 0, when none of the samples have a defined
// value - never silently averaging in "missing" as zero.
float averagedScenarioLayerValue (int i, int[] sampleNowK, int[] sampleNowJ, int layerId, int l) {
  int sampleCount = sampleNowK.length;

  float sum = 0;
  float weightSum = 0;

  for (int s = 0; s < sampleCount; s++) {
    float P = getValue_currentDataSource(i, sampleNowJ[s], sampleNowK[s], layerId);
    if (is_undefined(P)) continue;

    float weight = scenarioSampleWeight(s, sampleCount, l);
    sum += weight * P;
    weightSum += weight;
  }

  return (weightSum > 0) ? (sum / weightSum) : FLOAT_undefined;
}
