*01_02_02_Merge_program_degree

*Input files:
local in "$mydir\clean_mike\merged_main.dta"
local term_index "$mydir\clean_mike\term_index.dta"
local degree "$mydir\clean_mike\clean_degree.dta"

*main in
use `in', clear

*merge main and degree
merge m:1 id term_index using `degree'
drop if _merge == 2
rename _merge PhD_merge

* mark term_earned
bysort id (term_earned): replace term_earned = term_earned[_n-1] if missing(term_earned)
rename term_earned term_earned_phd

*generate variable for ever completes PhD
egen everPhD=max(PhD_merge==3), by(person_inst)

*Calculate yrs-to-degree for PhD
gen yrstoPhD=(term_index-first_term_PhD+1)/4

*drop
drop pgrm_code incarcerate*

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\merged_main_done.dta",replace
********************************************************************************
