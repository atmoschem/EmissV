#' Calculate total emissions by territory (city, state, country, etc) by pollutant
#'
#' @description caculate the total emission with:
#'
#'   Emission = sum( No_vehicles(n) * Km_day_use(n) * Emission_Factory(n,pollutant) (*Deterioration_Factors(n)) )
#'
#' where n is the type of the veicle
#'
#' @format Return the total emission (or a list) with the total emission (by day)
#'
#' @param v dataframe with the vehicle data
#' @param ef emission factors
#' @param pol pollutant name in ef
#' @param verbose display adicional information
#'
#' @note its works with some wrf files (inicial condictions and emission) for now.
#'
#' @seealso \code{\link{territory}}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' veiculos <- vehicles(total_v = c(25141442, 5736428, 9147282, 6523727, 4312896),
#'                      territory_name = c("SP", "RJ", "MG", "PR", "SC"),
#'                      distribution = c( 0.4253, 0.0320, 0.3602, 0.0260, 0.0290, 0.0008, 0.1181, 0.0086),
#'                      category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5","CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                      type = c("LDV", "LDV", "LDV","TRUCKS","BUS","BUS","MOTO", "MOTO"),
#'                      fuel = c("E25", "E100", "FLEX","B5","B5","B5","E25", "FLEX"),
#'                      vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol","Light Duty Vehicles Flex","Diesel trucks",
#'                                 "Diesel urban busses","Diesel intercity busses","Gasohol motorcycles","Flex motorcycles")
#'
#'
#'}

totalEmission <- function(v,ef,pol,verbose = T){

  TOTAL_veic <- as.matrix(v[5:ncol(v)])
  use        <- v$Use

  for(i in 1:length(pol)){
    fe_p       <- ef[,pol[i]]

    total =  TOTAL_veic[1,] * use[1] * fe_p[1]
           + TOTAL_veic[2,] * use[2] * fe_p[2]
           + TOTAL_veic[3,] * use[3] * fe_p[3]
           + TOTAL_veic[4,] * use[4] * fe_p[4]
           + TOTAL_veic[5,] * use[5] * fe_p[5]
           + TOTAL_veic[6,] * use[6] * fe_p[6]
           + TOTAL_veic[7,] * use[7] * fe_p[7]
           + TOTAL_veic[8,] * use[8] * fe_p[8]

    if(verbose){
      print(paste("Total of",pol[i],":",sum(as.numeric(total))))
    }
    assign(pol[i],total)
  }
  TOTAL <- mget(pol)

  return(TOTAL)
}
