#' Distribution of emissions by streets
#'
#' @description Create a distribution from sp spatial lines data frame or spatial lines
#'
#' @param s SpatialLinesDataFrame of SpatialLines object
#' @param grid grid object with the grid information
#' @param as_raster output format, TRUE for raster, FALSE for matrix
#' @param verbose display additional information
#' @export
#'
#' @importFrom methods as
#' @importFrom data.table data.table
#' @importFrom data.table .SD
#' @import sf
#' @import raster
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{rasterSource}}
#'
#'
#' @examples \donttest{
#' roads <- osmar::get_osm(osmar::complete_file(),
#'                         source = osmar::osmsource_file(paste(system.file("extdata",
#'                         package="EmissV"),"/streets.osm.xz",sep="")))
#' road_lines <- osmar::as_sp(roads,what = "lines")
#' roads <- sf::st_as_sf(road_lines)
#'
#' d3    <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))
#'
#' roadLength <- lineSource(roads,d3,as_raster=TRUE)
#' sp::spplot(roadLength, scales = list(draw=TRUE), ylab="Lat", xlab="Lon",main="Length of roads",
#'            sp.layout=list("sp.lines", road_lines))
#' }
#'
#'
#'@source OpenstreetMap data avaliable \url{https://www.openstreetmap.org/} and \url{https://download.geofabrik.de/}
#'

