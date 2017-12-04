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

# FUNÇÃO NO PACOTE VEIN
# emis_grid <- function(spobj, g, sr, type="lines"){
#   if ( type == "lines" ) {
#     net <- spobj
#     for( i in 1:ncol(net@data) ){
#       net@data[,i] <- as.numeric(net@data[,i])
#     }
#     net$lkm <-  rgeos::gLength(sp::spTransform(net,CRS(sr)),byid = T)/1000
#     netg <- raster::intersect(net,g)
#     netg$lkm2 <-  rgeos::gLength(sp::spTransform(netg,CRS(sr)),byid = T)/1000
#     netg@data[,1:(ncol(netg@data)-3)] <-  netg@data[,1:(ncol(netg@data)-3)] * netg$lkm2/netg$lkm
#     dfm <- stats::aggregate(cbind(netg@data[,1:(ncol(netg@data)-3)]),
#                             by=list(netg$id), sum, na.rm=TRUE)
#     colnames(dfm)[1] <- "id"
#     gg <- merge(g, dfm, by="id")
#     # for(i in 2:ncol(gg)){
#     #   gg@data[,i] <- gg@data[,i] * units::parse_unit("g h-1")
#     # } # spplot does not work with units
#     return(gg)
#   } else if ( type == "points" ){
#     g@data <- sp::over(g,spobj, fn=sum)
#     #Add units
#     return(g)
#   }
# }
