# SOLARCHVISION-BIM

**Bring space, time, energy, and climate into the design process.**

SOLARCHVISION-BIM is an open-source desktop application for **3D modeling, BIM and geographic data integration, and solar-climatic analysis**. It brings building and site geometry together with geographic context, weather and climate data, and time-dependent visualization to help explore how the sun, local climate, weather, and design choices interact.

The SOLARCHVISION approach treats solar exposure and shade as context-dependent effects: they can be beneficial in one season or location and undesirable in another. Use the application to investigate design alternatives across buildings, façades, streets, courtyards, landscapes, neighborhoods, and solar-energy applications.

By combining spatial models with time-varying environmental data, SOLARCHVISION-BIM helps design teams consider energy demand and production, daylight, comfort, health, and safety earlier in the design process.

- **For:** Architects, urban and landscape planners, renewable-energy specialists, researchers, educators, and project teams.
- **Platforms:** GNU/Linux, macOS, and Microsoft Windows.
- **License:** GNU General Public License v2 (GPL-2.0).
- **Repository:** [archmoj/solarchvision_bim](https://github.com/archmoj/solarchvision_bim)
- **Documentation:** [Command reference](command/README.md) · [Import tools](import/README.md)

> **Scope and limitations:** SOLARCHVISION-BIM supports design exploration and environmental analysis. Results depend on the model, location, input data, processing assumptions, and selected workflow. Outputs are not certified engineering calculations and do not replace professional review or specialist simulations where required.

## Contents

- [Why SOLARCHVISION-BIM?](#why-solarchvision-bim)
- [Get started](#get-started)
- [What can you explore?](#what-can-you-explore)
- [Model interoperability and imports](#model-interoperability-and-imports)
- [3D modeling, editing, and visualization](#3d-modeling-editing-and-visualization)
- [Geographic context and site modeling](#geographic-context-and-site-modeling)
- [Weather, climate, and geographic data](#weather-climate-and-geographic-data)
- [Modeling and analysis workflow](#modeling-and-analysis-workflow)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Command bar, scripting, and exports](#command-bar-scripting-and-exports)
- [The SOLARCHVISION approach](#the-solarchvision-approach)
- [Statistical scenarios, built from real data](#statistical-scenarios-built-from-real-data)
- [Method and publications](#method-and-publications)
- [Technical overview](#technical-overview)
- [Contribute and follow the project](#contribute-and-follow-the-project)
- [License](#license)

## Why SOLARCHVISION-BIM?

Many design questions are spatial and time-dependent: When does a façade receive useful solar radiation? When does the same exposure contribute to overheating? How do neighboring buildings and trees change shade in a public space? How might these effects vary across seasons, years, or forecast scenarios?

The SOLARCHVISION approach encourages **early, integrated environmental analysis**. Evaluating orientation, dimensions, layout, and form while design options are still flexible can reveal opportunities that may be harder to address later. Climate-aware design does not automatically mean higher construction costs: some improvements can come from adjusting core design parameters, although project costs and feasibility must be assessed individually.

The goal is not simply to maximize sunlight or minimize shade. It is to understand how design choices influence the natural and built environment across **space, time, and energy**, and to identify trade-offs before decisions are fixed.

SOLARCHVISION-BIM brings several parts of that investigation into one workspace:

- **Bring models together:** Import supported BIM, CAD, mesh, and point-cloud formats to use existing project geometry as a starting point.
- **Model the place:** Create and edit 3D buildings, surfaces, terrain, trees, and other site elements.
- **Work iteratively:** Use selection and editing tools, with separate undo/redo histories for the 3D scene, 3D viewport, geographic station selection, and 2D study graph.
- **Render efficiently:** Use dedicated one-click SOLARCHVISION render actions to run the required pre-bake and post-processing workflow for the current viewport or all sections.
- **Compare shading consistently:** Use calibrated global, vertex-level, pixel-level camera-render, and section-based shading workflows.
- **Explore solar exposure:** Investigate sun position, solar radiation, shading, and the effects of surrounding geometry.
- **Consider benefits and risks:** Explore when solar exposure may be useful and when shade, overheating, or seasonal environmental conditions may create design concerns.
- **Connect design to location:** Use geographic views, map imagery, station locations, terrain context, and available building and tree data.
- **Explore time and variability:** Compare hours, days, years, and supported forecast scenarios; inspect statistical summaries and percentiles where available.
- **Support design-team discussions:** Use 3D views, graphs, and supported exports to communicate how proposed changes may affect buildings and outdoor spaces.
- **Build repeatable workflows:** Use the graphical interface, command bar, scripts, and supported export formats.
- **Use and extend open-source software:** Inspect the code, report issues, and adapt the application to your needs.

The analyses available depend on the selected study, model setup, location, and dataset.

## Get started

### 1. Get the application

1. Open the [SOLARCHVISION-BIM GitHub repository](https://github.com/archmoj/solarchvision_bim).
2. Download the repository as a ZIP file or clone it with Git.
3. Open the `dist` directory.
4. Run the executable intended for your operating system, following any release-specific instructions.

Clone the repository with HTTPS:

```sh
git clone https://github.com/archmoj/solarchvision_bim.git
```

For a smaller, shallow clone:

```sh
git clone https://github.com/archmoj/solarchvision_bim.git --depth 1
```

Or use SSH if you have an SSH key configured with GitHub:

```sh
git clone git@github.com:archmoj/solarchvision_bim.git
```

Pre-built files and launch requirements can vary by release. If the application does not start, check the [`dist/` launch instructions](dist/LAUNCH.md) for your platform.

Prefer to run it from source, or contribute code? See [CONTRIBUTING.md](CONTRIBUTING.md) for installing Processing and building/running the sketch directly.

### 2. Try a first study

Start with one clear question—for example, how shade on a building or outdoor space changes throughout the day.

1. **Choose a location.** Use the `Location` menu to set the project location.
2. **Load suitable data.** Load an available weather or climate dataset for the location.
3. **Create or import a scene.** Use `3D-create` to add geometry, or import a supported model or point cloud.
4. **Choose a study.** Open the `Analysis` menu and select an available solar or environmental study.
5. **Inspect the result.** Use the 3D view and available study graphs.
6. **Move through time.** Use the Case Bar to select hours, days, years, or forecast scenarios supported by the dataset.
7. **Save or export.** Save the project or use an available export workflow.

For model-based studies such as `Skin Potential (Active)` and `Skin Potential (Passive)`, use the dedicated **SOLARCHVISION current viewport** or **SOLARCHVISION all sections** render action to run the relevant pre-bake and post-processing steps together. The first action processes the current camera/viewport; the second applies the workflow across the model's sections. These one-click actions reduce the need to invoke the individual preparation and processing steps manually.

### 3. Get familiar with the workspace

- **3D view:** Create, select, edit, and inspect buildings, surfaces, terrain, trees, and other objects. Supported environmental effects are visualized here.
- **World view:** Explore geographic context and work with available map, station, and terrain information. Hover over the map to see which stations are nearby; right-click sets the project location; left-click pins that station list in place (see [Explore the map interactively](#explore-the-map-interactively)).
- **Study/time view:** Inspect time-series graphs, environmental studies, and statistical or scenario results.
- **Case Bar:** Choose the hours, days, and scenarios or years included in a study, and select a statistical summary where available.
- **Command bar:** Enter commands for precise settings and repeatable workflows. Press `TAB` to show or hide it.

The initial layout can vary. Use the `Setup` menu to switch among available 3D models and time-view layouts.

## What can you explore?

### Architecture and building design

- Compare building form, orientation, surface exposure, and shading.
- Investigate how surrounding geometry affects solar access.
- Explore changes in solar exposure across hours, seasons, and supported weather scenarios.
- Consider trade-offs between useful solar gains and unwanted exposure.
- Import existing BIM or CAD geometry and use it as a basis for environmental design studies.

### Urban planning and public space

- Examine relationships among building massing, open space, and surrounding context.
- Explore solar access and shadow patterns in streets, courtyards, parks, and other public spaces.
- Investigate the influence of neighboring buildings, trees, and shading structures.
- Use geographic and weather context to inform early-stage comparisons.
- Build contextual massing from available OpenStreetMap or Overture Maps data using the supplied import scripts.

### Landscape architecture

- Represent terrain, trees, and site elements in a 3D scene.
- Explore how vegetation and structures affect shade and solar exposure.
- Compare landscape alternatives across seasons.
- Use point-cloud data as a basis for site and terrain representation where appropriate.

### Climate and environmental studies

- Work with supported weather, climate, observation, and ensemble forecast datasets.
- Compare selected hours, days, years, and forecast scenarios.
- Inspect statistical summaries such as minimum, average, maximum, and percentiles where supported.
- Visualize selected environmental fields and export geometry or model states for other workflows.

These analyses can inform early design, option comparison, and design refinement. Depending on the project and the data available, they may help teams identify locations that warrant closer review for uncomfortable solar exposure, excessive shade, overheating, or seasonal energy and safety concerns—including under selected extreme-weather conditions.

## Model interoperability and imports

SOLARCHVISION-BIM can use existing project geometry as well as geometry created inside the application. Import workflows help bring architectural models, exchange files, meshes, and point-cloud data into a common 3D workspace.

### Supported import formats

| Format | Typical use |
|---|---|
| **IFC** (`.ifc`) | Building Information Modeling (BIM) exchange |
| **gbXML** (`.xml`) | Building and energy-model geometry exchange |
| **OBJ** (`.obj`) | General 3D geometry and mesh exchange |
| **DAE** (`.dae`) | COLLADA 3D scenes |
| **DXF** (`.dxf`) | CAD drawing and geometry exchange |
| **GLB** (`.glb`) | Binary glTF 3D assets |
| **PLY** (`.ply`) | Polygon and vertex-based geometry |
| **LAS** (`.las`) | LiDAR and point-cloud data |
| **STL** (`.stl`) | Triangulated surface and solid-mesh geometry |

Import behavior and the geometry or attributes retained depend on the source format and the contents of the file. Check the imported result before using it for measurement or analysis. A successful geometry import does not necessarily mean that all source BIM properties, classifications, materials, or relationships are preserved.

### LAS point-cloud workflow

LAS files can be imported as point-cloud data. By default, imported points are meshed into a surface. The **Import LAS** options dialog provides controls to disable meshing, choose a meshing algorithm, and specify a point range. This can be useful when working with large point clouds or when testing a subset before processing the full dataset.

The command interface also provides `IMPORT.LAS` for scripted imports, including an optional maximum point index. The interactive import dialog provides additional point-range controls.

### Import commands

The command line includes dedicated import commands:

```text
IMPORT.OBJ
IMPORT.GBXML
IMPORT.IFC
IMPORT.DAE
IMPORT.DXF
IMPORT.GLB
IMPORT.PLY
IMPORT.LAS
IMPORT.STL
```

See the [command reference](command/README.md) for command syntax and details.

## 3D modeling, editing, and visualization

SOLARCHVISION-BIM includes its own 3D geometry and scene-editing environment. You can create geometry directly, modify imported models, and add contextual elements for architectural, urban, landscape, and environmental studies.

### Create and edit geometry

The `3D-create` menu provides tools for creating supported objects, including houses, parametric surfaces, boxes, cones, cushions, cylinders, spheres, planes, polygons, extrusions, surfaces, polylines, points, trees, people, and cameras.

Use the selection and editing tools to work with objects and their components:

- **Select:** Select objects and supported geometry elements.
- **Alter and modify:** Adjust object position, orientation, dimensions, and other available properties.
- **Match and align:** Align objects and geometry using the available matching tools.
- **Group and organize:** Work with groups, layers, visibility, and materials.
- **Inspect and navigate:** Use cameras and viewport controls to examine the model from different perspectives.

### Undo and redo

Undo and redo are available across several parts of the application, so changes can be reversed in the context where they were made. The supported histories cover:

- **3D scene:** changes to model geometry and scene objects.
- **3D viewport:** changes to the 3D view and its viewport state.
- **Geographic stations:** station selection and related station-state changes in the World view.
- **2D study graph:** changes to the study graph and its 2D viewport state.

The 3D scene, 3D viewport, station, and study-graph histories are distinct; an undo or redo operation applies to the relevant context rather than treating every interaction as one undifferentiated history. The general keyboard shortcuts documented here include:

| Shortcut | Action |
|---|---|
| `Ctrl+Z` | Undo a model change |
| `Ctrl+Y` | Redo a model change |
| `Ctrl+Shift+Z` | Undo a viewport change |
| `Ctrl+Shift+Y` | Redo a viewport change |

Additional context-specific undo/redo commands are available for the other supported histories. The exact operation that is reversed depends on the active context and command.

### Visualization

The 3D environment supports perspective and orthographic views, surface and edge display, materials, layers, and analytical overlays. Switch between available shading and impact views to inspect geometry, solar exposure, and environmental results.

### Calibrated shading at multiple levels

SOLARCHVISION-BIM provides complementary shading and solar-impact calculations at several spatial and display levels. These include global calculations based on surface orientation and inclination, vertex-level evaluation, pixel-level evaluation in a camera render, and calculations on model sections. The methods are calibrated to produce results that agree across these representations, allowing a study to be inspected at different levels of detail without treating each display method as an unrelated analysis.

The appropriate method depends on the study and the desired representation: global orientation/inclination analysis provides a surface-level view; vertex-level calculations resolve variation across model geometry; pixel-level camera rendering provides a view-dependent image; and section-based calculations support inspection of selected cuts through the model.

### One-click SOLARCHVISION render actions

Two dedicated render actions bring the required pre-bake and post-processing steps together:

- **SOLARCHVISION current viewport:** runs the SOLARCHVISION render workflow for the current camera/viewport.
- **SOLARCHVISION all sections:** runs the workflow across all prepared model sections.

These actions simplify workflows that previously required several separate preparation and processing operations. Use the current-viewport action when working with a particular camera view, or the all-sections action when the analysis needs to be prepared and processed across the section set.

## Geographic context and site modeling

A design model is more meaningful when considered in its real geographic context. SOLARCHVISION-BIM provides a World view with geographic positioning, map imagery, station locations, and terrain visualization.

The geographic subsystem supports latitude/longitude positioning, map projections, map tiles, station locations, zoom levels, and terrain context. Some geographic features, including terrain mesh and terrain texture, require an API key.

### Building and tree context from map data

The repository includes scripts for generating 3D building massing around a specified geographic location:

- **OpenStreetMap (OSM):** Python and JavaScript implementations can retrieve building footprints and tree locations through the Overpass API.
- **Overture Maps:** A Python script can retrieve building data from Overture Maps. Optional tree data can be sourced from OpenStreetMap.

The scripts generate geometry in a local projected coordinate system and can produce OBJ models and native SOLARCHVISION `.svs` geometry scripts. The generated context can include extruded building massing, a ground reference, and tree objects where source data is available.

Building heights depend on available source attributes and fallback settings. The generated massing is intended for contextual modeling, not as a surveyed or construction-accurate representation. Data coverage, completeness, licensing, and attribution requirements depend on the source.

For setup, dependencies, command-line options, and details about the generated files, see the [3D building import documentation](import/README.md).

### Explore the map interactively

The World view's map responds to the mouse directly, without going through a menu:

- **Hover** over the map to see the short name of whichever weather or climate station(s) are nearby, without clicking. When zoomed out over a dataset with many stations, the list is automatically kept short, with a note of how many additional nearby stations were left out rather than listing them all.
- **Right-click** sets the project location to the clicked point and zooms in to confirm exactly where it landed.
- **Left-click** pins that same nearby-station list in place instead of it following the mouse, so you can look elsewhere while it stays visible. A pinned list stays attached to the real-world location it was pinned at as the map is panned or zoomed, rather than to a fixed spot on screen, and is removed automatically once that location is no longer part of the visible map.

A left-click pins a hover point the same way on a study graph, and in the 3D view while the solar-impact overlay is showing; a right-click never pins one in any of these. Press `ESC` to remove the most recently pinned point.

## Weather, climate, and geographic data

Use the `Location` menu to select a project location and load or download supported weather and geographic data. EPW/TMY data are used by default when available. Other supported sources and workflows include:

- **CWEEDS:** Multi-year engineering climate data for Canadian locations.
- **CLMREC:** Supported climate-record data.
- **NAEFS:** Ensemble forecast data for exploring a range of forecast scenarios.
- **SWOB:** Meteorological observations.
- **HRDPS/GDPS forecast imagery:** Available through the atmospheric visualization workflow where configured.

Coverage and availability vary by location and workflow. For Canadian CWEEDS data, consult [Engineering Climate Datasets](https://climate.weather.gc.ca/prods_servs/engineering_e.html). CWEEDS files are expected under `input/climate/CWEEDS/`.

### Check data before interpreting results

Confirm the source, geographic representativeness, time coverage, units, missing values, and processing assumptions. Typical weather years, historical records, recent observations, deterministic forecasts, and ensemble forecasts describe different aspects of environmental conditions and should not be treated as interchangeable.

A typical weather file is useful for many building-energy workflows, but it does not represent every possible weather pattern or extreme. A forecast is not a climate projection, and a single observation station is not automatically representative of the project site.

Solar quantities need particular care. A dataset may not provide solar radiation directly, or may provide it at a coarser time step than the analysis requires. Some workflows may derive direct and diffuse solar components from other forecast parameters or estimate hourly values from coarser intervals. Such values are **derived estimates**, not direct measurements; they depend on the source data, method, and assumptions.

When using estimated or interpolated data, document the source variables, time step, assumptions, and uncertainty.

### Match solar studies to the design question

The appropriate study depends on the design stage and the question being asked. A quick sun-path review can help with orientation, while time-dependent studies using representative weather or climate data can reveal seasonal patterns that a single date or image may miss.

For building-skin and urban-fabric studies, where the required inputs and workflows are available, hourly analysis over a year—or comparison across multiple years—can help distinguish recurring patterns from conditions tied to a particular period.

When comparing design alternatives, consider:

1. **Surface orientation and inclination.** Compare relevant façades, roofs, canopies, and other surfaces.
2. **Direct and diffuse components.** Where supported, consider these separately before interpreting global solar exposure.
3. **Shading and surrounding geometry.** Review how building form, adjacent buildings, trees, and other obstructions alter solar access.
4. **Seasonal context.** Compare periods when solar gains may be useful with periods when exposure may contribute to overheating or other undesirable effects.
5. **Variability and extremes.** Alongside averages, inspect relevant extremes and probabilities when the available dataset supports them.

Before comparing results, record the site and orientation, dataset and period, whether solar values are measured or derived, temporal resolution, selected statistic or forecast members, and relevant assumptions. Compare like with like and state limitations when presenting findings.

## Modeling and analysis workflow

### Create or import a scene

Use the `3D-create` menu to add supported objects, or import existing geometry using one of the supported formats described above.

After choosing an object type, click in the 3D view to place it:

- **Right-click:** Place the object on the land surface.
- **Left-click:** Place the object on the surface of an existing 3D model.

Default creation parameters are available under `Geometries & Space` → `Create`. Use `3D-select`, `3D-alter`, `3D-modify`, and `3D-match` to select, adjust, modify, and align objects.

### Choose and interpret a study

Start with an available study in the `Analysis` menu. General studies include wind patterns, orientation potential, hourly sun position, and annual sun paths, with active and passive variants where offered.

Use the `3D-shade` menu to change the visualization, including options such as `Shade Global Solar` where available. Move through time to see how the display changes. Interpret colors and values according to the selected layer and its units; different layers can represent different environmental quantities.

### Compare hours, days, years, and scenarios

The **Case Bar** sits above the command bar. Its range controls let you select:

- **Hours** within the available data period.
- **Days** to include in the study.
- **Scenarios** for ensemble forecasts, or **Years** for multi-year climate input.

Use a left-click to set the start of a range and a right-click to set its end. Available statistical choices include minimum, average, maximum, the 25th, 50th (median), and 75th percentiles, plus `Leaning Low`, `Well-tempered`, and `Leaning High`—three scenarios unique to SOLARCHVISION (see [Statistical scenarios, built from real data](#statistical-scenarios-built-from-real-data)).

These options are not interchangeable: choose the statistic or scenario selection that matches the question being investigated.

### Save and export

Use the application's project save/load functions to retain supported scene and study information. Available export workflows include:

- **OBJ:** Export scene geometry.
- **OBJ time-series:** Export geometry at different hours.
- **OBJ date-series:** Export geometry at different days.
- **LAS:** Export the positions of points in the scene as a point cloud.
- **RAD:** Export Radiance geometry.
- **SCR:** Export an AutoCAD script.
- **HTML:** Export through the available HTML workflow.
- **Image capture:** Record viewport frames in PNG, JPG, TIF, or BMP formats using the command interface.

These formats serve different purposes; check the target application's documentation before relying on an export for downstream production work.

## Keyboard shortcuts

Shortcuts may behave differently when a text field or the command bar has focus.

### General

| Shortcut | Action |
| --- | --- |
| `TAB` | Show or hide the command bar; advance to the next spinner edit when in progress |
| `ESC` | Cancel an in-progress spinner edit; otherwise close an open menu, cancel console input, cancel an open pick list, cancel viewport shading, or remove the most recently pinned hover point—whichever applies |
| `Ctrl+Z` | Undo model change |
| `Ctrl+Y` | Redo model change |
| `Ctrl+Shift+Z` | Undo viewport change |
| `Ctrl+Shift+Y` | Redo viewport change |
| `a` / `A` | Switch between active and passive impact views in the 3D view |
| `s` / `S` | Change the sky scenario: all data, sunny, partly cloudy, or cloudy |
| `d` / `D` | Change the impact-display day in the 3D view |

### Camera and view navigation

| Shortcut | Action |
| --- | --- |
| `` ` `` / `~` | Cycle through world-view zoom levels |
| `+` / `-` | Zoom the 3D view in or out |
| `Ctrl+,` / `Ctrl+.` | Move the camera closer to or farther from the selection |
| `,` / `.` | Move the camera closer or farther |
| `2` / `8` | Rotate the camera up or down |
| `4` / `6` | Rotate the camera left or right |
| `1` / `3` | Move the camera left or right |
| `7` / `9` | Move the camera up or down |
| `5` | Aim the camera at the selection, or the origin if nothing is selected |
| `0` | Move the camera closer |
| `/` / `*` | Move the camera toward or away from the selection |
| Arrow keys | Rotate the camera around the selection |

### Selection, model, and time

| Shortcut | Action |
| --- | --- |
| `DELETE` | Delete selected items |
| `Shift+UP` / `Shift+DOWN` | Move, rotate, scale, or adjust selection properties, depending on the active control |
| `c` / `C` | Switch to available cameras in the scene |
| `ENTER` | Rebuild global and vertex solar-energy/impact data |
| `SPACE` | Advance time and shade the view |
| `BACKSPACE` | Move time backward and shade the view |
| `Alt+RIGHT` | Advance time |
| `Alt+LEFT` | Rewind time |
| `Alt+UP` | Advance month |
| `Alt+DOWN` | Rewind month |
| `t` / `T` | Change the forecast hour used for atmospheric visualization |

### Time graphs and layouts

| Shortcut | Action |
| --- | --- |
| `Ctrl+UP` / `Ctrl+DOWN` | Change the weather layer in the hourly graph |
| `Ctrl+LEFT` / `Ctrl+RIGHT` | Change the impact layer in the daily graph |
| `Ctrl+PAGE_UP` / `Ctrl+PAGE_DOWN` | Switch among numbered layouts available in `Setup` |
| `Ctrl+;` | Show or hide the impact summary |
| `Ctrl+'` / `Ctrl+"` | Adjust the hourly graph's vertical scale factor |
| `<` / `>` | Change the number of joined days |
| `(` / `)` | Change the number of displayed days |
| `[` / `]` | Change the horizontal interval of the probability graph |
| `{` / `}` | Change the vertical interval of the probability graph |
| `v` / `V` | Show or hide raw values on the hourly graph |
| `b` / `B` | Show or hide probabilities on the hourly graph |
| `n` / `N` | Show or hide statistics on the hourly graph |
| `m` / `M` | Show or hide sorted values on the hourly graph |

## Command bar, scripting, and exports

The command bar is optional. It is useful for setting values precisely, repeating operations, or running commands from scripts. Press `TAB` to show or hide it, or click inside the dark command area at the bottom of the interface.

The command system supports project operations, object creation and editing, camera and view controls, dates, palettes, latitude/longitude, numeric controls, and on/off settings. Commands are not case-sensitive. Use `RUN.SCRIPT` to execute a text file containing commands, commonly with the `.svs` extension.

Examples:

```text
OPEN
SAVE
IMPORT.IFC
IMPORT.LAS
EXPORT.OBJ
EXPORT.LAS
RUN.SCRIPT
```

See the [command reference](command/README.md) for complete syntax, arguments, and available commands. The [import documentation](import/README.md) describes the OSM and Overture building-context scripts and their generated files.

## The SOLARCHVISION approach

**Solar-climatic vision means looking at architecture and urban space from the perspectives of the sun and climate.** Rather than treating sunlight as an unqualified benefit or relying only on a sun-path diagram, investigate where radiation reaches a surface or space, when it arrives, and whether its effect is desirable under local climatic conditions.

The approach treats solar design as an integrated problem spanning building form, orientation, the building skin, outdoor space, urban fabric, and renewable-energy systems. It considers both immediate design decisions and longer-term performance across seasons and changing weather conditions.

The analysis is most useful when introduced early enough to influence fundamental choices—such as orientation, dimensions, layout, façade proportions, landscape placement, and shading—rather than being used only to check a nearly finished design.

The purpose is to help a project team identify promising options, recognize areas that may need further investigation, and exchange evidence in forms that support discussion among architects, landscape architects, urban planners, energy modelers, clients, municipalities, and other decision-makers.

### Active and passive strategies are complementary

- **Active solar strategy:** Shape and orient buildings and surfaces to make solar energy available for useful purposes. Depending on the project and systems, this may include solar collection or electricity generation.
- **Passive solar-climatic strategy:** Evaluate both beneficial and undesirable effects of solar radiation on buildings and outdoor spaces. Solar heat gains can help during cold periods but contribute to overheating during warm periods.

A design should not maximize solar exposure everywhere. It should balance useful gains and unwanted exposure while considering daylight, views, ventilation, construction, operation, and the needs of people using the space.

### From radiation to solar-climatic effect

The amount of solar radiation is not the same as its effect in a particular climate. The method described in the SOLARCHVISION publications includes the *Degree of Need to Shade/Shine*, which relates solar radiation to the difference between outdoor temperature and a desired indoor temperature. This provides a way to distinguish periods when solar radiation may be beneficial from periods when shading or other responses may be desirable.

### Analyze the whole design—not just one façade

1. **Building skin:** Study each orientation, transparent and opaque surfaces, overhangs, vertical and horizontal shading, and reflective elements.
2. **Building form and layout:** Compare orientation, proportions, massing, self-shading, and the relationship between transparent and opaque surfaces.
3. **Indoor and outdoor conditions:** Consider how solar exposure and shade may affect energy demand, daylight, comfort, and use of interior and exterior spaces.
4. **Outdoor space and urban fabric:** Examine how buildings, street orientation, spacing, trees, terrain, and secondary structures affect courtyards, sidewalks, plazas, and other public spaces.
5. **Renewable-energy systems and site planning:** Where relevant, consider solar collectors and other renewable-energy elements alongside building and landscape decisions; combine solar-climatic information with geographic and planning layers where supported.

### A practical solar-climatic design loop

1. **Establish the context.** Confirm location, orientation, topography where relevant, intended use, surrounding geometry, and the quality and coverage of available climate data.
2. **Choose meaningful periods and data types.** Consider representative climate patterns and relevant extremes. Where appropriate, compare long-term records, observations, and forecast scenarios.
3. **Check the solar inputs.** Confirm whether direct, diffuse, and global radiation values are supplied, estimated, interpolated, or post-processed. Note the time step and assumptions.
4. **Map performance and potential risks.** Review relevant surfaces and indoor or outdoor spaces across hours, days, and seasons. Look for both beneficial conditions and potential problems such as excessive exposure, persistent shade, overheating, or seasonal safety concerns.
5. **Generate alternatives.** Test changes to orientation, massing, transparent and opaque façade areas, shading devices, trees, landscape elements, and public-space layout where appropriate.
6. **Compare trade-offs.** Consider energy demand and production, comfort, daylight, health, safety, views, constructability, operation, and effects on neighboring spaces together.
7. **Communicate and refine.** Share views, graphs, and supported exports with the design team; repeat the analysis after design changes. Use specialist daylight, thermal, energy, wind, safety, or other simulation tools where required.

The method can inform early design, refinement of building or landscape elements, and review of existing places. It supports the identification of design questions and alternatives; it does not guarantee a universally optimal design or replace formal risk assessment or specialist calculations.

## Statistical scenarios, built from real data

A single weather or climate file can only show one version of the past or a forecast. SOLARCHVISION-BIM can instead work with a collection of ensemble members or climate scenarios and derive representative values from their distribution. The Case Bar exposes standard statistics—Minimum, Maximum, Average, and the 25th, 50th (median), and 75th percentiles—alongside three SOLARCHVISION-specific scenarios: **Leaning Low**, **Well-tempered**, and **Leaning High**.

The implementation separates two related tasks:

1. **Calculate the target statistic from the full distribution.** The statistical routine sorts the available values for a time slot and calculates the requested statistic. Minimum and Maximum are the extremes; Average is the arithmetic mean; and the 25th, 50th, and 75th percentiles are order statistics selected from the sorted values (with the median averaging the two middle values when the sample count is even).
2. **Select real ensemble member(s) to represent that statistic in the simulation.** The scenario-selection workflow identifies the real ensemble member or members closest to the calculated target. Depending on the statistic and available members, it can use one, two, or three representative samples. Their hourly solar and impact values are then combined using the weighting rule appropriate to the selected statistic.

This means the displayed statistic and the weather member(s) used to drive a time-dependent simulation are related, but they are not the same operation. The simulation remains grounded in actual ensemble-member data rather than inventing a synthetic weather sequence independently of the source records.

### Percentiles and representative-member weighting

Minimum and Maximum use the single real member closest to the corresponding extreme. The 25th, 50th, and 75th percentiles each select up to two nearest members; the closest receives twice the weight of the second (**2:1**). This keeps the resulting hourly values closer to the requested percentile while using a second nearby member to reduce noise from relying on only one ensemble member.

The implementation also handles missing or filtered data at the hourly level. A sample contributes only when the required values are defined and it passes the applicable member filter. If a sample cannot contribute for a particular hour, its weight is not reassigned to another sample. If no selected sample has usable data, the result remains undefined rather than silently treating missing data as zero.

### Leaning Low, Well-tempered, and Leaning High: scenarios unique to SOLARCHVISION

These three options are **not percentiles**. They are rank-weighted means—statistical estimators that use every defined value in the sorted distribution, with a weight determined by its rank:

- **Leaning Low:** weights lower-ranked values more strongly, with weights decreasing toward the high end. It produces a value between the mean and the minimum.
- **Well-tempered:** uses a triangular weighting that peaks at the center rank and decreases toward both extremes. Every value contributes, but central values have more influence. The name refers to J.S. Bach's *Well-Tempered Clavier*: “well-tempered,” not “even-tempered,” because the weighting is deliberately non-uniform while remaining balanced around the center.
- **Leaning High:** weights higher-ranked values more strongly, with weights increasing toward the high end. It produces a value between the mean and the maximum.

Unlike a percentile, which reads a value at one position in the sorted distribution, each of these three estimators is influenced by the entire distribution. The resulting target is then matched to one or more real ensemble members for the time-dependent simulation.

For Average and the three SOLARCHVISION rank-weighted scenarios, up to three nearest representative members are selected and their usable hourly samples are combined with **equal weights**. These statistics describe the distribution as a whole rather than a single rank, so equal weighting helps reduce single-member noise without biasing the result toward one selected member. The number of members is therefore statistic-specific: one for Minimum/Maximum, two for the three percentiles, and three for Average and the SOLARCHVISION scenarios. For passive-impact studies, directional statistics are remapped during member selection so that high/low scenario labels remain intuitive for the passive-impact interpretation.

The implementation is documented in the source files [`normal.pde`](src/solarchvision_bim/normal.pde), which calculates the nine representative statistics, and [`averagedScenarioValues.pde`](src/solarchvision_bim/averagedScenarioValues.pde), which combines hourly values from the selected representative members. The scenario-selection logic is also handled by the related `findScenarioCloseToDailyStatistic` workflow.

## Method and publications

SOLARCHVISION-BIM is the product of the author's own research into solar-climatic design, carried on for decades and implemented by hand—connecting weather data, building geometry, and environmental analysis into one tool, one design question at a time. The publications below mark some of that work's milestones, not where it started or where it stops.

The following publications describe the principles behind SOLARCHVISION's solar-climatic approach and show how weather data, solar orientation, building geometry, and urban context can inform design decisions.

- Samimi, Mojtaba. *From the Sun to the Architect (AZ MEHR TA MEHRAZ): Calculation of General Patterns of Direct and Diffuse Solar Radiation for 16 Cities of Iran, Analysis of the Sun’s Positive and Negative Effects on Different Building Orientations and Inclinations and Design Optimization using the Perspectives from the Sun*. M.Arch thesis (Supervisor: M. Tahbaz), Faculty of Architecture and Urban Planning, Shahid Beheshti University, Tehran, 2002–2007, completed 2007 *(recipient of two national awards)*.
- Samimi, Mojtaba, and Farshad Nasrollahi. [*Intelligent Design using Solar-Climatic Vision: Energy and Comfort Improvement in Architecture and Urban Planning using SOLARCHVISION*](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8). Young Cities Research Paper Series, Volume 09, 2014.
- Samimi, Mojtaba. [“Weather Data and Solar Orientations.”](https://doi.org/10.1007/978-3-319-15030-7_12) In *Future City: Architecture for Optimal Living*, edited by Stamatina Th. Rassia and Panos M. Pardalos, Springer, 2015, pp. 221–240.
- [SOLARCHVISION presentation at Ouranos](https://www.dropbox.com/scl/fo/5r66ns7r9j0rezprwa567/ADuKLQ_qQo98gDnlqDQMXVY?dl=0&e=2&preview=SOLARCHVISION_2015_12_09_Ouranos.pdf&rlkey=0x1wzfy5dll3bvx6j9ltw96v6)
- [BIM6D presentation](https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtibaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1)

If you build upon, adapt, or reimplement these methods in academic research or software tools, **please acknowledge prior art**—especially when foundational concepts trace back to the same academic lineage!

For an acceptable example of how published solar-climatic methods could be independently reimplemented and properly credited, see [IFC Viewer Online](https://ifcvieweronline.eu) ([SOLARCHVISION's passive shade/shine impact on the IFC](https://github.com/j03rul4nd/ifc-viewer-online/pull/241)), which reimplemented SOLARCHVISION's passive and active solar-climatic impact analysis (*Degree of Need to Shade/Shine*) directly on IFC models in the browser with explicit attribution in both code and interface.

## Technical overview

### Modeling and visualization

The application includes a 3D geometry system for points, faces, solids, groups, polylines, materials, and 1D/2D models. Supported workflows include object creation, selection, transformation, grouping, visibility, layers, and material assignment. Procedural vegetation and parametric objects can represent aspects of the built and natural environment.

Import workflows support IFC, gbXML, OBJ, DAE, DXF, GLB, PLY, LAS, and STL files. The exact geometry and information retained depend on the format and source file. LAS point clouds can be meshed into surfaces during import, with options available through the import dialog.

The interface provides 3D, world/geographic, and study/time views. Rendering supports perspective and orthographic cameras, surface and edge display, analytical overlays, and cached or clipped rendering for interactive performance. Dedicated SOLARCHVISION render actions combine pre-bake and post-processing for the current viewport or all sections. Calibrated solar/shading workflows operate at global orientation/inclination, vertex, pixel (camera-render), and section levels. Separate undo/redo histories support the 3D scene, 3D viewport, geographic station state, and 2D study graph.

### Solar, shade, and environmental analysis

Solar workflows use the project location and time, weather or climate radiation data, and modeled geometry. Supported calculations and visualizations include solar direction, direct and diffuse radiation handling, shadow/occlusion calculations, and solar impact at global orientation/inclination, vertex, pixel (camera-render), and section levels. These shading methods are calibrated to agree across their respective representations. Other environmental features may include wind visualization, wind-rose views, environmental impact fields, contours, raster-like representations, and atmospheric/cloud visualization.

Exact outputs depend on the selected study and available data.

### Weather, climate, and scenario data

Supported workflows include EPW/TMY, CWEEDS, CLMREC, ensemble forecast and observation data, and meteorological station data. Loading, processing, and analysis workflows prepare source data for variables and visual layers. Ensemble and multi-year data can be explored across hours, days, scenarios, and years, with statistical summaries and percentile-based views where supported.

### Geographic context and time

The geographic subsystem supports latitude/longitude positioning, map projections, map tiles, station locations, zoom levels, and terrain visualization. The Earth model can display map imagery around the project location with geographic-grid and terrain context. Companion import scripts can generate contextual building massing from OpenStreetMap and Overture Maps data. Time-dependent studies can be explored by hour, day, season, annual period, forecast period, or scenario, depending on the dataset.

### Projects, commands, and exchange

Project persistence uses structured XML for supported model geometry, layers, materials, station information, time state, study configuration, analysis settings, and object properties. The command system supports interactive entry and scripts or text files for repeatable operations.

Export options include OBJ, time-series/date-series OBJ, LAS, RAD, SCR, HTML, and viewport image capture. The import and export capabilities are described in the [command reference](command/README.md).

A typical supported workflow is:

```text
BIM / CAD / Mesh / Point-Cloud Model
                  +
       Geographic Location / Site
                  ↓
          Weather / Climate Data
                  ↓
        Select Time and Scenarios
                  ↓
     Solar / Shade / Environmental Study
                  ↓
      Explore 3D Views and Study Graphs
                  ↓
             Save or Export
```

For exact commands and additional workflows, consult the [command reference](command/README.md) and [import documentation](import/README.md).

## Contribute and follow the project

SOLARCHVISION-BIM is open source. If it is useful to your work:

- **Star the repository** to help others discover it.
- **Follow the project** for updates.
- **Try it and report issues** through the [GitHub repository](https://github.com/archmoj/solarchvision_bim).
- **Explore the code and contribute** improvements, documentation, or bug reports.

When reporting an issue, include your operating system, the steps to reproduce the problem, the relevant dataset or workflow, and any error message that may help diagnose it.

See [CONTRIBUTING.md](CONTRIBUTING.md) for installing Processing, running the application from source, running the test suite, and building a distributable.

## License

The source code and documentation are released under the [GNU General Public License v2](LICENSE.md). Bundled third-party libraries (in `dist/lib/`, once built), the bundled font and imagery, and the external weather/elevation/imagery data sources used at runtime all carry their own separate terms—see [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md). See [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md) for acknowledgements and thanks.
