#' Distribution of emissions by a georeferenced image
#'
#' @description Calculate the spatial distribution by a raster
#'
#' @return Returns a matrix
#'
#' @param r input raster object
#' @param grid grid object with the grid information
#' @param nlevels number of vertical levels off the emission array
#' @param verbose display additional information
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{lineSource}}
#'
#' @source Exemple data is a low resolution cutting from image of persistent lights of the Defense Meteorological Satellite Program (DMSP) \url{https://pt.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}
#'
#' @export
#'
#' @import raster
#'
#' @examples
#' # Do not run
#' grid  <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' x     <- raster::raster(paste(system.file("extdata", package = "EmissV"),"/dmsp.tiff",sep=""))
#' test  <- rasterSource(x,grid)
#' \donttest{
#' image(test,axe = F, main = "Spatial distribution by Persistent Nocturnal Lights from DMSP")
#'}
#'
#'@source Data avaliable \url{https://ngdc.noaa.gov/eog/dmsp/downloadV4composites.html}
#'@details About the DMSP and example data \url{https://en.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}


rasterSource <- function(r,grid,nlevels="all",verbose = T){

  col   <- grid$Horizontal[1]
  rol   <- grid$Horizontal[2]
  r.lat <- range(grid$Lat)
  r.lon <- range(grid$Lon)
  box   <- raster::raster(nrows=rol,ncols=col,
                          xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                          crs=sp::proj4string(r))

  if(is.na(grid$z[1])){
    total_box <- cellStats(raster::crop(r,box),"sum",na.rm=TRUE)

    X    <- raster::resample(r,box,method = "bilinear") # non-conservative transformation
    X    <- raster::flip(X,2)
    X    <- raster::t(X)
    X    <- raster::as.matrix(X)
    X[is.na(X)] <- 0             # for low resolution input data
    X    <- X * total_box/sum(X) # to conserve mass

    if(verbose)
      print(paste("Grid output:",col,"columns",rol,"rows"))
  }else{
    if(nlevels == "all"){
      nlevels <- dim(grid$z)[3]
    }else{
      nlevels <- nlevels
    }
    # total_box <- cellStats(raster::crop(r,box),"sum",na.rm=TRUE)

    X    <- raster::resample(r,box,method = "bilinear") # non-conservative transformation
    X    <- raster::flip(X,2)
    X    <- raster::t(X)
    X    <- raster::as.array(X)
    X    <- X[,,1:nlevels]
    # X    <- X * total_box[1:nlevels]/sum(X) # to conserve mass

    if(verbose)
      print(paste("Grid output:",col,"columns",rol,"rows",nlevels,"levels"))
  }

  return(X)
}


