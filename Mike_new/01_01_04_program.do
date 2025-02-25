********************************************************************************
*01_01_04_program.do
********************************************************************************
local main_in "$mydir\clean_mike\clean_main.dta"
local pgrm "$mydir\raw\dim_academic_program.dta"
local term_index "$mydir\clean_mike\term_index.dta"
local CIP2000 "$mydir\clean_mike\CIPmaster_nomiss2000.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster_nomiss2010.dta"

use `main_in', clear

rename cip_code pgrm_subj_code

*Merge in field titles from program subject codes using CIP code crosswalks
*first match CIP codes from before 2010
destring pgrm_subj_code, gen(temp)
gen cipcode2010=temp 
merge m:1 cipcode2010 using `CIP2010', update 
drop if _merge==2
drop temp _merge subjecttitle2010  disciplinearea
rename cipcode2010 pgrm_cipcode2010
rename ciptitle2010 pgrm_ciptitle2010
rename subjectfield2010 pgrm_cipfield2010
rename stemdesignation pgrm_STEM

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_main_cip.dta",replace
********************************************************************************
