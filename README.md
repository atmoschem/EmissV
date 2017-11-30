# EmissV

## Top-down methods to create vehicular emissions.

Collection of methods for create veicular emissions to air quality models like [WRF-Chem](https://ruc.noaa.gov/wrf/wrf-chem/).

functions:

- newGrid: Create a grid set-up based on a NetCDF file
- rasterToGrid: Transform a raster into a grinded outpu
- shapeToGrid: Transform a shape into a grinded output
- territory: Process georeferenced and geopolitical information

# to install

devtools::install_github("Schuch666/EmissV")

library(EmissV)
