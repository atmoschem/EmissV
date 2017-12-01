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
#'                                 "Diesel urban busses","Diesel intercity busses","Gasohol motorcycles","Flex motorcycles"))
#'
#' EmissionFactors <- as.data.frame.matrix(matrix(NA,ncol = 2,nrow = 8))
#' rownames(EmissionFactors) <- c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol","Light Duty Vehicles Flex","Diesel trucks",
#'                                "Diesel urban busses","Diesel intercity busses","Gasohol motorcycles","Flex motorcycles")
#' names(EmissionFactors) <- c("CO","HC")
#' EmissionFactors["CO"]  <- rep(0.1,8)
#' EmissionFactors["HC"]  <- rep(0.15,8)
#'
#' TOTAL <- totalEmission(veiculos,EmissionFactors,pol = c("CO","HC"),verbose = T)
#'
#'}

totalEmission <- function(v,ef,pol,verbose = T){

  TOTAL_veic <- as.matrix(v[5:ncol(v)])
  use        <- v$Use

  for(i in 1:length(pol)){
    fe_p       <- ef[,pol[i]]

    total =  TOTAL_veic[1,] * use[1] * fe_p[1]
    if(nrow(v) >= 2){
      for(j in 2:nrow(v)){
        total   = total + TOTAL_veic[j,] * use[j] * fe_p[j]
      }
    }

    if(verbose){
      print(paste("Total of",pol[i],":",sum(as.numeric(total))))
    }
    assign(pol[i],total)
  }
  TOTAL <- mget(pol)

  return(TOTAL)
}
