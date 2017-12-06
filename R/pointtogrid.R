#' create a point source
#'
#' @description Transform a set of points into a grinded output
#'
#' @param p list of points
#' @param grid grid object with the grid information
#' @param verbose display adicional information
#'
#' @export
#'
#' @seealso \code{\link{newGrid}} and \code{\link{rasterToGrid}}
#'
pointToGrid <- function(p = list(lat=-24.67123,lon=-47.26636,z = 100, e = 666),grid,verbose = T){
  # g     <- grid with class SpatialPolygonsDataFrame
  # spobj <- A spatial dataframe of class sp
  lat <- p$lat
  lon <- p$lon
  z   <- p$z
  e   <- p$e
  p   <- SpatialPoints(data.frame(lon,lat))
  # lon <- grid$Lon
  # lat <- grid$Lat

  # pts = expand.grid(lon = grid$Lon[1,], lat = grid$Lat[,1])
  # g   = SpatialPixels(SpatialPoints(pts),tolerance = 0.01)
  # g   = as(g, "SpatialGrid")
  # gridded(g) = T

  g = data.frame(lon = c(grid$Lon), lat = c(grid$Lat), emiss = rep(0,length(lat)))
  coordinates(g) = ~lon+lat

  em <- sp::over(p,g,fn=sum)
  return(em)
}

# apt do sergio: http://rpubs.com/djxhie/autooilp3
# esse artigo: https://rpubs.com/markpayne/132500

# emis_grid <- function(spobj, g, sr){
#     g@data <- sp::over(g,spobj, fn=sum)
#     #Add units
#     return(g)
# }
#
# x = "SpatialPoints", y = "SpatialGrid"
# xx
# x = "SpatialPoints", y = "SpatialGridDataFrame"
# xx
# x = "SpatialPoints", y = "SpatialPixels"
# xx
# x = "SpatialPoints", y = "SpatialPixelsDataFrame"
# xx
# x = "SpatialPolygons", y = "SpatialGridDataFrame"
# xx
