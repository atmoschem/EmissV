#' Emissions to atmospheric models
#'
#' @description Combine territorial data and total emissions to model output
#'
#' @format matrix of emission
#'
#' @param total list of total emission
#' @param pol pollutant name
#' @param territorys list of territory outputs
#' @param grid grid information
#' @param mm pollutant molar mass
#' @param aerosol TRUE for aerosols and FALSE (defoult) for gazes
#' @param verbose display adicional information
#'
#' @note Is a god practice use the set_units(fe,your_unity), where fe is your emission factory and your_unity is usually g/km on your emission factory
#'
#' @note the list of territorys must be in the same order as defined in vehicles and total emission.
#'
#' @seealso \code{\link{totalEmission}} and \code{\link{territory}}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#' veiculos <- vehicles(total_v = c(25141442, 5736428, 9147282, 6523727, 4312896),
#'                      territory_name = c("SP", "RJ", "MG", "PR", "SC"),
#'                      distribution = c( 0.4253, 0.0320, 0.3602, 0.0260, 0.0290, 0.0008, 0.1181, 0.0086),
#'                      category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5","CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                      type = c("LDV", "LDV", "LDV","TRUCKS","BUS","BUS","MOTO", "MOTO"),
#'                      fuel = c("E25", "E100", "FLEX","B5","B5","B5","E25", "FLEX"),
#'                      vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol","Light Duty Vehicles Flex","Diesel trucks",
#'                                 "Diesel urban busses","Diesel intercity busses","Gasohol motorcycles","Flex motorcycles"))
#'
#' EmissionFactors <- as.data.frame.matrix(matrix(NA,ncol = 1,nrow = 8))
#' rownames(EmissionFactors) <- c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol","Light Duty Vehicles Flex","Diesel trucks",
#'                                "Diesel urban busses","Diesel intercity busses","Gasohol motorcycles","Flex motorcycles")
#' names(EmissionFactors) <- c("CO")
#' EmissionFactors["CO"]  <- set_units(rep(0.1,8),g/km)
#'
#' TOTAL  <- totalEmission(veiculos,EmissionFactors,pol = c("CO"),verbose = T)
#'
#' grid   <- newGrid(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' shape  <- st_read(paste(system.file("extdata", package = "EmissV"),"/BR.shp",sep=""),verbose = F)
#' raster <- raster(paste(system.file("extdata", package = "EmissV"),"/sample.tiff",sep=""))
#'
#' SP     <- territory(shape[22,1],raster,grid)
#' RJ     <- territory(shape[17,1],raster,grid)
#'
#' sudoeste <- list(SP = SP, RJ = RJ)
#'
#' e_CO   <- emission(TOTAL,"CO",sudoeste,grid)
#'}

emission <- function(total,pol,territorys,grid, mm = 1, aerosol = F, verbose = T){
  MOL <- make_unit("MOL")
  install_conversion_constant("g", "MOL", 1/mm)

  if(verbose)
    print(paste("calculating emissions for ",pol," ...",sep=""))

  n <- which(names(total) == pol)
  if(length(n) == 0){
    print(paste(pol,"not found in total !"))
    stop()
  }
  var <- unlist(total[n])

  for(i in 1:length(territorys)){
    territorys[[i]] = territorys[[i]] * var[i]
  }
  territorys <- unname(territorys)
  VAR_e  <- do.call(sp::merge,territorys)

  VAR_e[is.na(VAR_e)]     <- 0

  dx <- grid$DX
  dx = set_units(dx,km)

  if(aerosol){
    ##  ug m^-2 s^-1
    dx    = set_units(dx,m)
    VAR_e = set_units(VAR_e,ug)
    VAR_e = VAR_e / ( dx^2 * 60*60)
  }
  else{
    #  mol km^-2 hr^-1
    VAR_e   =  VAR_e / (mm * dx^2) # mm = massa molar do poluente
  }

  return(rasterToGrid(VAR_e,grid,verbose = F))
}
