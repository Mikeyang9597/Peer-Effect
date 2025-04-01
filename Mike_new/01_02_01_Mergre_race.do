*01_02_01_Merge.do

local main "$mydir\clean_mike\clean_main_cip.dta"
local race "$mydir\clean_mike\clean_race.dta"
local term_index "$mydir\clean_mike\term_index.dta"

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

replace term_code="AU" if hold==1
replace yr_num=2011 if hold==1
replace yr_num=yr_num+1 if hold2==1
drop hold hold2 term_index

*merge with term index
merge m:1 yr_num term_code using `term_index'
keep if _merge==3
drop _merge

*revise first and last term variables now that I've dropped non-doctorates
rename first_term first_term_GRD
rename last_term last_term_GRD
egen first_term_PhD=min(term_index), by(id inst_code)
egen last_term_PhD=max(term_index), by(id inst_code)
egen transfer_from_other_level=max(first_term_PhD!=first_term_GRD), by(id inst_code)
egen transfer_to_other_level=max(last_term_PhD!=last_term_GRD), by(id inst_code)

*revise first term variable
rename first_term_PhD first_term_nocredit
egen first_term_PhD=min(term_index), by(id inst_code)

*Create group observation identifiers
egen person_inst=group(id inst_code)

compress

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\merged_main.dta",replace

********************************************************************************
