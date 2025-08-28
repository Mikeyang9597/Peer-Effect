*04_00_00_Main_Analyses.do

*Input files:
local main "$mydir\clean_mike\Data_Preferred_Sample.dta"
local robust "$mydir\clean_mike\Data_for_Robustness.dta"
local allyrs "$mydir\clean_mike\Data_all_Years.dta"

global controls "cip_cohort_size c.age##c.age female race_ind1-race_ind4 race_ind6"
global controls_age "cip_cohort_size female race_ind1-race_ind4 race_ind6"
global FEs "i.first_term_PhD i.cip_inst"

***************************************************************************
*Table 1: Summary Statistics by CIP Code
***************************************************************************

*Make list of CIP Codes and main characteristics
*Include only those programs in the main estimation sample

*main in
use `main', clear

gen dropout_by1 = 1 - persist_to_yr2
gen dropout_by2 = 1 - persist_to_yr3
gen dropout_by3 = 1 - persist_to_yr4
gen dropout_by4 = 1 - persist_to_yr5
gen dropout_by5 = 1 - persist_to_yr6
gen dropout_by6 = 1 - persist_to_yr7

egen mean_yrstoPhD = mean(yrstoPhD), by(first_term_PhD)
egen mean_dropout = mean(dropout), by(first_term_PhD)
egen mean_dropout_program = mean(dropout), by(first_term_PhD inst_code pgrm_cipcode2010)
egen mean_PhDin5 = mean(PhDin5), by(first_term_PhD)
egen mean_PhDin6 = mean(PhDin6), by(first_term_PhD)
egen mean_PhDin7 = mean(PhDin7), by(first_term_PhD)
egen mean_PhDin8 = mean(PhDin8), by(first_term_PhD)

egen mean_persist_to_yr2 = mean(persist_to_yr2), by(first_term_PhD inst_code)
egen mean_persist_to_yr3 = mean(persist_to_yr3), by(first_term_PhD inst_code)
egen mean_persist_to_yr4 = mean(persist_to_yr4), by(first_term_PhD inst_code)
egen mean_persist_to_yr5 = mean(persist_to_yr5), by(first_term_PhD inst_code)

egen mean_dropout_by1 = mean(dropout_by1), by(first_term_PhD)

egen mean_everPhD = mean(everPhD), by (inst_code pgrm_cipcode2010)

egen mean_international = mean(international), by(first_term_PhD)

* Keep only one observation per ID
bysort first_term_PhD inst_code: keep if _n == 1
*sort mean_dropout_program

*plot mean_dropout_program mean_cohort_size
*twoway line mean_PhDin5 first_term_PhD
*twoway line mean_PhDin6 first_term_PhD
*twoway line mean_PhDin7 first_term_PhD
*twoway line mean_PhDin8 first_term_PhD

*twoway line mean_dropout_by1 first_term_PhD

twoway line mean_persist_to_yr2 first_term_PhD if inst_code == "OHSU"
twoway line mean_persist_to_yr2 first_term_PhD if inst_code == "AKRN"
twoway line mean_persist_to_yr2 first_term_PhD if inst_code == "TLDO"
*twoway line mean_persist_to_yr3 first_term_PhD
*twoway line mean_persist_to_yr4 first_term_PhD
*twoway line mean_persist_to_yr5 first_term_PhD
*twoway line mean_international first_term_PhD
