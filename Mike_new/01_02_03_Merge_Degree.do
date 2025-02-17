*01_02_02_Merge_program_degree

*Input files:
local in "$mydir\clean_mike\merged_main_indiv.dta"
local term_index "$mydir\clean_mike\term_index.dta"
local degree "$mydir\clean_mike\clean_degree.dta"
local CIP2000 "$mydir\clean_mike\CIPmaster_nomiss2000.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster_nomiss2010.dta"

*main in
use `in', clear

*merge main and degree
merge m:1 id term_index using `degree'
drop if _merge == 2
rename _merge PhD_merge

* mark term_earned
bysort id (term_earned): replace term_earned = term_earned[_n-1] if missing(term_earned)
rename term_earned term_earned_phd

*rename CIP
rename cip_code subject_code


*Merge in field titles from degree subject codes using CIP code crosswalks
*first match CIP codes from before 2010
destring subject_code, gen(temp)
gen cipcode2000=temp if term_index<49
merge m:1 cipcode2000 using `CIP2000'
drop if _merge==2
drop _merge 
*Then match CIP codes from after 2010
replace cipcode2010=temp if term_index>=49
merge m:1 cipcode2010 using `CIP2010', update 
drop if _merge==2
drop temp _merge incarcerate*

*generate variable for ever completes PhD
egen everPhD=max(PhD_merge==3), by(person_inst)
*Calculate yrs-to-degree for PhD
gen yrstoPhD=(term_index-first_term_PhD+1)/4

*Flag students who earn multiple PhDs
duplicates tag person_inst, gen(multiplePhD)

**If more than 1 degree:
*Then, keep earliest PhD only
egen earliestPhD=min(term_index), by(person_inst)
drop if term_index!=earliestPhD
duplicates report person_inst
foreach var of varlist term_index cipcode2010 subjectfield2010 stemdesignation pgrm_code {
rename `var' `var'_PhD
}

*Drop extraneous variables
drop subject_code

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\main_in.dta",replace
********************************************************************************
