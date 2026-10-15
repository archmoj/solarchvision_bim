class Materials {

  int Number = 18; //256;
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
      { 63,  63,  63,  63}, // 8
      {127, 127, 127, 127}, // 9  translucent gray ("glass"; see import_objects_IFC.pde's IFC_MATERIAL_GLASS)
      {191, 191, 191, 191}, // 10
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
      {255,  92,  64,  51}  // 17 Earth / Soil (Excavation, Backfill)
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
