// Everything ___executeScriptLine___ (in runScript.pde) uses, before its
// own switch-case, to resolve a typed command line against allActions:
// sanitizing/tokenizing the raw line, then the three progressively
// looser ways it can match a registered command (full line, the line
// with its last word removed, first token alone). Pulled out into its
// own file so each piece can be exercised directly in tests - against a
// throwaway allActions map and/or a synthetic bypass entry - rather than
// only indirectly through a full runScriptLine(...) call; see
// RunScriptTest.java's own "sanitizeScriptLine / tokenizeScriptLine",
// "matchFullLine / matchTrailingWordRemoved / matchFirstToken", and
// "resolveAction: future collision scenarios" sections.

// Lowercase command names that must always reach the switch-case in
// runScriptLine below, even though each also has a bare, zero-argument
// menu action of the same name (e.g. "Move" switches the active move
// tool - see UI_setTo_Modify_Move). Without this, the allActions lookup
// there would match that bare action - by a full-line match on the bare
// name alone, or by first token when real parameters follow it - before
// the switch-case ever runs, silently ignoring those parameters, or
// printing that bare action's own hint instead of the switch-case
// command's. Checked below against each of allActions' three match
// attempts individually, against the exact key *that* attempt would
// look up (the full line, the first token, or the line with its last
// word removed) - not merely against the line's first word - so a
// different, longer command that only *starts* with one of these names
// (e.g. "Scale Vector Index", starting with "scale") is unaffected and
// still dispatches normally.
HashSet<String> bypassAllActionsFor = new HashSet<String>(Arrays.asList(
  "box", "camera", "cone", "cushion",
  "cylinder", "house1", "house2", "house3",
  "icosahedron", "mesh", "move", "octahedron",
  "person", "polyline", "pyramid",
  "rotate", "rotatex", "rotatey", "rotatez",
  "scale", "section", "solid", "sphere"
));

// One resolved allActions match: which key resolved it, the Action
// itself (so a caller/test never needs a second allActions.get(key)
// lookup), and the args to invoke it with - not always the full typed
// line, see matchTrailingWordRemoved below.
class ActionMatch {
  String key;
  Action action;
  String[] args;
  ActionMatch (String key, Action action, String[] args) {
    this.key = key;
    this.action = action;
    this.args = args;
  }
}

// Strips a script line down to something ___executeScriptLine___ can
// use, or signals it should be skipped entirely - blank, a "=" section
// marker, or a "#" comment line (each ignored the same way by
// _runScriptLine's own, separate copy of this same check, upstream of
// here). Returns null for skip.
String sanitizeScriptLine (String lineSTR) {
  lineSTR = lineSTR.stripLeading();
  if (lineSTR.startsWith("=")) return null;
  if (lineSTR.startsWith("#")) return null;
  lineSTR = lineSTR.stripTrailing();
  if (lineSTR.equals("")) return null;
  return lineSTR;
}

// Splits a sanitized line into the space-separated tokens the
// switch-case below (and allActions' first-token/trailing-word matches)
// both key off: drops quotes, collapses repeated spaces, turns "="
// into ":" and collapses repeated colons (so a command's key:value
// pairs tolerate either separator plus any extra whitespace), then
// splits on spaces.
String[] tokenizeScriptLine (String lineSTR) {
  String transformedLine = lineSTR
    .replace("\"", "")
    .replaceAll(" +", " ")  // replace multiple spaces with a single space
    .replace("=", ":")      // replace equal with colon
    .replaceAll(":+", ":"); // replace multiple colons with a single colon

  return split(transformedLine, ' ');
}

// Tier 1: full-line match - menu captions such as "Save As..." that may
// contain spaces and take no arguments. Skipped when the full line is
// exactly one of bypassAllActionsFor's bare, switch-case-reserved names
// (see that set's own comment): that bare caption also has its own,
// same-named menu action registered, and the switch-case's own no-args
// branch must win over it (e.g. runScriptLine("Scale") needs to reach
// SCALE's hint branch, not UI_setTo_Modify_Scale(3)).
ActionMatch matchFullLine (String key, String[] parts) {
  if (key.equals("") || bypassAllActionsFor.contains(key)) return null;
  Action action = allActions.get(key);
  if (action == null) return null;
  return new ActionMatch(key, action, parts);
}

// Tier 2: the line with its last word removed - a multi-word command
// name (e.g. "days merged count", also registered under its literal
// caption by putAction's "withSpace" fallback) can then also be typed
// with a value appended (e.g. "days merged count 15"), the trailing
// word being that value. Tried before matchFirstToken below on purpose:
// this prefix is always at least as long as (and, whenever the line has
// more than two words, strictly longer than) the bare first token
// alone, so it's the more specific of the two whenever both would match
// - e.g. "Day Increment 2.5" must resolve to "day increment" (this
// match), not fall - as it would if matchFirstToken ran first - to
// "day" (TIME.day, a completely different, separately-registered
// command that first token also happens to name on its own), which
// would then try and fail to parse "Increment" as Day's numeric value
// instead. Same bypass exception as matchFullLine: a two-word line like
// "Scale 2" (SCALE's own shorthand uniform-factor form) strips down to
// the bare "scale" here too.
ActionMatch matchTrailingWordRemoved (String key, String[] parts) {
  int lastSpace = key.lastIndexOf(' ');
  if (lastSpace <= 0) return null;
  String prefix = key.substring(0, lastSpace);
  if (bypassAllActionsFor.contains(prefix)) return null;
  Action action = allActions.get(prefix);
  if (action == null) return null;
  return new ActionMatch(prefix, action, new String[]{prefix, parts[parts.length - 1]});
}

// Tier 3: a first-token match, so commands registered with parameters
// (e.g. "start_day 15") can be reused here - same bypass exception as
// the other two tiers, now checked against just the first token (e.g.
// "Move dx:1 dy:2 dz:3" must still reach MOVE's switch-case, not the
// bare "Move" menu action a first-token-only match would otherwise
// find). The least specific of the three tiers, and tried last: see
// matchTrailingWordRemoved's own comment for why.
ActionMatch matchFirstToken (String[] parts) {
  if (parts.length == 0) return null;
  String firstToken = parts[0].toLowerCase();
  if (bypassAllActionsFor.contains(firstToken)) return null;
  Action action = allActions.get(firstToken);
  if (action == null) return null;
  return new ActionMatch(firstToken, action, parts);
}

// Tries all three allActions match tiers above, in order, returning the
// first (most specific) hit, or null if none match - the single place
// that order is decided, so a collision scenario (two separately-
// registered commands where one's full name is a prefix of the
// other's, as "Day"/"Day Increment" and "Pivot"/"Pivot Alignment X"
// both were) can be tested directly against it, with a throwaway
// allActions map, instead of only via the real app's full command set.
ActionMatch resolveAction (String lineSTR, String[] parts) {
  String key = lineSTR.toLowerCase();
  ActionMatch match = matchFullLine(key, parts);
  if (match == null) match = matchTrailingWordRemoved(key, parts);
  if (match == null) match = matchFirstToken(parts);
  return match;
}
