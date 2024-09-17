#' Distribution of emissions by a georeferenced image
#'
#' @description Calculate the spatial distribution by a raster
#'
#' @return Returns a matrix
#'
#' @param r input raster object
#' @param grid grid object with the grid information
#' @param nlevels number of vertical levels off the emission array
#' @param conservative TRUE (default) to conserve total mass, FALSE to conserve flux
#' @param verbose display additional information
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{lineSource}}
#'
#' @source Exemple data is a low resolution cutting from image of persistent lights of the Defense Meteorological Satellite Program (DMSP) \url{https://pt.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}
#'
#' @export
#'
#' @import raster sf
#'
#' @examples
#' grid  <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' x     <- raster::raster(paste(system.file("extdata", package = "EmissV"),"/dmsp.tiff",sep=""))
#' test  <- rasterSource(x, grid)
#' image(test, axe = FALSE, main = "Spatial distribution by Persistent Nocturnal Lights from DMSP")
#'
#'@source Data avaliable \url{https://www.nesdis.noaa.gov/current-satellite-missions/currently-flying/defense-meteorological-satellite-program}
#'@details About the DMSP and example data \url{https://en.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}


rasterSource <- function(r,grid,nlevels="all",conservative = TRUE,verbose = TRUE){

  if(grid$map_proj %in% c(1,2,3,6)){
    box   <- grid$r
  }else{
    col   <- grid$Horizontal[1]
    rol   <- grid$Horizontal[2]
    r.lat <- range(grid$Lat)
    r.lon <- range(grid$Lon)
    box   <- raster::raster(nrows=rol,ncols=col,
                            xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                            crs='+proj=longlat')
  }

  if(is.na(grid$z[1])){
    # to reduce the memory
    box_ll <- suppressWarnings( projectRaster(box, crs='+proj=longlat') )
    r      <- raster::crop(r,raster::extent(box_ll))
    if(conservative)
      total_box <- cellStats(r,"sum",na.rm=TRUE) # nocov

    r    <- suppressWarnings(raster::projectRaster(r,crs = raster::crs(box))) # to the new projection
    X    <- raster::resample(r,box,method = "bilinear")                       # non-conservative transformation
    X    <- raster::flip(X,2)
    X    <- raster::t(X)
    X    <- raster::as.matrix(X)
    X[is.na(X)] <- 0             # for low resolution input data
    # to conserve mass
    if(conservative)
      X    <- X * total_box/sum(X) # nocov

    if(verbose)
      cat(paste("Grid output:",grid$Horizontal[1],
                "columns",grid$Horizontal[2],"rows\n"))

  }else{
    if(nlevels == "all"){
      nlevels <- dim(grid$z)[3]
    }else{
      nlevels <- nlevels
    }

    r    <- suppressWarnings(raster::projectRaster(r,crs = raster::crs(box))) # to the new projection
    r    <- raster::crop(r,box)
    X    <- raster::resample(r,box,method = "bilinear")                       # non-conservative transformation
    X    <- raster::flip(X,2)
    X    <- raster::t(X)
    Y    <- raster::as.matrix(X)
    X    <- array(NA,c(dim(Y),nlevels))
    for(i in 1:nlevels){
      X[,,i] = Y
    }

    if(verbose){
      col   <- grid$Horizontal[1]
      rol   <- grid$Horizontal[2]
      cat(paste("Grid output:",col,"columns",rol,"rows",nlevels,"levels\n"))
    }
  }

  return(X)
}


