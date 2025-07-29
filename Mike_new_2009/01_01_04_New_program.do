********************************************************************************
* clean_OLDA_program.do
* Description: Clean academic program data, create term index per program
********************************************************************************

* Define paths
local main_in     "$mydir\clean_mike\clean_main.dta"
local pgrm        "$mydir\raw\dim_academic_program"
local pgrm_clean  "$mydir\clean_mike\clean_pgrm.dta"
local CIP2010     "$mydir\clean_mike\CIPmaster.dta"
local term_index  "$mydir\clean_mike\term_index.dta"

* Load academic program data
use `pgrm', clear

* Rename and convert key variables
rename prog_cip_code cip_code
destring cip_code, replace
destring academic_program_key, replace

* Keep relevant variables
keep degree_level_code cip_code academic_program_key degree_level_desc degree_name_code program_code campus_key begin_term_key end_term_key

egen ever17=max(degree_level_code=="17"), by(academic_program_key campus_key)
egen ever09=max(degree_level_code=="09"), by(academic_program_key campus_key)
gen tag1 = .
replace tag = 1 if ever17 == 1 | ever09 == 1
replace degree_level_code = "17" if begin_term_key ==2122 & end_term_key==2122 & campus_key == 331 & tag1 == 1
drop ever17 ever09 tag1

********************************************************************************
* Convert begin_term_key to term_index (term_begin)
********************************************************************************
gen term = mod(begin_term_key, 10)
gen term_code = ""
replace term_code = "SM" if term == 1
replace term_code = "AU" if term == 2
replace term_code = "WI" if term == 3
replace term_code = "SP" if term == 4

gen temp = int(begin_term_key / 10)
gen yr_num = real(substr(string(temp, "%03.0f"), 1, 1) + "0" + substr(string(temp, "%03.0f"), 2, .))
replace yr_num = yr_num - 1 if term < 3

merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

rename term_index term_begin
rename yr_num yr_begin
drop term_code temp term

********************************************************************************
* Convert end_term_key to term_index (term_end)
********************************************************************************
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

merge m:1 yr_num term_code using `term_index'
keep if _merge == 3
drop _merge

rename term_index term_end
rename yr_num yr_end
drop term_code temp term yr_end yr_begin

********************************************************************************
* Expand program-period panel: one row per program per term_index
********************************************************************************
gen term_count = term_end - term_begin + 1
expand term_count

bysort academic_program_key term_begin (term_begin): gen term_index = term_begin + _n - 1

* Keep only records after 2011SM (term_index >= 48)
drop if term_index < 31
drop if term_index > 102

* Drop duplicate program-campus-term combinations
duplicates drop academic_program_key campus_key term_index, force

* Save cleaned program dataset
save "$mydir\clean_mike\clean_pgrm.dta", replace
