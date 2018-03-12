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
#' @param inventory a inventory raster from read
#' @param mm pollutant molar mass
#' @param aerosol TRUE for aerosols and FALSE (defoult) for gazes
#' @param verbose display additional information
#'
#' @note if Inventory is provided, the firsts tree arguments are not be used by the funciton.
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
#' veiculos <- vehicles(example = T)
#'
#' EmissionFactors <- emissionFactor(example = T)
#'
#' TOTAL  <- totalEmission(veiculos,EmissionFactors,pol = c("CO"),verbose = T)
#'
#' grid   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
#' shape  <- raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))
#' raster <- raster::raster(paste0(system.file("extdata", package = "EmissV"),"/sample.tiff"))
#'
#' SP     <- areaSource(shape[22,1],raster,grid,name = "SP")
#' RJ     <- areaSource(shape[17,1],raster,grid,name = "RJ")
#' MG     <- areaSource(shape[12,1],raster,grid,name = "MG")
#'
#' e_CO   <- emission(TOTAL,"CO",list(SP = SP, RJ = RJ, MG = MG),grid,mm=28)
#'}

emission <- function(total,pol,area,grid, inventory = NULL,mm = 1, aerosol = F, verbose = T){

  if(!is.null(inventory)){
    if(verbose)
      print("Using raster from inventory ... ")
    # input is g m-2 s-1
    if(class(inventory)[1]=="RasterLayer"){
      VAR_e <- rasterSource(inventory,grid,verbose = verbose)
    }else{
      VAR_e <- inventory
    }

    if(aerosol){
      ##  ug m-2 s-1
      VAR_e = units::set_units(VAR_e,"ug m-2 s-1")
    }
    else{
      ##  mol km-2 h-1
      VAR_e   =  units::set_units(VAR_e,"g km-2 h-1")
      units::install_symbolic_unit("MOL")
      MOL <- units::make_unit("MOL")                           # new unit MOL
      # install_conversion_constant("MOL","g",as.numeric(mm))  # new conversion
      # VAR_e   =  units::set_units(VAR_e,"MOL km-2 h-1")      # n funcionou
      conversao <- as_units(1/mm, "MOL g-1")
      VAR_e     <- VAR_e * conversao
    }
    return(VAR_e)
  }

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

    if(length(area) > 1){
      VAR_e  <- do.call(sp::merge,area)
    }else{
      VAR_e  <- area[[1]]
    }
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
  dx <- dx*units::as_units("km")
  # dx =  units::set_units(dx,km)

  if(aerosol){
    ##  ug m^-2 s^-1
    dx    = units::set_units(dx,"m")
    VAR_e = units::set_units(VAR_e,"ug/s")
    VAR_e = VAR_e / dx^2
  }
  else{
    #  mol km^-2 hr^-1
    units::install_symbolic_unit("MOL")
    MOL <- units::make_unit("MOL")                   # new unit MOL
    install_conversion_constant("MOL/h","g/d",mm/24) # new conversion
    VAR_e   =  units::set_units(VAR_e,"MOL/h")
    VAR_e   =  VAR_e / dx^2
  }

  return(VAR_e)
}
