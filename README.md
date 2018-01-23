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

## Packages needed
- [raster](http://cran.r-project.org/package=raster)
- [sp](https://github.com/edzer/sp/)
- [ncdf4](http://cran.r-project.org/package=ncdf4)
- [units](https://github.com/edzer/units/)
- [data.table](https://cran.r-project.org/package=data.table)
- [sf](https://github.com/r-spatial/sf)
- [spatstat](https://cran.r-project.org/package=spatstat)
- [maptools](https://cran.r-project.org/package=maptools)

The packages [spatsts](https://cran.r-project.org/package=spatstat), [maptools](https://cran.r-project.org/package=maptools) and [sp](https://github.com/edzer/sp/) will be removed son.

## Libraries for Ubuntu
before install in Ubuntu system, install the following libraries:

```bash
  sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable --yes
  sudo apt-get --yes --force-yes update -qq
  # units/udunits2 dependency:
  sudo apt-get install --yes libudunits2-dev
  # sf dependencies:
  sudo apt-get install --yes libgdal-dev libgeos-dev libproj-dev
  # netcdf dependenciy:
  sudo apt-get install --yes libnetcdf-dev netcdf-bin
```


## Libraries for Fedora

```bash
  sudo dnf update
  sudo yum install gdal-devel proj-devel proj-epsg proj-nad geos-devel udunits2-devel
  sudo yum install netcdf-devel
```

# to install

```{r eval=F}
#install.packages("devtools")
library(devtools)
devtools::install_github("atmoschem/EmissV")
library(EmissV)
```
