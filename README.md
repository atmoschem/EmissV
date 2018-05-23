# EmissV
[![Travis-CI Build Status](https://travis-ci.org/atmoschem/EmissV.svg?branch=master)](https://travis-ci.org/atmoschem/EmissV) [![Build status](https://ci.appveyor.com/api/projects/status/guuaaklaw6uyn4lj?svg=true)](https://ci.appveyor.com/project/Schuch666/emissv)

## Top-down methods to create vehicular emissions.

Methods to create vehicular and other emissions by a top-down approach for use in numeric air quality models like [WRF-Chem](https://ruc.noaa.gov/wrf/wrf-chem/).

![Emissions using nocturnal lights](https://raw.githubusercontent.com/atmoschem/EmissV/master/example.jpg)

functions:

- read: read global inventories in netcdf format
- vehicles: tool to set-up vehicle data.table
- emissionFactor: tool to set-up emission factors data.table
- gridInfo: read grid information from a NetCDF file
- pointSource: emissions from point sources
- plumeRise: calculate plume rise (in progress)
- rasterSource: distribution of emissions by a georeferenced image
- lineSource: distribution of emissions by line vectors
- streetDist: distribution by OpenStreetnMap street (in progress)
- areaSource: distribution of emissions by region
- totalEmission: total emissions
- totalVOC: total VOCs emission
- emission: Emissions to atmospheric models

datasets:

- Perfil: vehicle counting profile for vehicular activity
- Sample of an image of persistent lights of the Defense Meteorological Satellite Program (DMSP)
- CETESB 2015 emission factors as ```emissionFactor(example=T)```
- DETRAN 2016 data and SP vahicle distribution as ```vehicles(example=T)```
- Shapefiles for Brasil states

## Packages needed

EmissV uses functions from this packages and will install automatically.

- [raster](http://cran.r-project.org/package=raster)
- [sp](https://github.com/edzer/sp/)
- [ncdf4](http://cran.r-project.org/package=ncdf4)
- [units](https://github.com/edzer/units/)
- [data.table](https://cran.r-project.org/package=data.table)
- [sf](https://github.com/r-spatial/sf)
- [spatstat](https://cran.r-project.org/package=spatstat)
- [maptools](https://cran.r-project.org/package=maptools)

The dependency of the packages [spatsts](https://cran.r-project.org/package=spatstat), [maptools](https://cran.r-project.org/package=maptools) and [sp](https://github.com/edzer/sp/) will be removed son.

## Libraries for Ubuntu
The following libraries are required for installation on ubuntu:

```bash
  sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable --yes
  sudo apt-get --yes --force-yes update -qq
  # units/udunits2 dependency:
  sudo apt-get install --yes libudunits2-dev
  # sf dependencies (without libudunits2-dev):
  sudo apt-get install --yes libgdal-dev libgeos-dev libproj-dev
  # netcdf dependencies:
  sudo apt-get install --yes libnetcdf-dev netcdf-bin
```


## Libraries for Fedora

```bash
  sudo dnf update
  sudo yum install gdal-devel proj-devel proj-epsg proj-nad geos-devel udunits2-devel
  sudo yum install netcdf-devel
```

## To install

```r
# install.packages("devtools")
devtools::install_github("atmoschem/EmissV")
library(EmissV)
```
## About this package

EmissV is a tool developed during Daniel Schuch's post-doctorate at the at the Department of Atmospheric Sciences, University of São Paulo ([IAG-USP](http://www.iag.usp.br/atmosfericas/)) supervised by professor Edmilson Dias de Freitas.

## Licence notes

This package is provided "as is", without warranty of any kind. In no event shall the authors be liable for any claim, damages or other liability, arising from, out of or in connection with the software, for more details see [Licence file](https://github.com/atmoschem/EmissV/blob/master/LICENSE).
