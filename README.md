SOLARCHVISION-BIM is a desktop software application designed and
developed by [Mojtaba Samimi
(M.Arch)](https://www.linkedin.com/in/mojtaba-samimi-06178840) in the
[Processing](https://processing.org/) language. It is available for
`GNU/Linux`, `macOS`, and `Microsoft Windows`.

## Table of contents

-   [Clone using SSH](#clone-using-ssh)
-   [Clone using HTTPS](#clone-using-https)
-   [Requirements](#requirements)
-   [Run using Processing IDE](#run-using-processing-ide)
-   [Run using command line](#run-using-command-line)
-   [Download EPW files](#download-epw-files)
-   [Download CWEEDS files](#download-cweeds-files)
-   [Copyright and license](#copyright-and-license)
-   [User Interface](#user-interface)

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
    <img src="https://raw.githubusercontent.com/archmoj/solarchvision_bim/blob/main/doc/images/InitialView.jpg">
</p>

Please note that in above example the `Setup | 3D-model 1` option is selected. A person and a tree is also added close to the camera.

