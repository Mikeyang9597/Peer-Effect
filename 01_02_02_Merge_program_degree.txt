*01_02_02_Merge_program_degree

*Input files:
local in “$mydir\clean\merged_main.dta”
local term_index “$mydir\clean\term_index.dta”
local degree “$mydir\clean\clean_degree.dta”
local program “$mydir\clean\clean_program.dta”

use `in', clear

merge m:1 hei_psid term_index using `degree’
drop if _merge == 2
rename _merge PhD_merge
drop admission*

bysort hei_psid (year_earned): replace year_earned = year_earned[_n-1] if missing(year_earned)
rename year_earned term_earned_phd

*Drop Doctoral degrees earned before PhD enrollment started
*drop if term_index<first_term_PhD

*generate variable for ever completes PhD
egen everPhD=max(PhD_merge==3), by(person_inst)

*generate indicator for whether field enrolled==field of PhD
*gen samefieldPhD=(subjectfield2010==pgrm_cipfield2010_admit)

*Calculate yrs-to-degree for PhD
gen yrstoPhD=(term_index-first_term_PhD+1)/4

save “\\chrr\vr\profiles\syang\Desktop\clean\merged_main_done.dta”,replace

********************************************************************************

