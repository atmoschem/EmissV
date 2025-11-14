# Speciation of emissions in different compounds

Distribute the total mass of estimated emissions into model species.

## Usage

``` r
speciation(total, spec = NULL, verbose = TRUE)
```

## Arguments

- total:

  emissions from totalEmissions

- spec:

  numeric speciation vector of species

- verbose:

  display additional information

## Value

Return a list with the daily total emission by interest area (cityes,
states, countries, etc).

## See also

[`species`](https://atmoschem.github.io/EmissV/reference/species.md)

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
TOTAL <- totalEmission(veic,EmissionFactors,pol = "PM")
#> Total of PM : 15071.8124616163 t year-1 
pm_iag <- c(E_PM25I = 0.0509200,
            E_PM25J = 0.1527600,
            E_ECI   = 0.1196620,
            E_ECJ   = 0.0076380,
            E_ORGI  = 0.0534660,
            E_ORGJ  = 0.2279340,
            E_SO4I  = 0.0063784,
            E_SO4J  = 0.0405216,
            E_NO3J  = 0.0024656,
            E_NO3I  = 0.0082544,
            E_PM10  = 0.3300000)
PM <- speciation(TOTAL,pm_iag)
```
