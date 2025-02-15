*01_02_03_Collapse_to_individual.do

*Input files:
local in “$mydir\clean\merged_main_done.dta”
local term_index “$mydir\clean\term_index.dta”

use `in', clear

***generate first and last GPA***
bysort person_inst (term_index): gen firstQgpa=gpa[1]
bysort person_inst (term_index): gen lastQgpa=gpa[_N]

***Save 1st FALL quarter GPA as well***
bysort person_inst term_code (term_index): gen firstQgpa_season=gpa[1]
replace firstQgpa_season=. if term_code!="AU"
egen firstQgpa_AU=min(firstQgpa_season), by(person_inst)
drop firstQgpa_season

***Save 1st Year GPA (GPA in the Spring of the year after first enrollment)***
*Merge in year and term for PhD start
rename term_index current_term_index
rename yr_num current_yr_num
rename term_code current_term_code
rename first_term_PhD term_index
merge m:1 term_index using `term_index'
drop if _merge==2
drop _merge
gen temp=gpa if current_yr_num==yr_num+1 & current_term_code=="SP"
egen firstYrgpa=min(temp), by(person_inst)
drop temp yr_num term_code
rename term_index first_term_PhD 
rename current_term_code term_code
rename current_yr_num yr_num
rename current_term_index term_index

***keep only 1 obs per person-institution***
keep if term_index==first_term_PhD

***Drop unnecessary variables***
drop admission* gpa 

save “\\chrr\vr\profiles\syang\Desktop\clean\merged_main_indiv.dta”,replace

********************************************************************************