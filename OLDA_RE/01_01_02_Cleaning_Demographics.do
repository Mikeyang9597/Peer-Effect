*01_01_02_Cleaning_Demographics.do

local race “$mydir\raw\person_AY98_AY23.dta”
use `race’, clear

drop ssn_pseudo person_key begin* end* first*

rename higher_ed_pseudo_id hei_psid

*keep if inlist(sex, "F", "M")
rename country_of_origin_desc cood
rename country_of_origin coo

replace cood = "zzz" if coo == "99"
replace cood = "zzz" if coo == "98"
replace cood = "zzz" if coo == ""

bysort hei_psid (cood): gen oops = (cood[1]!=cood[_n])

sort cood

bysort hei_psid : keep if _n == 1

rename race race_ethnic_code
replace race_ethnic_code="AS" if race_ethnic_code=="HP"
replace race_ethnic_code="UK" if race_ethnic_code=="MR"

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_race.dta”,replace
