boolean diag_XML_input = false;
boolean diag_XML_output = false;

String XML_getContent(XML xml) {
 String result = xml.getContent();
 //if (diag_XML_input) println("<" + result + ">");
 return result;
}

String XML_getString(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 String result = xml.getString(tag);
 if (diag_XML_input) println('"' + result + '"');
 return result;
}

float XML_getFloat(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 float result = xml.getFloat(tag);
 if (diag_XML_input) println(result);
 return result;
}

int XML_getInt(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 int result = xml.getInt(tag);
 if (diag_XML_input) println(result);
 return result;
}

Boolean XML_getBoolean(XML xml, String tag) {
 if (diag_XML_input) print(tag + "=");
 Boolean result = Boolean.parseBoolean(xml.getString(tag));
 if (diag_XML_input) println(result);
 return result;
}

void XML_setContent(XML xml, String value) {
 //if (diag_XML_output) println("<" + value + ">");
 xml.setContent(value);
}

void XML_setString(XML xml, String tag, String value) {
 if (diag_XML_output) {
   print(tag + "=");
   println('"' + value + '"');
 }
 xml.setString(tag, value);
}

void XML_setFloat(XML xml, String tag, float value) {
 if (diag_XML_output) {
   print(tag + "=");
   println(value);
 }
 xml.setFloat(tag, value);
}

void XML_setInt(XML xml, String tag, int value) {
 if (diag_XML_output) {
   print(tag + "=");
   println(value);
 }
 xml.setInt(tag, value);
}

void XML_setBoolean(XML xml, String tag, boolean value) {
 if (diag_XML_output) {
   print(tag + "=");
   println(value);
 }
 xml.setString(tag, Boolean.toString(value));
}

// A variable-length flat float array (an n-gon's own {x0,y0,x1,y1,...}
// corners - Sections/SolidImpacts/SolarImpacts all have one of these
// now, see sections.pde's own comment) serialized as one comma-joined
// string attribute, since XML has no array setter/getter of its own
// (XML_setFloat/XML_getFloat above are scalar-only). Kept here, not
// duplicated in each of those 3 classes' own to_XML/from_XML.
void XML_setFloatArray(XML xml, String tag, float[] values) {
 String joined = "";
 for (int i = 0; i < values.length; i++) {
   if (i > 0) joined += ",";
   joined += nf(values[i], 0, 6).replace(",", ".");
 }
 XML_setString(xml, tag, joined);
}

float[] XML_getFloatArray(XML xml, String tag) {
 String raw = XML_getString(xml, tag);
 if ((raw == null) || raw.equals("")) return new float[0];
 String[] parts = split(raw, ",");
 float[] result = new float[parts.length];
 for (int i = 0; i < parts.length; i++) {
   result[i] = float(parts[i]);
 }
 return result;
}
