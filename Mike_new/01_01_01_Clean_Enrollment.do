********************************************************************************
*clean OLDA
********************************************************************************
*clean enrollments
local main_in "$mydir\raw\enrollments_AY98_AY23.dta"
local term_index "$mydir\clean_mike\term_index.dta"

use `main_in', clear

*drop 
drop ssn_pseudo person_key 

*keep only GRD & PHD
keep if admission_area_code == "GRD"
keep if student_rank_desc == "Doctoral Student"
keep if main_campus_type_code == "1"
drop if campus_code != institution_code

*drop 
drop admission* student* main* calendar*

*rename
rename higher_ed_pseudo_id id
rename fiscal_year yr_num
rename term term_code
rename institution_key inst_code

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

*tag first and last term of enrollment
egen first_term=min(term_index), by(id inst_code)
egen last_term=max(term_index), by(id inst_code)


*Generate GPA
gen gpa = cum_gpa_quality_points / cum_credit_hours_earned
*drop if gpa == .
drop cum* term_key special* subsidy* institution_level*

*rename prgm_code
rename academic_program_key pgrm_code
destring pgrm_code, replace

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main.dta",replace












