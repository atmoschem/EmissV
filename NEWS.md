## Version: 0.665.6.1 (2022-02-16)
- Fixed the case of 1MOL=1g (units package return an error)

## Version: 0.665.6.0 (2022-02-11)
- changing deprecated install_symbolic_unit to install_unit for units v0.8-0+
- order of emission function arguments changed
- function streetDist temporarily removed

## EmissV 0.665.5.5 (2021-06-23)
- substitution of rgdal to sf

## EmissV 0.665.5.4 (2021-06-16)
- added support for EDGAR, EDGAR_HTAPv2, GAINS, RCP, MACCITY, FFDAS, ODIAC, VULCAN and ACES inventories in read()
 
## EmissV 0.665.3.0 (2020-12-11)
- Removing the warning (due to Migration to PROJ6/GDAL3) on read() changing all "+proj=longlat +ellps=GRS80 +no_defs" tp "+proj=longlat"
- read() support 'VULCAN' dataset

## EmissV 0.665.3.0 (2020-09-28)
- New version for CRAN without hi-res dmsp image

## EmissV 0.665.2.1 (2020-04-01)
- New version for CRAN in fuction of new PROJ and GDAL
- function emission checks for negative values by defoult

## EmissV 0.665.2.0 (2020-03-25)
- New version on CRAN

## EmissV 0.665.1.1 (2020-03-19)
- read update: support for EDGAR_v432 and EDGAR_v432 added

## EmissV 0.665.1.1 (2019-12-27)
- gridInfo update: boundary of domain simulation added to output
- gridinfo: change output parameter Ylim for ylim

## EmissV 0.665.1.0 (2019-03-28)
- lineSource updates: faster, new options for grid generation and support for variables and length
- new profile data from 2018 traffic count

## EmissV 0.665.0.4 evil-power version 3 (2019-01-29)
- read support 'GEIA' format for ECCAD emissions and Scenarios 
- Fix 'MACCITY' option from read

## EmissV 0.665.0.3 evil-power version 3 (2019-01-29)
- read update
- GridInfo update
- adictional doc update

## EmissV 0.665.0.2 evil-power version 2 (2018-11-13)
- fix 'read()' for 'as_raster = F' and several inputs
- small fix on messages and examples

## EmissV 0.665.0.1 evil-power version (2018-11-13)
- added speciation dataset (pm-iag, bcom and edgar 4.3.2)
- read has speciation integated to split emissions into different species
- read has coef to merge different inputs to one specie
- new temporal profiles 'data(perfil)' for sectors from Oliver et al. (2003)
- Lost of new references

## EmissV 0.665.0 turbo version (2018-11-07)
- new speciation fuction for total emissions
- added speciation dataset (veicular-iag and mic)
- read has speciation integated

## EmissV 0.664.9 (2018-07-10)
- fix #20

## EmissV 0.664.8 (2018-06-19)
- doc updates

## EmissV 0.664.7 (2018-05-29)
- on CRAN (2018-06-19)
- added automated tests (cod-cov)
- lineSource is faster, uses sf and data.table instead of several packages
- removing: spatsts, maptools, rgeos, rgdal dependencies

## EmissV 0.664.6 (2018-05-29)
- adding fest (fast!) argument in lineSource
- lineSource use sp or sf

## EmissV 0.664.5 (2018-05-31)
- CRAN version
- funcion streetDist not included
- all external data was reduced from 28mb to less than 1mb
- examples update
- functions messages update
- links for more data sources to be used
- exemples tested, with the eception of plots and read (no extra data added)

## EmissV 0.664.3 (2018-03-14)
- plot output in 'emissions()'
- JOSS paper version

## EmissV 0.664.2 (2018-02-15)
- function 'emissions()' integred with read() via Inventory argument

## EmissV 0.664.1 (2018-02-07)
- function to 'read()' global inventories in NetCDF

## EmissV 0.664.1 (2018-01-31)
- Updates on units usage
- add profiles in data(perfil)

## EmissV 0.662 (2018-01-01)
- Updates on lineSource and exemple data added

## EmissV 0.661 (2017-12-18)
- New function names and future work

## EmissV 0.66 (2017-12-08)
-I'm not alone: Sergio Joint me and send me a sweet function
