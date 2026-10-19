// --- face-edges overlay -----------------------------------------------------
// A black-edges-on-transparent PNG, baked once per preBakeViewport() run
// (see that file's own comment, right alongside the Model2Ds mask) at the
// exact same resolution and camera as allSolarImpacts.Image[][] itself -
// meant to be drawn on top of the solar-impact overlay in draw_WIN3D_
// layers.pde, to make building edges easier to pick out against the
// heatmap. Because it's the same resolution as the overlay image, it needs
// no fit rect of its own - draw_WIN3D_layers.pde reuses the exact one
// already computed for the overlay image.
//
// Loaded lazily and cached here, rather than reloaded from disk every
// single frame the way allSolarImpacts.Image[][] itself gets freshly
// painted (see draw_WIN3D_layers.pde's own comment on that) - nothing
// about this file changes between bakes, so it's only re-loaded when the
// expected path itself changes (a different camera, location, or
// project).
PImage faceEdgesOverlay_cachedImage = null;
String faceEdgesOverlay_cachedPath = null;

// Returns the face-edges PNG for the current camera/location, or null if
// none has been baked yet (preBakeViewport() hasn't run, or ran before
// this feature existed) - mirrors exactly how calculate_Impact_
// CurrentPreBaked() locates its own Model2Ds mask (SolarImpacts.pde), and
// how preBakeViewport() itself names the file it saves.
PImage faceEdgesOverlay_load () {
  String path = Folder_Shadings + "/" + NearLatitude_Stamp() + "/" + SceneName + "FaceEdges_Camera" + nf(cameraIndex, 2) + ".png";

  if (!path.equals(faceEdgesOverlay_cachedPath)) {
    faceEdgesOverlay_cachedPath = path;
    faceEdgesOverlay_cachedImage = new File(path).exists() ? loadImage(path) : null;
  }

  return faceEdgesOverlay_cachedImage;
}
