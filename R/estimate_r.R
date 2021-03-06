#########################################################################################################################
# estimate_r replaces the old EstimateR function #
#########################################################################################################################

#' Estimated Instantaneous Reproduction Number
#' 
#' \code{estimate_r} estimates the reproduction number of an epidemic, given the incidence time series and the serial interval distribution. 
#' 
#' @param incid One of the following
#' \itemize{
#' \item{A vector (or a dataframe with a single column) of non-negative integers containing the incidence time series}
#' \item{A dataframe of non-negative integers with either i) \code{incid$I} containing the total incidence, or ii) two columns, 
#' so that \code{incid$local} contains the incidence of cases due to local transmission and 
#' \code{incid$imported} contains the incidence of imported cases (with \code{incid$local + incid$imported} 
#' the total incidence). If the dataframe contains a column \code{incid$dates}, this is used for plotting. 
#' \code{incid$dates} must contains only dates in a row.}
#' \item{An object of class \code{\link[incidence]{incidence}}}
#' } 
#' Note that the cases from the first time step are always all assumed to be imported cases.
#' @param method One of "non_parametric_si", "parametric_si", "uncertain_si", "si_from_data" or "si_from_sample" (see details).
#' @param si_sample For method "si_from_sample" ; a matrix where each column gives one distribution of the serial interval to be explored (see details).
#' @param si_data For method "si_from_data" ; the data on dates of symptoms of pairs of infector/infected individuals to be used to estimate the serial interval distribution (see details).
#' @param config A list containing the following:
#' \describe{
#' \item{t_start}{Vector of positive integers giving the starting times of each window over which the reproduction number will be estimated. These must be in ascending order, and so that for all \code{i}, \code{t_start[i]<=t_end[i]}. t_start[1] should be strictly after the first day with non null incidence.}
#' \item{t_end}{Vector of positive integers giving the ending times of each window over which the reproduction number will be estimated. These must be in ascending order, and so that for all \code{i}, \code{t_start[i]<=t_end[i]}.}
#' \item{n1}{For method "uncertain_si" and "si_from_data"; positive integer giving the size of the sample of SI distributions to be drawn (see details).}
#' \item{n2}{For methods "uncertain_si", "si_from_data" and "si_from_sample"; positive integer giving the size of the sample drawn from the posterior distribution of R for each serial interval distribution considered (see details).}
#' \item{mean_si}{For method "parametric_si" and "uncertain_si" ; positive real giving the mean serial interval (method "parametric_si") or the average mean serial interval (method "uncertain_si", see details).}
#' \item{std_si}{For method "parametric_si" and "uncertain_si" ; non negative real giving the stadard deviation of the serial interval (method "parametric_si") or the average standard deviation of the serial interval (method "uncertain_si", see details).}
#' \item{std_mean_si}{For method "uncertain_si" ; standard deviation of the distribution from which mean serial intervals are drawn (see details).}
#' \item{min_mean_si}{For method "uncertain_si" ; lower bound of the distribution from which mean serial intervals are drawn (see details).}
#' \item{max_mean_si}{For method "uncertain_si" ; upper bound of the distribution from which mean serial intervals are drawn (see details).}
#' \item{std_std_si}{For method "uncertain_si" ; standard deviation of the distribution from which standard deviations of the serial interval are drawn (see details).}
#' \item{min_std_si}{For method "uncertain_si" ; lower bound of the distribution from which standard deviations of the serial interval are drawn (see details).}
#' \item{max_std_si}{For method "uncertain_si" ; upper bound of the distribution from which standard deviations of the serial interval are drawn (see details).}
#' \item{si_distr}{For method "non_parametric_si" ; vector of probabilities giving the discrete distribution of the serial interval, starting with \code{si_distr[1]} (probability that the serial interval is zero), which should be zero.}
#' \item{si_parametric_distr}{For method "si_from_data" ; the parametric distribution to use when estimating the serial interval from data on dates of symptoms of pairs of infector/infected individuals (see details).
#' Should be one of "G" (Gamma), "W" (Weibull), "L" (Lognormal), "off1G" (Gamma shifted by 1), "off1W" (Weibull shifted by 1), or "off1L" (Lognormal shifted by 1).}
#' \item{mcmc_control}{For method "si_from_data" ; a list containing the following (see details):
#' \describe{
#'   \item{init_pars}{vector of size 2 corresponding to the initial values of parameters to use for the SI distribution. This is the shape and scale for all but the lognormal distribution, for which it is the meanlog and sdlog. If not specified these are chosen automatically using function \code{\link{init_mcmc_params}}.}
#'   \item{burnin}{a positive integer giving the burnin used in the MCMC when estimating the serial interval distribution.}
#'   \item{thin}{a positive integer corresponding to thinning parameter; the MCMC will be run for \code{burnin+n1*thin iterations}; 1 in \code{thin} iterations will be recorded, after the burnin phase, so the posterior sample size is n1.}
#'   \item{seed}{An integer used as the seed for the random number generator at the start of the MCMC estimation; useful to get reproducible results.} 
#' }}
#' \item{seed}{An optional integer used as the seed for the random number generator at the start of the function (then potentially reset within the MCMC for method \code{si_from_data}); useful to get reproducible results.}
#' \item{mean_prior}{A positive number giving the mean of the common prior distribution for all reproduction numbers (see details).}
#' \item{std_prior}{A positive number giving the standard deviation of the common prior distribution for all reproduction numbers (see details).}
#' \item{cv_posterior}{A positive number giving the aimed posterior coefficient of variation (see details).}
#' \item{plot}{Logical. If \code{TRUE} (default is \code{FALSE}), output is plotted (see value).}
#' \item{legend}{A boolean (TRUE by default) governing the presence / absence of legends on the plots}
#' }
#' @return {
#' a list with components: 
#' \itemize{
#' \item{R}{: a dataframe containing: 
#' the times of start and end of each time window considered ; 
#' the posterior mean, std, and 0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975 quantiles of the reproduction number for each time window.}
#' 	\item{method}{: the method used to estimate R, one of "non_parametric_si", "parametric_si", "uncertain_si", "si_from_data" or "si_from_sample"}
#' 	\item{si_distr}{: a vector or dataframe (depending on the method) containing the discrete serial interval distribution(s) used for estimation}
#' 	\item{SI.Moments}{: a vector or dataframe (depending on the method) containing the mean and std of the discrete serial interval distribution(s) used for estimation}
#' 	\item{I}{: the time series of total incidence}
#' 	\item{I_local}{: the time series of incidence of local cases (so that \code{I_local + I_imported = I})}
#' 	\item{I_imported}{: the time series of incidence of imported cases (so that \code{I_local + I_imported = I})}
#' 	\item{dates}{: a vector of dates corresponding to the incidence time series}
#' 	\item{MCMC_converged}{ (only for method \code{si_from_data}): a boolean showing whether the Gelman-Rubin MCMC convergence diagnostic was successful (\code{TRUE}) or not (\code{FALSE})}
#' }
#' }
#' @details{
#' Analytical estimates of the reproduction number for an epidemic over predefined time windows can be obtained within a Bayesian framework, 
#' for a given discrete distribution of the serial interval (see references). 
#' 
#' The more incident cases are observed over a time window, the smallest the posterior coefficient of variation (CV, ratio of standard deviation over mean) of the reproduction number. 
#' An aimed CV can be specified in the argument \code{cv_posterior} (default is \code{0.3}), and a warning will be produced if the incidence within one of the time windows considered is too low to get this CV. 
#' 
#' The methods vary in the way the serial interval distribution is specified. 
#' 
#' In short there are five methods to specify the serial interval distribution (see below for more detail on each method). 
#' In the first two methods, a unique serial interval distribution is considered, whereas in the last three, a range of serial interval distributions are integrated over:
#' \itemize{
#' \item{In method "non_parametric_si" the user specifies the discrete distribution of the serial interval}
#' \item{In method "parametric_si" the user specifies the mean and sd of the serial interval}
#' \item{In method "uncertain_si" the mean and sd of the serial interval are each drawn from truncated normal distributions, with parameters specified by the user}
#' \item{In method "si_from_data", the serial interval distribution is directly estimated, using MCMC, from interval censored exposure data, with data provided by the user together with a choice of parametric distribution for the serial interval}
#' \item{In method "si_from_sample", the user directly provides the sample of serial interval distribution to use for estimation of R. This can be a useful alternative to the previous method, where the MCMC estimation of the serial interval distribution could be run once, and the same estimated SI distribution then used in estimate_r in different contexts, e.g. with different time windows, hence avoiding to rerun the MCMC everytime estimate_r is called.}
#' }
#' 
#' If \code{plot} is \code{TRUE}, 3 plots are produced. 
#' The first one shows the epidemic curve. 
#' The second one shows the posterior mean and 95\% credible interval of the reproduction number. The estimate for a time window is plotted at the end of the time window. 
#' The third plot shows the discrete distribution(s) of the serial interval. 
#' 
#' ----------------------- \code{method "non_parametric_si"} -----------------------
#'   
#' The discrete distribution of the serial interval is directly specified in the argument \code{si_distr}.
#' 
#' ----------------------- \code{method "parametric_si"} -----------------------
#'   
#' The mean and standard deviation of the continuous distribution of the serial interval are given in the arguments \code{mean_si} and \code{std_si}.
#' The discrete distribution of the serial interval is derived automatically using \code{\link{discr_si}}.
#' 
#' ----------------------- \code{method "uncertain_si"} -----------------------
#'    
#' \code{Method "uncertain_si"} allows accounting for uncertainty on the serial interval distribution as described in Cori et al. AJE 2013.
#' We allow the mean \eqn{\mu} and standard deviation \eqn{\sigma} of the serial interval to vary according to truncated normal distributions. 
#' We sample \code{n1} pairs of mean and standard deviations, \eqn{(\mu^{(1)},\sigma^{(1)}),...,(\mu^{(n_2)},\sigma^{(n_2)})}, by first sampling the mean \eqn{\mu^{(k)}} 
#' from its truncated normal distribution (with mean \code{mean_si}, standard deviation \code{std_mean_si}, minimum \code{min_mean_si} and maximum \code{max_mean_si}), 
#' and then sampling the standard deviation \eqn{\sigma^{(k)}} from its truncated normal distribution 
#' (with mean \code{std_si}, standard deviation \code{std_std_si}, minimum \code{min_std_si} and maximum \code{max_std_si}), but imposing that \eqn{\sigma^{(k)}<\mu^{(k)}}. 
#' This constraint ensures that the Gamma probability density function of the serial interval is null at \eqn{t=0}. 
#' Warnings are produced when the truncated normal distributions are not symmetric around the mean. 
#' For each pair \eqn{(\mu^{(k)},\sigma^{(k)})}, we then draw a sample of size \code{n2} in the posterior distribution of the reproduction number over each time window, conditionnally on this serial interval distribution. 
#' After pooling, a sample of size \eqn{\code{n1}\times\code{n2}} of the joint posterior distribution of the reproduction number over each time window is obtained.
#' The posterior mean, standard deviation, and 0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975 quantiles of the reproduction number for each time window are obtained from this sample.
#' 
#' ----------------------- \code{method "si_from_data"} -----------------------
#'   
#' \code{Method "si_from_data"} allows accounting for uncertainty on the serial interval distribution. 
#' Unlike method "uncertain_si", where we arbitrarily vary the mean and std of the SI in truncated normal distributions, 
#' here, the scope of serial interval distributions considered is directly informed by data
#' on the (potentially censored) dates of symptoms of pairs of infector/infected individuals. 
#' This data, specified in argument \code{si_data}, should be a dataframe with 5 columns:
#' \itemize{
#' \item{EL: the lower bound of the symptom onset date of the infector (given as an integer)}
#' \item{ER: the upper bound of the symptom onset date of the infector (given as an integer). Should be such that ER>=EL}
#' \item{SL: the lower bound of the symptom onset date of the infected indivdiual (given as an integer)}
#' \item{SR: the upper bound of the symptom onset date of the infected indivdiual (given as an integer). Should be such that SR>=SL}
#' \item{type (optional): can have entries 0, 1, or 2, corresponding to doubly interval-censored, single interval-censored or exact observations, respectively, see Reich et al. Statist. Med. 2009. If not specified, this will be automatically computed from the dates}
#' }
#' Assuming a given parametric distribution for the serial interval distribution (specified in si_parametric_distr), 
#' the posterior distribution of the serial interval is estimated directly fom these data using MCMC methods implemented in the package \code{coarsedatatools}. 
#' The argument \code{mcmc_control} is a list of characteristics which control the MCMC. 
#' The MCMC is run for a total number of iterations of \code{mcmc_control$burnin + n1*mcmc_control$thin};
#' but the output is only recorded after the burnin, and only 1 in every \code{mcmc_control$thin} iterations, 
#' so that the posterior sample size is \code{n1}.
#' For each element in the posterior sample of serial interval distribution, 
#' we then draw a sample of size \code{n2} in the posterior distribution of the reproduction number over each time window, 
#' conditionnally on this serial interval distribution. 
#' After pooling, a sample of size \eqn{\code{n1}\times\code{n2}} of the joint posterior distribution of 
#' the reproduction number over each time window is obtained.
#' The posterior mean, standard deviation, and 0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975 quantiles of the reproduction number for each time window are obtained from this sample.
#' 
#' ----------------------- \code{method "si_from_sample"} -----------------------
#'
#' \code{Method "si_from_sample"} also allows accounting for uncertainty on the serial interval distribution. 
#' Unlike methods "uncertain_si" and "si_from_data", the user directly provides (in argument \code{si_sample}) a sample of serial interval distribution to be explored. 
#' 
#' }
#' @seealso \code{\link{discr_si}}
#' @author Anne Cori \email{a.cori@imperial.ac.uk} 
#' @references {
#' Cori, A. et al. A new framework and software to estimate time-varying reproduction numbers during epidemics (AJE 2013).
#' Wallinga, J. and P. Teunis. Different epidemic curves for severe acute respiratory syndrome reveal similar impacts of control measures (AJE 2004).
#' Reich, N.G. et al. Estimating incubation period distributions with coarse data (Statis. Med. 2009)
#' }
#' @importFrom coarseDataTools dic.fit.mcmc
#' @importFrom coda as.mcmc.list as.mcmc
#' @export
#' @examples
#' ## load data on pandemic flu in a school in 2009
#' data("Flu2009")
#' 
#' ## estimate the reproduction number (method "non_parametric_si")
#' estimate_r(Flu2009$incidence, method="non_parametric_si", 
#'           config=list(t_start=2:26, t_end=8:32,
#'           si_distr=Flu2009$si_distr, plot=TRUE))
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number over the 7-day window finishing on that day.
#' 
#' ## example with an incidence object
#' 
#' # create fake data
#' library(incidence)
#' data <- c(0,1,1,2,1,3,4,5,5,5,5,4,4,26,6,7,9)
#' location <- sample(c("local","imported"), length(data), replace=TRUE)
#' location[1] <- "imported" # forcing the first case to be imported
#' # get incidence per group (location)
#' incid <- incidence(data, groups = location)
#' # Estimate R with assumptions on serial interval
#' estimate_r(incid, method = "parametric_si", 
#'           config=list(t_start = 2:21, t_end = 8:27,
#'           mean_si = 2.6, std_si = 1.5, plot = TRUE))
#' 
#' ## estimate the reproduction number (method "parametric_si")
#' estimate_r(Flu2009$incidence, method="parametric_si", 
#'           config=list(t_start=2:26, t_end=8:32, 
#'           mean_si=2.6, std_si=1.5, plot=TRUE))
#' # the second plot produced shows, at each each day, 
#' # the estimate of the reproduction number over the 7-day window finishing on that day.
#' 
#' ## estimate the reproduction number (method "uncertain_si")
#' estimate_r(Flu2009$incidence, method="uncertain_si",
#'           config=list(t_start=2:26, t_end=8:32,
#'           mean_si=2.6, std_mean_si=1, min_mean_si=1, max_mean_si=4.2, 
#'           std_si=1.5, std_std_si=0.5, min_std_si=0.5, max_std_si=2.5, 
#'           n1=100, n2=100, plot=TRUE))
#' # the bottom left plot produced shows, at each each day, 
#' # the estimate of the reproduction number over the 7-day window finishing on that day.
#' 
#' \dontrun{
#' ## Note the following examples use an MCMC routine 
#' ## to estimate the serial interval distribution from data, 
#' ## so they may take a few minutes to run
#' 
#' ## load data on rotavirus
#' data("MockRotavirus")
#' 
#' ## estimate the reproduction number (method "si_from_data")
#' MCMC_seed <- 1
#' overall_seed <- 2
#' R_si_from_data <- estimate_r(MockRotavirus$incidence,
#'                             method="si_from_data",  
#'                             si_data=MockRotavirus$si_data, 
#'                             config=list(t_start=2:47, t_end=8:53, 
#'                                         si_parametric_distr = "G", 
#'                                         mcmc_control = list(burnin = 1000, 
#'                                         thin=10, seed = MCMC_seed), 
#'                                         n1 = 500, n2 = 50,
#'                                         seed = overall_seed,
#'                                         plot=TRUE))
#' ## compare with version with no uncertainty
#' R_Parametric <- estimate_r(MockRotavirus$incidence, 
#'                           method="parametric_si", 
#'                           config=list(t_start=2:47, t_end=8:53, 
#'                                       mean_si = mean(R_si_from_data$SI.Moments$Mean), 
#'                                       std_si = mean(R_si_from_data$SI.Moments$Std), 
#'                                       plot=TRUE))
#' ## generate plots
#' p_uncertainty <- plots(R_si_from_data, "R", options_R=list(ylim=c(0, 1.5)))
#' p_no_uncertainty <- plots(R_Parametric, "R", options_R=list(ylim=c(0, 1.5)))
#' gridExtra::grid.arrange(p_uncertainty, p_no_uncertainty,ncol=2)
#' # the left hand side graph is with uncertainty in the SI distribution, the right hand side without. 
#' # The credible intervals are wider when accounting for uncertainty in the SI distribution. 
#' 
#' #' ## estimate the reproduction number (method "si_from_sample")
#' MCMC_seed <- 1
#' overall_seed <- 2
#' SI.fit <- coarseDataTools::dic.fit.mcmc(dat = MockRotavirus$si_data, 
#'                              dist = "G", 
#'                              init.pars = init_mcmc_params(MockRotavirus$si_data, "G"),
#'                              burnin = 1000, 
#'                              n.samples = 5000, 
#'                              seed = MCMC_seed)
#' si_sample <- coarse2estim(SI.fit, thin=10)$si_sample
#' R_si_from_sample <- estimate_r(MockRotavirus$incidence, 
#'                             method = "si_from_sample", si_sample = si_sample,
#'                             config = list(t_start = 2:47, t_end = 8:53, 
#'                             n2 = 50,
#'                             seed = overall_seed,
#'                             plot = TRUE))
#' 
#' # check that R_si_from_sample is the same as R_si_from_data 
#' # since they were generated using the same MCMC algorithm to generate the SI sample
#' # (either internally to EpiEstim or externally)
#' all(R_si_from_sample$R$`Mean(R)` == R_si_from_data$R$`Mean(R)`) 
#' }
#' 
estimate_r <- function(incid,
                       method = c("non_parametric_si", "parametric_si",
                                  "uncertain_si", "si_from_data",
                                  "si_from_sample"),
                       si_data = NULL,
                       si_sample = NULL,
                       config) {
  
  method <- match.arg(method)
  config <- process_config(config)
  check_config(config, method)
  
  if (method=="si_from_data") {
    # Warning if the expected set of parameters is not adequate
    si_data <- process_si_data(si_data)
    config <- process_config_si_from_data(config, si_data)
    
    # estimate serial interval from serial interval data first
    if(!is.null(config$mcmc_control$seed)) {
      cdt <- dic.fit.mcmc(dat = si_data,
                          dist=config$si_parametric_distr,
                          burnin = config$mcmc_control$burnin,
                          n.samples = config$n1*config$mcmc_control$thin,
                          init.pars = config$mcmc_control$init_pars,
                          seed = config$mcmc_control$seed)
    }else{
      cdt <- dic.fit.mcmc(dat = si_data,
                          dist=config$si_parametric_distr,
                          burnin = config$mcmc_control$burnin,
                          n.samples = config$n1*config$mcmc_control$thin,
                          init.pars = config$mcmc_control$init_pars)
    }
    
    # check convergence of the MCMC and print warning if not converged
    MCMC_conv <- check_cdt_samples_convergence(cdt@samples)
    
    # thin the chain, and turn the two parameters of the SI distribution into a whole discrete distribution
    c2e <- coarse2estim(cdt, thin=config$mcmc_control$thin)
    
    cat(paste(
      "\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",
      "\nEstimating the reproduction number for these serial interval",
      "estimates...\n",
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    ))
    
    # then estimate R for these serial intervals
    
    if(!is.null(config$seed))
    {
      set.seed(config$seed)
    }
    
    out <- estimate_r_func(incid = incid,
                           method = "si_from_data",
                           si_sample = c2e$si_sample,
                           config = config
    )
    out[["MCMC_converged"]] <- MCMC_conv
  } else {
    
    if(!is.null(config$seed))
    {
      set.seed(config$seed)
    }
    
    out <- estimate_r_func(incid = incid, method = method, si_sample=si_sample,
                           config = config
    )
  }
  return(out)
}

