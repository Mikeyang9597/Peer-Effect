********************************************************************************
*clean OLDA
********************************************************************************
*clean enrollments
local main_in “$mydir\raw\enrollments_AY98_AY23.dta”
local term_index “$mydir\clean\term_index.dta”

use `main_in’, clear

drop ssn_pseudo person_key student_rank_code campus_key 

*keep only grad students
keep if admission_area_code == “GRD”
keep if student_rank_desc == “Doctoral Student”
drop if campus_code != institution_code

*merge with term index
rename fiscal_year yr_num
rename term term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

*tag first and last term of enrollment
rename higher_ed_pseudo_id hei_psid
rename institution_key inst_code
egen first_term=min(term_index), by(hei_psid inst_code)
egen last_term=max(term_index), by(hei_psid inst_code)

*keep only grad students who first enrolled SM05 or later
drop if first_term<25 

gen gpa = cum_gpa_quality_points / cum_credit_hours_earned

drop if gpa == .

drop cum* admission_area_desc calendar*

rename academic_program_key pgrm_code
destring pgrm_code, replace

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_main.dta”,replace

********************************************************************************