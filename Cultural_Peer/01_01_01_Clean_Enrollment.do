********************************************************************************
*clean OLDA
********************************************************************************
*clean enrollments
local main_in "$mydir\raw\enrollments_AY98_AY23.dta"
local term_index "$mydir\clean_mike\term_index.dta"

use `main_in', clear

*drop 
drop higher_ed_pseudo_id person_key

*keep only GRD & PHD
keep if admission_area_code == "GRD"
drop if campus_code != institution_code
drop admission* main*

*rename
rename ssn_pseudo id
rename calendar_year yr_num
rename term term_code
rename institution_code inst_code
drop if id == .


*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

drop if term_index > 68

*tag first and last term of enrollment
egen first_term=min(term_index), by(id inst_code)
egen last_term=max(term_index), by(id inst_code)

* keep 2005 to 2016
drop if first_term < 25

*Generate GPA 
gen gpa = .
replace gpa = cum_gpa_quality_points / cum_credit_hours
drop if gpa == .

drop special* subsidy* institution_level* institution* residency* fiscal* campus_code term_key student_rank_desc cum* ipeds* campus_ipeds_id living* incarcerated* campus_type*

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main.dta",replace
********************************************************************************

*sort id term_index
*browse id term_index first_term degree_level_code inst_code academic_program_key student_rank_desc