#########################################################
# estimate_r_func: Doing the heavy work in estimate_r     #
#########################################################

#' @import reshape2 grid gridExtra
#' @importFrom ggplot2 last_plot ggplot aes aes_string geom_step ggtitle geom_ribbon geom_line xlab ylab xlim geom_hline ylim geom_histogram
#' @importFrom plotly layout mutate arrange rename summarise filter ggplotly
#' @importFrom stats median pgamma plnorm pweibull qgamma qlnorm quantile qweibull rgamma rmultinom rnorm sd
#' @importFrom graphics plot
#' @importFrom incidence as.incidence 
estimate_r_func <- function (incid,
                             si_sample,
                             method = c("non_parametric_si", "parametric_si",
                                        "uncertain_si", "si_from_data", "si_from_sample"),
                             config) {
  
  #########################################################
  # Calculates the cumulative incidence over time steps   #
  #########################################################
  
  calc_incidence_per_time_step <- function(incid, t_start, t_end) {
    nb_time_periods <- length(t_start)
    incidence_per_time_step <- sapply(1:nb_time_periods, function(i) sum(incid[t_start[i]:t_end[i], c("local", "imported")]))
    return(incidence_per_time_step)
  }
  
  #########################################################
  # Calculates the parameters of the Gamma posterior      #
  # distribution from the discrete SI distribution        #
  #########################################################
  
  posterior_from_si_distr <- function(incid, si_distr, a_prior, b_prior,
                                      t_start, t_end) {
    nb_time_periods <- length(t_start)
    lambda <- overall_infectivity(incid, si_distr)
    final_mean_si <- sum(si_distr * (0:(length(si_distr) -
                                          1)))
    a_posterior <- vector()
    b_posterior <- vector()
    a_posterior <- sapply(1:(nb_time_periods), function(t) if (t_end[t] >
                                                               final_mean_si) {
      a_prior + sum(incid[t_start[t]:t_end[t], "local"]) # only counting local cases on the "numerator"
    }
    else {
      NA
    })
    b_posterior <- sapply(1:(nb_time_periods), function(t) if (t_end[t] >
                                                               final_mean_si) {
      1/(1/b_prior + sum(lambda[t_start[t]:t_end[t]]))
    }
    else {
      NA
    })
    return(list(a_posterior, b_posterior))
  }
  
  #########################################################
  # Samples from the Gamma posterior distribution for a   #
  # given mean SI and std SI                              #
  #########################################################
  
  sample_from_posterior <- function(sample_size, incid, mean_si, std_si, si_distr=NULL, 
                                    a_prior, b_prior, t_start, t_end) {
    
    nb_time_periods <- length(t_start)
    
    if(is.null(si_distr))
      si_distr <- discr_si(0:(T-1), mean_si, std_si)
    
    final_mean_si <- sum(si_distr * (0:(length(si_distr) -
                                          1)))
    lambda <- overall_infectivity(incid, si_distr)
    a_posterior <- vector()
    b_posterior <- vector()
    a_posterior <- sapply(1:(nb_time_periods), function(t) if (t_end[t] >
                                                               final_mean_si) {
      a_prior + sum(incid[t_start[t]:t_end[t], "local"]) # only counting local cases on the "numerator"
    }
    else {
      NA
    })
    b_posterior <- sapply(1:(nb_time_periods), function(t) if (t_end[t] >
                                                               final_mean_si) {
      1/(1/b_prior + sum(lambda[t_start[t]:t_end[t]], na.rm = TRUE))
    }
    else {
      NA
    })
    sample_r_posterior <- sapply(1:(nb_time_periods), function(t) if (!is.na(a_posterior[t])) {
      rgamma(sample_size, shape = unlist(a_posterior[t]),
             scale = unlist(b_posterior[t]))
    }
    else {
      rep(NA, sample_size)
    })
    if (sample_size == 1L) {
      sample_r_posterior <- matrix(sample_r_posterior, nrow = 1)
    }
    return(list(sample_r_posterior, si_distr))
  }
  
  method <- match.arg(method)
  
  incid <- process_I(incid)
  T<-nrow(incid)
  
  a_prior <- (config$mean_prior/config$std_prior)^2
  b_prior <- config$std_prior^2/config$mean_prior
  
  check_times(config$t_start, config$t_end, T)
  nb_time_periods <- length(config$t_start)
  
  if(method == "si_from_sample")
  {
    if (is.null(config$n2)) {
      stop("method si_from_sample requires to specify the config$n2 argument.")
    }
    si_sample <- process_si_sample(si_sample)
  }
  
  min_nb_cases_per_time_period <- ceiling(1/config$cv_posterior^2 - a_prior)
  incidence_per_time_step <- calc_incidence_per_time_step(incid, config$t_start,
                                                          config$t_end)
  if (incidence_per_time_step[1] < min_nb_cases_per_time_period) {
    warning("You're estimating R too early in the epidemic to get the desired posterior CV.")
  }
  
  if (method == "non_parametric_si") {
    si_uncertainty <- "N"
    parametric_si <- "N"
  }
  if (method == "parametric_si") {
    si_uncertainty <- "N"
    parametric_si <- "Y"
  }
  if (method == "uncertain_si") {
    si_uncertainty <- "Y"
    parametric_si <- "Y"
  }
  if (method == "si_from_data" | method == "si_from_sample") {
    si_uncertainty <- "Y"
    parametric_si <- "N"
  }
  if (si_uncertainty == "Y") {
    if  (parametric_si == "Y") {
      mean_si_sample <- rep(-1, config$n1)
      std_si_sample <- rep(-1, config$n1)
      for (k in 1:config$n1) {
        while (mean_si_sample[k] < config$min_mean_si || mean_si_sample[k] >
               config$max_mean_si) {
          mean_si_sample[k] <- rnorm(1, mean = config$mean_si,
                                     sd = config$std_mean_si)
        }
        while (std_si_sample[k] < config$min_std_si || std_si_sample[k] >
               config$max_std_si){ 
          std_si_sample[k] <- rnorm(1, mean = config$std_si, sd = config$std_std_si)
        }
      }
      temp <- lapply(1:config$n1, function(k) sample_from_posterior(config$n2,
                                                                    incid, mean_si_sample[k], std_si_sample[k], si_distr=NULL, a_prior,
                                                                    b_prior, config$t_start, config$t_end))
      config$si_distr <- cbind(t(sapply(1:config$n1, function(k) (temp[[k]])[[2]])),
                               rep(0, config$n1))
      r_sample <- matrix(NA, config$n2 * config$n1, nb_time_periods)
      for (k in 1:config$n1) {
        r_sample[((k - 1) * config$n2 + 1):(k * config$n2), which(config$t_end >
                                                                    mean_si_sample[k])] <- (temp[[k]])[[1]][, which(config$t_end >
                                                                                                                      mean_si_sample[k])]
      }
      mean_posterior <- apply(r_sample, 2, mean, na.rm = TRUE)
      std_posterior <- apply(r_sample, 2, sd, na.rm = TRUE)
      quantile_0.025_posterior <- apply(r_sample, 2, quantile,
                                        0.025, na.rm = TRUE)
      quantile_0.05_posterior <- apply(r_sample, 2, quantile,
                                       0.05, na.rm = TRUE)
      quantile_0.25_posterior <- apply(r_sample, 2, quantile,
                                       0.25, na.rm = TRUE)
      median_posterior <- apply(r_sample, 2, median, na.rm = TRUE)
      quantile_0.25_posterior <- apply(r_sample, 2, quantile,
                                       0.75, na.rm = TRUE)
      quantile_0.25_posterior <- apply(r_sample, 2, quantile,
                                       0.95, na.rm = TRUE)
      quantile_0.975_posterior <- apply(r_sample, 2, quantile,
                                        0.975, na.rm = TRUE)
    }
    else {
      config$n1<-dim(si_sample)[2]
      mean_si_sample <- rep(-1, config$n1)
      std_si_sample <- rep(-1, config$n1)
      for (k in 1:config$n1) {
        mean_si_sample[k] <- sum((1:dim(si_sample)[1]-1)*si_sample[,k])
        std_si_sample[k] <- sqrt(sum(si_sample[,k]*((1:dim(si_sample)[1]-1) - mean_si_sample[k])^2))
      }
      temp <- lapply(1:config$n1, function(k) sample_from_posterior(config$n2,
                                                                    incid, mean_si=NULL, std_si=NULL, si_sample[,k], a_prior,
                                                                    b_prior, config$t_start, config$t_end))
      config$si_distr <- cbind(t(sapply(1:config$n1, function(k) (temp[[k]])[[2]])),
                               rep(0, config$n1))
      r_sample <- matrix(NA, config$n2 * config$n1, nb_time_periods)
      for (k in 1:config$n1) {
        r_sample[((k - 1) * config$n2 + 1):(k * config$n2), which(config$t_end >
                                                                    mean_si_sample[k])] <- (temp[[k]])[[1]][, which(config$t_end >
                                                                                                                      mean_si_sample[k])]
      }
      mean_posterior <- apply(r_sample, 2, mean, na.rm = TRUE)
      std_posterior <- apply(r_sample, 2, sd, na.rm = TRUE)
      quantile_0.025_posterior <- apply(r_sample, 2, quantile,
                                        0.025, na.rm = TRUE)
      quantile_0.05_posterior <- apply(r_sample, 2, quantile,
                                       0.05, na.rm = TRUE)
      quantile_0.25_posterior <- apply(r_sample, 2, quantile,
                                       0.25, na.rm = TRUE)
      median_posterior <- apply(r_sample, 2, median, na.rm = TRUE)
      quantile_0.25_posterior <- apply(r_sample, 2, quantile,
                                       0.75, na.rm = TRUE)
      quantile_0.25_posterior <- apply(r_sample, 2, quantile,
                                       0.95, na.rm = TRUE)
      quantile_0.975_posterior <- apply(r_sample, 2, quantile,
                                        0.975, na.rm = TRUE)
    }
  }else{
    # CertainSI
    if (parametric_si == "Y") {
      config$si_distr <- discr_si(0:(T-1), config$mean_si, config$std_si)
    }
    if (length(config$si_distr) < T + 1) {
      config$si_distr[(length(config$si_distr) + 1):(T + 1)] <- 0
    }
    final_mean_si <- sum(config$si_distr * (0:(length(config$si_distr) -
                                                 1)))
    Finalstd_si <- sqrt(sum(config$si_distr * (0:(length(config$si_distr) -
                                                    1))^2) - final_mean_si^2)
    post <- posterior_from_si_distr(incid, config$si_distr, a_prior, b_prior,
                                    config$t_start, config$t_end)
    a_posterior <- unlist(post[[1]])
    b_posterior <- unlist(post[[2]])
    mean_posterior <- a_posterior * b_posterior
    std_posterior <- sqrt(a_posterior) * b_posterior
    quantile_0.025_posterior <- qgamma(0.025, shape = a_posterior,
                                       scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
    quantile_0.05_posterior <- qgamma(0.05, shape = a_posterior,
                                      scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
    quantile_0.25_posterior <- qgamma(0.25, shape = a_posterior,
                                      scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
    median_posterior <- qgamma(0.5, shape = a_posterior,
                               scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
    quantile_0.25_posterior <- qgamma(0.75, shape = a_posterior,
                                      scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
    quantile_0.25_posterior <- qgamma(0.95, shape = a_posterior,
                                      scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
    quantile_0.975_posterior <- qgamma(0.975, shape = a_posterior,
                                       scale = b_posterior, lower.tail = TRUE, log.p = FALSE)
  }
  
  results <- list(R = as.data.frame(cbind(config$t_start, config$t_end, mean_posterior,
                                   std_posterior, quantile_0.025_posterior, quantile_0.05_posterior,
                                   quantile_0.25_posterior, median_posterior, quantile_0.25_posterior,
                                   quantile_0.25_posterior, quantile_0.975_posterior)) )
  
  names(results$R) <- c("t_start", "t_end", "Mean(R)", "Std(R)",
                        "Quantile.0.025(R)", "Quantile.0.05(R)", "Quantile.0.25(R)",
                        "Median(R)", "Quantile.0.75(R)", "Quantile.0.95(R)",
                        "Quantile.0.975(R)")
  results$method <- method
  results$si_distr <- config$si_distr
  if(is.matrix(results$si_distr)) 
  {
    colnames(results$si_distr) <- paste0("t",0:(ncol(results$si_distr)-1))
  }else {
    names(results$si_distr) <- paste0("t",0:(length(results$si_distr)-1))
  }
  if (si_uncertainty == "Y") {
    results$SI.Moments <- as.data.frame(cbind(mean_si_sample,
                                              std_si_sample))
  }else {
    results$SI.Moments <- as.data.frame(cbind(final_mean_si,
                                              Finalstd_si))
  }
  names(results$SI.Moments) <- c("Mean", "Std")
  
  
  if(!is.null(incid$dates)) 
  {
    results$dates <- check_dates(incid)
  }else {
    results$dates <- 1:T
  }
  results$I <- rowSums(incid[,c("local", "imported")])
  results$I_local <- incid$local
  results$I_imported <- incid$imported
  
  if (config$plot) {
    
    if(sum(incid$imported[-1])>0) # more than the first cases are imported
    {
      add_imported_cases <- TRUE
    }else {
      add_imported_cases <- FALSE
    }
    
    plots(results, what="all", add_imported_cases = add_imported_cases, legend = config$legend)
  }
  
  return(results)
}

