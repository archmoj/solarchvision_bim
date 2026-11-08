// Model2DKind describes one "family" of Model2D billboard - currently
// PEOPLE and TREES: which folder its textures live in, and the handful
// of rendering/physics behaviors that differ between families (see the
// abstract methods below). This replaces the old Model2Ds.peopleFileCount
// / treesFileCount / isTree(int n) boundary-inference scheme.
//
// Each kind owns and indexes its OWN Images/ImagePath/ImageRatios arrays
// (1-indexed, [0] left null - same convention load_images() always used),
// so a PEOPLE-local index and a TREES-local index are never the same
// number space, and neither one shifts when the OTHER folder's file
// count changes - that was the actual bug: a single flat array built by
// concatenating both folders meant adding or removing a PEOPLE file
// silently renumbered every already-placed TREE (and vice versa),
// including the numbers already written into a saved project's XML.
//
// What a placed Model2Ds instance now stores (see Model2Ds.Kind/
// FileIndex/Mirror) is a reference to one of these kind singletons plus
// a *local* index into that kind's own array - a number that only ever
// means "this kind's own Nth file", independent of what the other
// folder currently contains.
abstract class Model2DKind {

  final static String CLASS_STAMP = "model2DKind";

  final String tag; // "PEOPLE" / "TREES" - matches Model2Ds.create()'s own `t` parameter and the scripting commands (Person/Tree2/Tree1)

  Model2DKind (String tag) {
    this.tag = tag;
  }

  // Supplied per family below. Returns the live global each time
  // (Folder_People/Folder_Trees, set by updateFolders.pde) rather than
  // capturing it once at construction time - PEOPLE_KIND/TREES_KIND
  // below are themselves top-level field initializers, which Processing
  // runs before setup() has populated the real folder paths, same
  // reasoning as StationPicker's own getCoords() comment in
  // mouseClicked.pde.
  abstract String folder ();

  // Whether this family is scalable via the Scale tool - people are not
  // (see scale3D.pde's own "does not scale people!" comment, now
  // expressed as allModel2Ds.isScalable(f) instead of a raw isTree()
  // check).
  abstract boolean isScalable ();

  // Whether addToFaceGrid() gives this family the extra vertical
  // shading quads (Model2Ds.verticalShadingSections) and the flat
  // "canopy cap" quads used for an overhead sun (trees), or exactly one
  // camera-facing quad and no cap (people) - see that method's own
  // comment for the full reasoning.
  boolean isTree () {
    return this.tag.equals("TREES");
  }

  boolean hasCanopyCap () {
    return this.isTree();
  }

  String[] Filenames = new String[0];
  String[] ImagePath; // 1-indexed, [0] left null
  PImage[] Images;
  float[] ImageRatios;
  int fileCount = 0;

  void loadImages () {

    this.Filenames = sort(OPESYS.getFiles(this.folder()));
    this.fileCount = this.Filenames.length;

    this.ImagePath = new String [this.fileCount + 1];
    this.Images = new PImage [this.fileCount + 1];
    this.ImageRatios = new float [this.fileCount + 1];

    for (int i = 1; i <= this.fileCount; i++) {

      this.ImagePath[i] = this.folder() + "/" + this.Filenames[i - 1];
      this.Images[i] = loadImage(this.ImagePath[i]);

      if (this.Images[i].height != 0) {
        this.ImageRatios[i] = float(this.Images[i].width) / float(this.Images[i].height);
      } else {
        this.ImageRatios[i] = 1;
      }
    }
  }

  // Resolves a filename read back from a project file to this family's
  // own local index. Returns 0 ("not found") rather than throwing when
  // a file has since been renamed or deleted, so from_XML() can fall
  // back gracefully to a default instead of crashing on a stale save -
  // see its own comment on why that's the only failure mode left once
  // identity no longer depends on folder file counts.
  int indexOfFile (String filename) {
    for (int i = 1; i <= this.fileCount; i++) {
      if (this.Filenames[i - 1].equals(filename)) return i;
    }
    return 0;
  }

  String filenameOf (int localIndex) {
    if ((localIndex < 1) || (localIndex > this.fileCount)) return "";
    return this.Filenames[localIndex - 1];
  }

  // Safe accessor for ImageRatios[n] (that file's width / height) -
  // returns 1 (square) instead of throwing when ImageRatios hasn't been
  // populated yet (loadImages() not called - e.g. a unit test building a
  // kind by hand) or n is outside its current bounds. Every caller that
  // used to read ImageRatios[n] directly now goes through this instead,
  // so "ratio unknown" and "square image" are treated the same way
  // everywhere - exactly the assumption this replaces was hard-coding
  // for trees before Model2Ds learned to use the real ratio for them too.
  float imageRatio (int n) {
    if ((this.ImageRatios == null) || (n < 0) || (n >= this.ImageRatios.length)) return 1;
    return this.ImageRatios[n];
  }
}

Model2DKind PEOPLE_KIND = new Model2DKind ("PEOPLE") {
  String folder () {
    return Folder_People;
  }
  boolean isScalable () {
    return false;
  }
};

Model2DKind TREES_KIND = new Model2DKind ("TREES") {
  String folder () {
    return Folder_Trees;
  }
  boolean isScalable () {
    return true;
  }
};

Model2DKind[] ALL_MODEL2D_KINDS = { PEOPLE_KIND, TREES_KIND };

// Defensive fallback to PEOPLE_KIND on an unrecognized tag rather than
// throwing - e.g. a future project file written by a newer build with a
// kind this build doesn't know about yet.
Model2DKind model2DKindByTag (String tag) {
  for (Model2DKind k : ALL_MODEL2D_KINDS) {
    if (k.tag.equals(tag)) return k;
  }
  return PEOPLE_KIND;
}
