********************************************************************************
*01_01_02_Cleaning_Demographics.do
********************************************************************************
local race "$mydir\raw\person_AY98_AY23.dta"
use `race', clear

*drop 
drop higher_ed_pseudo_id person_key

*drop missing data
keep if inlist(sex, "F", "M")
drop if birth_yr == .

*rename
rename ssn_pseudo id
rename country_of_origin_desc cood
rename country_of_origin coo

*sort coo
replace cood = "zzz" if coo == "99"
replace cood = "zzz" if coo == "98"
replace cood = "zzz" if coo == ""

bysort id (cood): gen oops = (cood[1] != cood[_n])
bysort id (cood): replace cood = cood[1] if oops == 1
bysort id (cood): replace coo = coo[1] if oops == 1
drop oops

bysort id : keep if _n == 1
replace cood = "." if cood == "zzz"

*clean race
replace race = "AS" if race == "HP"
replace race = "UK" if race == "MR"

*drop
drop zip* us* begin* end* first* active* dob ada* county* state*

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_race.dta",replace
********************************************************************************
