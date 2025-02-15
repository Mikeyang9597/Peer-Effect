*01_01_04_program.do

local program_desc “$mydir\raw\dim_academic_program.dta”
local term_index “$mydir\clean\term_index.dta”

use `program_desc’, clear

keep if inlist(degree_level_code, "17" )

drop degree_level*

rename academic_program_key pgrm_code
destring pgrm_code, replace

*egen ever17=max(degree_cert_level_code=="17"), by(pgrm_code campus_key)

*****************************************************************************************

gen term_key_b = string(begin_term_key)
gen ab = substr(term_key_b, 2, 2)
gen c = substr(term_key_b, 4, 1) 
destring c, replace

g b_year = ""
replace b_year = "19" + ab if substr(term_key_b, 1, 1) == "1"
replace b_year = "20" + ab if substr(term_key_b, 1, 1) == "2"

g b_term = ""
replace b_term = "SM" if c == 1
replace b_term = "AU" if c == 2
replace b_term = "WI" if c == 3
replace b_term = "SP" if c == 4

drop ab c 

*merge with term index
rename b_year yr_num
destring yr_num, replace
rename b_term term_code
destring term_code, replace

merge m:1 yr_num term_code using `term_index'
keep if _merge == 3

rename term_index b_term_index

drop _merge term* begin* yr* min*


*****************************************************************************************

replace end_term_key = 2254 if end_term_key == 9999
gen term_key_e = string(end_term_key)
gen ab = substr(term_key_e, 2, 2)
gen c = substr(term_key_e, 4, 1) 
destring c, replace

g e_year = ""
replace e_year = "19" + ab if substr(term_key_e, 1, 1) == "1"
replace e_year = "20" + ab if substr(term_key_e, 1, 1) == "2"

g e_term = ""
replace e_term = "SM" if c == 1
replace e_term = "AU" if c == 2
replace e_term = "WI" if c == 3
replace e_term = "SP" if c == 4

drop ab c 

*merge with term index
rename e_year yr_num
destring yr_num, replace
rename e_term term_code
destring term_code, replace

merge m:1 yr_num term_code using `term_index'
keep if _merge == 3

rename term_index e_term_index

drop _merge term* yr* end*

*****************************************************************************************

gen term_range = e_term_index - b_term_index + 1

expand term_range

bysort pgrm_code (b_term_index): gen term_index = b_term_index + _n - 1

sort pgrm_code

drop active* b* e* term_range

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_program.dta”,replace