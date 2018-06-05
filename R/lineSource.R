#' Distribution of emissions by streets
#'
#' @description Create a distribution from sp spatial lines data frame or spatial lines
#'
#' @param s SpatialLinesDataFrame of SpatialLines object
#' @param grid grid object with the grid information
#' @param as_raster output format, TRUE for raster, FALSE for matrix
#' @param verbose display additional information
#' @param fast fun (or not)
#' @export
#'
#' @importFrom methods as
#' @importFrom spatstat owin pixellate.psp as.psp
#' @importFrom vein emis_grid
#' @importFrom eixport wrf_grid
#' @import maptools raster
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{rasterSource}}
#'
#'
#' @examples \donttest{
#' roads <- osmar::get_osm(osmar::complete_file(),
#'                         source = osmar::osmsource_file(paste(system.file("extdata",
#'                         package="EmissV"),"/streets.osm.xz",sep="")))
#' roads <- osmar::as_sp(roads,what = "lines")
#' #roads <- sf::st_as_sf(roads)
#'
#' d3    <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))
#'
#' roadLength <- lineSource(roads,d3,as_raster=TRUE)
#' sp::spplot(roadLength, scales = list(draw=TRUE), ylab="Lat", xlab="Lon",main="Length of roads",
#'            sp.layout=list("sp.lines", roads))
#' roadLengthraster <- lineSource(roads,d3,as_raster=TRUE, fest = TRUE)
#' }
#'
#'
#'@source OpenstreetMap data avaliable \url{https://www.openstreetmap.org/} and \url{https://download.geofabrik.de/}
#'

# OLD algorithm source:
# https://gis.stackexchange.com/questions/119993/convert-line-shapefile-to-raster-value-total-length-of-lines-within-cell


lineSource <- function(s, grid, as_raster = F,verbose = T, fast = F){

  print("take a coffee, this function may take a few minutes ...")
  if (!fast) {
   g <- eixport::wrf_grid(filewrf = grid$File,
                           type = "wrfinput",
                           matrix = FALSE,
                           epsg = 4326)
    roads2 <- s
    #  Calculate the length
    roads2$length <- sf::st_length(sf::st_as_sf(roads2))
    # just length
    roads3 <- roads2[, "length"]
    # calculate the length of streets in each cell
    roads4 <- vein::emis_grid(spobj = roads3, g = g, sr = 4326, type = "lines")
    # normalyse
    roads4$length <- roads4$length / sum(roads4$length)
    # converts to Spatial
    roads4sp <- as(roads4, "Spatial")
    # make a raster
    r <- raster::raster(ncol = grid$Horizontal[1], nrow = grid$Horizontal[2])
    raster::extent(r) <- raster::extent(roads4sp)
    r <- raster::rasterize(roads4sp, r, field = roads4sp$length,
                           update = TRUE, updateValue = "NA")
    if(as_raster){
      return(r)
    } else {
      return(raster::as.matrix(roadLength))
    }
  } else {

  if(verbose) print("cropping data for domain (1 of 4) ...")
  x   <- grid$Box$x
  y   <- grid$Box$y
  box <- sp::bbox(sp::SpatialPoints(cbind(x,y)))
  s   <- raster::crop(s,box) # tira ruas fora do dominio

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
}
