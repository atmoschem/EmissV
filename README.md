# EmissV
[![Travis-CI Build Status](https://travis-ci.org/atmoschem/EmissV.svg?branch=master)](https://travis-ci.org/atmoschem/EmissV)

## Top-down methods to create vehicular emissions.

Methods for create veicular emissions (by a top-down approach) for air quality models like [WRF-Chem](https://ruc.noaa.gov/wrf/wrf-chem/).

functions:

- vehicles: tool to set-up vehicle data.table
- gridInfo: read grid information from a NetCDF file
- pointSource: emissions from point sources (in progress)
- plumeRise: calculate plume rise
- rasterSource: distribution of emissions by a georeferenced image
- lineSource: distribution of emissions by line vectors
- streetDist: distribution by OpenStreetnMap street (in progress)
- areaSource: distribution of emissions by region
- totalEmission: total emissions
- totalVOC: total VOCs emission
- emission: Emissions to atmospheric models

# to install

```{r eval=F}
#install.packages("devtools")
library(devtools)
install_github("atmoschem/EmissV")
library(EmissV)
```
