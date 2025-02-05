*01_01_02_Cleaning_Demographics.do

local race “$mydir\raw\person_AY98_AY23.dta”
use `race’, clear

drop ssn_pseudo person_key

rename higher_ed_pseudo_id hei_psid

*keep if inlist(sex, "F", "M")
bysort hei_psid : keep if _n == 1

rename race race_ethnic_code
replace race_ethnic_code="AS" if race_ethnic_code=="HP"
replace race_ethnic_code="UK" if race_ethnic_code=="MR"

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_race.dta”,replace
