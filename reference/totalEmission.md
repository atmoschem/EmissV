# Calculate total emissions

Caculate the total emission with:

Emission(pollutant) = sum( Vehicles(n) \* Km_day_use(n) \*
Emission_Factor(n,pollutant) )

where n is the type of the veicle

## Usage

``` r
totalEmission(v, ef, pol, verbose = TRUE)
```

## Arguments

- v:

  dataframe with the vehicle data

- ef:

  emission factor

- pol:

  pollutant name in ef

- verbose:

  display additional information

## Value

Return a list with the daily total emission by interest area (cityes,
states, countries, etc).

## Note

the units (set_units("value",unit) where the recomended unit is g/d)
must be used to make the ef data.frame

## See also

[`rasterSource`](https://atmoschem.github.io/EmissV/reference/rasterSource.md),
[`lineSource`](https://atmoschem.github.io/EmissV/reference/lineSource.md)
and
[`emission`](https://atmoschem.github.io/EmissV/reference/emission.md)

## Examples

``` r
veic <- vehicles(example = TRUE)
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

EmissionFactors <- emissionFactor(example = TRUE)
#> using a example emission factor (values calculated from CETESB 2015):
#>                                       CO            PM
#> Light Duty Vehicles Gasohol  1.75 [g/km] 0.0013 [g/km]
#> Light Duty Vehicles Ethanol 10.04 [g/km] 0.0000 [g/km]
#> Light Duty Vehicles Flex     0.39 [g/km] 0.0010 [g/km]
#> Diesel Trucks                0.45 [g/km] 0.0612 [g/km]
#> Diesel Urban Busses          0.77 [g/km] 0.1052 [g/km]
#> Diesel Intercity Busses      1.48 [g/km] 0.1693 [g/km]
#> Gasohol Motorcycles          1.61 [g/km] 0.0000 [g/km]
#> Flex Motorcycles             0.75 [g/km] 0.0000 [g/km]

TOTAL <- totalEmission(veic,EmissionFactors,pol = c("CO","PM"))
#> Total of CO : 1676996.43578795 t year-1 
#> Total of PM : 15071.8124616163 t year-1 
```
