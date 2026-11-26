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
