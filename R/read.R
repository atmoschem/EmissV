#' Read NetCDF data from global inventaries
#'
#' @description Read data from global inventories, can read several files and merge into one
#' emission and/or split into several species (speciation process)
#'
#' @return Matrix or raster
#'
#' @param file file name or names (variables are summed)
#' @param coef coef to merge different sources (file) into one emission
#' @param spec numeric speciation vector to split emission into different species
#' @param version inventory name 'EDGAR' (for 4.32 and 5.0),'EDGAR_HTAPv2','MACCITY','GAINS','RCP' or 'VULCAN'
#' @param month the desired month of the inventary (MACCITY)
#' @param year scenario index (GAINS)
#' @param categories considered categories (MACCITY, GAINS variable names), empty for all
#' @param as_raster return a raster (defoult) or matrix (with units)
#' @param skip_missing return a zero emission for missing variables and a warning
#' @param verbose display additional information
#'
#' @note for 'GAINS' version, please use flux (kg m-2 s-1) NetCDF file from https://eccad3.sedoo.fr
#'
#' @note VULCAN is not fully supported, only for visualization purposes
#'
#' @note for 'RCP' version, use the flux (kg m-2 s-1) Netcdf file from https://www.iiasa.ac.at/web-apps/tnt/RcpDb
#'
#' @seealso \code{\link{rasterSource}} and \code{\link{gridInfo}}
#'
#' @export
#'
#' @import raster
#' @import ncdf4
#' @importFrom units as_units set_units
#'
#' @seealso \code{\link{species}}
#'
#' @source Read abbout EDGAR at http://edgar.jrc.ec.europa.eu and MACCITY at
#' http://accent.aero.jussieu.fr/MACC_metadata.php
#'
#' @references
#' Janssens-Maenhout, G., Dentener, F., Van Aardenne, J., Monni, S., Pagliari, V., Orlandini,
#' L., ... & Wankmüller, R. (2012). EDGAR-HTAP: a harmonized gridded air pollution emission dataset
#' based on national inventories. European Commission Joint Research Centre Institute for
#' Environment and Sustainability. JRC 68434 UR 25229 EUR 25229, ISBN 978-92-79-23123-0.
#'
#' Lamarque, J.-F., Bond, T. C., Eyring, V., Granier, C., Heil, A., Klimont, Z., Lee, D., Liousse,
#' C., Mieville, A., Owen, B., Schultz, M. G., Shindell, D., Smith, S. J., Stehfest, E.,
#' Van Aardenne, J., Cooper, O. R., Kainuma, M., Mahowald, N., McConnell, J. R., Naik, V.,
#' Riahi, K., and van Vuuren, D. P.: Historical (1850-2000) gridded anthropogenic and biomass
#' burning emissions of reactive gases and aerosols: methodology and application,
#' Atmos. Chem. Phys., 10, 7017-7039, doi:10.5194/acp-10-7017-2010, 2010.
#'
#' Z Klimont, S. J. Smith and J Cofala The last decade of global anthropogenic sulfur dioxide:
#' 2000–2011 emissions Environmental Research Letters 8, 014003, 2013
#'
#' Gurney, Kevin R., Jianming Liang, Risa Patarasuk, Yang Song, Jianhua Huang, and
#' Geoffrey Roest (2019) The Vulcan Version 3.0 High-Resolution Fossil Fuel CO2 Emissions
#' for the United States. Nature Scientific Data.
#'
#' @examples \donttest{
#' dir.create(file.path(tempdir(), "EDGARv432"))
#' folder <- setwd(file.path(tempdir(), "EDGARv432"))
#'
#' url <- "http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v432_AP/NOx"
#' file1 <- 'v432_NOx_2012_IPCC_1A1a.0.1x0.1.zip'
#' file2 <- 'v432_NOx_2012_IPCC_1A2.0.1x0.1.zip'
#' file3 <- 'v432_NOx_2012_IPCC_1A3b.0.1x0.1.zip'
#'
#' download.file(paste0(url,'/ENE/',file1), file1)
#' download.file(paste0(url,'/IND/',file2), file2)
#' download.file(paste0(url,'/TRO/',file3), file3)
#'
#' unzip('v432_NOx_2012_IPCC_1A1a.0.1x0.1.zip')
#' unzip('v432_NOx_2012_IPCC_1A2.0.1x0.1.zip')
#' unzip('v432_NOx_2012_IPCC_1A3b.0.1x0.1.zip')
#'
#' nox    <- read(file = dir(pattern = '.nc'),version = 'EDGAR')
#' setwd(folder)
#'
#' sp::spplot(nox, scales = list(draw=TRUE), xlab="Lat", ylab="Lon",main="NOx emissions from EDGAR")
#'
#' d1     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' d2     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' nox_d1 <- rasterSource(nox,d1)
#' nox_d2 <- rasterSource(nox,d2)
#' image(nox_d1, axe = FALSE, main = "NOx emissions from transport-energy-industry for d1 (2012)")
#' image(nox_d2, axe = FALSE, main = "NOx emissions from transport-energy-industry for d2 (2012)")
#'}

