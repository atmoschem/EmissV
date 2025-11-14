# Tool to set-up vehicle data table

Return a data frame with 4 columns (vehicle category, type, fuel and
avarage kilometers driven) and an aditional column with the number of
vehicles for each interest area (cityes, states, countries, etc).

Average daily kilometres driven are defined by vehicle type:

\- LDV (Light duty Vehicles) 41 km / day

\- TRUCKS (Trucks) 110 km / day

\- BUS (Busses) 165 km / day

\- MOTO (motorcycles and other vehicles) 140 km / day

The number of vehicles are defined by the distribution of vehicles by
vehicle classs and the total number of vehicles by area.

## Usage

``` r
vehicles(
  total_v,
  area_name = names(total_v),
  distribution,
  type,
  category = NA,
  fuel = NA,
  vnames = NA,
  example = FALSE,
  verbose = TRUE
)
```

## Arguments

- total_v:

  total of vehicles by area (area length)

- area_name:

  area names (area length)

- distribution:

  distribution of vehicles by vehicle class

- type:

  type of vehicle by vehicle class (distribution length)

- category:

  category name (distribution length / NA)

- fuel:

  fuel type by vehicle class (distribution length / NA)

- vnames:

  name of each vehicle class (distribution length / NA)

- example:

  a simple example

- verbose:

  display additional information

## Value

a fleet distribution data.frame for totalEmission function

## Note

total_v and area_name must have the same length.

distribution, type, category (if used), fuel (if used) and vnames (if
used) must have the same length.

## See also

[`areaSource`](https://atmoschem.github.io/EmissV/reference/areaSource.md)
and
[`totalEmission`](https://atmoschem.github.io/EmissV/reference/totalEmission.md)

## Examples

``` r
fleet <- vehicles(example = TRUE)
#> using a example of vehicles (DETRAN 2016 data and SP vahicle distribution):
#>                              Category   Type Fuel        Use       SP      RJ
#> Light Duty Vehicles Gasohol   LDV_E25    LDV  E25  41 [km/d] 11624342 2712343
#> Light Duty Vehicles Ethanol  LDV_E100    LDV E100  41 [km/d]   874627  204079
#> Light Duty Vehicles Flex        LDV_F    LDV FLEX  41 [km/d]  9845022 2297169
#> Diesel Trucks               TRUCKS_B5 TRUCKS   B5 110 [km/d]   710634  165814
#> Diesel Urban Busses           CBUS_B5    BUS   B5 165 [km/d]   792630  184947
#> Diesel Intercity Busses       MBUS_B5    BUS   B5 165 [km/d]    21865    5101
#> Gasohol Motorcycles          MOTO_E25   MOTO  E25 140 [km/d]  3227921  753180
#> Flex Motorcycles               MOTO_F   MOTO FLEX 140 [km/d]   235056   54846
#>                                  MG      PR      SC
#> Light Duty Vehicles Gasohol 4371228 3036828 2029599
#> Light Duty Vehicles Ethanol  328895  228494  152709
#> Light Duty Vehicles Flex    3702131 2571986 1718932
#> Diesel Trucks                267227  185651  124076
#> Diesel Urban Busses          298061  207072  138392
#> Diesel Intercity Busses        8222    5712    3817
#> Gasohol Motorcycles         1213830  843285  563592
#> Flex Motorcycles              88390   61407   41040

# or the code bellow for the same result
# DETRAN 2016 data for total number of vehicles for 5 Brazilian states (Sao Paulo,
# Rio de Janeiro, Minas Gerais, Parana and Santa Catarina)
# vahicle distribution of Sao Paulo

fleet <- vehicles(total_v = c(27332101, 6377484, 10277988, 7140439, 4772160),
                  area_name = c("SP", "RJ", "MG", "PR", "SC"),
                  distribution = c( 0.4253, 0.0320, 0.3602, 0.0260,
                                   0.0290, 0.0008, 0.1181, 0.0086),
                  category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5",
                                "CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
                  type = c("LDV", "LDV", "LDV","TRUCKS",
                          "BUS","BUS","MOTO", "MOTO"),
                  fuel = c("E25", "E100", "FLEX","B5",
                           "B5","B5","E25", "FLEX"),
                  vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
                             "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
                             "Diesel intercity busses","Gasohol motorcycles",
                             "Flex motorcycles"))
#> vehicles:
#>                              Category   Type Fuel        Use       SP      RJ
#> Light duty Vehicles Gasohol   LDV_E25    LDV  E25  41 [km/d] 11624342 2712343
#> Light Duty Vehicles Ethanol  LDV_E100    LDV E100  41 [km/d]   874627  204079
#> Light Duty Vehicles Flex        LDV_F    LDV FLEX  41 [km/d]  9845022 2297169
#> Diesel trucks               TRUCKS_B5 TRUCKS   B5 110 [km/d]   710634  165814
#> Diesel urban busses           CBUS_B5    BUS   B5 165 [km/d]   792630  184947
#> Diesel intercity busses       MBUS_B5    BUS   B5 165 [km/d]    21865    5101
#> Gasohol motorcycles          MOTO_E25   MOTO  E25 140 [km/d]  3227921  753180
#> Flex motorcycles               MOTO_F   MOTO FLEX 140 [km/d]   235056   54846
#>                                  MG      PR      SC
#> Light duty Vehicles Gasohol 4371228 3036828 2029599
#> Light Duty Vehicles Ethanol  328895  228494  152709
#> Light Duty Vehicles Flex    3702131 2571986 1718932
#> Diesel trucks                267227  185651  124076
#> Diesel urban busses          298061  207072  138392
#> Diesel intercity busses        8222    5712    3817
#> Gasohol motorcycles         1213830  843285  563592
#> Flex motorcycles              88390   61407   41040
```
