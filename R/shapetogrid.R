#' Transform a shape into a grinded output
#'
#' @description create a distribution by a "Openstreetmap mystery file"
#'
#' @param s input sp object with projection
#' @param grid grid object with the grid information
#' @param as_raster output format, TRUE for raster, FALSE for matrix
#' @param verbose true for display adicional information
#'
#' @export
#'
#' @seealso \code{\link{newGrid}} and \code{\link{rasterToGrid}}
#'
#'
#' @examples \dontrun{
#' # Do not run
#'
#' library(sf)
#' print("chose the Openstreetmap file (.rds)")
#' roads <- readRDS(file.choose())
#' roads <- as_Spatial(st_geometry(roads[roads$highway != "residential", ]))
#'
#' d2    <- newGrid(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d02"))
#'
#' roadLength <- shapeToGrid(roads,d2,as_raster=T)
#'
#' spplot(roadLength, scales = list(draw=TRUE), xlab="lat", ylab="lon",main="Length of roads",
#'        sp.layout=list("sp.lines", roads))
#' }
#'

# algorithm source:
# https://gis.stackexchange.com/questions/119993/convert-line-shapefile-to-raster-value-total-length-of-lines-within-cell

shapeToGrid <- function(s,grid,as_raster = F,verbose = T){

  print("take a coffee, this function may take a few minutes ...")

  if(verbose) print("converting to a line segment pattern object with maptools (1 of 3) ...")
  roadsPSP <- spatstat::as.psp(as(s, 'SpatialLines'))

  if(verbose) print("Calculating lengths per cell (2 of 3) ...")
  n.lat <- grid$Horizontal[1]
  n.lon <- grid$Horizontal[2]
  roadLengthIM <- spatstat::pixellate.psp(roadsPSP, dimyx=c(n.lat,n.lon))

  if(verbose) print("Converting pixel image to raster in meters (3 of 3) ...")
  roadLength <- raster::raster(roadLengthIM, crs=sp::proj4string(s))

  if(as_raster) return(roadLength)

  if(verbose) print("Converting raster to matrix ...")
  roadLength <- raster::flip(roadLength,2)
  roadLength <- raster::t(roadLength)
  roadLength <- raster::as.matrix(roadLength)
  if(verbose)
    print(paste("Grid output:",n.lat,"columns",n.lon,"rows"))
  return(roadLength/sum(roadLength))
}
