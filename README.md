SOLARCHVISION-BIM is a desktop software application designed and
developed by [Mojtaba Samimi
(M.Arch)](https://www.linkedin.com/in/mojtaba-samimi-06178840) in the
[Processing](https://processing.org/) language. It is available for
`GNU/Linux`, `macOS`, and `Microsoft Windows`.

## Table of contents

-   [Clone using SSH](#clone-using-ssh)
-   [Clone using HTTPS](#clone-using-https)
-   [Requirements](#requirements)
-   [Before running the program](#before-running-the-program)
-   [Run using Processing IDE](#run-using-processing-ide)
-   [Run using command line](#run-using-command-line)
-   [Download EPW files](#download-epw-files)
-   [Download CWEEDS files](#download-cweeds-files)
-   [Copyright and license](#copyright-and-license)
-   [User Interface](#user-interface)
-   [Additional resources](#additional-resources)

------------------------------------------------------------------------

## Clone using SSH

``` sh
git clone git@github.com:archmoj/solarchvision_bim.git
```

or

``` sh
git clone git@github.com:archmoj/solarchvision_bim.git --depth 1
```

## Clone using HTTPS

``` sh
git clone https://github.com/archmoj/solarchvision_bim.git
```

or

``` sh
git clone https://github.com/archmoj/solarchvision_bim.git --depth 1
```

## Requirements

[Processing v4](https://processing.org/download) must be installed, as
SOLARCHVISION-BIM is a Processing sketch.

## Before running the program

You should adjust the `BaseFolder` variable inside `solarchvision_bim.pde`.

``` java
String BaseFolder = "/home/solarch/org/solarchvision_bim";
```

Also to your screen resolution you may need to scale initial values of following
variables and the size() function:
``` java
int SOLARCHVISION_pixel_H = 400;
int SOLARCHVISION_pixel_W = 724;

float MessageSize = 16.0;
int SOLARCHVISION_pixel_A = 24; // menu bar
int SOLARCHVISION_pixel_B = 44; // 3D tool bar
int SOLARCHVISION_pixel_C = 72; // time bar
int SOLARCHVISION_pixel_D = 72; // command bar

size(1848, 1016, P2D);
```

## Run using Processing IDE

The `solarchvision_bim` sketch can be opened in the Processing IDE and
executed using the Play button.

## Run using command line

To compile and run the `solarchvision_bim` sketch, adjust
`<PATH-TO-PROCESSING>` in the following command as needed.

Please note that the command must be executed from the parent directory
containing the `solarchvision_bim` folder.

``` sh
<PATH-TO-PROCESSING>/processing-java --sketch=solarchvision_bim --run
```

## Download EPW files

To download EPW/TMY (Typical Meteorological Year) data for various
locations, a script is provided inside the `scripts` folder.

You need to adjust the `outFolder` variable in the `download_epw.js`
file to point to your installation directory.

In addition, [`node.js`](https://nodejs.org/en) is required to run the
script.

``` sh
node scripts/download_epw.js
```

## Download CWEEDS files

For locations in `Canada`, there is another database called `CWEEDS`,
which includes multi-year climate data under the Engineering Climate
Datasets (https://climate.weather.gc.ca/prods_servs/engineering_e.html).

The files for the region of interest can be extracted and placed inside
the `solarchvision_bim/input/climate/CWEEDS/` folder.

## Copyright and license

The code and documentation are released under the [GPL
v2](https://github.com/archmoj/solarchvision_bim/blob/master/LICENSE.md).

## User Interface

Once loaded the UI would look like this:

<p align="center">
    <img src="https://raw.githubusercontent.com/archmoj/solarchvision_bim/refs/heads/main//doc/images/InitialView.jpg">
</p>

Please note that in above example the `Setup | 3D-model 1` option is selected. A person and a tree is also added close to the camera.

## Additional resources
### [BIM6D Presentation](https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtabaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1)
### [Presentation at Ouranos](https://www.dropbox.com/scl/fo/5r66ns7r9j0rezprwa567/ADuKLQ_qQo98gDnlqDQMXVY?dl=0&e=2&preview=SOLARCHVISION_2015_12_09_Ouranos.pdf&rlkey=0x1wzfy5dll3bvx6j9ltw96v6)
### [TU-Berlin book: Intelligent Design using Solar-Climatic Vision (Energy and Comfort Improvement in Architecture and Urban Planning using SOLARCHVISION)](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8)

## Command line
Use `TAB` to enable/disable command line or use click inside/outside the command line are which is a dark area at the bottom.
Here is a list of available commands. Please note both lowercase and uppercase variant are accepted.

- `CLS`: Clears the command line screen
- `OPEN`: Opens a saved project
- `SAVE.AS`: Saves the project as
- `SAVE`: Saves the project
- `HOLD`: Holds the scene
- `FETCH`: Fetches the scene
- `IMPORT`: Imports an OBJ file
- `EXECUTE`: Executes a script file including multiple SOLARCHVISION commands
- `EXPORT.OBJ.TIMESERIES`: Exports scene in OBJ format at different hours (multiple files)
- `EXPORT.OBJ.DATESERIES`: Exports scene in OBJ format at different days (multiple files)
- `EXPORT.OBJ`: Exports scene in OBJ format
- `EXPORT.RAD`: Exports scene in Radiance RAD format
- `EXPORT.SCR`: Exports scene in AutoCAD SCR format
- `QUIT`: Exits the software

- `LONLAT`: Sets longitude and latitude of location | "LonLat ? ?"

- `SELECT`: Selects various categegories | "Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/landpoint"
- `DELETE`: Deletes selection or various categegories | "Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras"
- `COPY`: Copies selection | "Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?"

- `MOVE`: Moves selection | "Move dx=? dy=? dz=?"
- `ROTATE`, `ROTATEX`, `ROTATEY`, `ROTATEZ`: Rotated selection | "Rotate[X|Y|Z] r=? x=? y=? z=?"
- `SCALE`: Scales selection | "Scale s=? sx=? sy=? sz=? x=? y=? z=?"

- `2DMAN`: Creates a person | "2Dman m=? x=? y=? z=?"
- `2DTREE`: Creates a 3D tree using vertical and horizontal sections | "2Dtree m=? x=? y=? z=? h=?"
- `3DTREE`: Creates a parametric fractal tree in 3D | "3Dtree m=? degree=? seed=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? Tk=? Lf=?"
- `BOX2P`: Creates a box using two corners | "Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?"
- `BOX`: Creates a box using center and width, length and height | "Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?"
- `HOUSE1`: Creates a house like structure with roof folded in all directions | "House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?"
- `HOUSE2`: Creates a house like structure with roof folded in one direction | "House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?"
- `HOUSE3`: Creates a house like structure with roof folded in second direction| "House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?"
- `CYLINDER`: Creates a cylinder | "Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?"
- `SPHERE`: Creates a sphere | "Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?"
- `SUPERSPHERE`: Creates a super-sphere (deforms from cube to star-like object) | "SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?"
- `CUSHION`: Creates a cushion like object | "Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?"
- `OCTAHEDRON`: Creates an octahedron | "Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?"
- `ICOSAHEDRON`: Creates an icosahedron | "Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?"
- `POLYGONMESH`: Creates a an equilateral polygon mesh | "PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?"
- `POLYGONHYPER`: Creates a hyperbolic surface based on an equilateral polygon | "PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?"
- `POLYGONEXTRUDE`: Creates an extrude of an equilateral polygon | "PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?"

- `MESH2`: Creates a mesh using two points | "Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?"
- `MESH3`: Creates a mesh using three points | "Mesh3 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=?"
- `MESH4`: Creates a mesh using four points | "Mesh4 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=?"
- `MESH5`: Creates a mesh using five points | "Mesh5 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=?"
- `MESH6`: Creates a mesh using six points | "Mesh6 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=? x3=? y3=? z3=? x4=? y4=? z4=? x5=? y5=? z5=? x6=? y6=? z6=?"
- `H_SHADE`: Creates a horizontal shade surface | "H_Shade m=? tes=? lyr=? x=? y=? z=? d=? w=? a=? b=?"
- `V_SHADE`: Creates a vertical shade surface| "V_Shade m=? tes=? lyr=? x=? y=? z=? d=? h=? a=? b=?"
- `SOLID`: Creates a parametric solid object | "Solid x=? y=? z=? px=? py=? pz=? sx=? sy=? sz=? rx=? ry=? rz=? v=?"
- `SECTION`: Creates a section for performing studies | "Section x=? y=? z=? r=? u=? v=? t=? i=? j=?"
- `CAMERA`: Creates a camera | "Camera px=? py=? pz=? pt=? rx=? ry=? rz=? rt=? a=? t=?"
- `PLOYLINE`: Creates an open or closed polyline | "Polyline m=? tes=? lyr=? xtr=? wgt=? clz=? x1,y1,z1 x2,y2,z2 etc."
- `ARC`: Creates an arc | "Arc m=? tes=? lyr=? xtr=? wgt=? clz=? x=? y=? z=? r=? deg=? rot=? ang=?"
- `PIVOT`: Places the pivot to start, middle or end of object on each axis | "PIVOT minX midY maxZ or other variations"
- `VERTEX>GROUP`: Selects the group(s) of the selected vertices
- `FACE>GROUP`: Selects the group(s) of the selected faces
- `GROUP>FACE`: Selects the face(s) of the selected groups
- `POLYLINE>GROUP`: Selects the group(s) of the selected polylines
- `GROUP>POLYLINE`: Selects the polyline(s) of the selected groups
- `POLYLINE>VERTEX`: Selects the vertices of the selected polylines
- `VERTEX>POLYLINE`: Selects the polyline(s) of the selected vertices
- `GROUP>VERTEX`: Selects the vertices of the selected groups
- `FACE>VERTEX`: Selects the vertices of the selected faces
- `VERTEX>FACE`: Selects the face(s) of the selected vertices
- `SOLID>GROUP`: Selects the group(s) of the selected solids
- `GROUP>SOLID`: Selects the solid(s) of the selected groups
- `2D>GROUP`: Selects the group(s) of the selected 2Ds
- `GROUP>2D`: Selects the 2D(s) of the selected 2Ds
- `1D>GROUP`: Selects the 1D(s) of the selected 1Ds
- `GROUP>1D`: Selects the 1D(s) of the selected groups

- `ALLVIEWPORTS`: Displays all viewports
- `ENLARGE3D`: Enlarges 3D viewport
- `PAN`: Camera pan
- `PANX`: Camera pan x axis
- `PANY`: Camera pan y axis
- `LOOKORG`: Camera look at the origin
- `LOOKDIR`: Camera look at direction
- `LOOKSEL`: Camera look at selection
- `TRUCKZ`: Camera truck z axis
- `TRUCKX`: Camera truck x axis
- `TRUCKY`: Camera truck y axis
- `TROLL`: Camera target troll
- `TROLLZ`: Camera target troll z axis
- `TROLLXY`: Camera target troll xy plane
- `CROLL`: Camera roll
- `CROLLZ`: Camera roll z axis
- `CROLLXY`: Camera roll xy plane
- `ORBIT`: Camera orbit
- `ORBITZ`: Camera orbit z axis
- `ORBITXY`: Camera orbit xy plane
- `LANDORBIT`: Camera land orbit
- `DISTZ`: Camera truck z axis option
- `DISTC`: Camera distance option
- `DISTP`: Camera target roll z axis and xy plane
- `SIZEALL`: Size all
- `SIZESKY`: Size sky only
- `SIZE3D`: Size objects only
- `ZOOM`: Camera zoom
- `NORMALZOOM`: Camera set zoom to normal view
- `ORTHOGRAPHIC`: Orthographic camera
- `PERSPECTIVE`: Perspective camera
- `TOP`: Display top view
- `FRONT`: Display front view
- `LEFT`: Display left view
- `BACK`: Display back view
- `RIGHT`: Display right view
- `BOTTOM`: Display bottom view
- `S.W.`: Display South West view
- `S.E.`: Display South East view
- `N.E.`: Display North East view
- `N.W.`: Display North West view
- `SHADE.WIRE`: Sets shade to view wireframe
- `SHADE.BASE`: Sets shade to base
- `SHADE.WHITE`: Sets shade to white
- `SHADE.MATERIALS`: Sets shade to view materals
- `SHADE.GLOBAL`: Sets shade to global solar values of different orientations and inclinations
- `SHADE.REAL`: Sets shade to solar values at each vertex
- `SHADE.SOLID`: Sets shade to total solid parameter
- `SHADE.ELEVATION`: Sets shade to elevation
- `RENDER.VIEWPORT`: Renders viewport
- `PREBAKE.VIEWPORT`: Pre-bakes viewport

