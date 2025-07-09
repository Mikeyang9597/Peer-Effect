********************************************************************************
*clean OLDA
********************************************************************************
*clean enrollments
local main_in "$mydir\clean_mike\clean_main.dta"
local pgrm "$mydir\raw\dim_academic_program"
local pgrm_clean "$mydir\clean_mike\clean_pgrm.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster.dta"

* Load data
use `pgrm', clear

*rename
rename prog_cip_code cip_code
destring cip_code, replace
destring academic_program_key, replace

* Drop unnecessary variables related to campus and activity status
keep degree_level_code cip_code academic_program_key degree_level_desc campus_key degree_name_code program_code begin_term_key end_term_key

gen term = mod(begin_term_key, 10)
gen term_code = ""
replace term_code = "SM" if term == 1
replace term_code = "AU" if term == 2
replace term_code = "WI" if term == 3
replace term_code = "SP" if term == 4

gen temp = int(begin_term_key / 10)
gen yr_num = real(substr(string(temp, "%03.0f"), 1, 1) + "0" + substr(string(temp, "%03.0f"), 2, .))
replace yr_num = yr_num - 1 if term < 3

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

rename term_index term_begin
rename yr_num yr_begin
drop term_code temp term

replace end_term_key = 2242 if end_term_key == 9999
gen term = mod(end_term_key, 10)

gen term_code = ""
replace term_code = "SM" if term == 1
replace term_code = "AU" if term == 2
replace term_code = "WI" if term == 3
replace term_code = "SP" if term == 4

gen temp = int(end_term_key / 10)
gen yr_num = real(substr(string(temp, "%03.0f"), 1, 1) + "0" + substr(string(temp, "%03.0f"), 2, .))
replace yr_num = yr_num - 1 if term < 3


*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

rename term_index term_end
rename yr_num yr_end

drop term_code temp term yr_end yr_begin

gen term_count = term_end - term_begin + 1
expand term_count
bysort academic_program_key term_begin (term_begin): gen term_index = term_begin + _n - 1

drop if term_index < 40
drop if term_index > 102

* Ensure all unique prog_cip_code values are retained while keeping all academic_program_key values
duplicates drop academic_program_key campus_key term_index ,force

*save
save "$mydir\clean_mike\clean_pgrm", replace
