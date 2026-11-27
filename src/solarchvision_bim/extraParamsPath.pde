// Dotted-path read/write on top of extraParamsHelpers.pde's own parsed
// JSONObject - "ifcShape.origin" means "the origin key inside the
// ifcShape key", the same addressing PARENT_EXTRA_PARAMS' own row
// captions show the user (uiRollout.pde) and that EXTRAPARAMS.SET/
// EXTRAPARAMS.REMOVE (extraCommands.pde) take as their own <key>
// argument - one scheme, so what a row displays is always exactly what
// could also be typed on the command line to produce the same edit.
//
// A literal "." inside a real key name would be misread as a path
// separator - nothing any importer in this app produces does that
// today, so this is a documented v1 limitation rather than something
// escaped/guarded against here.

// Splits a dotted path into its segments. Deliberately NOT tokenizeScriptLine
// (runScriptDispatch.pde) - a path has nothing in it that needs quote-
// stripping or space-collapsing, and reusing that would be reaching for
// a tool built for a different, unrelated problem.
String[] extraParamsSplitPath (String path) {
  return split(path, '.');
}

// obj's existing value at key, but only if it's actually a JSONObject -
// same defensive shape as importGeojson.pde's own geojsonGetObjectOrNull
// (hasKey() alone is true for an explicit JSON null too, and a
// non-object value must never be handed back as if it were one), just
// checked by instanceof instead of a getJSONObject() call, since here
// the key's value could legitimately be anything at all, not something
// a format spec already promises is an object or null.
JSONObject extraParamsExistingChildObject (JSONObject obj, String key) {
  if (obj == null || !obj.hasKey(key) || obj.isNull(key)) return null;
  Object v = obj.get(key);
  return (v instanceof JSONObject) ? (JSONObject) v : null;
}

// Decodes a SET command's raw value text (exactly as typed - see
// EXTRAPARAMS.SET's own tokenizer-bypass comment in runScript.pde) into
// whatever Object JSONObject.put() would store for it. Wraps the text as
// the lone value of a throwaway {"v": ...} object and leans on
// JSONObject's own parser for the actual decoding, rather than hand-
// rolling JSON value parsing - the same "paraphrase instead of
// reinvent" posture extraParamsHelpers.pde's own extraParamsToJSONObject()
// already takes for the object-as-a-whole case.
//
// This means a properly JSON-quoted string ("South wall\nupper row")
// decodes its \n the normal JSON way, a bare number/true/false/{...}/
// [...] becomes that real type, and a bare "null" becomes a real,
// explicit JSON null (JSONObject.NULL) - not a sentinel for delete;
// EXTRAPARAMS.REMOVE is the dedicated command for that, kept separate
// specifically so a field can legitimately hold null (e.g. GeoJSON
// properties, which RFC 7946 allows to be null) without colliding with
// "delete this key".
//
// Anything that fails to parse this way - most plain typed text, e.g.
// Window Panel A: unquoted, with spaces, not valid JSON on its own -
// falls back to being stored exactly as typed, as a literal String, so
// an ordinary name/description never needs to be hand-quoted just to be
// entered.
Object extraParamsParseCommandValue (String rawValue) {
  try {
    JSONObject wrapper = JSONObject.parse("{\"v\":" + rawValue.strip() + "}");
    return wrapper.get("v");
  } catch (RuntimeException e) {
    return rawValue;
  }
}

// Upserts rawValue into root at the given dotted path, creating
// intermediate JSONObjects as needed - including replacing any
// intermediate segment whose existing value isn't itself a JSONObject,
// consistent with this app's existing "extraparams always wins"
// collision policy (exportIfc.pde's own header comment). Mutates root in
// place and returns it, for convenience at the call site.
JSONObject extraParamsSetAtPath (JSONObject root, String path, String rawValue) {
  String[] segments = extraParamsSplitPath(path);
  JSONObject cursor = root;
  for (int i = 0; i < segments.length - 1; i++) {
    JSONObject next = extraParamsExistingChildObject(cursor, segments[i]);
    if (next == null) {
      next = new JSONObject();
      cursor.setJSONObject(segments[i], next);
    }
    cursor = next;
  }
  cursor.put(segments[segments.length - 1], extraParamsParseCommandValue(rawValue));
  return root;
}

// Removes the key at the given dotted path, if present. A no-op (never
// throws) if any segment along the way is missing or isn't itself a
// JSONObject - a key that was never there is already, in effect,
// removed. Returns true only when an actual removal happened, so a
// caller can tell "removed" apart from "nothing there to remove" for its
// own hint text.
boolean extraParamsRemoveAtPath (JSONObject root, String path) {
  String[] segments = extraParamsSplitPath(path);
  JSONObject cursor = root;
  for (int i = 0; i < segments.length - 1; i++) {
    cursor = extraParamsExistingChildObject(cursor, segments[i]);
    if (cursor == null) return false;
  }
  String lastKey = segments[segments.length - 1];
  if (!cursor.hasKey(lastKey)) return false;
  cursor.remove(lastKey);
  return true;
}
