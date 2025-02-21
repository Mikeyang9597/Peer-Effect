*04_00_00_Main_Analyses.do

*Input files:
local main "$mydir\clean_mike\Data_Preferred_Sample.dta"
local robust "$mydir\clean_mike\Data_for_Robustness.dta"
local allyrs "$mydir\clean_mike\Data_all_Years.dta"

***************************************************************************
*Table 1: Summary Statistics by CIP Code
***************************************************************************

*Make list of CIP Codes and main characteristics
*Include only those programs in the main estimation sample

*main in
use `main', clear
rename subjectfield2010_PhD pgrm_cipfield
rename ciptitle2010 pgrm_ciptitle
collapse (first) pgrm_cipfield pgrm_ciptitle mean_cohort_size mean_per_female, by(pgrm_cipcode inst_code)
collapse (first) pgrm_cipfield  pgrm_ciptitle (mean) mean_cohort_size mean_per_female (count) num_pgrms=mean_cohort_size, by(pgrm_cipcode)
sort mean_per_female 


***************************************************************************
*Table 2: Cohort Characteristics
***************************************************************************

*Cohort Characteristics
*Panel A: Estimation sample
use `main', clear
summ STEM cip_cohort_size cip_num_female cip_per_female ratioFM if cohort_tag==1

*Panel B: Estimation Sample + Non-STEM + Small Programs
use `robust', clear
summ STEM cip_cohort_size cip_num_female cip_per_female ratioFM if cohort_tag==1

*Panel C: Full Sample, All Years
use `allyrs', clear
summ STEM cip_cohort_size cip_num_female cip_per_female ratioFM if cohort_tag==1


***************************************************************************
*Table 3: Summary Statistics by Gender
***************************************************************************
*Compare men to women in estimation sample
use $main, clear
gen dropout_by6 = 1 - persist_to_yr7
gen enrolledafter6 = persist_to_yr7 - PhDin6

forval f = 0/1 {
    * Outcome variables
    summ PhDin6 yrstoPhD dropout_by6 enrolledafter6 yrs_enrolled_PhD if female == `f'
    
    * Demographics/Controls
    summ age international if female == `f'
    
    * Grades 
    summ firstQgpa firstYrgpa if female == `f'
}




***************************************************************************
*Figure 1: Trends in Cohort Gender Composition By Field
***************************************************************************
use $allyrs, clear
keep if STEM==1
drop if mean_cohort_size<=9
*drop programs that start after 2009
egen first_cohort=min(first_term_PhD), by(cip_inst)
drop if first_cohort>42
collapse (first) cip_per_female pgrm_cipfield inst_code, by(cip_inst first_term_PhD)
sort cip_inst first_term_PhD



