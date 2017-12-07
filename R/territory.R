#' Subset a raster with a shape (and grid)
#'
#' @description Create a subset of a raster by a shape and return a new masked raster. If grid argument is used return in grid format and the fraction within the grid.
#'
#' @param s input shape object
#' @param r input raster object
#' @param grid grid with the output format
#' @param verbose display adicional data
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' shape  <- read_sf(paste(system.file("extdata", package = "EmissV"),"/BR.shp",sep=""),verbose = F)
#' shape  <- shape[22,1] # subset for Sao Paulo - BR
#' raster <- raster(paste(system.file("extdata", package = "EmissV"),"/sample.tiff",sep=""))
#' grid   <- newGrid(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' SP     <- territory(shape,raster,grid)
#' plot(SP,main = "Sao Paulo Metropolitan Area", xlab="Lon",ylab="Lat",col = heat.colors(12, alpha = 1))
#'}

territory <- function(s,r,grid = NA,verbose = T){
  if(verbose){
    print("processing territory's frontier ... ")
  }

  sp       <- mask(r,spTransform(s,CRS(proj4string(r))))
  sp_soma  <- cellStats(sp,"sum")
  if(!is.na(grid[1])){
    col    <- grid$Horizontal[1]
    rol    <- grid$Horizontal[2]
    r.lat  <- range(grid$Lat)
    r.lon  <- range(grid$Lon)
    box    <- raster(nrows=rol,ncols=col,
                     xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                     crs=CRS(proj4string(r)))
    sp     <- crop(sp / sp_soma ,box)
    sp_r   <- cellStats(sp,"sum")
    if(verbose)
      print(paste("fraction =",sp_r))
    return(sp)
  }
  return(sp)
}
