#' Emissions in the format for atmospheric models
#'
#' @description Combine area sources and total emissions to model output
#'
#' @format matrix of emission
#'
#' @param total list of total emission
#' @param pol pollutant name
#' @param area list of area sources or matrix with a spatial distribution
#' @param grid grid information
#' @param mm pollutant molar mass
#' @param aerosol TRUE for aerosols and FALSE (defoult) for gazes
#' @param verbose display additional information
#'
#' @note Is a good practice use the set_units(fe,your_unity), where fe is your emission factory and your_unity is usually g/km on your emission factory
#'
#' @note the list of area must be in the same order as defined in vehicles and total emission.
#'
#' @note just WRF-Chem is suported by now
#'
#' @seealso \code{\link{totalEmission}} and \code{\link{areaSource}}
#'
#' @export
#'
#' @import units raster
#'
#' @examples \dontrun{
#' # Do not run
#'
#' # DETRAN 2016 data and SP vahicle distribution
#' veiculos <- vehicles(total_v = c(27332101, 6377484, 10277988),
#'                      area_name = c("SP", "RJ", "MG"),
#'                      distribution = c( 0.4253, 0.0320, 0.3602, 0.0260,
#'                                        0.0290, 0.0008, 0.1181, 0.0086),
#'                      category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5",
#'                                    "CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                      type = c("LDV", "LDV", "LDV","TRUCKS",
#'                               "BUS","BUS","MOTO", "MOTO"),
#'                      fuel = c("E25", "E100", "FLEX","B5",
#'                               "B5","B5","E25", "FLEX"),
#'                      vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
#'                                 "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
#'                                 "Diesel intercity busses","Gasohol motorcycles","Flex motorcycles"))
#'
#' # values calculated from CETESB 2015 with
#' # weighted.mean( emissions by type and year, DETRAN frota by type and year)
#' # for Sao Paulo
#' EmissionFactors <- as.data.frame.matrix(matrix(NA,ncol = 1,nrow = 8))
#' names(EmissionFactors) <- c("CO")
#' EmissionFactors$CO <- set_units(c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),g/km)
#' rownames(EmissionFactors) <- c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
#'                                "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
#'                                "Diesel intercity busses","Gasohol motorcycles","Flex motorcycles")
#'
#' TOTAL  <- totalEmission(veiculos,EmissionFactors,pol = c("CO"),verbose = T)
#'
#' grid   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
#' shape  <- readOGR(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"),verbose = F)
#' raster <- raster(paste0(system.file("extdata", package = "EmissV"),"/sample.tiff"))
#'
#' SP     <- areaSource(shape[22,1],raster,grid,name = "SP")
#' RJ     <- areaSource(shape[17,1],raster,grid,name = "RJ")
#' MG     <- areaSource(shape[12,1],raster,grid,name = "MG")
#'
#' e_CO   <- emission(TOTAL,"CO",list(SP = SP, RJ = RJ, MG = MG),grid,mm=28)
#'}

emission <- function(total,pol,area,grid, mm = 1, aerosol = F, verbose = T){

  if(verbose)
    if(aerosol){
      print(paste("calculating emissions for ",pol," as aerosol"," ...",sep=""))
    }else{
      if(mm == 1){
        print(paste("calculating emissions for ",pol," ...",sep=""))
      }else{
        print(paste("calculating emissions for ",pol," using molar mass = ",mm," ...",sep=""))
      }
    }

  n <- which(names(total) == pol)
  if(length(n) == 0){
    print(paste(pol,"not found in total !"))
    stop()
  }

  var <- total[[n]]

  if(is.list(area)){
    # get the units (in order to work with raster)
    unidade <- total[[1]][1]/as.numeric(total[[1]][[1]])

    for(i in 1:length(area)){
      area[[i]] = area[[i]] * var[[i]]
    }
    area <- unname(area)

    VAR_e  <- do.call(sp::merge,area)

    VAR_e[is.na(VAR_e)]     <- 0

    VAR_e <- rasterSource(VAR_e,grid,verbose = F)

    # put the units (to back the unit)
    VAR_e <- VAR_e * unidade
  }
  if(is.matrix(area)){
    VAR_e               <- area * var[[1]]
    VAR_e[is.na(VAR_e)] <- 0
  }

  dx <- grid$DX
  dx <- dx*units::parse_unit("km")
  # dx =  units::set_units(dx,km)

  if(aerosol){
    ##  ug m^-2 s^-1
    # dx    = units::set_units(dx,m)
    dx    = units::set_units(dx,units::parse_unit("m"))
    VAR_e = units::set_units(VAR_e,units::parse_unit("ug/s"))
    VAR_e = VAR_e / dx^2
  }
  else{
    #  mol km^-2 hr^-1
    MOL <- units::make_unit("MOL") # new unit MOL
    install_conversion_constant("MOL","g",mm) # new conversion
    install_conversion_constant("d","h",24)   # new conversion
    VAR_e   =  units::set_units(VAR_e,units::parse_unit("g/h"))
    # VAR_e   <- units::set_units(VAR_e,MOL/h)            # brute force conversion!
    VAR_e   =  VAR_e * MOL / (mm * units::set_units(1,units::parse_unit("g"))) # <<-- bfc !
    VAR_e   =  VAR_e / dx^2
  }

  return(VAR_e)
}
