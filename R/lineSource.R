#' Distribution of emissions by lines
#'
#' @description Create a emission distribution from 'sp' or 'sf' spatial lines data.frame or
#' spatial lines.
#'
#' There 3 modes available to create the emission grid:
#' - using gridInfo function output (defoult)
#' - using the patch to "wrfinput" (output from real.exe) file or "geo" for (output from geog.exe)
#' - "sf" (and "sp") uses a grid in SpatialPolygons format
#'
#' The variable is the column of the data.frame with contains the variable to be used as emissions,
#' by defoult the idstribution taken into acount the lench distribution of lines into each grid cell
#' and the output is normalized.
#'
#' @param s SpatialLinesDataFrame of SpatialLines object
#' @param grid grid object with the grid information or filename
#' @param as_raster output format, TRUE for raster, FALSE for matrix
#' @param verbose display additional information
#' @param type "info" (default), "wrfinput", "geo", "sp" or "sf" for grid type
#' @param gcol grid points for a "sp" or "sf" type
#' @param grow grid points for a "sp" or "sf" type
#' @param variable variable to use, default is line length
#'
#' @return a raster object containing the spatial distribution of emissions
#'
#' @export
#'
#' @importFrom methods as
#' @importFrom data.table data.table
#' @importFrom data.table .SD
#' @import sf
#' @import raster
#' @import ncdf4
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{rasterSource}}
#'
#' @examples \donttest{
#' # loading a shapefile with osm data for sao paulo metropolitan area
#' roads <- sf::st_read(paste0(system.file("extdata",package="EmissV"),"/streets.shp"))
#' d3    <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d03"))
#'
#' # calculating only for 2 streets
#' roadLength <- lineSource(roads[1:2,],d3,as_raster=TRUE)
#'
#' # to generate a quick plot
#' raster::plot(roadLength,ylab="Lat", xlab="Lon",main="Length of roads")
#' # lines(road_lines)
#' }
#'
#'
#'@source OpenstreetMap data avaliable \url{https://www.openstreetmap.org/} and \url{https://download.geofabrik.de/}
#'

