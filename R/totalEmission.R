#' Calculate total emissions
#'
#' @description caculate the total emission with:
#'
#'   Emission = sum( Vehicles(n) * Km_day_use(n) * Emission_Factory(n,pollutant) (*Deterioration_Factors(n)) )
#'
#' where n is the type of the veicle
#'
#' @format Return a list with the daily total emission by territory.
#'
#' @param v dataframe with the vehicle data
#' @param ef emission factors
#' @param pol pollutant name in ef
#' @param verbose display adicional information
#'
#' @note the units (set_units("value",unit) where the recomended unit is g/d) must be used to make the ef data.frame
#'
#' @seealso \code{\link{rasterToGrid}}, \code{\link{shapeToGrid}} and \code{\link{emission}}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' # DETRAN 2016 data and SP vahicle distribution
#' veiculos <- vehicles(total_v = c(25141442, 5736428, 9147282, 6523727, 4312896),
#'                      territory_name = c("SP", "RJ", "MG", "PR", "SC"),
#'                      distribution = c( 0.4253, 0.0320, 0.3602, 0.0260,
#'                                        0.0290, 0.0008, 0.1181, 0.0086),
#'                      category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5",
#'                                    "CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                      type = c("LDV", "LDV", "LDV","TRUCKS",
#'                               "BUS","BUS","MOTO", "MOTO"),
#'                      fuel = c("E25", "E100", "FLEX","B5",
#'                               "B5","B5","E25", "FLEX"),
#'                      vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
#'                                "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
#'                                "Diesel intercity busses","Gasohol motorcycles","Flex motorcycles"))
#'
#' EmissionFactors <- as.data.frame.matrix(matrix(NA,ncol = 2,nrow = 8))
#' rownames(EmissionFactors) <- c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
#'                                "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
#'                                "Diesel intercity busses","Gasohol motorcycles","Flex motorcycles")
#' names(EmissionFactors) <- c("CO","PM")
#'
#' # values calculated from CETESB 2015 with
#' # weighted.mean( emissions by type and year, DETRAN frota by type and year)
#' # for Sao Paulo
#' EmissionFactors$CO <- set_units(c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),g/km)
#' EmissionFactors$PM <- set_units(c(0.0013,0.0,0.0010,0.0612,0.1052,0.1693,0.0,0.0),g/km)
#'
#' TOTAL <- totalEmission(veiculos,EmissionFactors,pol = c("CO","PM"))
#'
#'}

totalEmission <- function(v,ef,pol,verbose = T){

  TOTAL_veic <- as.matrix(v[5:ncol(v)])
  use        <- v$Use
  ef_names   <- names(ef)

  for(i in 1:length(pol)){
    if(!is.element(pol[i], ef_names)){
      print(paste0(pol[i]," not found in emission factor!"))
      print("The emissions factors contains:")
      print(ef_names)
      total = units::set_units(NA * TOTAL_veic[1,],g/d)
      assign(pol[i],total)
    }
    else{
      fe_p       <- ef[,pol[i]]

      total =  TOTAL_veic[1,] * use[1] * fe_p[1]
      if(nrow(v) >= 2){
        for(j in 2:nrow(v)){
          total   = total + TOTAL_veic[j,] * use[j] * fe_p[j]
        }
      }

      if(verbose){
        if(class(total) == "units"){
          y <- units::make_unit("y")
          units::install_conversion_constant("g/d", "t/y", 365/1000000 )
          total_t_y <- units::set_units(total,with(units::ud_units, t/y))
          print(paste("Total of",pol[i],":",sum(total_t_y),units::deparse_unit(total_t_y)))
        }else
          print(paste("Total of",pol[i],":",sum(total)))
      }
      assign(pol[i],total)
    }
  }
  TOTAL <- mget(pol)

  return(TOTAL)
}
