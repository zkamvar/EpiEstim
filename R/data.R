#' Data on the 2009 H1N1 influenza pandemic in a school in New York city
#'
#' This data set gives:
#' 1/ the daily incidence of self-reported and laboratory-confirmed cases of influenza 
#' amongst children in a school in New York city during the 2009 H1N1 influenza pandemic (see source and references),
#' 2/ interval-censored serial interval data from the 2009 outbreak of H1N1 influenza 
#' in a New York city school (see references).
#' 
#' @name flu_2009_NYC_school
#' @docType data
#' @format A list of two elements: 
#' \describe{
#'   \item{incidence}{a dataframe with 14 lines containing dates in first column, and daily incidence in second column ,}
#'   \item{si_data}{a dataframe containing data on the generation time for 16 pairs of infector/infected individuals 
#'   (see references and see argument \code{si_data} of function \code{estimate_r} for details on columns) }
#' }
#' @source Lessler J. et al. (2009) Outbreak of 2009 pandemic influenza A (H1N1) at a New York City school. New Eng J Med 361: 2628-2636.
#' @references 
#' {
#' Lessler J. et al. (2009) Outbreak of 2009 pandemic influenza A (H1N1) at a New York City school. New Eng J Med 361: 2628-2636. }
#' @examples 
#' \dontrun{
#' ## Note the following examples use an MCMC routine 
#' ## to estimate the serial interval distribution from data, 
#' ## so they may take a few minutes to run
#' 
#' ## load data on pandemic flu in a New York school in 2009
#' data("flu_2009_NYC_school")
#' 
#' ## estimate the reproduction number (method "si_from_data")
#' estimate_r(flu_2009_NYC_school$incidence, method="si_from_data",
#'          si_data = flu_2009_NYC_school$si_data,
#'           config=list(t_start=2:8, t_end=8:14,
#'                       si_parametric_distr = "G", 
#'                       mcmc_control = list(burnin = 1000, 
#'                                  thin=10, seed = 1), 
#'                       n1 = 1000, n2 = 50,
#'                       plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
#' }
NULL

##################################################################################################
#' Data on the 1918 H1N1 influenza pandemic in Baltimore.
#'
#' This data set gives:
#' 1/ the daily incidence of onset of disease in Baltimore during the 1918 H1N1 influenza pandemic (see source and references),
#' 2/ the discrete daily distribution of the serial interval for influenza, assuming a shifted Gamma distribution with mean 2.6 days, standard deviation 1.5 days and shift 1 day (see references).
#' 
#' @name Flu1918
#' @docType data
#' @format A list of two elements: 
#' \describe{
#'   \item{incidence}{a vector containing 92 days of observation,}
#'   \item{si_distr}{a vector containing a set of 12 probabilities.}
#' }
#' @source Frost W. and E. Sydenstricker (1919) Influenza in Maryland: preliminary statistics of certain localities. Public Health Rep.(34): 491-504.
#' @references 
#' {
#' Cauchemez S. et al. (2011) Role of social networks in shaping disease transmission during a community outbreak of 2009 H1N1 pandemic influenza. Proc Natl Acad Sci U S A 108(7), 2825-2830.
#' 
#' Ferguson N.M. et al. (2005) Strategies for containing an emerging influenza pandemic in Southeast Asia. Nature 437(7056), 209-214.
#' 
#' Fraser C. et al. (2011) Influenza Transmission in Households During the 1918 Pandemic. Am J Epidemiol 174(5): 505-514.
#' 
#' Frost W. and E. Sydenstricker (1919) Influenza in Maryland: preliminary statistics of certain localities. Public Health Rep.(34): 491-504.
#' 
#' Vynnycky E. et al. (2007) Estimates of the reproduction numbers of Spanish influenza using morbidity data. Int J Epidemiol 36(4): 881-889.
#' 
#' White L.F. and M. Pagano (2008) Transmissibility of the influenza virus in the 1918 pandemic. PLoS One 3(1): e1498.
#' }
#' @examples 
#' ## load data on pandemic flu in Baltimore in 1918
#' data("Flu1918")
#' 
#' ## estimate the reproduction number (method "non_parametric_si")
#' estimate_r(Flu1918$incidence, 
#'           method="non_parametric_si",
#'           config=list(t_start=2:86, t_end=8:92, 
#'                       si_distr=Flu1918$si_distr, 
#'                       plot=TRUE))
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
NULL

##################################################################################################

