********************************************************************************
*01_01_04_program.do
********************************************************************************
local main_in "$mydir\clean_mike\clean_main.dta"
local pgrm "$mydir\raw\dim_academic_program.dta"
local term_index "$mydir\clean_mike\term_index.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster.dta"

use `main_in', clear

rename cip_code pgrm_subj_code

*Merge in field titles from program subject codes using CIP code crosswalks
*first match CIP codes from before 2010
destring pgrm_subj_code, replace
merge m:1 pgrm_subj_code using `CIP2010'
drop if _merge==2
drop disciplinearea _merge
rename pgrm_subj_code pgrm_cipcode2010
rename subjecttitle ciptitle2010
rename subjectfield subjectfield2010
rename ciptitle2010 pgrm_ciptitle2010
rename subjectfield2010 pgrm_cipfield2010
rename stemdesignation pgrm_STEM

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main_cip.dta",replace
********************************************************************************
