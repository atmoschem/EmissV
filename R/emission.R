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
#' @param plot TRUE for plot the final emissions
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
#' @import units raster sp
#'
#' @examples
#' veiculos <- vehicles(example = TRUE)
#'
#' EmissionFactors <- emissionFactor(example = TRUE)
#'
#' TOTAL  <- totalEmission(veiculos,EmissionFactors,pol = c("CO"),verbose = TRUE)
#'
#' grid   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
#' shape  <- raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))
#' raster <- raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff"))
#'
#' SP     <- areaSource(shape[22,1],raster,grid,name = "SP")
#' RJ     <- areaSource(shape[17,1],raster,grid,name = "RJ")
#'
#' e_CO   <- emission(TOTAL,"CO",list(SP = SP, RJ = RJ),grid,mm=28)
#'

emission <- function(total,pol,area,grid, inventory = NULL,mm = 1, aerosol = F,
                     plot = F, verbose = T){

  if(!is.null(inventory)){
    if(verbose)
      cat("Using raster from inventory ...\n")
    # input is g m-2 s-1
    if(class(inventory)[1]=="RasterLayer"){
      VAR_e <- rasterSource(inventory,grid,verbose = verbose)
    }

    if(aerosol){
      ##  ug m-2 s-1
      VAR_e = units::set_units(VAR_e,"ug m-2 s-1")
    }
    else{
      ##  mol km-2 h-1
      VAR_e   =  units::set_units(VAR_e,"g km-2 h-1")
      suppressWarnings( units::install_symbolic_unit("MOL") )
      MOL <- units::as_units("MOL")
      conversao <- as_units(1/mm, "MOL g-1")
      VAR_e     <- VAR_e * conversao
    }

    if(plot == T){
      col   <- grid$Horizontal[1]
      rol   <- grid$Horizontal[2]
      r.lat <- range(grid$Lat)
      r.lon <- range(grid$Lon)
      r     <- raster::raster(nrows=rol,ncols=col,
                              xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                              crs= "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

      raster::values(r) <- as.matrix(as.numeric(VAR_e),ncol = col,nrow = row,byrow = T)
      r                 <- raster::flip(r,2)

      a <- sp::spplot(r,scales = list(draw=TRUE),ylab="Lat",xlab="Lon",
                      main=list(label=paste("Emissions of", pol ,"[",deparse_unit(VAR_e),"]")),
                      col.regions = c("#031638","#001E48","#002756","#003062",
                                      "#003A6E","#004579","#005084","#005C8E",
                                      "#006897","#0074A1","#0081AA","#008FB3",
                                      "#009EBD","#00AFC8","#00C2D6","#00E3F0"))

      print(a)
    }
    return(VAR_e)
  }

  if(verbose){
    if(aerosol){
      cat(paste("calculating emissions for ",pol," as aerosol"," ...\n",sep=""))
    }else{
      if(mm == 1){
        cat(paste("calculating emissions for ",pol," ...\n",sep=""))
      }else{
        cat(paste("calculating emissions for ",pol," using molar mass = ",mm," ...\n",sep=""))
      }
    }
  }

  n <- which(names(total) == pol)
  if(length(n) == 0){
    return(cat(paste(pol,"not found in total !\n")))
  }

  var <- total[[n]]

  if(is.list(area)){
    # get the units (in order to work with raster)
    unidade <- total[[1]][1]/as.numeric(total[[1]][[1]])

    for(i in 1:length(area)){
      area[[i]] = area[[i]] * drop_units(var[[i]])
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
# if (utils::packageVersion("units") <= "0.5-1") {
#       units::install_symbolic_unit("MOL")
#       MOL <- units::as_units("MOL")                    # new unit MOL
#       install_conversion_constant("MOL/h","g/d",mm/24) # new conversion
# 	} else{
    remove_symbolic_unit("MOL")
	  install_conversion_constant("MOL", "g", mm) # new conversion
# }
    VAR_e   =  units::set_units(VAR_e,"MOL/h")
    VAR_e   =  VAR_e / dx^2
  }

  if(plot == T){
    col   <- grid$Horizontal[1]
    rol   <- grid$Horizontal[2]
    r.lat <- range(grid$Lat)
    r.lon <- range(grid$Lon)
    r     <- raster::raster(nrows=rol,ncols=col,
                            xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                            crs= "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

    raster::values(r) <- as.matrix(as.numeric(VAR_e),ncol = col,nrow = row,byrow = T)
    r                 <- raster::flip(r,2)

    a <- sp::spplot(r,scales = list(draw=TRUE),ylab="Lat",xlab="Lon",
                    main=list(label=paste("Emisions of", pol ,"[",deparse_unit(VAR_e),"]")),
                    col.regions = c("#031638","#001E48","#002756","#003062",
                                    "#003A6E","#004579","#005084","#005C8E",
                                    "#006897","#0074A1","#0081AA","#008FB3",
                                    "#009EBD","#00AFC8","#00C2D6","#00E3F0"))

    print(a)
  }

  return(VAR_e)
}
