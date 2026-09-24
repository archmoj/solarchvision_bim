## Command line

Use `TAB` to enable or disable the command line, or click inside/outside
the command line area (the dark region at the bottom).

Below is a list of available commands. Both lowercase and uppercase
variants are accepted.

------------------------------------------------------------------------

-   `CLS`: Clears the command line screen
-   `NEW`: New project
-   `OPEN`: Opens a saved project
-   `SAVE.AS`: Saves the project with a new name
-   `SAVE`: Saves the project
-   `HOLD`: Holds the scene
-   `FETCH`: Fetches the scene
-   `IMPORT.OBJ`: Imports a `.obj` file
-   `EXPORT.OBJ.TIMESERIES`: Exports the scene in `.obj` format at
    different hours (multiple files)
-   `EXPORT.OBJ.DATESERIES`: Exports the scene in `.obj` format at
    different days (multiple files)
-   `EXPORT.OBJ`: Exports the scene in `.obj` format
-   `EXPORT.RAD`: Exports the scene in Radiance `.rad` format
-   `EXPORT.SCR`: Exports the scene in AutoCAD `.scr` format
-   `RUN.SCRIPT`: Executes a `.txt` script file containing multiple SOLARCHVISION
    commands
-   `REC.PNG`: Records the frame (screenshot) in `.png` format
-   `REC.JPG`: Records the frame (screenshot) in `.jpg` format
-   `REC.TIF`: Records the frame (screenshot) in `.tif` format
-   `REC.BMP`: Records the frame (screenshot) in `.bmp` format
-   `QUIT` or `EXIT`: Exits the software

------------------------------------------------------------------------

### Location

-   `SETLONLAT`: Sets the longitude and latitude of the location

```
SetLonLat ? ?
```

-   `SETLON`: Sets the longitude of the location

```
SetLon ?
```

-   `SETLAT`: Sets the latitude of the location

```
SetLat ?
```

------------------------------------------------------------------------

### Selection and editing

-   `SELECT`: Selects various categories
```
Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/landpoint
```

-   `DELETE`: Deletes the selection or various categories
```
Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras
```

-   `COPY`: Copies the selection

```
Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?
```

-   `MOVE`: Moves the selection

```
Move dx=? dy=? dz=?
```

-   `ROTATE`, `ROTATEX`, `ROTATEY`, `ROTATEZ`: Rotates the selection

```
Rotate[X|Y|Z] r=? x=? y=? z=?
```

-   `SCALE`: Scales the selection

```
Scale s=? sx=? sy=? sz=? x=? y=? z=?
```

------------------------------------------------------------------------

### Object creation

-   `PERSON`: Creates a person

```
Person m=? x=? y=? z=?
```

-   `TREE2`: Creates a 2D tree using vertical and horizontal sections

```
Tree2 m=? x=? y=? z=? h=?
```

-   `TREE1`: Creates a parametric fractal tree in 3D
```
Tree1 m=? seed=? degree=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? trunk=? leaf=?
```

-   `BOX2P`: Creates a box using two corner points

```
Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?
```

-   `BOX`: Creates a box using center point, width, length, and height

```
Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?
```

-   `HOUSE1`: Creates a house-like structure with roof folded in all
    directions

```
House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?
```

-   `HOUSE2`: Creates a house-like structure with roof folded in one
    direction

```
House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?
```

-   `HOUSE3`: Creates a house-like structure with roof folded in the
    second direction

```
House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?
```

-   `CYLINDER`: Creates a cylinder

```
Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?
```

-   `SPHERE`: Creates a sphere

```
Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?
```

-   `SUPERSPHERE`: Creates a supersphere (deforms from cube to star-like
    object)

```
SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?
```

-   `CUSHION`: Creates a cushion-like object

```
Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?
```

-   `OCTAHEDRON`: Creates an octahedron

```
Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?
```

-   `ICOSAHEDRON`: Creates an icosahedron

```
Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?
```

-   `POLYGONMESH`: Creates an equilateral polygon mesh

```
PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?
```

-   `POLYGONHYPER`: Creates a hyperbolic surface based on an equilateral
    polygon

```
PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?
```

-   `POLYGONEXTRUDE`: Creates an extrusion from an equilateral polygon

```
PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?
```

------------------------------------------------------------------------

### Mesh creation

