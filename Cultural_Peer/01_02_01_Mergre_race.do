*01_02_01_Merge.do

local main "$mydir\clean_mike\clean_main.dta"
local race "$mydir\clean_mike\clean_race.dta"
local term_index "$mydir\clean_mike\term_index.dta"
local pgrm_clean "$mydir\clean_mike\clean_pgrm.dta"
local CIP2010 "$mydir\clean_mike\CIPmaster.dta"

*data in
use `main' , clear

*merge
merge m:1 id using `race'
keep if _merge == 3
drop _merge

gen hold=(inst_code=="OHSU" & yr_num==2011 & term_code=="AU")
replace term_code="SP" if hold==1
replace yr_num=2012 if hold==1

gen hold2=((yr_num==2015 & term_code!="SP") | yr_num==2016)
replace yr_num=yr_num-1 if hold2==1

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

destring cip_code academic_program_key campus_key, replace
merge m:1 academic_program_key campus_key term_index using `pgrm_clean'
drop if _merge==2
replace term_code="AU" if hold==1
replace yr_num=2011 if hold==1
replace yr_num=yr_num+1 if hold2==1
drop _merge hold hold2

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge


****Update program code variables for pgrm_code=="UNDECI" rows****
*For pgrm_code=="UNDECI", look forward to first non-missing pgrm_code and reassign to that value
gsort id inst_code -term_index
*also fill in all other academic program variables
foreach var of varlist academic_program_key degree_level_code cip_code ever18 ever19 {
replace `var'=`var'[_n-1] if degree_level_code=="" & id==id[_n-1] & inst_code==inst_code[_n-1] 
}
replace degree_level_code=degree_level_code[_n-1] if degree_level_code=="" & id==id[_n-1] & inst_code==inst_code[_n-1] 


*For pgrm_code=="UNDECI", look backward to first non-missing pgrm_code and reassign to that value
gsort id inst_code term_index
*also fill in all other academic program variables
foreach var of varlist academic_program_key degree_level_code cip_code  {
replace `var'=`var'[_n-1] if degree_level_code=="" & id==id[_n-1] & inst_code==inst_code[_n-1] 
}
replace degree_level_code=degree_level_code[_n-1] if degree_level_code=="" & id==id[_n-1] & inst_code==inst_code[_n-1] 

*drop remaining students where pgrm_code is always undecided
drop if degree_level_code==""


************************************************
*Only keep PhD students
************************************************
*keep doctorates (09, 17) but drop programs that switch from 09 to 18 or 19 or if degree_code!=PHD
keep if degree_level_code=="09" | degree_level_code=="17"
drop if ever18 | ever19
drop ever18 ever19

*revise first and last term variables now that I've dropped non-doctorates
rename first_term first_term_GRD
rename last_term last_term_GRD
egen first_term_PhD=min(term_index), by(id inst_code)
egen last_term_PhD=max(term_index), by(id inst_code)
egen transfer_from_other_level=max(first_term_PhD!=first_term_GRD), by(id inst_code)
egen transfer_to_other_level=max(last_term_PhD!=last_term_GRD), by(id inst_code)

sort id term_index 
*browse id term_index first_term_GRD first_term_P inst_code transfer_from_other_level cip_code degree_level_code

*revise first term variable
rename first_term_PhD first_term_nocredit
egen first_term_PhD=min(term_index), by(id inst_code)

*Create group observation identifiers
egen person_inst=group(id inst_code)

rename cip_code cipcode2010

*Merge in field titles from program subject codes using CIP code crosswalks
*first match CIP codes from before 2010
destring cipcode2010, replace
merge m:1 cipcode2010 using `CIP2010'
keep if _merge==3
drop _merge
rename cipcode2010 pgrm_cipcode2010
rename subjecttitle2010 pgrm_ciptitle2010
rename subjectfield2010 pgrm_cipfield2010
rename stemdesignation pgrm_STEM

compress

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\merged_main.dta",replace

********************************************************************************

