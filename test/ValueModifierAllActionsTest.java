import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// ValueModifierTest.java demonstrated the pattern on 3 representative
// vm.* methods (impactDisplayDay/cameraClipNear/currentCameraIndex).
// This file completes it generically for ALL 233 - every single
// ValueModifier method, not a sample - rather than hand-writing 230 more
// near-identical tests.
//
// Every one of the 233 command name strings below was extracted
// directly from valueModifier.pde's own source (each method's own
// "String command = \"...\";" line, paired with its enclosing method by
// position in the file via a script, not retyped by hand or guessed
// from a naming convention - a few genuinely don't follow simple
// "Title Case Each Word" ("WindRoses displayImage", "SolarImpacts
// sectionType", ...), confirming this really is the literal registered
// string, not a derived approximation). The trailing "// methodName"
// comment on each line names the vm.* method it came from, for anyone
// cross-referencing back to valueModifier.pde.
//
// app.build_allActions() (ValueModifierTest.java's own per-method
// vm.xxx(0) calls, done here all at once) ends by calling UI_rollout.
// registerSpinnerActions(), which itself calls every single one of
// these 233 methods with created == 0 - registering all 233 actions in
// one call. Each is then triggered here with NO argument - safe (see
// ValueModifierTest.java's own impactDisplayDay_withNoValue_... test),
// and - this is the real point - putValueAction()'s own "if (args.
// length < 2)" branch still calls minGetter.get()/maxGetter.get() to
// build its error message, so this exercises each of the 233 methods'
// own min/max getter closures for real, not just the shared dispatch
// machinery around them.
//
// _runScriptLine()'s own allActions branch (runScript.pde) calls
// callAction(lineSTR) without ever using its return value, so the hint
// this test actually gets back is always "" for a found-and-dispatched
// action - whether putValueAction()'s own rejection fired internally or
// not (it only PRINTS, via printError(), never returns anything
// _runScriptLine() propagates). An earlier version of this file
// wrongly expected a non-blank hint here and failed on all 233 as a
// result; see the loop's own comment below for what's actually checked
// instead. The getter/setter lambda bodies specifically (as opposed to
// the min/max ones) only run on an actual, successful set - not
// attempted here for all 233, since each one's own valid range isn't
// safely derivable from the no-arg error message alone (it's rounded
// to whole numbers for display - nf(min_v, 0, 0) - which isn't precise
// enough to reconstruct a fractional bound like cameraClipNear's own
// real 0.01 minimum) - ValueModifierTest.java's own 3 curated tests
// remain this suite's only coverage of that successful-set path, each
// with its own independently hand-verified bounds.
class ValueModifierAllActionsTest {

  private solarchvision_bim app;