#' Data on the 2009 H1N1 influenza pandemic in a school in Pennsylvania.
#'
#' This data set gives:
#' 1/ the daily incidence of onset of acute respiratory illness 
#' (ARI, defined as at least two symptoms among fever, cough, sore throat, and runny nose)
#' amongst children in a school in Pennsylvania during the 2009 H1N1 influenza pandemic (see source and references),
#' 2/ the discrete daily distribution of the serial interval for influenza, assuming a shifted Gamma distribution with mean 2.6 days, standard deviation 1.5 days and shift 1 day (see references).
#' 3/ interval-censored serial interval data from the 2009 outbreak of H1N1 influenza 
#' in San Antonio, Texas, USA (see references).
#' 
#' @name Flu2009
#' @docType data
#' @format A list of three elements: 
#' \describe{
#'   \item{incidence}{a dataframe with 32 lines containing dates in first column, and daily incidence in second column (Cauchemez et al., 2011),}
#'   \item{si_distr}{a vector containing a set of 12 probabilities (Ferguson et al, 2005),}
#'   \item{si_data}{a dataframe with 16 lines giving serial interval patient data collected in a household study in San Antonio, 
#'   Texas throughout the 2009 H1N1 outbreak (Morgan et al., 2010). }
#' }
#' @source 
#' {
#' Cauchemez S. et al. (2011) Role of social networks in shaping disease transmission during a community outbreak of 2009 H1N1 pandemic influenza. Proc Natl Acad Sci U S A 108(7), 2825-2830.
#' 
#' Morgan O.W. et al. (2010) Household transmission of pandemic (H1N1) 2009, San Antonio, Texas, USA, April-May 2009. Emerg Infect Dis 16: 631-637. 
#' }
#' @references 
#' {
#' Cauchemez S. et al. (2011) Role of social networks in shaping disease transmission during a community outbreak of 2009 H1N1 pandemic influenza. Proc Natl Acad Sci U S A 108(7), 2825-2830.
#' 
#' Ferguson N.M. et al. (2005) Strategies for containing an emerging influenza pandemic in Southeast Asia. Nature 437(7056), 209-214.
#' }
#' @examples 
#' ## load data on pandemic flu in a school in 2009
#' data("Flu2009")
#' 
#' ## estimate the reproduction number (method "non_parametric_si")
#' estimate_r(Flu2009$incidence, method="non_parametric_si",
#'           config=list(t_start=2:26, t_end=8:32, 
#'                       si_distr=Flu2009$si_distr, 
#'                       plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
#' 
#' \dontrun{
#' ## Note the following examples use an MCMC routine 
#' ## to estimate the serial interval distribution from data, 
#' ## so they may take a few minutes to run
#' 
#' ## estimate the reproduction number (method "si_from_data")
#' estimate_r(Flu2009$incidence, method="si_from_data",
#'           si_data = Flu2009$si_data,
#'           config=list(t_start=2:26, t_end=8:32, 
#'                       mcmc_control = list(burnin = 1000, 
#'                                  thin=10, seed = 1), 
#'                       n1 = 1000, n2 = 50,
#'                       si_parametric_distr = "G",
#'                       plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
#' }
#' 
#' 
NULL

##################################################################################################

#' Data on the 1861 measles epidemic in Hagelloch, Germany.
#'
#' This data set gives:
#' 1/ the daily incidence of onset of symptoms in Hallegoch (Germany) during the 1861 measles epidemic (see source and references),
#' 2/ the discrete daily distribution of the serial interval for measles, assuming a shifted Gamma distribution with mean 14.9 days, standard deviation 3.9 days and shift 1 day (see references).
#' 
#' @name Measles1861
#' @docType data
#' @format A list of two elements: 
#' \describe{
#'   \item{incidence}{a vector containing 48 days of observation,}
#'   \item{si_distr}{a vector containing a set of 38 probabilities.}
#' }
#' @source Groendyke C. et al. (2011) Bayesian Inference for Contact Networks Given Epidemic Data. Scandinavian Journal of Statistics 38(3): 600-616.
#' @references Groendyke C. et al. (2011) Bayesian Inference for Contact Networks Given Epidemic Data. Scandinavian Journal of Statistics 38(3): 600-616.
#' @examples 
#' ## load data on measles in Hallegoch in 1861
#' data("Measles1861")
#' 
#' ## estimate the reproduction number (method "non_parametric_si")
#' estimate_r(Measles1861$incidence, method="non_parametric_si",
#'           config=list(t_start=17:42, t_end=23:48, 
#'                 si_distr=Measles1861$si_distr, 
#'                 plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
NULL

##################################################################################################