read <- function(file = file.choose(), coef = rep(1,length(file)), spec = NULL,
                 version = NA, month = 1, year = 1, categories,
                 as_raster = T, skip_missing = F, verbose = T){

  if(is.na(version)){                 # nocov start
    cat('versions supported:\n')
    cat(' - EDGAR\n')
    cat(' - EDGAR_HTAPv2\n')
    cat(' - GAINS\n')
    cat(' - RCP\n')
    cat(' - MACCITY\n')
    cat(' - VULCAN\n')
    stop('check version argument')    # nocov end
  }

  raster_to_ncdf <- function(r,na_value = 0){
    N_times <- dim(r)[3]
    a       <- array(na_value,c(dim(r)[2],dim(r)[1],N_times))
    for(i in 1:N_times){
      a[,,i] <- as.matrix(t(raster::flip(r[[i]],2)))
    }
    return(a)
  }

  if(length(coef) != length(file)){ # nocov start
    cat('file and coef has different length, check the read arguments!\n')
    cat('file:\n ')
    cat(paste0(1:length(file),' ',file,'\n'))
    cat('coef:\n ')
    cat(paste0(1:length(coef),' ',coef,'\n'))
  }                                 # nocov end

  if(is.list(coef))
    coef <- as.numeric(as.character(unlist(coef))) #nocov
  if(is.list(spec))
    spec <- as.numeric(as.character(unlist(spec))) #nocov

  if(!missing(categories) && skip_missing == T){   #nocov start
    ed   <- ncdf4::nc_open(file[1])
    if(!(categories %in% names(ed$var))){
      cat('category',categories,'is missing, returning zero emission grid!\n')
      version = "ZEROS"
      # warning(categories,' is missing on file: ',file,' using zero emission!\n')
      varall    <- matrix(NA, ncol = 360, nrow = 720)
      if(as_raster){
        rz <- raster::raster(0.0 * varall,xmn=0,xmx=360,ymn=-90,ymx=90)
        values(rz) <- rep(0,ncell(rz))
        raster::crs(rz) <- "+proj=longlat"
      }

      # if(as_raster){
      #   r      <- raster::raster(x = matrix(0,nrow = 360,ncol = 720),xmn=0,xmx=360,ymn=-90,ymx=90)
      #   raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
      #   rz     <- r
      #   # return(r)
      # }else{
      #   # return(matrix(0,nrow = 720,ncol = 360))
      #   varall <- matrix(0,nrow = 720,ncol = 360)
      # }
    }
  }                                                # nocov end

  if(version == "GAINS"){                          # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('date',             name, invert = T, value = T)
    name <- grep('crs',              name, invert = T, value = T)
    name <- grep('gridcell_area',    name, invert = T, value = T)
    name <- grep('emis_all',         name, invert = T, value = T)
    name <- grep('emiss_sum',        name, invert = T, value = T)
    name <- grep('molecular_weight', name, invert = T, value = T)

    if(verbose)
      cat(paste0("reading",
                 " ",version," ",
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))

    data <- as.Date('1850-01-01')   # units is days since 1850-01-01 00:00
    data <- data + ncdf4::ncvar_get(ed,'time')[year]
    cat(paste0("scenario: year ",format(data,"%Y"),"\n"))

    var    <- ncdf4::ncvar_get(ed,name[1])
    var    <- var[,,year]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    r      <- raster::raster(x = var,xmn=-180,xmx=180,ymn=-90,ymx=90)
    raster::crs(r) <- "+proj=longlat"
    # area   <- raster::area(r)
    # area   <- raster::flip(area,2)
    # area   <- raster::t(area)
    # area   <- raster::as.matrix(area)
    # area   <- units::as_units(area,"km2")
    if(as_raster){
      rz <- raster::raster(0.0 * var, xmn=-180,xmx=180,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',             name, invert = T, value = T)
        name <- grep('crs',              name, invert = T, value = T)
        name <- grep('gridcell_area',    name, invert = T, value = T)
        name <- grep('emis_all',         name, invert = T, value = T)
        name <- grep('molecular_weight', name, invert = T, value = T)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,year]
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        # var_a  <- var_a / area
        # var_a  <- units::set_units(var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = var,xmn=-180,xmx=180,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        varall <- varall + var * coef[i]
      }
    }
  }                                              # nocov end

  if(version == "RCP"){                          # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('date',             name, invert = T, value = T)
    name <- grep('crs',              name, invert = T, value = T)
    name <- grep('gridcell_area',    name, invert = T, value = T)
    name <- grep('emis_all',         name, invert = T, value = T)
    name <- grep('emiss_sum',        name, invert = T, value = T)
    name <- grep('molecular_weight', name, invert = T, value = T)

    if(verbose)
      cat(paste0("reading",
                 " ",version," ",
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))

    data <- as.Date('1850-01-01')   # units is days since 1850-01-01 00:00
    data <- data + ncdf4::ncvar_get(ed,'time')[year]
    cat(paste0("scenario: year ",format(data,"%Y"),"\n"))

    var    <- ncdf4::ncvar_get(ed,name[1])
    var    <- var[,,year]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    r      <- raster::raster(x = var,xmn=0,xmx=360,ymn=-90,ymx=90)
    raster::crs(r) <- "+proj=longlat"
    if(as_raster){
      rz <- raster::raster(0.0 * var, xmn=-0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',             name, invert = T, value = T)
        name <- grep('crs',              name, invert = T, value = T)
        name <- grep('gridcell_area',    name, invert = T, value = T)
        name <- grep('emis_all',         name, invert = T, value = T)
        name <- grep('molecular_weight', name, invert = T, value = T)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,year]
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        varall <- varall + var * coef[i]
      }
    }
  }                                                # nocov end

  if(version == "MACCITY"){                        # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    if(verbose)
      cat(paste0("reading",
                 " ",version," ",
                 " emissions for ",
                 format(ISOdate(1996,month,1),"%B"),
                 ", output unit is g m-2 s-1 ...\n"))
    var  <- ncdf4::ncvar_get(ed,name[1])
    var  <- var[,,month]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var  <- apply(0.0 * var,1,rev)
    if(as_raster){
      r  <- raster::raster(x = 0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,month]
        var_a  <- units::as_units(var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  }                                                # nocov end

  if(version == "EDGAR" || version == "EDGAR_v432"){
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    if(verbose)
      cat(paste0("reading",
                 " ",version," ",
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))
    var    <- ncdf4::ncvar_get(ed,name)
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    if(as_raster){
      r  <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      raster::values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      ed   <- ncdf4::nc_open(file[i])
      name <- names(ed$var)
      cat(paste0("from ",file[i]),name[1],"x",sprintf("%02.6f",coef[i]),"\n")
      var  <- ncdf4::ncvar_get(ed,name)
      if(as_raster){
        var <- apply(var,1,rev)
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  }

  if(version == "EDGAR_HTAPv2"){  # nocov start
    if(verbose)
      cat(paste0("reading",
                 " ",version," ",
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))
    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',         name, invert = T, value = T)
        name <- grep('crs',          name, invert = T, value = T)
        name <- grep('gridcell_area',name, invert = T, value = T)
        name <- grep('emis_all',     name, invert = T, value = T)
        name <- grep('emiss_sum',    name, invert = T, value = T)
      }else{
        name <- categories
      }
      ed   <- ncdf4::nc_open(file[i])
      var  <- ncdf4::ncvar_get(ed,name[1])
      var  <- apply(var,1,rev)
      if(as_raster){
        r  <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        values(rz) <- rep(0,ncell(rz))
        raster::crs(rz) <- "+proj=longlat"
      }
      var_a  <- units::as_units(0.0 * var,"g m-2 s-1")
      varall <- units::as_units(0.0 * var,"g m-2 s-1")
      var    <- units::as_units(0.0 * var,"g m-2 s-1")
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])
        var_a  <- apply(var_a,1,rev)
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        var    <- var + var_a
      }
      if(as_raster){
        var    <- ncdf4::ncvar_get(ed,name[1])
        var    <- apply(var,1,rev)
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  } # nocov end

  if(version == "VULCAN"){                   # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('time_bnds',name, invert = T, value = T)
    name <- grep('crs',      name, invert = T, value = T)
    name <- grep('lat',      name, invert = T, value = T)
    name <- grep('lon',      name, invert = T, value = T)

    # var   <- ncdf4::ncvar_get(ed,name[1])
    # lat   <- ncdf4::ncvar_get(ed,'lat')
    # lon   <- ncdf4::ncvar_get(ed,'lon')
    # crs   <- ncdf4::ncvar_get(ed,'crs')
    var   <- raster::stack(file[1])            # WARNINGS
    times <- ncdf4::ncvar_get(ed,'time_bnds')
    inicial  <- as.POSIXct('2010-01-01 00:00:00',tz = 'GMT')

    time_start <- inicial + 60*60*24* times[1,]
    time_end   <- inicial + 60*60*24* times[2,]

    if(year > length(time_end)){
      stop('wrong armument value, year must be lesser than ',length(time_end),'\n  for ', file)
    }

    # Mg km-2 year-1
    unidades <- ncdf4::ncatt_get(ed,name[1],'units')$value

    # cat(' crs:',  crs,                           '\n',
    #     'var:',   name[1],                       '\n',
    #     'units:', unidades,                      '\n',
    #     'dim:',   dim(lat),                      '\n',
    #     'year:',  format(time_start[year], "%Y"),'\n')

    # var   <- var[,,year]
    # var[is.na(var)] <- 0
    var               <- var[[year]]
    var[is.na(var[])] <- 0

    # UNIT conversion
    # initial == units: Mg km-2 year-1
    # final   == units: g m-2 s-1

    # 'MgC km-2 year-1' to 'Mg km-2 year-1'
    var = 12.0107 * var

    # 'Mg km-2 year-1' to 'g km-2 year-1'
    # var = 1000000 * var                 # x10**6
    # 'g km-2 year-1' to 'g km-2 s-1'
    var = var / (365 * 24 * 60 * 60)
    # 'g km-2 s-1' to 'g m-2 s-1'
    # var = var / (1000 * 1000)           # /10**6

    cat(' var:',  name[1],                       '\n',
        'units:', 'g m-2 s-1',                   '\n',
        'year:',  format(time_start[year], "%Y"),'\n')

    if(as_raster){
      return(var)
      # max_lon <- max(lon,na.rm = T)
      # max_lat <- max(lat,na.rm = T)
      # min_lon <- min(lon,na.rm = T)
      # min_lat <- min(lat,na.rm = T)
      #
      # var <- t(var)
      # var <- apply(var, 2, rev)
      #
      # r   <- raster::raster(x   = var,
      #                       xmn = min_lon,
      #                       xmx = max_lon,
      #                       ymn = min_lat,
      #                       ymx = max_lat)
      # raster::crs(r) <- "+proj=longlat"
      # names(r) <- name[1]
      # return(r)
    }else{
      a <- raster_to_ncdf(var)
      if(dim(a)[3] == 1) a <- a[,,1,drop = T]

      return(a)
      # return(var)
    }
  }                                                        # nocov end

  if(as_raster){
    if(is.null(spec)){
      if(version == 'GAINS'){
        return(rz)                                          #nocov
      }else{
        return(raster::rotate(rz))
      }
    }else{
      if(verbose)  cat("using the following speciation:\n") # nocov start
      rz_spec <- list()
      for(i in 1:length(spec)){
        if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
        if(version == 'GAINS'){
          rz_spec[[i]] <- rz * spec[i]
        }else{
          rz_spec[[i]] <- raster::rotate(rz * spec[i])
        }
      }
      names(rz_spec) <- names(spec)
      return(rz_spec)                                      # nocov end
    }
  }else{
    if(is.null(spec)){
      return(varall)
    }else{
      if(verbose)  cat("using the following speciation:\n") # nocov start
      var_spec <- list()
      for(i in 1:length(spec)){
        if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
        var_spec[[i]] <- varall * spec[i]
      }
      names(var_spec) <- names(spec)
      return(var_spec)                                     # nocov end
    }
  }
}
