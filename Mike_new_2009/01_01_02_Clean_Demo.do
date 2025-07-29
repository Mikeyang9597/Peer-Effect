********************************************************************************
* 01_01_02_Cleaning_Demographics.do
* Description: Clean demographic data (sex, race, country of origin)
********************************************************************************

* Load raw demographic data
local race "$mydir\raw\person_AY98_AY23.dta"
local continent "$mydir\clean_mike\continent.dta"
use `race', clear

* Drop unnecessary variables
drop higher_ed_pseudo_id person_key zip* us* begin* end* first* active* dob
drop ada* county* state* aian baa race_unk_flag record* asian white nhopi
drop academic* ethnicity*

* Keep only observations with valid sex and non-missing birth year
keep if inlist(sex, "F", "M")
drop if birth_yr == .

* Rename variables for consistency
rename ssn_pseudo id
rename country_of_origin_desc cood
rename country_of_origin coo

* Recode and standardize country of origin
replace cood = "zz_Unknown"       if coo == "99"
replace cood = "United States"    if coo == "98"
replace cood = "zz_United States" if cood == "United States"
replace cood = "zz_Unknown"       if coo == ""

* Resolve multiple cood values per ID
bysort id (cood): gen oops_cood = (cood[1] != cood[_n])
bysort id (cood): replace cood = cood[1] if oops_cood == 1
drop oops_cood

* Clean race variable
replace race = "AS" if race == "HP"  
replace race = "UK" if race == "MR"  

* Keep only one observation per ID
bysort id: keep if _n == 1

*international variable
gen international = 0
replace international = 1 if nonresident_alien_flag == "Y"
***Drop Unknown coo students***
replace cood = "zz_United States" if international == 0
gen unknown = 0
replace unknown = 1 if cood == "zz_Unknown"


* Merge with continent data
merge m:1 cood using `continent'
keep if _merge == 3
drop _merge

* 1. Create a numeric variable for continent
gen continent_num = .

* 2. Assign codes based on continent
replace continent_num = .  if continent == "Unknown"
replace continent_num = 1  if continent == "Domestic"
replace continent_num = 2  if continent == "Asia"
replace continent_num = 3  if continent == "Africa"
replace continent_num = 4  if continent == "Europe"
replace continent_num = 5  if continent == "South America"
replace continent_num = 6  if continent == "Oceania"

* 3. Reassign specific South and Southeast Asian countries to a separate group (e.g., South/Southeast Asia)
replace continent_num = 7 if inlist(cood, "India", "Nepal", "Bangladesh", "Sri Lanka", "Bhutan", "Pakistan", "Maldives", "Myanmar")
replace continent_num = 7 if inlist(cood, "Thailand", "Laos", "Cambodia", "Indonesia", "Malaysia", "Tibet", "Vietnam")

* 4. Label values
label define continent_lbl 1 "Domestic" 2 "Asia" 3 "Africa" 4 "Europe" 5 "South America" 6 "Oceania" 7 "South/Southeast Asia"
label values continent_num continent_lbl

* Save cleaned dataset
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\clean_race.dta", replace