lineSource <- function(s, grid, as_raster = F,verbose = T){

  wrf_grid <- function(filewrf, type = "wrfinput", matrix = F, epsg = 4326){
    cat(paste("using grid info from:", filewrf, "\n"))
    wrf <- ncdf4::nc_open(filewrf)
    if(type == "wrfinput"){
      lat    <- ncdf4::ncvar_get(wrf, varid = "XLAT")
      lon    <- ncdf4::ncvar_get(wrf, varid = "XLONG")
    } else if(type == "geo"){
      lat    <- ncdf4::ncvar_get(wrf, varid = "XLAT_M")
      lon    <- ncdf4::ncvar_get(wrf, varid = "XLONG_M")
    }
    time   <- ncdf4::ncvar_get(wrf, varid = "Times")
    dx     <- ncdf4::ncatt_get(wrf, varid = 0,
                               attname = "DX")$value
    n.lat  <- ncdf4::ncatt_get(wrf, varid = 0,
                               attname = "SOUTH-NORTH_PATCH_END_UNSTAG")$value
    n.lon  <- ncdf4::ncatt_get(wrf, varid = 0,
                               attname = "WEST-EAST_PATCH_END_UNSTAG")$value
    cat(paste0("Number of lat points ", n.lat, "\n"))
    cat(paste0("Number of lon points ", n.lon, "\n"))
    ncdf4::nc_close(wrf)
    r.lat  <- range(lon)
    r.lon  <- range(lat)
    EM  <- matrix(0, nrow = n.lon, ncol = n.lat)

    points      <- data.frame(lat  = c(lat),
                              long = c(lon))
    points$lat  <- as.numeric(points$lat)
    points$long <- as.numeric(points$long)

    dx <- 1.0 * (r.lat[1] - r.lat[2]) / (n.lat+1)
    dy <- 1.0 * (r.lon[2] - r.lon[1]) / (n.lon+1)
    alpha = 0 * (pi / 180)
    dxl <- cos(alpha) * dx - sin(alpha) * dy
    dyl <- sin(alpha) * dx + cos(alpha) * dy

    grid = list()

    for(i in 1:nrow(points)){
      # for(i in 1:2){
      p1_lat = points$lat[i]  - dx/2
      p1_lon = points$long[i] + dy/2

      p2_lat = points$lat[i]  + dx/2
      p2_lon = points$long[i] + dy/2

      p3_lat = points$lat[i]  + dx/2
      p3_lon = points$long[i] - dy/2

      p4_lat = points$lat[i]  - dx/2
      p4_lon = points$long[i] - dy/2

      mat  <- matrix(c(p1_lon,p1_lat,
                       p2_lon,p2_lat,
                       p3_lon,p3_lat,
                       p4_lon,p4_lat,
                       p1_lon,p1_lat),
                     ncol=2, byrow=TRUE)
      cell <- sf::st_polygon(list(mat))
      grid[[i]] = cell
    }
    geometry <- sf::st_sfc(sf::st_multipolygon(grid))
    grid <- sf::st_cast(x = st_sf(geometry = geometry, crs = epsg),
                        to = "POLYGON")
    grid$id <- 1:nrow(grid)

    if (matrix == T){
      return(EM)
    } else {
      return(grid)
    }

  }

  emis_grid <- function (spobj, g, sr, type = "lines")
  {
    net <- sf::st_as_sf(spobj)
    net$id <- NULL
    g <- sf::st_as_sf(g)
    if (!missing(sr)) {
      message("Transforming spatial objects to 'sr' ")
      net <- sf::st_transform(net, sr)
      g <- sf::st_transform(g, sr)
    }
    if (type == "lines") {
      netdf <- sf::st_set_geometry(net, NULL)
      snetdf <- sum(netdf, na.rm = TRUE)
      # cat(paste0("Sum of street emissions ", round(snetdf,
      #                                              2), "\n"))
      ncolnet <- ncol(sf::st_set_geometry(net, NULL))
      net <- net[, grep(pattern = TRUE, x = sapply(net, is.numeric))]
      namesnet <- names(sf::st_set_geometry(net, NULL))
      net$LKM <- sf::st_length(sf::st_cast(net[sf::st_dimension(net) ==
                                                 1, ]))
      netg <- suppressWarnings(st_intersection(net, g))
      netg$LKM2 <- sf::st_length(netg)
      xgg <- data.table::data.table(netg)
      xgg[, 1:ncolnet] <- xgg[, 1:ncolnet] * as.numeric(xgg$LKM2/xgg$LKM)
      xgg[is.na(xgg)] <- 0
      dfm <- xgg[, lapply(.SD, sum, na.rm = TRUE), by = "id",
                 .SDcols = namesnet]
      id <- dfm$id
      dfm <- dfm * snetdf/sum(dfm, na.rm = TRUE)
      # cat(paste0("Sum of gridded emissions ", round(sum(dfm,
      #                                                   na.rm = T), 2), "\n"))
      dfm$id <- id
      names(dfm) <- c("id", namesnet)
      gx <- data.frame(id = g$id)
      gx <- merge(gx, dfm, by = "id", all.x = TRUE)
      gx[is.na(gx)] <- 0
      gx <- sf::st_sf(gx, geometry = g$geometry)
      return(gx)
    }
    else if (type == "points") {
      xgg <- data.table::data.table(sf::st_set_geometry(sf::st_intersection(net,
                                                                            g), NULL))
      xgg[is.na(xgg)] <- 0
      dfm <- xgg[, lapply(.SD, sum, na.rm = TRUE), by = "id",
                 .SDcols = namesnet]
      names(dfm) <- c("id", namesnet)
      gx <- data.frame(id = g$id)
      gx <- merge(gx, dfm, by = "id", all.x = TRUE)
      gx[is.na(gx)] <- 0
      gx <- sf::st_sf(gx, geometry = g$geometry)
      return(gx)
    }
  }

  # if (!fast) {
   g <- wrf_grid(filewrf = grid$File,
                 type = "wrfinput",
                 matrix = FALSE,
                 epsg = 4326)
    roads2 <- s
    #  Calculate the length
    roads2$length <- sf::st_length(sf::st_as_sf(roads2))
    # just length
    roads3 <- roads2[, "length"]
    # calculate the length of streets in each cell
    roads4 <- emis_grid(spobj = roads3, g = g, sr = 4326, type = "lines")
    # normalyse
    roads4$length <- roads4$length / sum(roads4$length)
    # converts to Spatial
    roads4sp <- as(roads4, "Spatial")
    # make a raster
    r <- raster::raster(ncol = grid$Horizontal[1], nrow = grid$Horizontal[2])
    raster::extent(r) <- raster::extent(roads4sp)
    r <- raster::rasterize(roads4sp, r, field = roads4sp$length,
                           update = TRUE, updateValue = "NA")
    r[is.na(r[])] <- 0
    if(as_raster){
      return(r)
    } else {
      roadLength <- raster::flip(r,2)
      roadLength <- raster::t(roadLength)
      roadLength <- raster::as.matrix(roadLength)
      return(raster::as.matrix(roadLength))
    }
  # } else {

  # OLD algorithm source:
  # https://gis.stackexchange.com/questions/119993/convert-line-shapefile-to-raster-value-total-length-of-lines-within-cell
  # print("take a coffee, this function may take a few minutes ...")
  # if(verbose) print("cropping data for domain (1 of 4) ...")
  # x   <- grid$Box$x
  # y   <- grid$Box$y
  # box <- sp::bbox(sp::SpatialPoints(cbind(x,y)))
  # s   <- raster::crop(s,box) # tira ruas fora do dominio
  #
  # if(verbose) print("converting to a line segment pattern object (2 of 4) ...")
  # roadsPSP <- spatstat::as.psp(as(s, 'SpatialLines'))
  #
  # if(verbose) print("Calculating lengths per cell (3 of 4) ...")
  # n.lat        <- grid$Horizontal[2]
  # n.lon        <- grid$Horizontal[1]
  # limites      <- spatstat::owin(xrange=c(grid$xlim[1],grid$xlim[2]), yrange=c(grid$Ylim[1],grid$Ylim[2]))
  # roadLengthIM <- spatstat::pixellate.psp(roadsPSP, W=limites,dimyx=c(n.lat,n.lon))
  #
  # if(verbose) print("Converting pixel image to raster in meters (4 of 4) ...")
  # roadLength <- raster::raster(roadLengthIM, crs=sp::proj4string(s))
  #
  # if(as_raster) return(roadLength)
  #
  # if(verbose) print("Converting raster to matrix ...")
  # roadLength <- raster::flip(roadLength,2)
  # roadLength <- raster::t(roadLength)
  # roadLength <- raster::as.matrix(roadLength)
  # if(verbose)
  #   print(paste("Grid output:",n.lon,"columns",n.lat,"rows"))
  # return(roadLength/sum(roadLength))
  # }
}
