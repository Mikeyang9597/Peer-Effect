********************************************************************************
* Clean OLDA Enrollment Data
********************************************************************************

* Define file paths
local main_in  "$mydir\raw\enrollments_AY98_AY23.dta"
local term_index "$mydir\clean_mike\term_index.dta"

* Load enrollment data
use `main_in', clear

* Drop unnecessary identifiers
drop higher_ed_pseudo_id person_key

* Keep only graduate-level (GRD) students from main campus
keep if admission_area_code == "GRD"
drop if campus_code != institution_code

* Rename variables for consistency
rename ssn_pseudo id
rename calendar_year yr_num
rename term term_code
rename institution_code inst_code

* Drop unused variables
drop admission* main*
drop if id == .

* Generate gpa and fix the errors
gen gpa = .
replace gpa = cum_gpa_quality_points / cum_gpa_credit_hours
drop if gpa == . | gpa == 0
replace gpa = 4 if gpa > 4

* Merge with term index data
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

* Tag first and last term of enrollment
egen first_term = min(term_index), by(id inst_code)
egen last_term = max(term_index), by(id inst_code)

* Drop students whose first term is before 2005SM (term_index < 31)
drop if first_term < 31

* Drop additional unused or irrelevant variables
drop special*  subsidy*  institution_level*  institution*  residency*  fiscal*  campus_code  term_key  student_rank_desc  ipeds*  campus_ipeds_id  living*  incarcerated*  campus_type*  cip_title cum*

* Save cleaned data
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main.dta", replace
