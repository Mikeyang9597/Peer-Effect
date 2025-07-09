********************************************************************************
*01_01_03_Degree.do
********************************************************************************
local degree "$mydir\raw\degree_AY98_AY23.dta"
local term_index "$mydir\clean_mike\term_index.dta"

use `degree', clear

*drop 
drop higher_ed_pseudo_id person_key term 

*rename
rename ssn_pseudo id

*keep only GRD & PHD
*keep if admission_area_code == "GRD"
keep if inlist(level_completed_code,"17")

*merge with term index
rename earned_calendar_year yr_num
rename earned_term_desc term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

drop if term_index > 68

*keep only 1st degree
bysort id (term_index): keep if _n==1
*keep only needed data
keep id degree*  campus* institution* ipeds* credit* cip* term_index

*generate term_earned
gen term_earned = term_index

drop if term_index < 25

keep id term_earned

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_degree.dta",replace
********************************************************************************


********************************************************************************
*01_01_03_Degree.do
********************************************************************************
local degree "$mydir\raw\degree_AY98_AY23.dta"
local term_index "$mydir\clean_mike\term_index.dta"

use `degree', clear

*drop 
drop higher_ed_pseudo_id person_key term 

*rename
rename ssn_pseudo id

*keep only GRD & PHD
*keep if admission_area_code == "GRD"
keep if inlist(level_completed_code, "07")

*merge with term index
rename earned_calendar_year yr_num
rename earned_term_desc term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

drop if term_index > 68

*keep only 1st degree
bysort id (term_index): keep if _n==1
*keep only needed data
keep id degree*  campus* institution* ipeds* credit* cip* term_index

*generate term_earned
gen term_earned_MA = term_index

drop if term_index < 25

keep id term_earned_MA

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_degree_MA.dta",replace
********************************************************************************

