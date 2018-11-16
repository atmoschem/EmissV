#' Read NetCDF data from global inventaries
#'
#' @description Read data from global inventories, can read several files and merge into one emission
#' and/or split into several species (speciation process)
#'
#' @return Matrix or raster
#'
#' @param file file name or names (variables are summed)
#' @param coef coef to merge different sources into one emission
#' @param spec numeric speciation vector to split emission into different species
#' @param version inventory name and verion
#' @param as_raster return a raster (defoult) or matrix (with units)
#' @param verbose display additional information
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
#' @source Read abbout EDGAR at http://edgar.jrc.ec.europa.eu
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
                 version = "EDGAR 4.3.1 v2", as_raster = T, verbose = T){

  if(is.list(coef))
    coef <- as.numeric(as.character(unlist(coef))) #nocov
  if(is.list(spec))
    spec <- as.numeric(as.character(unlist(spec))) #nocov


  if(version == "EDGAR 4.3.1 v2"){
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    var  <- ncdf4::ncvar_get(ed,name[1])
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var  <- apply(var,1,rev)
    if(as_raster){
      # r  <- raster::raster(x = 1000 * var,xmn=-180,xmx=180,ymn=-90,ymx=90)
      # rz <- raster::raster(0.0 * var,xmn=-180,xmx=180,ymn=-90,ymx=90)
      r  <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat +ellps=GRS80 +no_defs"
    }

    if(verbose)
      cat(paste0("reading ",name," (",version,") units are g m-2 s-1 ...\n"))

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.2f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      name <- names(ed$var)
      var  <- ncdf4::ncvar_get(ed,name[1])
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
    if(as_raster){

      if(is.null(spec)){
        return(raster::rotate(rz))
      }else{
        if(verbose)  cat("using the following speciation:\n") # nocov start
        rz_spec <- list()
        for(i in 1:length(spec)){
          if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
          rz_spec[[i]] <- raster::rotate(rz * spec[i])
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
  # if(version == "osm"){
  #   cat(paste("reading osm data from",file,"\n"))
  #   roads <- osmar::get_osm(osmar::complete_file(),source = osmar::osmsource_file(file))
  #   road_lines <- osmar::as_sp(roads,what = "lines")
  #   roads <- sf::st_as_sf(road_lines)
  #   return(roads)
  # }
}
