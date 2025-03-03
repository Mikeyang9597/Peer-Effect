********************************************************************************
*01_01_02_Cleaning_Demographics.do
********************************************************************************
local race "$mydir\raw\person_AY98_AY23.dta"
use `race', clear

*drop
*drop ssn_pseudo person_key 
drop begin* end* first* active* dob ada*
keep if inlist(sex, "F", "M")
drop if birth_yr == .

*rename
rename higher_ed_pseudo_id id
rename country_of_origin_desc cood
rename country_of_origin coo
rename nonresident_alien_flag international_

*sort coo
replace cood = "zzz" if coo == "99"
replace cood = "zzz" if coo == "98"
replace cood = "zzz" if coo == ""

bysort id (cood): gen oops = (cood[1] != cood[_n])
bysort id (cood): replace cood = cood[1] if oops == 1
bysort id (cood): replace coo = coo[1] if oops == 1
bysort id (cood): gen oops_ = (cood[1] != cood[_n])
tab oops_
drop oops oops_

*keep 1 per student
bysort id : keep if _n == 1
replace cood = "." if cood == "zzz"

*clean race
replace race = "AS" if race == "HP"
replace race = "UK" if race == "MR"

*drop
drop zip* us* underprepared*

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_race.dta",replace
********************************************************************************
