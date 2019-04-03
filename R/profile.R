#' Temporal profile for emissions
#'
#' @description Set of hourly profiles that represents the mean activity for each hour (local time) of the week.
#'
#' \describe{
#'   \item{LDV}{Light Duty vehicles}
#'   \item{HDV}{Heavy Duty vehicles}
#'   \item{PC_JUNE_2012}{passenger cars counted in June 2012}
#'   \item{PC_JUNE_2013}{passenger cars counted in June 2013}
#'   \item{PC_JUNE_2014}{passenger cars counted in June 2014}
#'   \item{LCV_JUNE_2012}{light comercial vehicles counted in June 2012}
#'   \item{LCV_JUNE_2013}{light comercial vehicles counted in June 2013}
#'   \item{LCV_JUNE_2014}{light comercial vehicles counted in June 2014}
#'   \item{MC_JUNE_2012}{motorcycles counted in June 2012}
#'   \item{MC_JUNE_2013}{motorcycles counted in June 2013}
#'   \item{MC_JUNE_2014}{motorcycles counted in June 2014}
#'   \item{HGV_JUNE_2012}{Heavy good vehicles counted in June 2012}
#'   \item{HGV_JUNE_2013}{Heavy good vehicles counted in June 2013}
#'   \item{HGV_JUNE_2014}{Heavy good vehicles counted in June 2014}
#'   \item{PC_JANUARY_2012}{passenger cars counted in january 2012}
#'   \item{PC_JANUARY_2013}{passenger cars counted in january 2013}
#'   \item{PC_JANUARY_2014}{passenger cars counted in january 2014}
#'   \item{LCV_JANUARY_2012}{light comercial vehicles counted in january 2012}
#'   \item{LCV_JANUARY_2013}{light comercial vehicles counted in january 2013}
#'   \item{LCV_JANUARY_2014}{light comercial vehicles counted in january 2014}
#'   \item{MC_JANUARY_2012}{Motorcycles counted in january 2012}
#'   \item{MC_JANUARY_2014}{Motorcycles counted in january 2014}
#'   \item{HGV_JANUARY_2012}{Heavy good vehicles counted in january 2012}
#'   \item{HGV_JANUARY_2013}{Heavy good vehicles counted in january 2013}
#'   \item{HGV_JANUARY_2014}{Heavy good vehicles counted in january 2014}
#'   \item{POW}{Power generation emission profile}
#'   \item{IND}{Industrial emission profile}
#'   \item{RES}{Residencial emission profile}
#'   \item{TRA}{Transport emission profile}
#'   \item{AGR}{Agriculture emission profile}
#'   \item{SHP}{Emission profile for ships}
#'   \item{SLV}{Solvent use emission constant profile}
#'   \item{WBD}{Waste burning emisssion constant profile}
#'   \item{PC_nov_2018}{passenger cars at Janio Quadros on November 2018}
#'   \item{HGV_nov_2018}{heavy good vehicles at Janio Quadros on November 2018}
#'   \item{TOTAL_nov_2018}{total vehicle at Janio Quadros on November 2018}
#'   \item{PC_out_2018}{passenger cars at Anhanguera-Castello Branco on October 2018}
#'   \item{MC_out_2018}{Motorcycles cars at Anhanguera-Castello Branco on October 2018}
#'
#' }
#'
#' @details
#'
#' - Profiles 1 to 2 are from traffic count at São Paulo city from Perez Martínez et al (2014).
#'
#' - Profiles 3 to 25 comes from traffic counted of toll stations located in São Paulo city,
#' for summer and winters of 2012, 2013 and 2014.
#'
#' - Profiles 26 to 33 are for different sectors from Oliver et al (2003).
#'
#' - Profiles 34 to 36 are for volumetric mechanized traffic count at Janio Quadros tunnel on November 2018.
#'
#' - Profiles 37 to 38 are for volumetric mechanized traffic count at Anhanguera-Castello Branco on October 2018.
#'
#' @references
#'
#' Pérez-Martínez, P. J., Miranda, R. M., Nogueira, T., Guardani, M. L., Fornaro, A., Ynoue, R., &
#' Andrade, M. F. (2014). Emission factors of air pollutants from vehicles measured inside road
#' tunnels in São Paulo: case study comparison. International Journal of Environmental Science
#' and Technology, 11(8), 2155-2168.
#'
#' Olivier, J., J. Peters, C. Granier, G. Pétron, J.F. Müller, and S. Wallens,
#' Present and future surface emissions of atmospheric compounds, POET Report #2,
#' EU project EVK2-1999-00011, 2003.
#'
#' @format A list of data frames with activity by hour and weekday.
#'
#' @note The profile is normalized by days (but is balanced for a complete week) it means
#' diary_emission x profile = hourly_emission.
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
#'   cat(paste("profile",i,names(perfil)[i],"\n"))
#'   plot.perfil(perfil[[i]],names(perfil)[i])
#' }
#' }
#' }
#' @usage data(perfil)
#' @docType data
"perfil"
