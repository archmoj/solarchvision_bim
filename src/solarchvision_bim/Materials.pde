class Materials {

  int Number = 20; //256;
  int Selection = 1;

  int[][] Color = new int [this.Number][4]; // ARGB

  {
    int[][] fixed = {
      {255, 255, 127,   0}, // 0
      {255, 255,   0,   0}, // 1
      {255, 255, 255,   0}, // 2
      {255,   0, 255,   0}, // 3
      {255,   0, 255, 255}, // 4
      {255,   0,   0, 255}, // 5
      {255, 255,   0, 255}, // 6
      {255, 255, 255, 255}, // 7
      // 8: a faint, mostly-transparent grey for an interior IfcSpace's
      // own volume (a room/zone boundary, not real building fabric) -
      // alpha 63, a bare outline rather than something meant to read as
      // a solid surface. See import_objects_IFC.pde's
      // IFC_MATERIAL_INDOOR_SPACE.
      { 63,  63,  63,  63}, // 8 Indoor space (IfcSpace room/zone volume, PredefinedType INTERNAL or unset)
      {127, 127, 127, 127}, // 9  translucent gray ("glass"; see import_objects_IFC.pde's IFC_MATERIAL_GLASS)
      // 10: the same idea as material 8's own grey, but less transparent
      // (alpha 191, not 63) for an exterior IfcSpace's own volume - a
      // courtyard, terrace or other outdoor amenity area still worth
      // seeing the footprint of, unlike an indoor room's own volume,
      // which this app otherwise has no reason to render as anything
      // but a faint outline. See import_objects_IFC.pde's
      // IFC_MATERIAL_OUTDOOR_SPACE.
      {191, 191, 191, 191}, // 10 Outdoor space (IfcSpace room/zone volume, PredefinedType EXTERNAL)
      // 11-17: representative colors for common real-world building
      // materials, for the IFC importer to pick by IfcMaterial name (see
      // import_objects_IFC.pde's IFC_MATERIAL_* constants and
      // ifcMaterialNameToConstant()) rather than cycling through 1-8.
      // RGB values and opacity from the "Standard IFC Materials Mapping
      // Table for 3D Visualization" reference table; alpha is 255 for
      // every "100% (Opaque)" row, scaled the same way material 9 above
      // represents its own "50%" for the one "Semi-Trans" row.
      {255, 138, 141, 143}, // 11 Concrete (Structural Concrete, Precast)
      {255,  67,  75,  84}, // 12 Steel / Metal (Structural Steel, Rebar)
      {255, 160,  82,  45}, // 13 Timber / Wood (Framing, Plywood, Finish)
      {255, 178,  34,  34}, // 14 Masonry (Brick, CMU Block)
      {127, 255, 245, 157}, // 15 Insulation (Thermal Barrier, Batting) - 50% semi-transparent
      {255,   0, 188, 212}, // 16 MEP / Plastics (PVC, Conduit, Piping)
      {255,  92,  64,  51}, // 17 Earth / Soil (Excavation, Backfill)
      // 18: a natural grass green for planted surfaces - green roofs,
      // green walls, gardens/lawns - deliberately not material 3
      // (0,255,0, fully saturated "pure" green, one of the original
      // 8 cycling colors, not meant to represent anything specific)
      // which would look cartoonish next to the realistic tones above.
      // See import_objects_IFC.pde's IFC_MATERIAL_VEGETATION.
      {255,  76, 153,  56}, // 18 Vegetation (Green Roof, Green Wall, Garden/Grass)
      // 19: a translucent pool blue for standing water - alpha 127,
      // the same "50%, no cast shadow" value as material 9 (glass) and
      // 15 (insulation) above (see Faces.castShadows()'s own
      // alpha > 127 check) - a pool's water surface shouldn't cast a
      // hard shadow the way its coping/deck does.
      // See import_objects_IFC.pde's IFC_MATERIAL_WATER.
      {127,  64, 164, 223}  // 19 Water (Pool)
    };

    int fixedCount = min(fixed.length, this.Number);
    for (int mt = 0; mt < fixedCount; mt++) {
      this.Color[mt] = fixed[mt];
    }

    for (int mt = fixedCount; mt < this.Number; mt++) {
      this.Color[mt] = new int[] {255, int(random(256)), int(random(256)), int(random(256))};
    }
  }
}