#' Data on the 2003 SARS epidemic in Hong Kong.
#'
#' This data set gives:
#' 1/ the daily incidence of onset of symptoms in Hong Kong during the 2003 severe acute respiratory syndrome (SARS) epidemic (see source and references),
#' 2/ the discrete daily distribution of the serial interval for SARS, assuming a shifted Gamma distribution with mean 8.4 days, standard deviation 3.8 days and shift 1 day (see references).
#' 
#' @name SARS2003
#' @docType data
#' @format A list of two elements: 
#' \describe{
#'   \item{incidence}{a vector containing 107 days of observation,}
#'   \item{si_distr}{a vector containing a set of 25 probabilities.}
#' }
#' @source Cori A. et al. (2009) Temporal variability and social heterogeneity in disease transmission: the case of SARS in Hong Kong. PLoS Comput Biol 5(8): e1000471.
#' @references 
#' {
#' Cori A. et al. (2009) Temporal variability and social heterogeneity in disease transmission: the case of SARS in Hong Kong. PLoS Comput Biol 5(8): e1000471.
#' 
#' Lipsitch M. et al. (2003) Transmission dynamics and control of severe acute respiratory syndrome. Science 300(5627): 1966-1970.
#' }
#' @examples 
#' ## load data on SARS in Hong Kong in 2003
#' data("SARS2003")
#' 
#' ## estimate the reproduction number (method "non_parametric_si")
#' estimate_r(SARS2003$incidence, method="non_parametric_si",
#'           config=list(t_start=14:101, t_end=20:107, 
#'                       si_distr=SARS2003$si_distr, 
#'                       plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
NULL

##################################################################################################

#' Data on the 1972 smallpox epidemic in Kosovo
#'
#' This data set gives:
#' 1/ the daily incidence of onset of symptoms in Kosovo during the 1972 smallpox epidemic (see source and references),
#' 2/ the discrete daily distribution of the serial interval for smallpox, assuming a shifted Gamma distribution with mean 22.4 days, standard deviation 6.1 days and shift 1 day (see references).
#' 
#' @name Smallpox1972
#' @docType data
#' @format A list of two elements: 
#' \describe{
#'   \item{incidence}{a vector containing 57 days of observation,}
#'   \item{si_distr}{a vector containing a set of 46 probabilities.}
#' }
#' @source Fenner F. et al. (1988) Smallpox and its Eradication. Geneva, World Health Organization.
#' @references 
#' {
#' Fenner F. et al. (1988) Smallpox and its Eradication. Geneva, World Health Organization.
#' 
#' Gani R. and S. Leach (2001) Transmission potential of smallpox in contemporary populations. Nature 414(6865): 748-751.
#'
#' Riley S. and N. M. Ferguson (2006) Smallpox transmission and control: spatial dynamics in Great Britain. Proc Natl Acad Sci U S A 103(33): 12637-12642.
#' }
#' @examples 
#' ## load data on smallpox in Kosovo in 1972
#' data("Smallpox1972")
#' 
#' ## estimate the reproduction number (method "non_parametric_si")
#' estimate_r(Smallpox1972$incidence, method="non_parametric_si",
#'           config=list(t_start=27:51, t_end=33:57, 
#'                       si_distr=Smallpox1972$si_distr, 
#'                       plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
NULL

##################################################################################################

#' Mock data on a rotavirus epidemic.
#'
#' This data set gives:
#' 1/ the daily incidence of onset of symptoms in a mock outbreak of rotavirus ,
#' 2/ mock observations of symptom onset dates for 19 pairs of infector/infected individuals.
#' 
#' @name MockRotavirus
#' @docType data
#' @format A list of two elements: 
#' \describe{
#'   \item{incidence}{a vector containing 53 days of observation,}
#'   \item{si_distr}{a dataframe containing a set of 19 observations; each observation corresponds to a pair of infector/infected individuals. EL and ER columns contain the lower an upper bounds of the dates of symptoms onset in the infectors. SL and SR columns contain the lower an upper bounds of the dates of symptoms onset in the infected indiviuals. The type column corresponds to XXX TO BE COMPLETED XXX}
#' }
#' @source XXX TO BE COMPLETED XXX
#' @references 
#' {
#' XXX TO BE COMPLETED XXX
#' }
#' @examples 
#' \dontrun{
#' ## Note the following example uses an MCMC routine 
#' ## to estimate the serial interval distribution from data, 
#' ## so may take a few minutes to run
#' 
#' ## load data 
#' data("MockRotavirus")
#' 
#' ## estimate the reproduction number (method "si_from_data")
#' estimate_r(MockRotavirus$incidence, 
#'           method="si_from_data", 
#'           si_data=MockRotavirus$si_data,
#'           config=list(
#'             t_start=2:47, t_end=8:53,  
#'             si_parametric_distr = "G", 
#'             mcmc_control = list(burnin = 3000, thin=10), 
#'             n1 = 500, n2 = 50,
#'             plot=TRUE)
#'           )
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number 
#' # over the 7-day window finishing on that day.
#' }
NULL