lineSource <- function(s, grid, as_raster = FALSE, type = "info",
                       gcol = 100, grow = 100, variable = "length",
                       verbose = TRUE){

  if(verbose) cat('using',variable,'as emission variable\n')

  wrf_grid <- function(filewrf, type = "wrfinput", epsg = 4326, grid = NULL){
    if(type == 'info'){
      if(is.null(grid)){
        stop('grid nod found!') # nocov
      }
      lat    <- grid$Lat
      lon    <- grid$Lon
      time   <- grid$Times
      dx     <- grid$DX
      n.lon  <- grid$Horizontal[1]
      n.lat  <- grid$Horizontal[2]

      if(verbose){
        cat(paste0("Number of lat points ", n.lat, "\n"))
        cat(paste0("Number of lon points ", n.lon, "\n"))
      }
    }else{
      cat(paste("using grid info from:", filewrf, "\n"))    # nocov
      wrf <- ncdf4::nc_open(filewrf)                        # nocov
      if(type == "wrfinput"){                               # nocov
        lat    <- ncdf4::ncvar_get(wrf, varid = "XLAT")     # nocov
        lon    <- ncdf4::ncvar_get(wrf, varid = "XLONG")    # nocov
      } else if(type == "geo"){                             # nocov
        lat    <- ncdf4::ncvar_get(wrf, varid = "XLAT_M")   # nocov
        lon    <- ncdf4::ncvar_get(wrf, varid = "XLONG_M")  # nocov
      }
      time   <- ncdf4::ncvar_get(wrf, varid = "Times")      # nocov
      dx     <- ncdf4::ncatt_get(wrf, varid = 0,            # nocov
                                 attname = "DX")$value      # nocov
      n.lat  <- ncdf4::ncatt_get(wrf, varid = 0,            # nocov
                                 attname = "SOUTH-NORTH_PATCH_END_UNSTAG")$value  # nocov
      n.lon  <- ncdf4::ncatt_get(wrf, varid = 0,            # nocov
                                 attname = "WEST-EAST_PATCH_END_UNSTAG")$value  # nocov
      if(verbose){                                            # nocov
        cat(paste0("Number of lat points ", n.lat, "\n"))     # nocov
        cat(paste0("Number of lon points ", n.lon, "\n"))     # nocov
      }
      ncdf4::nc_close(wrf)                                    # nocov
    }
    r.lat  <- range(lon)
    r.lon  <- range(lat)

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

    return(grid)
  }

  emis_grid <- function (spobj, g, sr, type = "lines")
  {
    net <- sf::st_as_sf(spobj)
    net$id <- NULL
    g <- sf::st_as_sf(g)
    sf::st_crs(g) <- sf::st_crs(net)                   # NEW for PROJ 7.0.0
    if (!missing(sr)) {
      if(verbose)                                        # nocov
        message("Transforming spatial objects to 'sr' ") # nocov
      net <- sf::st_transform(net, sr)                   # nocov
      g <- sf::st_transform(g, sr)                       # nocov
    }
    if (type == "lines") {
      netdf <- sf::st_set_geometry(net, NULL)
      snetdf <- sum(netdf, na.rm = TRUE)
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
      dfm$id <- id
      names(dfm) <- c("id", namesnet)
      gx <- data.frame(id = g$id)
      gx <- merge(gx, dfm, by = "id", all.x = TRUE)
      gx[is.na(gx)] <- 0
      gx <- sf::st_sf(gx, geometry = g$geometry)
      return(gx)
    }
    else if (type == "points") { # nocov start
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
      return(gx) # nocov end
    }
  }

  if(type %in% c("wrfinput","geo","info")){
    if(type == 'info'){
      g <- wrf_grid(filewrf = NA,
                    type = type,
                    epsg = 4326,
                    grid = grid)
    }else{
      g <- wrf_grid(filewrf = grid$File, # nocov
                    type = type,         # nocov
                    epsg = 4326)         # nocov
    }

    roads2 <- s
    if(variable == "length"){
      #  Calculate the length
      roads2$length <- sf::st_length(sf::st_as_sf(roads2))
      # just length
      roads3 <- roads2[, "length"]
      # calculate the length of streets in each cell
      roads4 <- emis_grid(spobj = roads3, g = g, type = "lines") # sr = 4326
    }else{
      # calculate with 'variable' columns instead of 'length'
      roads3 <- s[, variable]                                    # nocov
      names(roads3) <- c("length","geo")                         # nocov
      roads4 <- emis_grid(spobj = roads3, g = g, type = "lines") # nocov
    }
    # converts to Spatial
    roads4sp <- as(roads4, "Spatial")
    # make a raster
    # r <- raster::raster(ncol = grid$Horizontal[1], nrow = grid$Horizontal[2],
    #                     xmn=min(grid$Lon),xmx=max(grid$Lon),
    #                     ymn=min(grid$Lat),ymx=max(grid$Lat))
    # r <- raster::rasterize(roads4sp, r, field = roads4sp$length, fun = sum,
    #                        update = TRUE, updateValue = "all")
    # updated to gridInfo
    r <- raster::rasterize(roads4sp, grid$grid, field = roads4sp$length, fun = sum,
                           update = TRUE, updateValue = "all")

    r[is.na(r[])] <- 0
    crs(r) <- "+proj=longlat"
    # normalyse for roads use
    if(variable == "length"){
      r <- r / cellStats(r,'sum')
    }else{
      r <- sum(s[[variable]])  * ( r / cellStats(r,'sum') )      # nocov
    }

    if(as_raster){
      return(r)
    } else {
      roadLength <- raster::flip(r,2)
      roadLength <- raster::t(roadLength)
      roadLength <- raster::as.matrix(roadLength)
      return(raster::as.matrix(roadLength))
    }
  }

  if(type %in% c("sp","sf")){ # nocov start
    if("sp" %in% class(grid[1])){
      roads2 <- sf::st_as_sf(s)
    }else{
      roads2 <- s
    }
    #  Calculate the length
    roads2$length <- sf::st_length(sf::st_as_sf(roads2))
    # just length
    roads3 <- roads2[, "length"]
    # calculate the length of streets in each cell
    ras_Id <- cbind(id = 1:nrow(grid),grid)

    roads4 <- emis_grid(spobj = roads3, g = ras_Id, type = "lines")
    # normalyse
    roads4$length <- roads4$length / sum(roads4$length)
    if(as_raster){
      # converts to Spatial
      roads4sp <- as(roads4, "Spatial")
      # make a raster
      r <- raster::raster(ncol = gcol, nrow = grow)
      raster::extent(r) <- raster::extent(grid)
      r <- raster::rasterize(roads4sp, r, field = roads4sp$length,
                             update = TRUE, updateValue = "NA")
      r[is.na(r[])] <- 0
      return(r)
    }else{
      return(roads4)
    }
  }
}