-   `MESH2` to `MESH6`: Creates meshes using 2 to 6 points

```
Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?
```

------------------------------------------------------------------------

### Viewports

-   `ALLVIEWPORTS`: Displays all viewports
-   `ENLARGE3D`: Enlarges the 3D viewport

------------------------------------------------------------------------

### Camera control

Includes commands such as:

-   `PAN`, `PANX`, `PANY`
-   `LOOKORG`, `LOOKDIR`, `LOOKSEL`
-   `TRUCKX`, `TRUCKY`, `TRUCKZ`
-   `ORBIT`, `ORBITZ`, `ORBITXY`
-   `CAMERAROLL`, `CAMERAROLLZ`, `CAMERAROLLXY`
-   `TARGETROLL`, `TARGETROLLZ`, `TARGETROLLXY`
-   `DISTC`, `DISTZ`, `DISTXY`, `DISTP`
-   `ZOOM`, `NORMALZOOM`
-   `PERSPECTIVE`, `ORTHOGRAPHIC`

------------------------------------------------------------------------

### Views

-   `TOP`, `FRONT`, `LEFT`, `RIGHT`, `BACK`, `BOTTOM`
-   `S.W.`, `S.E.`, `N.E.`, `N.W.`

------------------------------------------------------------------------

### Shading and rendering

-   `SHADE.WIRE`: Wireframe view
-   `SHADE.BASE`: Base shading
-   `SHADE.WHITE`: White shading
-   `SHADE.MATERIALS`: Material shading
-   `SHADE.GLOBAL`: Global solar values shading
-   `SHADE.REAL`: Per-vertex solar values shading
-   `SHADE.SOLID`: Solid parameter shading
-   `SHADE.ELEVATION`: Elevation shading
-   `SHADE.VIEWPORT`: Shades the viewport
-   `PREBAKE.VIEWPORT`: Pre-bakes the viewport

