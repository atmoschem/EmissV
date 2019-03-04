#' Read NetCDF data from global inventaries
#'
#' @description Read data from global inventories, can read several files and merge into one
#' emission and/or split into several species (speciation process)
#'
#' @return Matrix or raster
#'
#' @param file file name or names (variables are summed)
#' @param coef coef to merge different sources (file) into one emission
#' @param spec numeric speciation vector to split emission into different species
#' @param version inventory name 'EDGAR', 'MACCITY' or 'GAINS'
#' @param month the desired month of the inventary (MACCITY)
#' @param year scenario index (GAINS)
#' @param categories considered categories (MACCITY, GAINS variable names), empty for all
#' @param as_raster return a raster (defoult) or matrix (with units)
#' @param verbose display additional information
#'
#' @note for 'GAINS' version, please use flux (kg m-2 s-1) NetCDF file from https://eccad3.sedoo.fr
#'
#' @seealso \code{\link{rasterSource}} and \code{\link{gridInfo}}
#'
#' @export
#'
#' @import raster
#' @import ncdf4
#' @importFrom units as_units set_units
#'
#' @seealso \code{\link{species}}
#'
#' @source Read abbout EDGAR at http://edgar.jrc.ec.europa.eu and MACCITY at
#' http://accent.aero.jussieu.fr/MACC_metadata.php
#'
#' @references
#' Janssens-Maenhout, G., Dentener, F., Van Aardenne, J., Monni, S., Pagliari, V., Orlandini,
#' L., ... & Wankmüller, R. (2012). EDGAR-HTAP: a harmonized gridded air pollution emission dataset
#' based on national inventories. European Commission Joint Research Centre Institute for
#' Environment and Sustainability. JRC 68434 UR 25229 EUR 25229, ISBN 978-92-79-23123-0.
#'
#' Lamarque, J.-F., Bond, T. C., Eyring, V., Granier, C., Heil, A., Klimont, Z., Lee, D., Liousse,
#' C., Mieville, A., Owen, B., Schultz, M. G., Shindell, D., Smith, S. J., Stehfest, E.,
#' Van Aardenne, J., Cooper, O. R., Kainuma, M., Mahowald, N., McConnell, J. R., Naik, V.,
#' Riahi, K., and van Vuuren, D. P.: Historical (1850-2000) gridded anthropogenic and biomass
#' burning emissions of reactive gases and aerosols: methodology and application,
#' Atmos. Chem. Phys., 10, 7017-7039, doi:10.5194/acp-10-7017-2010, 2010.
#'
#' Z Klimont, S. J. Smith and J Cofala The last decade of global anthropogenic sulfur dioxide:
#' 2000–2011 emissions Environmental Research Letters 8, 014003, 2013
#'
#' @examples \donttest{
#' d1     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' d2     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' print("download and untar EDGAR data from:")
#' print("http://edgar.jrc.ec.europa.eu/gallery.php?release=v431_v2&substance=NOx&sector=TRO")
#' nox    <- read("v431_v2_REFERENCE_NOx_2010_10_TRO.0.1x0.1.nc")
#' sp::spplot(nox, scales = list(draw=TRUE), xlab="Lat", ylab="Lon",main="NOx emissions from EDGAR")
#' nox_d1 <- rasterSource(nox,d1)
#' nox_d2 <- rasterSource(nox,d2)
#' image(nox_d1, main = "NOx emissions from transport from EDGAR 3.4.1 for d1")
#' image(nox_d2, main = "NOx emissions from transport from EDGAR 3.4.1 for d2")
#'}

read <- function(file = file.choose(), coef = rep(1,length(file)), spec = NULL,
                 version = "EDGAR", month = 1, year = 1, categories,
                 as_raster = T, verbose = T){

  if(is.list(coef))
    coef <- as.numeric(as.character(unlist(coef))) #nocov
  if(is.list(spec))
    spec <- as.numeric(as.character(unlist(spec))) #nocov

  if(version == "GAINS"){                          # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('date',         name, invert = T, value = T)
    name <- grep('crs',          name, invert = T, value = T)
    name <- grep('gridcell_area',name, invert = T, value = T)
    name <- grep('emis_all',     name, invert = T, value = T)

    if(verbose)
      cat(paste0("reading",
                 " (",version,")",
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))

    data <- as.Date('1850-01-01')   # units is days since 1850-01-01 00:00
    data <- data + ncdf4::ncvar_get(ed,'time')[year]
    cat(paste0("scenario: year ",format(data,"%Y"),"\n"))

    var    <- ncdf4::ncvar_get(ed,name[1])
    var    <- var[,,year]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    r      <- raster::raster(x = var,xmn=-180,xmx=180,ymn=-90,ymx=90)
    raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
    # area   <- raster::area(r)
    # area   <- raster::flip(area,2)
    # area   <- raster::t(area)
    # area   <- raster::as.matrix(area)
    # area   <- units::as_units(area,"km2")
    if(as_raster){
      rz <- raster::raster(0.0 * var, xmn=-180,xmx=180,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat +ellps=GRS80 +no_defs"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.2f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',         name, invert = T, value = T)
        name <- grep('crs',          name, invert = T, value = T)
        name <- grep('gridcell_area',name, invert = T, value = T)
        name <- grep('emis_all',     name, invert = T, value = T)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,year]
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        # var_a  <- var_a / area
        # var_a  <- units::set_units(var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = var,xmn=-180,xmx=180,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        varall <- varall + var * coef[i]
      }
    }
  }                                                # nocov end

  if(version == "MACCITY"){                        # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    if(verbose)
      cat(paste0("reading",
                 " (",version,")",
                 " emissions for ",
                 format(ISOdate(1996,month,1),"%B"),
                 ", output unit is g m-2 s-1 ...\n"))
    var  <- ncdf4::ncvar_get(ed,name[1])
    var  <- var[,,month]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var  <- apply(0.0 * var,1,rev)
    if(as_raster){
      r  <- raster::raster(x = 0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat +ellps=GRS80 +no_defs"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.2f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,month]
        var_a  <- units::as_units(var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  }                                                # nocov end

  if(version == "EDGAR"){
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    if(verbose)
      cat(paste0("reading ",name," (",version,") output unit is g m-2 s-1 ...\n"))
    var    <- ncdf4::ncvar_get(ed,name)
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    if(as_raster){
      r  <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat +ellps=GRS80 +no_defs"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.2f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      name <- names(ed$var)
      var  <- ncdf4::ncvar_get(ed,name)
      if(as_raster){
        var <- apply(var,1,rev)
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  }

  if(as_raster){
    if(is.null(spec)){
      if(version == 'GAINS'){
        return(rz)                                          #nocov
      }else{
        return(raster::rotate(rz))
      }
    }else{
      if(verbose)  cat("using the following speciation:\n") # nocov start
      rz_spec <- list()
      for(i in 1:length(spec)){
        if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
        if(version == 'GAINS'){
          rz_spec[[i]] <- rz * spec[i]
        }else{
          rz_spec[[i]] <- raster::rotate(rz * spec[i])
        }
      }
      names(rz_spec) <- names(spec)
      return(rz_spec)                                      # nocov end
    }
  }else{
    if(is.null(spec)){
      return(varall)
    }else{
      if(verbose)  cat("using the following speciation:\n") # nocov start
      var_spec <- list()
      for(i in 1:length(spec)){
        if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
        var_spec[[i]] <- varall * spec[i]
      }
      names(var_spec) <- names(spec)
      return(var_spec)                                     # nocov end
    }
  }
}
