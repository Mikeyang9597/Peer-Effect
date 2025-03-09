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
keep if student_rank_desc == "Doctoral Student"
drop if campus_code != institution_code

*drop 
drop admission* student* main*

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

drop if first_term < 25
drop if first_term > 66

************************
* 2005 - 2015
drop if term_index > 66
************************

*Generate GPA
gen gpa = cum_gpa_quality_points / cum_credit_hours_earned
drop if gpa == .
drop if cum_gpa_quality_points == 0

*drop werid gpa
gen first_yr = 0
replace first_yr = 1 if term_index == first_term

gen cut = 0
replace cut = 1 if cum_credit_hours_earned > 25 

gen overgpa = 0
replace overgpa=1 if cut == 1 & first_yr ==1

drop academic_program_key cum* term_key special* subsidy* institution_level* institution* fiscal_year 

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main.dta",replace
********************************************************************************
