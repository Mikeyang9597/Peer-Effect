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

*tag first and last term of enrollment
egen first_term=min(term_index), by(id inst_code)
egen last_term=max(term_index), by(id inst_code)

*(2009년도 드랍 기준으로 고쳐야함)
drop if first_term < 25
drop if term_index > 68


*Generate GPA 
gen gpa = .
replace gpa = cum_gpa_quality_points / cum_credit_hours
drop if gpa == .

bysort id (student_rank_code): gen _oops = (student_rank_code[1] != student_rank_code[_n])

drop term_key special* subsidy* institution_level* institution* residency* fiscal*

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main.dta",replace
********************************************************************************
