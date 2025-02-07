*01_02_01_Merge.do

local main “$mydir\clean\clean_main.dta”
local race “$mydir\clean\clean_race.dta”
local degree “$mydir\clean\clean_degree.dta”
local program “$mydir\clean\clean_program.dta”

use `main’ , clear

merge m:1 hei_psid using `race’
keep if _merge == 3
drop _merge

merge m:1 hei_psid using `degree’
drop if _merge == 2
drop _merge

merge m:1 pgrm_code using `program’
keep if _merge == 3
drop _merge

*replace degree_cert_level_desc="Doctoral degree" if degree_cert_level_code=="09" & yr_num>2010
rename degree_cert_level_code pgrm_level_code
*rename degree_name_code pgrm_degree_code
*rename degree_concentration_desc pgrm_concentrate_desc
*rename degree_cert_level_desc pgrm_level_desc
*drop min_completion_time_yrs min_completion_cr_hours program_rec_status_code active_flag 
