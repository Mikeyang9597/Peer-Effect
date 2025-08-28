***************************************************************************
*Monte Carlo simulation exercise (following Lavy and Schlosser (2011))
*Does observed within-program variation in international composition in our
*data closely resemble randomly generated variation from a binomial dist?

*Updated: Aug 2025
***************************************************************************

local main "$mydir\clean_mike\Data_Preferred_Sample.dta"
local robust "$mydir\clean_mike\Data_for_Robustness.dta"
local allyrs "$mydir\clean_mike\Data_all_Years.dta"

set memory 500m

*Use all years of data, but only programs in the main sample
use `allyrs', clear
keep if STEM==1
drop if mean_cohort_size<=9

*For each program-cohort calculate the observed international composition
collapse (sum) actual_num_international=international (count) cohort_size=international, by(cip_inst first_term_PhD)
gen actual_per_international = actual_num_international/cohort_size

*For each program calculate the observed average international composition
egen mean_per_international = mean(actual_per_international), by(cip_inst)
save `cohort_list', replace

*For each program calculate average cohort size and the observed standard deviation of cohort international composition
collapse (sd) actual_sd_per = actual_per_international (first) mean_per_international (mean) avg_cohort_size=cohort_size, by(cip_inst)
save `results', replace

***Monte Carlo Simulation:***
*For 1,000 iterations:
set seed 010385
forval i=1/1000 {
    use `cohort_list', clear
    *For each cohort, draw a random # of internationals from a binomial(n,p) 
    *where n=cohort_size and p=mean(%international) for program over all years
    gen rand_num_international = rbinomial(cohort_size, mean_per_international)
    gen rand_per_international = rand_num_international/cohort_size
    
    *Calculate within-program standard deviation of the randomly-generated %international
    collapse (sd) rand_sd_per = rand_per_international, by(cip_inst)
    
    *Save results
    if `i'==1 {
        merge 1:1 cip_inst using `results'
        drop _merge
    }
    else {
        append using `results'
    }
    save `results', replace
    sleep 500
}

*Using the simulation results,
*calculate empirical confidence interval for the standard dev for each program
use `results', clear
egen p5 = pctile(rand_sd_per), p(5) by(cip_inst)
egen p95 = pctile(rand_sd_per), p(95) by(cip_inst)
keep if actual_sd_per!=.
drop rand_sd_per

*What % of programs have observed sd that lies within the empirical confidence interval?
gen within_of_CI = (actual_sd_per>=p5 & actual_sd_per<=p95)
replace within_of_CI = . if p5==.
summ
