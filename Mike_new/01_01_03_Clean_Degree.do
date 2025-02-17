********************************************************************************
*01_01_03_Degree.do
********************************************************************************
local degree "$mydir\raw\degree_AY98_AY23.dta"
local term_index "$mydir\clean_mike\term_index.dta"

use `degree', clear

*drop 
drop ssn_pseudo person_key term 

*rename
rename higher_ed_pseudo_id id
rename academic_program_key pgrm_code
destring pgrm_code, replace

*keep only GRD & PHD
keep if admission_area_code == "GRD"
keep if inlist(level_completed_code, "17")

*merge with term index
rename earned_fiscal_year yr_num
rename earned_term_desc term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

*keep only 1st degree
sort term_index
bysort id : keep if _n == 1
*keep only needed data
keep id degree*  campus* institution* pgrm* ipeds* credit* cip* term_index

*generate term_earned
gen term_earned = term_index

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_degree.dta",replace
********************************************************************************
