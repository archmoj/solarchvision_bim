// The app's one shared way of rating "how good is this orientation's/
// vertex's net solar response" - a benefit-vs-harm balance, not just a
// raw net total. This AVERAGE/PERCENTAGE/COMPARISON method is the
// author's own invention - see the repo's top-level CITATION.cff for
// how to cite it.
//
// Previously duplicated verbatim (same AVERAGE/
// PERCENTAGE/COMPARISON three-liner, differing only in which two
// variables feed sumP/sumN) in seven places across four files:
// calculateGlobalSolarArray.pde (the whole-sky inclination/orientation
// grid, once per sampled day and once more for the all-days total),
// viewport2D.pde's sky-hover readout (the same grid, recomputed live
// under the cursor, also per-day and all-days-total), calculateVertex
// SolarArray.pde (per-vertex sample point, per-day and all-days-total),
// and solarImpacts.pde (the solar-impact-coloring sweep). Centralized
// here so all seven stay in lockstep by construction, and so a future
// caller (e.g. the Passive Solar Touch modifier, modify3D.pde - or a
// later, broader form-finding process that pulls that modifier's push/
// pull decision together with other factors - wanting this same
// per-vertex/per-orientation score) has one obvious function to call
// instead of re-deriving or re-copying the formula a fourth time.
//
// sumP/sumN are a (positive effect, negative effect) pair - whatever
// the caller's own units are (this file doesn't care): each call site
// sums some set of signed solar contributions into two buckets first -
// SolarAtSurface() readings split by sign in calculateGlobalSolarArray.
// pde/calculateVertexSolarArray.pde/viewport2D.pde, or a (benefit,harm)
// image-pixel pair in solarImpacts.pde - then passes the two sums here.
//
// What this computes, and why it's the right shape for "how good":
//   AVERAGE    = sumP - sumN                         (the net balance)
//   PERCENTAGE = AVERAGE / (sumP + sumN)              (net as a share of
//                                                       total exposure,
//                                                       0 if that total
//                                                       is ~0 - avoids a
//                                                       divide-by-near-
//                                                       zero on an all-
//                                                       shaded sample)
//   return     = |PERCENTAGE| * AVERAGE
//
// Substituting PERCENTAGE into the return expression collapses it to
// sign(AVERAGE) * AVERAGE^2 / (sumP + sumN) - i.e. the net balance,
// SQUARED, divided by total exposure. That's deliberately not the same
// ranking a plain AVERAGE (raw net) would give: two cases with the same
// raw sumP-sumN don't score the same here. A case where sumP and sumN
// are both large and nearly cancel (lots of exposure in both directions,
// no clear overall direction) scores LOWER than a case where the same
// net comes from a clearly one-sided split (little opposing exposure to
// cancel it out). For anything using this as an optimization objective
// (ranking orientations, or nudging a shape toward a better one), that
// means it rewards a CONSISTENTLY one-sided solar response over merely a
// LARGER one that's actually a wash between strong opposing effects.
//
// Returns 0 when sumP+sumN is at or below the same 0.00001 floor every
// original call site already guarded with, not NaN/Infinity. If either
// input is the FLOAT_undefined sentinel (globalFunctions.pde), the
// result comes out equal to that same sentinel too (float32's precision
// loss at that magnitude swallows any ordinary-sized sumP/sumN added to
// or divided into it) - every call site already relies on exactly that
// propagation via its own is_defined(...) check afterward, so this
// keeps it, rather than adding an explicit early-return for it, to stay
// bit-identical to the formula each site had inlined before.
float solarComparisonScore (float sumP, float sumN) {
  float AVERAGE = sumP - sumN;
  float PERCENTAGE = ((sumP + sumN) > 0.00001) ? (AVERAGE / (1.0 * (sumP + sumN))) : 0.0;
  return (abs(PERCENTAGE) * AVERAGE);
}
