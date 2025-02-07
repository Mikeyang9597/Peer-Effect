*01_01_03_Degree.do

local degree “$mydir\raw\degree_AY98_AY23.dta”

use `degree’, clear

drop ssn_pseudo person_key

rename higher_ed_pseudo_id hei_psid

*keep only grad students
keep if admission_area_code == “GRD”

keep if inlist(level_completed_code, "17")

*duplicates tag hei_psid , gen (tag)

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_degree.dta”,replace