  private static final String[] COMMAND_NAMES = {
      "End Day", // endDay
      "Day Increment", // dayIncrement
      "Days Merged Count", // daysMergedCount
      "Date", // date
      "Begin Day", // beginDay
      "Day", // day
      "Month", // month
      "Year", // year
      "Start Hour", // startHour
      "End Hour", // endHour
      "Sample Year Start", // sampleYearStart
      "Sample Year End", // sampleYearEnd
      "Sample Member Start", // sampleMemberStart
      "Sample Member End", // sampleMemberEnd
      "Sample Station Start", // sampleStationStart
      "Sample Station End", // sampleStationEnd
      "Ensemble Observation Max Days", // ensembleObservationMaxDays
      "Sky Scenario Setting", // skyScenarioSetting
      "Temporal Filter Setting", // temporalFilterSetting
      "Location Latitude", // locationLatitude
      "Location Longitude", // locationLongitude
      "Climate Typical Year Display All", // climateTypicalYearDisplayAll
      "Climate Typical Year Display Near", // climateTypicalYearDisplayNear
      "Climate Engineering Display All", // climateEngineeringDisplayAll
      "Climate Engineering Display Near", // climateEngineeringDisplayNear
      "Climate Archive Display All", // climateArchiveDisplayAll
      "Climate Archive Display Near", // climateArchiveDisplayNear
      "Ensemble Observation Display All", // ensembleObservationDisplayAll
      "Ensemble Observation Display Near", // ensembleObservationDisplayNear
      "Ensemble Forecast Display All", // ensembleForecastDisplayAll
      "Ensemble Forecast Display Near", // ensembleForecastDisplayNear
      "Add To Last Group", // addToLastGroup
      "Creator Material", // creatorMaterial
      "Creator Tessellation", // creatorTessellation
      "Creator Layer", // creatorLayer
      "Creator Visibility", // creatorVisibility
      "Creator Weight", // creatorWeight
      "Creator Closed", // creatorClosed
      "Creator Orientation", // creatorOrientation
      "Creator Length", // creatorLength
      "Creator Width", // creatorWidth
      "Creator Height", // creatorHeight
      "Creator Volume", // creatorVolume
      "Creator Snap Mode Index", // creatorSnapModeIndex
      "Creator Sphere Degree", // creatorSphereDegree
      "Creator Cylinder Degree", // creatorCylinderDegree
      "Creator Cone Degree", // creatorConeDegree
      "Creator Polygon Degree", // creatorPolygonDegree
      "Creator Parametric Type Index", // creatorParametricTypeIndex
      "Creator Person Type Index", // creatorPersonTypeIndex
      "Creator Plant Type Index", // creatorPlantTypeIndex
      "Modifier Opening Depth", // modifierOpeningDepth
      "Modifier Opening Area", // modifierOpeningArea
      "Modifier Opening Deviation", // modifierOpeningDeviation
      "Modifier Tessellate Rows", // modifierTessellateRows
      "Modifier Tessellate Columns", // modifierTessellateColumns
      "Modifier Offset Amount", // modifierOffsetAmount
      "Modifier Weld Threshold", // modifierWeldThreshold
      "Soft Selection Falloff Power", // softSelectionFalloffPower
      "Soft Selection Falloff Radius", // softSelectionFalloffRadius
      "Position Vector Index", // positionVectorIndex
      "Rotation Vector Index", // rotationVectorIndex
      "Scale Vector Index", // scaleVectorIndex
      "Position Selection", // positionSelection
      "Rotation Selection", // rotationSelection
      "Scale Selection", // scaleSelection
      "Pivot Alignment X", // pivotAlignmentX
      "Pivot Alignment Y", // pivotAlignmentY
      "Pivot Alignment Z", // pivotAlignmentZ
      "Creator Uniform Superellipsoid Power", // creatorUniformSuperellipsoidPower
      "Creator Superellipsoid Power X", // creatorSuperellipsoidPowerX
      "Creator Superellipsoid Power Y", // creatorSuperellipsoidPowerY
      "Creator Superellipsoid Power Z", // creatorSuperellipsoidPowerZ
      "Creator Model1D Type Index", // creatorModel1DTypeIndex
      "Creator Model1D Degree Max", // creatorModel1DDegreeMax
      "Creator Model1D Seed", // creatorModel1DSeed
      "Creator Model1D Trunk Size", // creatorModel1DTrunkSize
      "Creator Model1D Leaf Size", // creatorModel1DLeafSize
      "Creator Model1D Branch Tilt", // creatorModel1DBranchTilt
      "Creator Model1D Branch Twist", // creatorModel1DBranchTwist
      "Creator Model1D Branch Ratio", // creatorModel1DBranchRatio
      "Creator Model1D Tree Base", // creatorModel1DTreeBase
      "Terrain Load Textures", // TerrainLoadTextures
      "Terrain Load Mesh", // TerrainLoadMesh
      "Terrain Skip Start", // TerrainSkipStart
      "Terrain Skip End", // TerrainSkipEnd
      "Terrain Display Surface", // TerrainDisplaySurface
      "Terrain Display Texture", // TerrainDisplayTexture
      "Terrain Display Points", // TerrainDisplayPoints
      "Display Depth", // TerrainDisplayDepth
      "Model2Ds Display All", // Model2DsDisplayAll
      "Model1Ds Display All", // Model1DsDisplayAll
      "Model1Ds Display Leaves", // Model1DsDisplayLeaves
      "Polylines Display All", // PolylinesDisplayAll
      "Faces Display All", // FacesDisplayAll
      "Solids Display All", // SolidsDisplayAll
      "Sections Display All", // SectionsDisplayAll
      "WindRoses displayImage", // WindRoseDisplayImage
      "Wind Roses Plane Size", // WindRosePlaneSize
      "Sky3D Display Surface", // Sky3DDisplaySurface
      "Sun3D Display Path", // Sun3DDisplayPath
      "Sun3D Display Pattern", // Sun3DDisplayPattern
      "Current Camera Index", // currentCameraIndex
      "Camera Clip Near", // cameraClipNear
      "Camera Clip Far", // cameraClipFar
      "Create3D Display Vertices", // Create3DDisplayVertices
      "Create3D Display Edges", // Create3DDisplayEdges
      "Create3D Display Normals", // Create3DDisplayNormals
      "Cameras Display All", // CamerasDisplayAll
      "Impact Display Day", // impactDisplayDay
      "SolarImpacts displayImage", // SolarImpactsDisplayImage
      "SolidImpacts displayImage", // SolidImpactsDisplayImage
      "SolarImpacts sectionType", // SolarImpacts_sectionType
      "SolidImpacts sectionType", // SolidImpacts_sectionType
      "Solid Impacts Grade", // SolidImpacts_grade
      "Solid Impacts Power", // SolidImpacts_power
      "Solid Impacts R", // SolidImpacts_r
      "Solid Impacts Z", // SolidImpacts_z
      "Solid Impacts Position Step", // SolidImpacts_positionStep
      "Solid Impacts U", // SolidImpacts_u
      "Solid Impacts V", // SolidImpacts_v
      "Solid Impacts X", // SolidImpacts_x
      "Solid Impacts Y", // SolidImpacts_y
      "Solid Impacts Wind Speed", // SolidImpacts_windSpeed
      "Solid Impacts Wind Direction", // SolidImpacts_windDirection
      "Solid Impacts Process Sub Divisions", // SolidImpacts_processSubDivisions
      "SolidImpacts displayPoints", // SolidImpactsDisplayPoints
      "Solid Impacts Display Lines", // SolidImpactsDisplayLines
      "WindFlows Display All", // WindFlowsDisplayAll
      "Create3D Display Tessellation", // Create3DDisplayTessellation
      "Terrain displayTessellation", // TerrainDisplayTessellation
      "Sky3D displayTessellation", // Sky3DDisplayTessellation
      "Sky3D Radius", // Sky3DRadius
      "Tropo3D Display Surface", // Tropo3DDisplaySurface
      "Tropo3D Display Texture", // Tropo3DDisplayTexture
      "Earth3D Display Surface", // Earth3DDisplaySurface
      "Earth3D Display Texture", // Earth3DDisplayTexture
      "Earth3D Level Of Detail", // Earth3DLevelOfDetail
      "Moon3D Display Surface", // Moon3DDisplaySurface
      "Moon3D Display Texture", // Moon3DDisplayTexture
      "Moon3D Fit In Sky Dome", // Moon3DFitInSkyDome
      "Sun3D Display Surface", // Sun3DDisplaySurface
      "Sun3D Display Texture", // Sun3DDisplayTexture
      "Sun3D Fit In Sky Dome", // Sun3DFitInSkyDome
      "Celestial Magnification", // celestialMagnification
      "Overall Scale", // overallScale
      "Plot Layout Index", // plotLayoutIndex
      "Vertical Unit Scale", // verticalUnitScale
      "Show Raw Lines", // showRawLines
      "Show Statistical Ranges", // showStatisticalRanges
      "Show Statistics", // showStatistics
      "Show Probabilities", // showProbabilities
      "Probability Width Interval", // probabilityWidthInterval
      "Probability Height Interval", // probabilityHeightInterval
      "Study Active ColorScale Index", // Study_activeColorScaleIndex
      "Study Active ColorScale Direction", // Study_activeColorScaleDirection
      "Study Active ColorScale Factor", // Study_activeColorScaleFactor
      "Study Passive ColorScale Index", // Study_passiveColorScaleIndex
      "Study Passive ColorScale Direction", // Study_passiveColorScaleDirection
      "Study Passive ColorScale Factor", // Study_passiveColorScaleFactor
      "Statistical Ranges ColorScale Index", // statisticalRangesColorScaleIndex
      "Statistical Ranges ColorScale Direction", // statisticalRangesColorScaleDirection
      "Statistical Ranges ColorScale Factor", // statisticalRangesColorScaleFactor
      "Probabilities ColorScale Index", // probabilitiesColorScaleIndex
      "Probabilities ColorScale Direction", // probabilitiesColorScaleDirection
      "Probabilities ColorScale Factor", // probabilitiesColorScaleFactor
      "Opacity Percentage", // opacityPercentage
      "Faces Active ColorScale Index", // Faces_activeColorScaleIndex
      "Faces Active ColorScale Direction", // Faces_activeColorScaleDirection
      "Faces Active ColorScale Factor", // Faces_activeColorScaleFactor
      "Faces Passive ColorScale Index", // Faces_passiveColorScaleIndex
      "Faces Passive ColorScale Direction", // Faces_passiveColorScaleDirection
      "Faces Passive ColorScale Factor", // Faces_passiveColorScaleFactor
      "Sky3D Active ColorScale Index", // Sky3D_activeColorScaleIndex
      "Sky3D Active ColorScale Direction", // Sky3D_activeColorScaleDirection
      "Sky3D Active ColorScale Factor", // Sky3D_activeColorScaleFactor
      "Sky3D Passive ColorScale Index", // Sky3D_passiveColorScaleIndex
      "Sky3D Passive ColorScale Direction", // Sky3D_passiveColorScaleDirection
      "Sky3D Passive ColorScale Factor", // Sky3D_passiveColorScaleFactor
      "Sun3D Active ColorScale Index", // Sun3D_activeColorScaleIndex
      "Sun3D Active ColorScale Direction", // Sun3D_activeColorScaleDirection
      "Sun3D Active ColorScale Factor", // Sun3D_activeColorScaleFactor
      "Sun3D Passive ColorScale Index", // Sun3D_passiveColorScaleIndex
      "Sun3D Passive ColorScale Direction", // Sun3D_passiveColorScaleDirection
      "Sun3D Passive ColorScale Factor", // Sun3D_passiveColorScaleFactor
      "Solids ColorScale Index", // SolidsColorScaleIndex
      "Solids ColorScale Direction", // SolidsColorScaleDirection
      "Solids ColorScale Factor", // SolidsColorScaleFactor
      "Terrain ColorScale Index", // TerrainColorScaleIndex
      "Terrain ColorScale Direction", // TerrainColorScaleDirection
      "Terrain ColorScale Factor", // TerrainColorScaleFactor
      "WindFlows ColorScale Index", // WindFlowsColorScaleIndex
      "WindFlows ColorScale Direction", // WindFlowsColorScaleDirection
      "WindFlows ColorScale Factor", // WindFlowsColorScaleFactor
      "Group Display Pivot", // groupDisplayPivot
      "Pivot Display Reference", // pivotDisplayReference
      "Group Display Box", // groupDisplayBox
      "Group Display Edges", // groupDisplayEdges
      "Face Display Edges", // faceDisplayEdges
      "Face Display Vertex Selection", // faceDisplayVertexSelection
      "Polyline Display Vertex Selection", // polylineDisplayVertexSelection
      "Vertex Display Markers", // vertexDisplayMarkers
      "Polyline Display Vertices", // polylineDisplayVertices
      "Model2DDisplay Bounds", // model2DDisplayBounds
      "Model1DDisplay Bounds", // model1DDisplayBounds
      "Solid Display Edges", // solidDisplayEdges
      "Section Display Edges", // sectionDisplayEdges
      "Camera Display Frustum", // cameraDisplayFrustum
      "Terrain Display Vertices", // terrainDisplayVertices
      "Interpolation Weight", // interpolationWeight
      "Climate Based Solar Forecast", // climateBasedSolarForecast
      "Climate Based Weather Forecast", // climateBasedWeatherForecast
      "Develop Layer Option", // developLayerOption
      "Develop Layer Interval", // developLayerInterval
      "Develop Layer Angle Inclination", // developLayerAngleInclination
      "Develop Layer Angle Orientation", // developLayerAngleOrientation
      "Current Data Source", // currentDataSource
      "Impact Layer Index", // impactLayerIndex
      "Raw Lines Exporter", // rawLinesExporter
      "Normal Lines Exporter", // normalLinesExporter
      "Probabilities Exporter", // probabilitiesExporter
      "Exporter Scale", // exporterScale
      "Exporter Yaxis Up", // exporterYaxisUp
      "Exporter Precision Vertex", // exporterPrecisionVertex
      "Exporter Precision Vertex Texture", // exporterPrecisionVertexTexture
      "Exporter Maintain Polygons", // exporterMaintainPolygons
      "Exporter Material Library", // exporterMaterialLibrary
      "Exporter Double Sided", // exporterDoubleSided
      "Exporter ColorScale Resolution", // exporterColorScaleResolution
      "Record SolidImpact in JPG", // Record_SolidImpact_in_JPG
      "Record Solid Impact In PDF", // Record_SolidImpact_in_PDF
      "Record Solar Analysis in JPG", // Record_Solar_Analysis_in_JPG
      "Wind Roses Image Resolution", // WindRoseImageResolution
  };

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    app.build_allActions(); // registers all 233 ValueModifier actions via UI_rollout.registerSpinnerActions()
  }

  @Test
  void everyValueModifierAction_isRegistered_andDispatchesWithoutThrowing () {
    StringBuilder failures = new StringBuilder();

    for (String name : COMMAND_NAMES) {
      try {
        String hint = app.runScriptLine(name);

        // _runScriptLine()'s own allActions branch (runScript.pde) calls
        // callAction(lineSTR) without ever using its return value - hint
        // stays at its initial "" for every successfully-dispatched
        // action, whether putValueAction()'s own "missing argument"
        // rejection fired internally (only printed, via printError(),
        // never returned) or not. So "" here is the CORRECT result for
        // a found-and-dispatched action, not a failure - only
        // UnrecognizedCommand (the one case _runScriptLine() DOES
        // return explicitly, from the switch-case's own default branch)
        // means this name wasn't actually registered at all.
        if (hint.equals(app.UnrecognizedCommand)) {
          failures.append("[" + name + "]: not recognized as a registered action at all\n");
        }
      } catch (Exception ex) {
        failures.append("[" + name + "]: threw " + ex + "\n");
      }
    }

    assertEquals("", failures.toString(), "one or more ValueModifier actions failed:\n" + failures);
  }

  @Test
  void everyCommandNameInThisListIsUnique () {
    // Guards the list itself - a duplicate here would silently halve
    // this test's real coverage without ever failing the loop above.
    java.util.Set<String> seen = new java.util.HashSet<>();
    for (String name : COMMAND_NAMES) {
      assertTrue(seen.add(name), "duplicate command name in this file's own list: " + name);
    }
    assertEquals(233, COMMAND_NAMES.length);
  }
}
