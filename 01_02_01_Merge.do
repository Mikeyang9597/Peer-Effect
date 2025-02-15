*01_02_01_Merge.do

local main “$mydir\clean\clean_main.dta”
local race “$mydir\clean\clean_race.dta”
local degree “$mydir\clean\clean_degree.dta”
local program “$mydir\clean\clean_program.dta”

use `main’ , clear

merge m:1 hei_psid using `race’
keep if _merge == 3
drop _merge

drop student*

*revise first and last term variables now that I've dropped non-doctorates

rename first_term first_term_GRD
rename last_term last_term_GRD

egen first_term_PhD=min(term_index), by(hei_psid inst_code)
egen last_term_PhD=max(term_index), by(hei_psid inst_code)

egen transfer_from_other_level=max(first_term_PhD!=first_term_GRD), by(hei_psid inst_code)
egen transfer_to_other_level=max(last_term_PhD!=last_term_GRD), by(hei_psid inst_code)

*revise first term variable
rename first_term_PhD first_term_nocredit
egen first_term_PhD=min(term_index), by(hei_psid inst_code)

*Create group observation identifiers
egen person_inst=group(hei_psid inst_code)

save “\\chrr\vr\profiles\syang\Desktop\clean\merged_main.dta”,replace

********************************************************************************
