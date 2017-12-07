#' Transform a raster into a grinded output
#'
#' @description Returns a matrix
#'
#' @param r input raster object
#' @param grid grid object with the grid information
#' @param verbose display adicional information
#'
#' @seealso \code{\link{newGrid}} and \code{\link{shapeToGrid}}
#'
#' @source exemple data from image of persistent lights of the Defense Meteorological Satellite Program (DMSP) \url{https://pt.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#' grid  <- newGrid(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' x     <- raster(paste(system.file("extdata", package = "EmissV"),"/sample.tiff",sep=""))
#' test  <- rasterToGrid(x,grid)
#' image(test)
#' title("Persistent Nocturnal Lights from DMSP")
#'}

rasterToGrid <- function(r,grid,verbose = T){

  col   <- grid$Horizontal[1]
  rol   <- grid$Horizontal[2]
  r.lat <- range(grid$Lat)
  r.lon <- range(grid$Lon)
  box   <- raster::raster(nrows=rol,ncols=col,
                          xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                          crs=sf::st_crs(proj4string(r)))

  X    <- resample(r,box,method = "bilinear")
  X    <- raster::flip(X,2)
  X    <- raster::t(X)
  X    <- raster::as.matrix(X)

  if(verbose)
    print(paste("Grid output:",col,"columns",rol,"rows"))
  return(X)
}


