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
replace cood = "zz_Unknown" if coo == "99"
replace cood = "United States" if coo == "98"
replace cood = "zz_United States" if cood == "United States"
replace cood = "zz_Unknown" if coo == ""

bysort id (cood): gen oops_cood = (cood[1] != cood[_n])
bysort id (cood): replace cood = cood[1] if oops_cood == 1
drop oops_cood

*clean race
replace race = "AS" if race == "HP"
replace race = "UK" if race == "MR"

bysort id : keep if _n == 1

*drop
drop zip* us* begin* end* first* active* dob ada* county* state* aian baa race_unk_flag record* asian white nhopi academic* ethnicity*

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_race.dta",replace
********************************************************************************
