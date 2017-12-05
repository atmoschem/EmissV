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
pointToGrid <- function(p = list(x=-24.67123,y=-47.26636),grid,verbose = T){
  # g     <- grid with class SpatialPolygonsDataFrame
  # spobj <- A spatial dataframe of class sp
  x <- p$x
  y <- p$y
  p <- SpatialPoints(data.frame(x,y))

  cc <- matrix(c(grid$Lon,grid$Lat),ncol = 2,byrow = F)

  x <- grid$Lon
  y <- grid$Lat
  points <- SpatialPoints(data.frame(x,y))

  Spixel <- sp::SpatialPixels(points)
  # g <- SpatialGrid(p2)

  # g <- sp::over(g,spobj, fn=sum)
  # return(g)
  return(Spixel)
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
#
# x = "SpatialPoints", y = "SpatialGridDataFrame"
# xx
#
# x = "SpatialPoints", y = "SpatialPixels"
# xx
#
# x = "SpatialPoints", y = "SpatialPixelsDataFrame"
# xx
#
# x = "SpatialPolygons", y = "SpatialGridDataFrame"
# xx
