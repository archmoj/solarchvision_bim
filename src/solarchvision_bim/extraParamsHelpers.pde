// Shared conversion between an item's own raw extraParams String (one per
// item, default "" - faces.pde/polylines.pde/model1Ds.pde/groups.pde and
// friends each carry a parallel String[] extraParams array, the same way
// they already carry int[]/float[] option columns) and a parsed
// JSONObject a caller can actually read/write named keys on (name,
// percentCompleted, etc. - see the architecture discussion this
// implements). Pulled out here, once, rather than re-implemented per
// class, so every class's own getExtraParamsObject(n)/
// setExtraParamsObject(n, obj) is a one-line call into this file instead
// of five slightly-different hand-rolled JSON parse/stringify blocks.

// Parses a raw extraParams string into a JSONObject - never null, never
// throws. An empty/missing string, the literal "{}", or JSON that fails
// to parse as an object (JSONObject.parse() throws rather than returning
// null on malformed input, confirmed against this build's own core.jar)
// all resolve to the exact same thing: a fresh empty JSONObject. That
// means every caller has exactly one "nothing here" case to handle, not
// four, and can read a key straight off the result (JSONObject's own
// getString(key, default)/getFloat(key, default)/etc. already treat a
// missing key as "use the default") without any of its own null-checks
// or try/catch.
JSONObject extraParamsToJSONObject (String raw) {
  if (raw == null || raw.length() == 0) return new JSONObject();
  try {
    return JSONObject.parse(raw);
  } catch (RuntimeException e) {
    return new JSONObject(); // malformed - treated exactly like "no extra params"
  }
}

// The inverse - canonicalizes obj back down to a raw extraParams string.
// An empty (or null) object always collapses back to "", this field's
// own default/"nothing here" value, rather than a literal "{}" - so
// clearing an item's last extra-params key naturally returns that item
// to its original, never-used-this-feature state (and to_XML()'s own
// output for it), instead of leaving a permanent "{}" behind.
String extraParamsFromJSONObject (JSONObject obj) {
  if (obj == null || obj.keys().size() == 0) return "";
  return obj.toString();
}

// ----------------------------------------------------------------------
// Multi-entity key logic shared by PARENT_EXTRA_PARAMS's "Bulk Edit"/
// "Assign Missing" tabs (uiRollout.pde's drawExtraParamsBulkEditPanel()/
// drawExtraParamsAssignMissingTab()) - pulled out here, independently
// testable, same reasoning as stripExtraParams_Selection()/
// stripExtraParams_Scene() (extraParamsSelection.pde): every other piece
// of extraParams logic in this app is callable on its own, without
// going through a draw method or the untestable action registry
// (test/ExtraParamsCommandTest.java's own setUp() resets allActions to
// empty), and this is no exception. Each caller still owns the
// deterministic sort it applies to the result, and the UI-specific
// "various"/"missing N/M" display strings - these functions return only
// the underlying key sets/counts, nothing about how a row is drawn.

// Bulk Edit's own "commonKeys" - keys present on every one of objs (an
// intersection, not a union). Trivially every key of objs.get(0) when
// objs has exactly one entry, same as drawExtraParamsBulkEditPanel()'s
// own comment already notes (a single selected entity has nothing to
// disagree with).
ArrayList<String> extraParamsCommonKeys (ArrayList<JSONObject> objs) {
  ArrayList<String> commonKeys = new ArrayList<String>(objs.get(0).keys());
  for (int i = 1; i < objs.size(); i++) {
    commonKeys.retainAll(objs.get(i).keys());
  }
  return commonKeys;
}

// Whether every one of objs shows the same value for key - returns that
// shared value (JSONObject-stringified if the value is itself an
// object, same as the row's own "shown" string) when every object
// agrees, or null when they don't. The caller decides what null means
// to display ("various" today); a pure function has no business owning
// that string. Assumes every object in objs actually has key - callers
// only ever call this for a key already known to be common (an entry of
// extraParamsCommonKeys()'s own result).
String extraParamsUniformValueForKey (ArrayList<JSONObject> objs, String key) {
  String firstShown = null;
  for (JSONObject o : objs) {
    Object v = o.get(key);
    String shown = (v instanceof JSONObject) ? ((JSONObject) v).toString() : String.valueOf(v);
    if (firstShown == null) firstShown = shown;
    else if (!firstShown.equals(shown)) return null;
  }
  return firstShown;
}

// Assign Missing's own "partialKeys" - the complement of
// extraParamsCommonKeys() above: every key present on at least one of
// objs but absent from at least one other, so a key lands on exactly
// one of extraParamsCommonKeys()'s own result or this one's (or
// neither, if it's on none of objs at all).
ArrayList<String> extraParamsPartialKeys (ArrayList<JSONObject> objs) {
  java.util.LinkedHashSet<String> unionKeys = new java.util.LinkedHashSet<String>();
  for (JSONObject o : objs) unionKeys.addAll(o.keys());

  ArrayList<String> partialKeys = new ArrayList<String>();
  for (String key : unionKeys) {
    int presentCount = 0;
    for (JSONObject o : objs) if (o.keys().contains(key)) presentCount++;
    if (presentCount > 0 && presentCount < objs.size()) partialKeys.add(key);
  }
  return partialKeys;
}

// How many of objs are missing key entirely - Assign Missing's own
// per-row "missing N/M" count (drawExtraParamsAssignMissingTab()).
int extraParamsMissingCount (ArrayList<JSONObject> objs, String key) {
  int missingCount = 0;
  for (JSONObject o : objs) if (!o.keys().contains(key)) missingCount++;
  return missingCount;
}
