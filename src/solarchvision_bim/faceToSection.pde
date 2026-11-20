// "Face >> Section" action (actions.pde/uiMenuBar.pde) - converts every
// currently selected face into its own Section, lifted off the face's
// own plane along its own normal so the newly baked section doesn't
// z-fight with the face it came from.

// How far (world units) a converted section is lifted off its source
// face's own plane, along the face's own normal. No longer a fixed
// constant - exposed as its own spinner (valueModifier.pde's
// faceToSectionLift(), drawn in the CHILD_GEOMETRY_CREATE rollout panel
// - see uiRollout.pde) and saved to XML with the rest of the "display"
// settings (saveProject.pde/parseXmlVariables.pde), the same way
// Celestial Magnification and World Scale already are, for a
// face/surface too thin or too close-up for the 0.01 default to clear
// it without still z-fighting.
float FACE_TO_SECTION_LIFT = 0.01;

// Reuses computeSectionParamsFromFace() (mouseClicked.pde) for each
// face's own plane - the exact same centroid and 3 Euler angles a live
// left-click on that face would have produced, now including a genuine
// tilted-plane fit for a sloped face (that function's own comment on
// newellNormal()/fitTiltedSectionPlane() has the detail) rather than
// just the old flat-or-vertical-only choice. The one thing this adds on
// top of computeSectionParamsFromFace() itself: every one of the face's
// own vertices, projected into the new section's local X-Y plane via
// arbitrarySection_pointWorldToLocal() (arbitrarySection.pde), become
// the section's real corners - not just its bounding rectangle - so the
// section's mask crops down to the face's actual shape (see sections
// .pde's own comment on sectionInsideMask()/applySectionMask()). Since
// Sections now store an arbitrary n-gon (sections.pde's own corners
// field) rather than a fixed 4-corner quad, this is an EXACT fit for
// any face, a pentagon or hexagon included - no bounding-rectangle
// fallback needed anymore for a face with more than 4 sides.
void convertSelectedFacesToSections () {
  beginScene3DChange();

  int numberBefore = allSections.num;

  for (int o = 0; o < Select3D.faceSelection.length; o++) {
    int f = Select3D.faceSelection[o];

    SectionParams sp = computeSectionParamsFromFace(f);
    if (!sp.createNew) continue; // 2-or-fewer-node face - nothing to convert

    int[] nodes = allFaces.nodes[f];
    int n = nodes.length;

    float[] cornersXY = new float[2 * n];
    for (int j = 0; j < n; j++) {
      // The face's own vertices, in its own winding order -
      // sectionInsideMask()'s point-in-polygon test doesn't care
      // whether that's CW or CCW, so they're used as-is.
      float[] local = arbitrarySection_pointWorldToLocal(
        allPoints.getX(nodes[j]), allPoints.getY(nodes[j]), allPoints.getZ(nodes[j]),
        sp.RotX, sp.RotY, sp.RotZ, sp.X, sp.Y, sp.Z);
      cornersXY[2 * j] = local[0];
      cornersXY[2 * j + 1] = local[1];
    }

    // Lift the section off the face's own plane, along its own local Z
    // axis - which computeSectionParamsFromFace()'s own flip-correction
    // already lined up with the face's own (outward) normal - so the new
    // section doesn't z-fight with the face it came from.
    float[] liftWorld = arbitrarySection_rotateLocalToWorld(0, 0, FACE_TO_SECTION_LIFT, sp.RotX, sp.RotY, sp.RotZ);

    allSections.create(
      sp.X + liftWorld[0], sp.Y + liftWorld[1], sp.Z + liftWorld[2],
      sp.RotX, sp.RotY, sp.RotZ,
      cornersXY,
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
