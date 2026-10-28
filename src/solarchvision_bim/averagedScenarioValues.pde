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
// hour, averaged across samples. A sample only contributes if ALL FOUR of
// its layers are defined AND it passes the isMemberCounted filter (called
// once per sample, not once per layer - filter() can itself loop across
// all 24 hours in filter_DAILY mode, so evaluating it four times over for
// every sample/hour would be purely wasted work). Returns {R_dir, R_dif,
// E_dir, E_dif} (already *0.001-scaled, like every call site already
// scaled its own single-scenario Pa/Pb/Pc/Pd), or null when NONE of the
// samples have usable data for this hour - the same "nothing to use this
// hour" outcome a single-scenario pick already produces when its own
// values are undefined or filtered out, just not giving up until every
// sample has been tried.
float[] averagedScenarioHourlyValues (int i, int[] sampleNowK, int[] sampleNowJ) {
  float sumRdir = 0;
  float sumRdif = 0;
  float sumEdir = 0;
  float sumEdif = 0;
  int count = 0;

  for (int s = 0; s < sampleNowK.length; s++) {
    int now_k = sampleNowK[s];
    int now_j = sampleNowJ[s];

    float Pa = getValue_currentDataSource(i, now_j, now_k, LAYER_dirnorrad.id);
    float Pb = getValue_currentDataSource(i, now_j, now_k, LAYER_difhorrad.id);
    float Pc = getValue_currentDataSource(i, now_j, now_k, LAYER_direffect.id);
    float Pd = getValue_currentDataSource(i, now_j, now_k, LAYER_difeffect.id);

    if (is_undefined(Pa) || is_undefined(Pb) || is_undefined(Pc) || is_undefined(Pd)) continue;

    boolean isMemberCounted = filter(currentDataSource, LAYER_cloudcover.id, STUDY.temporalFilterSetting, STUDY.skyScenarioSetting, i, now_j, now_k);
    if (!isMemberCounted) continue;

    sumRdir += 0.001 * Pa;
    sumRdif += 0.001 * Pb;
    sumEdir += 0.001 * Pc;
    sumEdif += 0.001 * Pd;
    count += 1;
  }

  if (count == 0) return null;

  return new float[] { sumRdir / count, sumRdif / count, sumEdir / count, sumEdif / count };
}

// The narrower case (Sun3D.pde's sun-path coloring, its first call site):
// a single raw layer value, averaged across samples, with no
// isMemberCounted filter applied at all - matching that one call site's
// own existing behavior, which never checked that filter either (it only
// ever gated on is_undefined()). Returns FLOAT_undefined, not 0, when none
// of the samples have a defined value - never silently averaging in
// "missing" as zero.
float averagedScenarioLayerValue (int i, int[] sampleNowK, int[] sampleNowJ, int layerId) {
  float sum = 0;
  int count = 0;

  for (int s = 0; s < sampleNowK.length; s++) {
    float P = getValue_currentDataSource(i, sampleNowJ[s], sampleNowK[s], layerId);
    if (is_undefined(P)) continue;

    sum += P;
    count += 1;
  }

  return (count > 0) ? (sum / count) : FLOAT_undefined;
}