### Additional commands
-   `21d-tree`,
-   `2d-tree`,
-   `3d-create.branchratio`,
-   `3d-create.branchtilt`,
-   `3d-create.branchtwist`,
-   `3d-create.closed`,
-   `3d-create.cylinderdegree`,
-   `3d-create.degreemax`,
-   `3d-create.displaytessellation`,
-   `3d-create.height_(rand_negative)`,
-   `3d-create.layer`,
-   `3d-create.leafsize`,
-   `3d-create.length_(rand_negative)`,
-   `3d-create.material`,
-   `3d-create.orientation`,
-   `3d-create.parametric_type`,
-   `3d-create.person_type`,
-   `3d-create.plant_type`,
-   `3d-create.polydegree`,
-   `3d-create.powall`,
-   `3d-create.powx`,
-   `3d-create.powy`,
-   `3d-create.powz`,
-   `3d-create.seed`,
-   `3d-create.snap`,
-   `3d-create.spheredegree`,
-   `3d-create.tessellation`,
-   `3d-create.treebase`,
-   `3d-create.trunksize`,
-   `3d-create.type`,
-   `3d-create.visibility`,
-   `3d-create.volume`,
-   `3d-create.weight`,
-   `3d-create.width_(rand_negative)`,
-   `3d-export.backsides`,
-   `3d-export.flipzyaxis`,
-   `3d-export.materiallibrary`,
-   `3d-export.paletteresolution`,
-   `3d-export.polytopoly`,
-   `3d-export.precisionvertex`,
-   `3d-export.precisionvtexture`,
-   `3d-export.scale`,
-   `3d-model 1`,
-   `3d-model 10`,
-   `3d-model 11`,
-   `3d-model 2`,
-   `3d-model 3`,
-   `3d-model 4`,
-   `3d-model 5`,
-   `3d-model 6`,
-   `3d-model 7`,
-   `3d-model 8`,
-   `3d-model 9`,
-   `3d-modify.offsetamount`,
-   `3d-modify.openningarea`,
-   `3d-modify.openningdepth`,
-   `3d-modify.openningdeviation`,
-   `3d-modify.tessellatecolumns`,
-   `3d-modify.tessellaterows`,
-   `3d-modify.weldtreshold`,
-   `3d-select.alignx`,
-   `3d-select.aligny`,
-   `3d-select.alignz`,
-   `3d-select.camera_displayedges`,
-   `3d-select.displayreferencepivot`,
-   `3d-select.face_displayedges`,
-   `3d-select.face_displayvertexcount`,
-   `3d-select.group_displaybox`,
-   `3d-select.group_displayedges`,
-   `3d-select.group_displaypivot`,
-   `3d-select.landpoint_displaypoints`,
-   `3d-select.model1d_displayedges`,
-   `3d-select.model2d_displayedges`,
-   `3d-select.polyline_displayvertexcount`,
-   `3d-select.polyline_displayvertices`,
-   `3d-select.posvalue`,
-   `3d-select.posvector`,
-   `3d-select.rotvalue`,
-   `3d-select.rotvector`,
-   `3d-select.scalevalue`,
-   `3d-select.scalevector`,
-   `3d-select.section_displayedges`,
-   `3d-select.softpower`,
-   `3d-select.softradius`,
-   `3d-select.solid_displayedges`,
-   `3d-select.vertex_displayvertices`,
-   `3dmodelsize`,
-   `active shade`,
-   `add 1d-trees on land`,
-   `add 2d-trees on land`,
-   `add people on land`,
-   `addtolastgroup`,
-   `allmodelsize`,
-   `annual cycle sun path (active)`,
-   `annual cycle sun path (passive)`,
-   `assign branchratio`,
-   `assign branchtilt`,
-   `assign branchtwist`,
-   `assign degreemax`,
-   `assign layer`,
-   `assign leafsize`,
-   `assign model1dsprops`,
-   `assign pivot`,
-   `assign seed/material`,
-   `assign tessellation`,
-   `assign treebase`,
-   `assign trunksize`,
-   `assign visibility`,
-   `assign weight`,
-   `attach to last group`,
-   `auto-normal selected faces`,
-   `back`,
-   `begin new group at origin`,
-   `begin new group at pivot`,
-   `begin_day`,
-   `begin_month`,
-   `begin_year`,
-   `bottom`,
-   `box`,
-   `camera`,
-   `camera >> viewport`,
-   `camera view`,
-   `camera_clipfar`,
-   `camera_clipnear`,
-   `cameradistance`,
-   `cameraroll`,
-   `camerarollxy`,
-   `camerarollz`,
-   `cameras.displayall`,
-   `change branchratio`,
-   `change branchtilt`,
-   `change branchtwist`,
-   `change degreemax`,
-   `change layer`,
-   `change leafsize`,
-   `change seed/material`,
-   `change tessellation`,
-   `change treebase`,
-   `change trunksize`,
-   `change visibility`,
-   `change weight`,
-   `climate-based_solar_forecast`,
-   `climate-based_temperature_forecast`,
-   `clone selection (identical)`,
-   `clone selection (variation)`,
-   `create3d.displayedges`,
-   `create3d.displaynormals`,
-   `create3d.displayvertices`,
-   `currentcamera`,
-   `cushion`,
-   `cylinder`,
-   `day_step`,
-   `days_past_march_equinox`,
-   `delete all`,
-   `delete all cameras`,
-   `delete all faces`,
-   `delete all groups`,
-   `delete all model1ds`,
-   `delete all model2ds`,
-   `delete all polylines`,
-   `delete all sections`,
-   `delete all solids`,
-   `delete scene empty groups`,
-   `delete scene isolated vertices`,
-   `delete selection`,
-   `delete selection isolated vertices`,
-   `deselect all`,
-   `dettach from groups selection`,
-   `develop_dayhour`,
-   `develop_option`,
-   `diagram_setup`,
-   `display all viewports`,
-   `displayall_clmrec`,
-   `displayall_cweeds`,
-   `displayall_naefs`,
-   `displayall_swob`,
-   `displayall_tmyepw`,
-   `displaynear_clmrec`,
-   `displaynear_cweeds`,
-   `displaynear_naefs`,
-   `displaynear_swob`,
-   `displaynear_tmyepw`,
-   `distmousexy`,
-   `distz`,
-   `download clmrec`,
-   `download land mesh`,
-   `download land texture`,
-   `download naefs`,
-   `download swob`,
-   `download tmyepw`,
-   `draw_data`,
-   `draw_probabilities`,
-   `draw_sorted`,
-   `draw_statistics`,
-   `drop on landsurface`,
-   `drop on modelsurface (down)`,
-   `drop on modelsurface (up)`,
-   `earth3d.displaysurface`,
-   `earth3d.displaytexture`,
-   `earth3d.levelofdetail`,
-   `end_hour`,
-   `end_member`,
-   `end_station`,
-   `end_year`,
-   `enlarge 3d viewport`,
-   `enlarge map viewport`,
-   `enlarge time viewport`,
-   `export 3d-model > html`,
-   `export 3d-model > obj`,
-   `export 3d-model > obj (date-series)`,
-   `export 3d-model > obj (time-series)`,
-   `export 3d-model > rad`,
-   `export 3d-model > scr`,
-   `export_ascii_data`,
-   `export_ascii_probabilities`,
-   `export_ascii_statistics`,
-   `extrude`,
-   `extrude face edges`,
-   `faces >> groups`,
-   `faces >> vertices`,
-   `faces.active_palette_clr`,
-   `faces.active_palette_dir`,
-   `faces.active_palette_mlt`,
-   `faces.displayall`,
-   `faces.passive_palette_clr`,
-   `faces.passive_palette_dir`,
-   `faces.passive_palette_mlt`,
-   `fetch`,
-   `flatten selected landpoints`,
-   `flip normal`,
-   `force triangulate selected faces`,
-   `forecast/obs_maxdays`,
-   `front`,
-   `get dx`,
-   `get dxy`,
-   `get dxyz`,
-   `get dy`,
-   `get dz`,
-   `get firstvertex`,
-   `group selection`,
-   `groups >> faces`,
-   `groups >> model1ds`,
-   `groups >> model2ds`,
-   `groups >> polylines`,
-   `groups >> solids`,
-   `groups >> vertices`,
-   `hide all faces`,
-   `hide cameras`,
-   `hide clmrec nearest`,
-   `hide clmrec stations`,
-   `hide cweeds nearest`,
-   `hide cweeds stations`,
-   `hide earth surface`,
-   `hide edges`,
-   `hide faces`,
-   `hide land depth`,
-   `hide land mesh`,
-   `hide land points`,
-   `hide land texture`,
-   `hide leaves`,
-   `hide model1ds`,
-   `hide model2ds`,
-   `hide moon surface`,
-   `hide naefs nearest`,
-   `hide naefs stations`,
-   `hide normals`,
-   `hide polylines`,
-   `hide sections`,
-   `hide selected 1d edges`,
-   `hide selected 2d edges`,
-   `hide selected cameras`,
-   `hide selected faces`,
-   `hide selected faces vertex count`,
-   `hide selected group box`,
-   `hide selected group edges`,
-   `hide selected group pivot`,
-   `hide selected landpoints`,
-   `hide selected polylines`,
-   `hide selected polylines vertex count`,
-   `hide selected ref pivot`,
-   `hide selected sections`,
-   `hide selected solids`,
-   `hide selected vertices`,
-   `hide sky`,
-   `hide solar section`,
-   `hide solid section`,
-   `hide solids`,
-   `hide sun grid`,
-   `hide sun path`,
-   `hide sun pattern`,
-   `hide sun surface`,
-   `hide swob nearest`,
-   `hide swob stations`,
-   `hide tmyepw nearest`,
-   `hide tmyepw stations`,
-   `hide troposphere`,
-   `hide vertices`,
-   `hide wind flow`,
-   `hold`,
-   `hourly sun position (active)`,
-   `hourly sun position (passive)`,
-   `hourly/daily_filter`,
-   `house1`,
-   `house2`,
-   `house3`,
-   `hyper`,
-   `icosahedron`,
-   `impact_min/50%/max`,
-   `impact_source`,
-   `impacts_displayday`,
-   `import 3d-model...`,
-   `import command file...`,
-   `inclination_angle`,
-   `insert corner opennings`,
-   `insert edge opennings`,
-   `insert parallel opennings`,
-   `insert rotated opennings`,
-   `interpolation_weight`,
-   `invert selection`,
-   `isolate selection`,
-   `join_days`,
-   `jpg 3d full-period`,
-   `jpg 3d graph`,
-   `jpg location graph`,
-   `jpg time graph`,
-   `land.displaytessellation`,
-   `land3d.displaydepth`,
-   `land3d.displaypoints`,
-   `land3d.displaysurface`,
-   `land3d.displaytexture`,
-   `land3d.loadmesh`,
-   `land3d.loadtextures`,
-   `land3d.palette_clr`,
-   `land3d.palette_dir`,
-   `land3d.palette_mlt`,
-   `land3d.skipend`,
-   `land3d.skipstart`,
-   `landgap >> group`,
-   `landmesh >> group`,
-   `landorbit`,
-   `latitude`,
-   `layout -1`,
-   `layout -2`,
-   `layout 0`,
-   `layout 1`,
-   `layout 2`,
-   `layout 3`,
-   `layout 4`,
-   `layout 5`,
-   `layout 6`,
-   `layout 7`,
-   `layout 8`,
-   `left`,
-   `load land mesh`,
-   `load land texture`,
-   `load toroposphere`,
-   `longitude`,
-   `look at direction`,
-   `look at origin`,
-   `look at selection`,
-   `model1ds >> groups`,
-   `model1ds.displayall`,
-   `model1ds.displayleaves`,
-   `model1dsprops`,
-   `model2ds >> groups`,
-   `model2ds.displayall`,
-   `mojtaba samimi`,
-   `moon3d.displaysurface`,
-   `moon3d.displaytexture`,
-   `moon3d.fitinskydome`,
-   `move`,
-   `movex`,
-   `movey`,
-   `movez`,
-   `n.e.`,
-   `n.w.`,
-   `new`,
-   `number_of_days_to_plot`,
-   `objects_scale`,
-   `octahedron`,
-   `offset(above) vertices`,
-   `offset(below) vertices`,
-   `offset(expand) vertices`,
-   `offset(shrink) vertices`,
-   `open...`,
-   `optimize faces`,
-   `orbit`,
-   `orbitxy`,
-   `orbitz`,
-   `orientation potential (active)`,
-   `orientation potential (passive)`,
-   `orientation_angle`,
-   `orthographic`,
-   `pan`,
-   `panx`,
-   `pany`,
-   `parametric 1`,
-   `parametric 2`,
-   `parametric 3`,
-   `parametric 4`,
-   `parametric 5`,
-   `parametric 6`,
-   `passive shade`,
-   `pdf location graph`,
-   `pdf time graph`,
-   `person`,
-   `perspective`,
-   `pick branchratio`,
-   `pick branchtilt`,
-   `pick branchtwist`,
-   `pick degreemax`,
-   `pick layer`,
-   `pick leafsize`,
-   `pick model1dsprops`,
-   `pick pivot`,
-   `pick seed/material`,
-   `pick select`,
-   `pick select-`,
-   `pick select+`,
-   `pick tessellation`,
-   `pick treebase`,
-   `pick trunksize`,
-   `pick visibility`,
-   `pick weight`,
-   `pivot`,
-   `pivotx:center`,
-   `pivotx:maximum`,
-   `pivotx:minimum`,
-   `pivoty:center`,
-   `pivoty:maximum`,
-   `pivoty:minimum`,
-   `pivotz:center`,
-   `pivotz:maximum`,
-   `pivotz:minimum`,
-   `plane`,
-   `planetary_magnification`,
-   `point`,
-   `polygon`,
-   `polyline`,
-   `polylines >> groups`,
-   `polylines >> vertices`,
-   `polylines.displayall`,
-   `power`,
-   `powerx`,
-   `powery`,
-   `powerz`,
-   `prebake selected sections`,
-   `prebake viewport`,
-   `probabilities_interval`,
-   `probabilities_range`,
-   `process active impact`,
-   `process passive impact`,
-   `process solid impact`,
-   `pyramid`,
-   `quit`,
-   `rec. location graph`,
-   `rec. screenshot`,
-   `rec. solid graph`,
-   `rec. time graph`,
-   `record_solar_analysis_in_jpg`,
-   `record_solidimpact_in_jpg`,
-   `record_solidimpact_in_pdf`,
-   `reposition selected vertices`,
-   `reset saved referencebox`,
-   `reverse visibility of all faces`,
-   `right`,
-   `rotate`,
-   `rotatex`,
-   `rotatey`,
-   `rotatez`,
-   `run wind 3d-model`,
-   `s.e.`,
-   `s.w.`,
-   `save`,
-   `save as...`,
-   `save current referencebox`,
-   `scale`,
-   `scale`,
-   `scalex`,
-   `scaley`,
-   `scalez`,
-   `screenshot`,
-   `screenshot+click`,
-   `screenshot+drag`,
-   `section`,
-   `sections.displayall`,
-   `select all`,
-   `select all cameras`,
-   `select all faces`,
-   `select all groups`,
-   `select all model1ds`,
-   `select all model2ds`,
-   `select all polylines`,
-   `select all sections`,
-   `select all solids`,
-   `select all verices`,
-   `select camera`,
-   `select face`,
-   `select group`,
-   `select landpoint`,
-   `select model1ds`,
-   `select model2ds`,
-   `select near selected vertices`,
-   `select polyline`,
-   `select scene isolated vertices`,
-   `select section`,
-   `select solid`,
-   `select vertex`,
-   `separate selected vertices`,
-   `set-in normal`,
-   `set-out normal`,
-   `shade global solar`,
-   `shade surface base`,
-   `shade surface materials`,
-   `shade surface white`,
-   `shade surface wire`,
-   `shade vertex elevation`,
-   `shade vertex solar`,
-   `shade vertex solid`,
-   `shade viewport`,
-   `show cameras`,
-   `show clmrec nearest`,
-   `show clmrec stations`,
-   `show cweeds nearest`,
-   `show cweeds stations`,
-   `show earth surface`,
-   `show edges`,
-   `show faces`,
-   `show land depth`,
-   `show land mesh`,
-   `show land points`,
-   `show land texture`,
-   `show leaves`,
-   `show model1ds`,
-   `show model2ds`,
-   `show moon surface`,
-   `show naefs nearest`,
-   `show naefs stations`,
-   `show normals`,
-   `show polylines`,
-   `show sections`,
-   `show selected 1d edges`,
-   `show selected 2d edges`,
-   `show selected cameras`,
-   `show selected faces`,
-   `show selected faces vertex count`,
-   `show selected group box`,
-   `show selected group edges`,
-   `show selected group pivot`,
-   `show selected landpoints`,
-   `show selected polylines`,
-   `show selected polylines vertex count`,
-   `show selected ref pivot`,
-   `show selected sections`,
-   `show selected solids`,
-   `show selected vertices`,
-   `show sky`,
-   `show solar section`,
-   `show solid section`,
-   `show solids`,
-   `show sun grid`,
-   `show sun path`,
-   `show sun pattern`,
-   `show sun surface`,
-   `show swob nearest`,
-   `show swob stations`,
-   `show tmyepw nearest`,
-   `show tmyepw stations`,
-   `show troposphere`,
-   `show vertices`,
-   `show wind flow`,
-   `show/hide cameras`,
-   `show/hide clmrec nearest`,
-   `show/hide clmrec stations`,
-   `show/hide cweeds nearest`,
-   `show/hide cweeds stations`,
-   `show/hide earth surface`,
-   `show/hide edges`,
-   `show/hide faces`,
-   `show/hide land depth`,
-   `show/hide land mesh`,
-   `show/hide land points`,
-   `show/hide land texture`,
-   `show/hide leaves`,
-   `show/hide model1ds`,
-   `show/hide model2ds`,
-   `show/hide moon surface`,
-   `show/hide naefs nearest`,
-   `show/hide naefs stations`,
-   `show/hide normals`,
-   `show/hide polylines`,
-   `show/hide sections`,
-   `show/hide selected 1d edges`,
-   `show/hide selected 2d edges`,
-   `show/hide selected cameras`,
-   `show/hide selected faces`,
-   `show/hide selected faces vertex count`,
-   `show/hide selected group box`,
-   `show/hide selected group edges`,
-   `show/hide selected group pivot`,
-   `show/hide selected landpoints`,
-   `show/hide selected polylines`,
-   `show/hide selected polylines vertex count`,
-   `show/hide selected ref pivot`,
-   `show/hide selected sections`,
-   `show/hide selected solids`,
-   `show/hide selected vertices`,
-   `show/hide sky`,
-   `show/hide solar section`,
-   `show/hide solid section`,
-   `show/hide solids`,
-   `show/hide sun grid`,
-   `show/hide sun path`,
-   `show/hide sun pattern`,
-   `show/hide sun surface`,
-   `show/hide swob nearest`,
-   `show/hide swob stations`,
-   `show/hide tmyepw nearest`,
-   `show/hide tmyepw stations`,
-   `show/hide troposphere`,
-   `show/hide vertices`,
-   `show/hide wind flow`,
-   `sky_status`,
-   `sky.displaytessellation`,
-   `sky.scale`,
-   `sky3d.active_palette_clr`,
-   `sky3d.active_palette_dir`,
-   `sky3d.active_palette_mlt`,
-   `sky3d.displaysurface`,
-   `sky3d.passive_palette_clr`,
-   `sky3d.passive_palette_dir`,
-   `sky3d.passive_palette_mlt`,
-   `skydomesize`,
-   `soft selection`,
-   `solarchvision-bim6d`,
-   `solarimpacts.displayimage`,
-   `solarimpacts.sectiontype`,
-   `solid`,
-   `solidimpacts.displayimage`,
-   `solidimpacts.displaylines`,
-   `solidimpacts.displaypoints`,
-   `solidimpacts.grade`,
-   `solidimpacts.positionstep`,
-   `solidimpacts.power`,
-   `solidimpacts.process_subdivisions`,
-   `solidimpacts.r`,
-   `solidimpacts.sectiontype`,
-   `solidimpacts.u`,
-   `solidimpacts.v`,
-   `solidimpacts.winddirection`,
-   `solidimpacts.windspeed_(m/s)`,
-   `solidimpacts.x`,
-   `solidimpacts.y`,
-   `solidimpacts.z`,
-   `solids >> groups`,
-   `solids.displayall`,
-   `solids.palette_clr`,
-   `solids.palette_dir`,
-   `solids.palette_mlt`,
-   `sphere`,
-   `start_hour`,
-   `start_member`,
-   `start_station`,
-   `start_year`,
-   `stop rec.`,
-   `study.active_palette_clr`,
-   `study.active_palette_dir`,
-   `study.active_palette_mlt`,
-   `study.passive_palette_clr`,
-   `study.passive_palette_dir`,
-   `study.passive_palette_mlt`,
-   `study.prob_palette_clr`,
-   `study.prob_palette_dir`,
-   `study.prob_palette_mlt`,
-   `study.sort_palette_clr`,
-   `study.sort_palette_dir`,
-   `study.sort_palette_mlt`,
-   `sun3d.active_palette_clr`,
-   `sun3d.active_palette_dir`,
-   `sun3d.active_palette_mlt`,
-   `sun3d.displaypath`,
-   `sun3d.displaypattern`,
-   `sun3d.displaysurface`,
-   `sun3d.displaytexture`,
-   `sun3d.fitinskydome`,
-   `sun3d.passive_palette_clr`,
-   `sun3d.passive_palette_dir`,
-   `sun3d.passive_palette_mlt`,
-   `surface`,
-   `targetroll`,
-   `targetrollxy`,
-   `targetrollz`,
-   `tessellate rectangular`,
-   `tessellate rows & columns`,
-   `tessellate triangular`,
-   `top`,
-   `trend_period_hours`,
-   `tropo3d.displaysurface`,
-   `tropo3d.displaytexture`,
-   `truckx`,
-   `trucky`,
-   `truckz`,
-   `ungroup selection`,
-   `unhide all faces`,
-   `unhide selected faces`,
-   `update clmrec`,
-   `update cweeds`,
-   `update naefs`,
-   `update station`,
-   `update swob`,
-   `update tmyepw`,
-   `urban solar potential (active)`,
-   `urban solar potential (passive)`,
-   `use long-term (clmrec)`,
-   `use long-term (cweeds)`,
-   `use origin referencebox`,
-   `use real-time observed (swob)`,
-   `use selection referencebox`,
-   `use typical year (tmy)`,
-   `use weather forecast (naefs)`,
-   `vertices >> faces`,
-   `vertices >> groups`,
-   `vertices >> polylines`,
-   `viewport >> camera`,
-   `weighted/equal_trend`,
-   `weld objects selected vertices`,
-   `weld scene selected vertices`,
-   `wind pattern (active)`,
-   `wind pattern (passive)`,
-   `windflows.displayall`,
-   `windflows.palette_clr`,
-   `windflows.palette_dir`,
-   `windflows.palette_mlt`,
-   `windose_opacity_scale`,
-   `window select`,
-   `window select-`,
-   `window select+`,
-   `windroses.displayimage`,
-   `windroses.scale`,
-   `www.solarchvision.com`,
-   `zoom`,
-   `zoom as default`
