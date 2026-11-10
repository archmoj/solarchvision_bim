// A "type 0" (arbitrary) section is oriented by 3 Euler angles - rotX
// (stored in the section's own existing R slot, reused rather than
// adding a redundant 4th column), rotY and rotZ - composed in exactly
// the same order Solids' own getCorners() (solids.pde) composes
// Solid_rotX/Solid_rotY/Solid_rotZ: rotate about X first, then about Y
// (using the already-rotated coordinates), then about Z. So an
// arbitrary section's rotX/rotY/rotZ mean exactly what a solid's own
// rotX/rotY/rotZ already mean elsewhere in this app - the same
// convention, not a new one.
//
// Both functions below are pure rotation - no position offset. A point
// additionally needs its position translated (added after rotating
// local-to-world, subtracted before rotating world-to-local); a pure
// direction (the sun vector, in castShadowsCurrentSection.pde) needs
// nothing extra, since a direction has no position to translate.
//
// rotateWorldToLocal() is the exact mathematical inverse of
// rotateLocalToWorld() - same 3 rotations, reverse order, negated
// angles - verified by ArbitrarySectionTest.java's own round-trip
// coverage.

// Rotates a LOCAL vector (a, b, c) into its WORLD orientation.
float[] arbitrarySection_rotateLocalToWorld (float a, float b, float c, float rotX, float rotY, float rotZ) {

  float y1 = b * funcs.cos_ang(rotX) - c * funcs.sin_ang(rotX);
  float z1 = b * funcs.sin_ang(rotX) + c * funcs.cos_ang(rotX);
  float x1 = a;

  a = x1;
  b = y1;
  c = z1;

  float z2 = c * funcs.cos_ang(rotY) - a * funcs.sin_ang(rotY);
  float x2 = c * funcs.sin_ang(rotY) + a * funcs.cos_ang(rotY);
  float y2 = b;

  a = x2;
  b = y2;
  c = z2;

  float x = a * funcs.cos_ang(rotZ) - b * funcs.sin_ang(rotZ);
  float y = a * funcs.sin_ang(rotZ) + b * funcs.cos_ang(rotZ);
  float z = c;

  return new float[] { x, y, z };
}

// Rotates a WORLD vector (x, y, z) into its LOCAL orientation - the
// exact inverse of arbitrarySection_rotateLocalToWorld() above: undo Z,
// then Y, then X.
float[] arbitrarySection_rotateWorldToLocal (float x, float y, float z, float rotX, float rotY, float rotZ) {

  float a1 =  x * funcs.cos_ang(rotZ) + y * funcs.sin_ang(rotZ);
  float b1 = -x * funcs.sin_ang(rotZ) + y * funcs.cos_ang(rotZ);
  float c1 = z;

  float c2 =  c1 * funcs.cos_ang(rotY) + a1 * funcs.sin_ang(rotY);
  float a2 = -c1 * funcs.sin_ang(rotY) + a1 * funcs.cos_ang(rotY);
  float b2 = b1;

  float b3 =  b2 * funcs.cos_ang(rotX) + c2 * funcs.sin_ang(rotX);
  float c3 = -b2 * funcs.sin_ang(rotX) + c2 * funcs.cos_ang(rotX);
  float a3 = a2;

  return new float[] { a3, b3, c3 };
}

// Point (not direction) convenience wrappers - fold the section's own
// position offset in, so call sites that already have an (X, Y, Z)
// position and a world or local point don't each have to add/subtract
// it by hand.
float[] arbitrarySection_pointLocalToWorld (float a, float b, float c, float rotX, float rotY, float rotZ, float X, float Y, float Z) {
  float[] r = arbitrarySection_rotateLocalToWorld(a, b, c, rotX, rotY, rotZ);
  return new float[] { r[0] + X, r[1] + Y, r[2] + Z };
}

float[] arbitrarySection_pointWorldToLocal (float x, float y, float z, float rotX, float rotY, float rotZ, float X, float Y, float Z) {
  return arbitrarySection_rotateWorldToLocal(x - X, y - Y, z - Z, rotX, rotY, rotZ);
}
