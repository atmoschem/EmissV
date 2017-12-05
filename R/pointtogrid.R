#' create a point source
#'
#' @description under development (test)
#'
#' @param p input point object
#' @param grid grid object with the grid information
#' @param verbose display adicional information
#'
#' @export
#'
#' @seealso \code{\link{newGrid}} and \code{\link{rasterToGrid}}
#'
pointToGrid <- function(p,grid,verbose = T){

  print("test")

  return(NA)
}

# olhar emis_grid do vein :

# emis_grid <- function(spobj, g, sr){
#     g@data <- sp::over(g,spobj, fn=sum)
#     #Add units
#     return(g)
# }
