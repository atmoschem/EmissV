
#' Temporal profile for veicular emissions
#'
#' @description set of houtly profiles that represent the mean activity for each day of the week. These profiles comes from traffic counts of toll stations located in São Paulo city, for summer and winters of 2012, 2013 and 2014.
#'
#' @format A list of data frames by hour and weekday.
#'
#' @note The profile is normalized by days (but is balanced for a complete week) so diary emission x profile = hourly emission.
#'
#' @examples
#' # load the data
#' data(perfil)
#' \donttest{
#' # function to simple view
#' plot.perfil <- function(per = perfil$LDV, text="", color = "#0000FFBB"){
#'   plot(per[,1],ty = "l", ylim = range(per),axe = FALSE,
#'        xlab = "hour",ylab = "Intensity",main = text,col=color)
#'   for(i in 2:7){
#'     lines(per[,i],col = color)
#'   }
#'   for(i in 1:7){
#'     points(per[,i],col = "black", pch = 20)
#'   }
#'   axis(1,at=0.5+c(0,6,12,18,24),labels = c("00:00","06:00","12:00","18:00","00:00"))
#'   axis(2)
#'   box()
#' }
#'\donttest{
#' # view all profiles in perfil data
#' for(i in 1:length(names(perfil))){
#'   print(paste("profile",i,names(perfil)[i]))
#'   plot.perfil(perfil[[i]],names(perfil)[i])
#' }
#' }
#' }
#' @usage data(perfil)
#' @docType data
"perfil"
