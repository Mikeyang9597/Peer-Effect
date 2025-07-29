********************************************************************************
* 01_01_03_Degree_PHD.do
* Description: Extract first doctoral degree earned after 2011SM
********************************************************************************

* Define file paths
local degree      "$mydir\raw\degree_AY98_AY23.dta"
local term_index  "$mydir\clean_mike\term_index.dta"

* Load degree data
use `degree', clear

* Drop unnecessary variables
drop higher_ed_pseudo_id person_key term

* Rename identifier
rename ssn_pseudo id

* Keep only doctoral-level degrees (code "17")
keep if inlist(level_completed_code, "17", "09")

* Merge with term index
rename earned_calendar_year yr_num
rename earned_term_desc term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

* Keep only degrees earned after 2005 SM
drop if term_index < 31
drop if term_index > 102

* Keep only the first doctoral degree per person
bysort id (term_index): keep if _n == 1

* Retain only needed variables
keep id degree* campus* institution* ipeds* credit* cip* term_index

* Generate term_earned variable
gen term_earned = term_index

* Keep final variables
keep id term_earned

* Save cleaned doctoral degree data
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_degree.dta", replace



********************************************************************************
* 01_01_03_Degree_MA.do
* Description: Extract first master's degree earned after 2011SM
********************************************************************************

* Define file paths
local degree      "$mydir\raw\degree_AY98_AY23.dta"
local term_index  "$mydir\clean_mike\term_index.dta"

* Load degree data
use `degree', clear

* Drop unnecessary variables
drop higher_ed_pseudo_id person_key term

* Rename identifier
rename ssn_pseudo id

* Keep only master's-level degrees (code "07")
keep if inlist(level_completed_code, "07")

* Merge with term index
rename earned_calendar_year yr_num
rename earned_term_desc term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

* Keep only degrees earned after 2005 SM
drop if term_index < 31
drop if term_index > 102

* Keep only the first master's degree per person
bysort id (term_index): keep if _n == 1

* Retain only needed variables
keep id degree* campus* institution* ipeds* credit* cip* term_index

* Generate term_earned_MA variable
gen term_earned_MA = term_index

* Keep final variables
keep id term_earned_MA

* Save cleaned master's degree data
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_degree_MA.dta", replace
