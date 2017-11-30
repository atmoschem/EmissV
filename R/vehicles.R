#' Vehicles by territory
#'
#' @description return a data.frame with veicle information. types argument define the diary use:
#'
#' - LDV (Light duty Vehicles) 41 km / day
#'
#' - TRUCKS (Trucks) 110 km / day
#'
#' - BUS (Busses) 165 km / day
#'
#' - MOTO (motorcycles and other vehicles) 140 km / day
#'
#' @note total_v and territory_name must have the same length.
#'
#' @note distribution, category, type, fuel and vnames (if used) must have the same length.
#'
#' @format data.frame with lines by vehicle category and columns for category, type, Fuel, use and a adictional column for eath territory.
#'
#' @param total_v total of vehicles by territory (territory length)
#' @param territory_name territory names (territory length)
#' @param distribution distribution of vehicles by category (category length)
#' @param category category (category length)
#' @param type type of vehicle by category (category length)
#' @param fuel fuel type by category (category length)
#' @param vnames name of eath categoy (category length / NA)
#' @param verbose display adicional information
#'
#' @seealso \code{\link{territory}} and  \code{\link{totalEmission}}
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
#'                      )
#'
#'}

vehicles <- function(total_v,territory_name,distribution,category,type,fuel,vnames = NA,verbose = T)
  {

  frota <- data.frame(
    Estados = territory_name,
    Vehiculos = total_v
  )

  Veh_fuel <- data.frame(
    x =  distribution / sum(distribution),
    Category = category,
    Type = type,
    Fuel = fuel
  )

  veh_estado <- as.data.frame(as.matrix(Veh_fuel$x) %*% matrix(unlist(frota$Vehiculos),nrow = 1))
  names(veh_estado) <- frota$Estados
  as.data.frame(veh_estado)

  for (i  in 1:ncol(veh_estado) ) {
    veh_estado[,i] <- as.numeric(veh_estado[,i])
  }

  Veh_fuel$Use <- ifelse(
    veh$Type == "LDV", 41,
    ifelse(
      veh$Type == "TRUCKS", 110,
      ifelse(
        veh$Type == "BUS", 165,
        140
      )
    )
  )

  veh <- cbind(Veh_fuel[2:5], veh_estado)

  if(!is.na(vnames[1])){
    row.names(veh) <- vnames
  }
  if(verbose){
    print(veh)
  }
  return(veh)
}
