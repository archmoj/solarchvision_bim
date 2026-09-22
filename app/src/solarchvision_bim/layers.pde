LAYER LAYER_ceilingsky = new LAYER(
  0.1,
  0,
  0,
  "m",
  "Ceiling height",
  "Hauteur sous plafond",
  ""
);

LAYER LAYER_cloudcover = new LAYER(
  10.0,
  0,
  0,
  "tenth",
  "Total Cloud Cover",
  "Couvert nuageux total",
  "TCDC"
);

LAYER LAYER_winddir = new LAYER(
  100.0 / 360.0,
  0,
  0,
  "°",
  "Surface Wind Direction",
  "Direction du vent à la surface",
  "WDIR-SFC"
);

LAYER LAYER_windspd = new LAYER(
  2.5,
  0,
  0,
  "km/h",
  "Surface Wind Speed",
  "Vitesse du vent à la surface",
  "WIND-SFC"
);

LAYER LAYER_pressure = new LAYER(
  2.0,
  -1000,
  1,
  "hPa",
  "Mean Sea level Pressure",
  "Pression moyenne au niveau de la mer",
  "MSLP"
);

LAYER LAYER_drybulb = new LAYER(
  2.5,
  0,
  1,
  "°C",
  "Surface Air Temperature",
  "Température de l'air à la surface",
  "TMP-SFC"
);

LAYER LAYER_relhum = new LAYER(
  1.0,
  0,
  0,
  "%",
  "Surface Relative Humidity",
  "Humidité relative à la surface",
  "RELH-SFC"
);

LAYER LAYER_dirnorrad = new LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Direct normal radiation",
  "Rayonnement direct normal",
  ""
);

LAYER LAYER_difhorrad = new LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Diffuse horizontal radiation",
  "Diffus rayonnement horizontal",
  ""
);

LAYER LAYER_glohorrad = new LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Global horizontal radiation",
  "Rayonnement global horizontal",
  ""
);

LAYER LAYER_direffect = new LAYER(
  0.0025,
  0,
  1,
  "W°C/m²",
  "Direct normal effect <18°C<",
  "Effet direct normal <18°C<",
  ""
);

LAYER LAYER_difeffect = new LAYER(
  0.0025,
  0,
  1,
  "W°C/m²",
  "Diffuse normal effect <18°C<",
  "Effet diffus normal <18°C<",
  ""
);

LAYER LAYER_precipitation = new LAYER(
  4.0,
  0,
  0,
  "mm",
  "Surface Accumulated Precipitation",
  "Précipitations accumulées à la surface",
  "APCP-SFC"
);

LAYER LAYER_developed = new LAYER(
  1,
  0,
  0,
  "",
  "",
  "",
  ""
);

LAYER[] allLayers = {
  LAYER_ceilingsky,
  LAYER_cloudcover,
  LAYER_winddir,
  LAYER_windspd,
  LAYER_pressure,
  LAYER_drybulb,
  LAYER_relhum,
  LAYER_dirnorrad,
  LAYER_difhorrad,
  LAYER_glohorrad,
  LAYER_direffect,
  LAYER_difeffect,
  LAYER_precipitation,
  LAYER_developed
};

int DevelopLayer_id = 0;
int CurrentLayer_id = 0;
String CurrentLayer_unit = allLayers[0].unit;
String CurrentLayer_name = allLayers[0].name;
String[] CurrentLayer_descriptions = {
  allLayers[0].descriptions[Language_EN],
  allLayers[0].descriptions[Language_FR]
};

void changeCurrentLayerTo (int new_id) {

  STUDY.V_scale = allLayers[new_id].V_scale;
  STUDY.V_offset = allLayers[new_id].V_offset;
  STUDY.V_belowLine = allLayers[new_id].V_belowLine;

  DevelopLayer_id = new_id;
  CurrentLayer_id = new_id;

  CurrentLayer_unit = allLayers[new_id].unit;
  CurrentLayer_name = allLayers[new_id].name;
  CurrentLayer_descriptions[Language_EN] = allLayers[new_id].descriptions[Language_EN];
  CurrentLayer_descriptions[Language_FR] = allLayers[new_id].descriptions[Language_FR];

}
