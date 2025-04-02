********************************************************************************
* Clean OLDA Enrollment Data
********************************************************************************

* Define file path for raw enrollment data
local main_in "$mydir\clean_mike\clean_main.dta"
local pgrm "$mydir\raw\dim_academic_program"
local term_index "$mydir\clean_mike\term_index.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster.dta"
local pgrm_clean "$mydir\clean_mike\clean_pgrm.dta"

* Load data
use `pgrm', clear
*rename
rename prog_cip_code cip_code
destring cip_code, replace
destring academic_program_key, replace
rename program_code pgrm_subj_code

*Drop program codes "UNDECI", "TRAMOD", and "XXXXXX"
drop if pgrm_subj_code=="UNDECI" | pgrm_subj_code=="TRAMOD" | pgrm_subj_code=="XXXXXX"
drop if academic_program_key < 1

* Drop unnecessary variables related to campus and activity status
drop active* active* min*

gen term = mod(begin_term_key, 10)
gen term_code = ""
replace term_code = "SM" if term == 1
replace term_code = "AU" if term == 2
replace term_code = "WI" if term == 3
replace term_code = "SP" if term == 4

gen temp = int(begin_term_key / 10)
gen yr_num = real(substr(string(temp, "%03.0f"), 1, 1) + "0" + substr(string(temp, "%03.0f"), 2, .))
replace yr_num = yr_num + 1 if term > 2

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

rename term_index term_begin
rename yr_num yr_begin
drop term_code temp term term_num

replace end_term_key = 2222 if end_term_key == 9999
gen term = mod(end_term_key, 10)

gen term_code = ""
replace term_code = "SM" if term == 1
replace term_code = "AU" if term == 2
replace term_code = "WI" if term == 3
replace term_code = "SP" if term == 4

gen temp = int(end_term_key / 10)
gen yr_num = real(substr(string(temp, "%03.0f"), 1, 1) + "0" + substr(string(temp, "%03.0f"), 2, .))
replace yr_num = yr_num + 1 if term > 2

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

rename term_index term_end
rename yr_num yr_end

drop term_code temp term term_num

gen term_count = term_end - term_begin + 1
expand term_count
bysort academic_program_key term_begin (term_begin): gen term_index = term_begin + _n - 1

*mark the programs that switch from code 09=PHD to 18 or 19 for PhDs
egen ever18=max(degree_level_code=="18"), by(academic_program_key campus_key)
egen ever19=max(degree_level_code=="19"), by(academic_program_key campus_key)

replace degree_level_desc ="Doctoral degree" if degree_level_code=="09" & term_index>45

*keep doctorates (09, 17) but drop programs that switch from 09 to 18 or 19 or if degree_code!=PHD
keep if degree_level_code=="09" | degree_level_code=="17"
drop if ever18 | ever19
drop ever18 ever19
drop if degree_level_desc!="Doctoral degree"

********************************************************************************
* Ensure all unique prog_cip_code values are retained while keeping all academic_program_key values
duplicates drop academic_program_key, force

rename term_index d_term_index
drop yr* term*
rename d_term_index term_index

* Save cleaned dataset (modify path as needed)
save "$mydir\clean_mike\clean_pgrm", replace
********************************************************************************

use `main_in', clear
destring cip_code, replace
destring academic_program_key, replace

drop if academic_program_key == -2

merge m:1 academic_program_key using `pgrm_clean'
keep if _merge == 3
drop _merge
rename cip_code cipcode2010

*Merge in field titles from program subject codes using CIP code crosswalks
*first match CIP codes from before 2010
destring cipcode2010, replace
merge m:1 cipcode2010 using `CIP2010'
keep if _merge==3
drop _merge
rename cipcode2010 pgrm_cipcode2010
rename subjecttitle2010 pgrm_ciptitle2010
rename subjectfield2010 pgrm_cipfield2010
rename stemdesignation pgrm_STEM

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main_cip.dta",replace
********************************************************************************
