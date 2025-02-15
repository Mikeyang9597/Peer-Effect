*01_01_03_Degree.do

local degree “$mydir\raw\degree_AY98_AY23.dta”
local term_index “$mydir\clean\term_index.dta”

use `degree’, clear

drop ssn_pseudo person_key term 

rename higher_ed_pseudo_id hei_psid
rename academic_program_key pgrm_code
destring pgrm_code, replace

*keep only grad students
keep if admission_area_code == “GRD”

keep if inlist(level_completed_code, "17")

duplicates tag hei_psid , generate(dup)

*merge with term index
rename earned_fiscal_year yr_num
rename earned_term_desc term_code
merge m:1 yr_num term_code using `term_index'
keep if _merge == 3

drop _merge

sort term_index

bysort hei_psid : keep if _n == 1

keep hei_psid degree*  campus* institution* pgrm* ipeds* credit* cip* term_index

gen year_earned = term_index

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_degree.dta”,replace


