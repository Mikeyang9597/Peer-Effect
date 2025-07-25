*01_02_03_Merge_program_degree

*Input files:
local in_main "$mydir\clean_mike\merged_main_indiv.dta"
local term_index "$mydir\clean_mike\term_index.dta"
local degree "$mydir\clean_mike\clean_degree.dta"
local degree_MA "$mydir\clean_mike\clean_degree_MA.dta"
local CIP2000 "$mydir\clean_mike\CIPmaster_nomiss2000.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster_nomiss2010.dta"

*main in
use `in_main', clear

*merge main and degree
merge m:1 id using `degree'
drop if _merge == 2
rename _merge PhD_merge
rename term_earned term_earned_PhD

merge m:1 id using `degree_MA'
drop if _merge == 2
rename _merge MA_merge

*generate variable for ever completes PhD
egen everPhD=max(PhD_merge==3), by(person_inst)
*generate variable for ever completes PhD
egen everMA=max(MA_merge==3), by(person_inst)
replace everMA = 0 if (term_earned_MA) < first_term_PhD
*Calculate yrs-to-degree for PhD
gen yrstoPhD=(term_earned_PhD-first_term_PhD+1)/4

*Drop Doctoral degrees earned before PhD enrollment started
drop if term_earned_PhD<first_term_PhD

*Flag students who earn multiple PhDs
duplicates tag person_inst, gen(multiplePhD)

**If more than 1 degree:
*Then, keep earliest PhD only
egen earliestPhD=min(term_index), by(person_inst)
drop if term_index!=earliestPhD
duplicates report person_inst
foreach var of varlist term_index {
rename `var' `var'_PhD
}

drop last_term_GRD

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\main_in_ready.dta",replace
********************************************************************************
