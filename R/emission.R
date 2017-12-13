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
#' veiculos <- vehicles(total_v = c(25141442, 5736428, 9147282),
#'                      territory_name = c("SP", "RJ", "MG"),
#'                      distribution = c( 0.4253, 0.0320, 0.3602, 0.0260,
#'                                        0.0290, 0.0008, 0.1181, 0.0086),
#'                      category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5",
#'                                    "CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                      type = c("LDV", "LDV", "LDV","TRUCKS",
#'                               "BUS","BUS","MOTO", "MOTO"),
#'                      fuel = c("E25", "E100", "FLEX","B5",
#'                               "B5","B5","E25", "FLEX"))
#'
#' EmissionFactors <- as.data.frame.matrix(matrix(NA,ncol = 1,nrow = 8))
#' names(EmissionFactors) <- c("CO")
#' EmissionFactors["CO"]  <- set_units(rep(0.1,8),g/km)
#'
#' TOTAL  <- totalEmission(veiculos,EmissionFactors,pol = c("CO"),verbose = T)
#'
#' grid   <- newGrid(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
#' shape  <- readOGR(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"),verbose = F)
#' raster <- raster(paste0(system.file("extdata", package = "EmissV"),"/sample.tiff"))
#'
#' SP     <- territory(shape[22,1],raster,grid)
#' RJ     <- territory(shape[17,1],raster,grid)
#' MG     <- territory(shape[12,1],raster,grid)
#'
#' mm_CO  <- 28 # Molar mass of CO
#'
#' e_CO   <- emission(TOTAL,"CO",list(SP = SP, RJ = RJ, MG = MG),grid,mm_CO)
#'}

emission <- function(total,pol,territorys,grid, mm = 1, aerosol = F, verbose = T){
  MOL <- units::make_unit("MOL")
  units::install_conversion_constant("g", "MOL", 1/mm)

  if(verbose)
    if(aerosol){
      print(paste("calculating emissions for ",pol," as aerosol"," ...",sep=""))
    }else{
      print(paste("calculating emissions for ",pol,", using molar mass = ",mm," ...",sep=""))
    }

  n <- which(names(total) == pol)
  if(length(n) == 0){
    print(paste(pol,"not found in total !"))
    stop()
  }
  var     <- unlist(total[n])
  unidade <- ????

  for(i in 1:length(territorys)){
    territorys[[i]] = territorys[[i]] * var[i]
  }
  territorys <- unname(territorys)
  VAR_e  <- do.call(sp::merge,territorys)

  VAR_e[is.na(VAR_e)]     <- 0

  dx <- grid$DX
  dx =  units::set_units(dx,km)

  VAR_e_test <- rasterToGrid(VAR_e,grid,verbose = F)

  # if(aerosol){
  #   ##  ug m^-2 s^-1
  #   dx    = units::set_units(dx,m)
  #   VAR_e = units::set_units(VAR_e,ug)
  #   VAR_e = VAR_e / ( dx^2 * 60*60)
  # }
  # else{
  #   #  mol km^-2 hr^-1
  #   VAR_e   =  VAR_e / (mm * dx^2) # mm = massa molar do poluente
  # }

  VAR_e   =  VAR_e / (mm * dx^2) # mm = massa molar do poluente

  return(VAR_e)
}
