#' Distribution of emissions by streets
#'
#' @description Create a distribution from sp spatial lines data frame or spatial lines
#'
#' @param s SpatialLinesDataFrame of SpatialLines object
#' @param grid grid object with the grid information
#' @param as_raster output format, TRUE for raster, FALSE for matrix
#' @param verbose display additional information
#'
#' @export
#'
#' @importFrom methods as
#' @importFrom spatstat owin pixellate.psp as.psp
#' @import maptools raster
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{rasterSource}}
#'
#'
#' @examples \dontrun{
#' # Do not run
#' roads <- osmar::get_osm(osmar::complete_file(),
#'                         source = osmar::osmsource_file(paste(system.file("extdata",
#'                         package="EmissV"),"/streets.osm.xz",sep="")))
#' roads <- osmar::as_sp(roads,what = "lines")
#'
#' d3    <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))
#'
#' roadLength <- lineSource(roads,d3,as_raster=TRUE)
#'
#' sp::spplot(roadLength, scales = list(draw=TRUE), ylab="Lat", xlab="Lon",main="Length of roads",
#'            sp.layout=list("sp.lines", roads))
#' }
#'
#'@source OpenstreetMap data avaliable \url{https://www.openstreetmap.org/}
#'

# algorithm source:
# https://gis.stackexchange.com/questions/119993/convert-line-shapefile-to-raster-value-total-length-of-lines-within-cell


lineSource <- function(s,grid,as_raster = F,verbose = T){

  print("take a coffee, this function may take a few minutes ...")

  if(verbose) print("cropping data for domain (1 of 4) ...")
  x   <- grid$Box$x
  y   <- grid$Box$y
  box <- sp::bbox(sp::SpatialPoints(cbind(x,y)))
  s   <- raster::crop(s,box)

  if(verbose) print("converting to a line segment pattern object (2 of 4) ...")
  roadsPSP <- spatstat::as.psp(as(s, 'SpatialLines'))

  if(verbose) print("Calculating lengths per cell (3 of 4) ...")
  n.lat        <- grid$Horizontal[2]
  n.lon        <- grid$Horizontal[1]
  limites      <- spatstat::owin(xrange=c(grid$xlim[1],grid$xlim[2]), yrange=c(grid$Ylim[1],grid$Ylim[2]))
  roadLengthIM <- spatstat::pixellate.psp(roadsPSP, W=limites,dimyx=c(n.lat,n.lon))

  if(verbose) print("Converting pixel image to raster in meters (4 of 4) ...")
  roadLength <- raster::raster(roadLengthIM, crs=sp::proj4string(s))

  if(as_raster) return(roadLength)

  if(verbose) print("Converting raster to matrix ...")
  roadLength <- raster::flip(roadLength,2)
  roadLength <- raster::t(roadLength)
  roadLength <- raster::as.matrix(roadLength)
  if(verbose)
    print(paste("Grid output:",n.lon,"columns",n.lat,"rows"))
  return(roadLength/sum(roadLength))
}
