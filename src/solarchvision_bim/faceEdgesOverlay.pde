// --- face-edges overlay -----------------------------------------------------
// A black-edges-on-transparent PNG, baked once per preBakeViewport() run
// (see that file's own comment, right alongside the Model2Ds mask) at the
// exact same resolution and camera as allSolarImpacts.Image[][] itself -
// meant to be drawn on top of the solar-impact overlay in draw_WIN3D_
// layers.pde, to make building edges easier to pick out against the
// heatmap. Because it's the same resolution as the overlay image, it needs
// no fit rect of its own - draw_WIN3D_layersAndHover.pde reuses the exact one
// already computed for the overlay image.
//
// Loaded lazily and cached here, rather than reloaded from disk every
// single frame the way allSolarImpacts.Image[][] itself gets freshly
// painted (see draw_WIN3D_layersAndHover.pde's own comment on that) - re-loaded
// only when the file actually needs it: the expected path changed (a
// different camera, location, or project), or the file at that same path
// was modified since it was last loaded (re-running preBakeViewport() -
// after moving the camera or editing the model, say - saves over the
// exact same path, which a path-only cache key would never notice).
PImage faceEdgesOverlay_cachedImage = null;
String faceEdgesOverlay_cachedPath = null;
long faceEdgesOverlay_cachedModified = -1;

// Returns the face-edges PNG for the current camera/location, or null if
// none has been baked yet (preBakeViewport() hasn't run, or ran before
// this feature existed) - mirrors exactly how calculate_Impact_
// CurrentPreBaked() locates its own Model2Ds mask (SolarImpacts.pde), and
// how preBakeViewport() itself names the file it saves.
PImage faceEdgesOverlay_load () {
  String path = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "FaceEdges_Camera" + nf(cameraIndex, 2) + ".png";
  File file = new File(path);

  if (!file.exists()) {
    faceEdgesOverlay_cachedPath = path;
    faceEdgesOverlay_cachedModified = -1;
    faceEdgesOverlay_cachedImage = null;
    return null;
  }

  long modified = file.lastModified();

  if (!path.equals(faceEdgesOverlay_cachedPath) || modified != faceEdgesOverlay_cachedModified) {
    faceEdgesOverlay_cachedPath = path;
    faceEdgesOverlay_cachedModified = modified;
    faceEdgesOverlay_cachedImage = loadImage(path);
  }

  return faceEdgesOverlay_cachedImage;
}
