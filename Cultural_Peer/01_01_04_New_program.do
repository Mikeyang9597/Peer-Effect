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
rename program_code pgrm_subj_code

*drop 
gen temp = int(begin_term_key / 10)
gen yr_num = real(substr(string(temp, "%03.0f"), 1, 1) + "0" + substr(string(temp, "%03.0f"), 2, .))
drop if yr_num < 2009

* Drop unnecessary variables related to campus and activity status
keep degree_level_code cip_code academic_program_key degree_level_desc campus_key degree_name_code yr_num
drop if academic_program_key == -2

drop if degree_level_code == "01"
drop if degree_level_code == "02"
drop if degree_level_code == "04"
drop if degree_level_code == "03"
drop if degree_level_code == "05"
drop if degree_level_code == "06"
drop if degree_level_code == "08"
drop if degree_level_code == "10"
drop if degree_level_code == "11"
drop if degree_level_code == "XX"
drop if degree_level_code == "T1"
drop if degree_level_code == "T2"
drop if degree_level_code == "TM"
drop if degree_level_code == "G1"
drop if degree_level_code == "G2"
replace degree_level_code = "09" if degree_level_code == "17"

*mark the programs that switch from code 09=PHD to 18 or 19 for PhDs
egen ever18=max(degree_level_code=="18"), by(academic_program_key campus_key)
egen ever19=max(degree_level_code=="19"), by(academic_program_key campus_key)

drop if ever18 | ever19
drop ever18 ever19

bysort academic_program_key campus_key (degree_level_code): gen byte _flag = degree_level_code[1] != degree_level_code[_n]

tab _flag

drop if degree_level_code == "07"

* Ensure all unique prog_cip_code values are retained while keeping all academic_program_key values
duplicates drop academic_program_key campus_key ,force

*save
save "$mydir\clean_mike\clean_pgrm", replace

* Load data
use `main_in', clear

destring cip_code academic_program_key campus_key, replace

*drop if prog_key missing

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
