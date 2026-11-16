// "Face >> Section" action (actions.pde/uiMenuBar.pde) - converts every
// currently selected face into its own Section, lifted off the face's
// own plane along its own normal so the newly baked section doesn't
// z-fight with the face it came from.

// How far (world units) a converted section is lifted off its source
// face's own plane, along the face's own normal.
final float FACE_TO_SECTION_LIFT = 0.01;

// Reuses computeSectionParamsFromFace() (mouseClicked.pde) for each
// face's own plane - the exact same centroid and 3 Euler angles a live
// left-click on that face would have produced, now including a genuine
// tilted-plane fit for a sloped face (that function's own comment on
// newellNormal()/fitTiltedSectionPlane() has the detail) rather than
// just the old flat-or-vertical-only choice. The one thing this adds on
// top of computeSectionParamsFromFace() itself: a triangular or
// quadrilateral face's own vertices, projected into the new section's
// local X-Y plane via arbitrarySection_pointWorldToLocal()
// (arbitrarySection.pde), become the section's real p1..p4 corners -
// not just its bounding rectangle - so the section's mask crops down to
// the face's actual shape (see sections.pde's own comment on
// sectionInsideMask()/applySectionMask()). A face with more than 4
// sides falls back to a bounding rectangle instead, since no single
// quad could represent it exactly - computed here as the true min/max
// of every one of the face's own vertices (projected the same way),
// NOT assumed centered on the face's own vertex centroid: those two
// only coincide for a shape symmetric about its centroid (a rectangle,
// say) - for an asymmetric n-gon (a gable wall's rectangle-plus-
// triangular-peak pentagon, for instance) they don't, and building a
// symmetric rectangle around the wrong center would leave part of the
// face uncovered on one side and waste rectangle on the other.
void convertSelectedFacesToSections () {
  beginScene3DChange();

  int numberBefore = allSections.num;

  for (int o = 0; o < Select3D.faceSelection.length; o++) {
    int f = Select3D.faceSelection[o];

    SectionParams sp = computeSectionParamsFromFace(f);
    if (!sp.createNew) continue; // 2-or-fewer-node face - nothing to convert

    int[] nodes = allFaces.nodes[f];
    int n = nodes.length;

    float[][] local = new float[n][];
    for (int j = 0; j < n; j++) {
      local[j] = arbitrarySection_pointWorldToLocal(
        allPoints.getX(nodes[j]), allPoints.getY(nodes[j]), allPoints.getZ(nodes[j]),
        sp.RotX, sp.RotY, sp.RotZ, sp.X, sp.Y, sp.Z);
    }

    float p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y;

    if ((n == 3) || (n == 4)) {
      // Exact shape: the face's own vertices, in its own winding order -
      // sectionInsideMask()'s point-in-polygon test doesn't care whether
      // that's CW or CCW, so it's used as-is.
      p1x = local[0][0];
      p1y = local[0][1];
      p2x = local[1][0];
      p2y = local[1][1];
      p3x = local[2][0];
      p3y = local[2][1];

      if (n == 4) {
        p4x = local[3][0];
        p4y = local[3][1];
      } else {
        // Triangle - closes back to its first point, same default
        // __SECTION__ (extraCommands.pde) uses when p4 is omitted.
        p4x = p1x;
        p4y = p1y;
      }
    } else {
      // More than 4 sides - the real bounding rectangle of every one of
      // this face's own vertices (not assumed centered on sp.X/Y/Z - see
      // this function's own comment above on why that assumption would
      // be wrong here).
      float minX = FLOAT_undefined;
      float maxX = -FLOAT_undefined;
      float minY = FLOAT_undefined;
      float maxY = -FLOAT_undefined;

      for (int j = 0; j < n; j++) {
        float lx = local[j][0];
        float ly = local[j][1];

        if (minX > lx) minX = lx;
        if (maxX < lx) maxX = lx;
        if (minY > ly) minY = ly;
        if (maxY < ly) maxY = ly;
      }

      p1x = minX;
      p1y = minY;
      p2x = maxX;
      p2y = minY;
      p3x = maxX;
      p3y = maxY;
      p4x = minX;
      p4y = maxY;
    }

    // Lift the section off the face's own plane, along its own local Z
    // axis - which computeSectionParamsFromFace()'s own flip-correction
    // already lined up with the face's own (outward) normal - so the new
    // section doesn't z-fight with the face it came from.
    float[] liftWorld = arbitrarySection_rotateLocalToWorld(0, 0, FACE_TO_SECTION_LIFT, sp.RotX, sp.RotY, sp.RotZ);

    allSections.create(
      sp.X + liftWorld[0], sp.Y + liftWorld[1], sp.Z + liftWorld[2],
      sp.RotX, sp.RotY, sp.RotZ,
      p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y,
      sp.ResX, sp.ResY
      );
  }

  Select3D.deselect_Faces();
  Select3D.deselect_Sections();
  // appendRange() is Clone3D's own small helper (clone3D.pde) - reused
  // here rather than duplicated, since it does exactly what's needed:
  // select every newly-created section, [numberBefore, allSections.num).
  Select3D.sectionSelection = Clone3D.appendRange(Select3D.sectionSelection, numberBefore, allSections.num);
  selection_changed();

  endScene3DChange();
}
