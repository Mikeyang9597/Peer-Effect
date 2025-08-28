*Clean & Merge CIP data
********************************************************************************
*1
import excel "$mydir\raw\CIPCrosswalk1990to2000",firstrow clear case(lower)
rename cip2000 cipcode2000
rename cip1990 cipcode1990
*remove duplicates
duplicates drop cipcode2000 cipcode1990, force
keep cipcode1990 cipcode2000
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPcrosswalk1990to2000.dta",replace

*2
import excel "$mydir\raw\discipline_subject_CIP_Nov2011",clear firstrow case(lower)
rename subjectcode cipcode2010
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIP2010.dta",replace

*3
import excel "$mydir\raw\CIPCrosswalk2000to2010", clear firstrow case(lower)
replace cipcode2000=round(cipcode2000*10000)
replace cipcode2010=round(cipcode2010*10000)
*remove duplicates
duplicates drop cipcode2000 cipcode2010, force
duplicates tag cipcode2010, gen(dup)
drop if dup>0 & action=="New"
drop dup
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPcrosswalk2000to2010.dta",replace

*4
import excel "$mydir\raw\prior_HEI_subject_codes", clear firstrow case(lower)
rename subjectcode cipcode2000
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIP2000.dta",replace



*Merge all together
use "$mydir\clean_mike\CIPcrosswalk1990to2000.dta" , clear
merge m:1 cipcode2000 using "$mydir\clean_mike\CIP2000.dta"
drop if _merge==1
drop _merge
drop subject*
joinby cipcode2000 using "$mydir\clean_mike\CIPcrosswalk2000to2010.dta", unmatched(both)
drop _merge
drop textchange 
*merge in 2010 CIP
merge m:1 cipcode2010 using "$mydir\clean_mike\CIP2010.dta"
drop _merge 
destring cipcode2010, replace
rename subjecttitle subjecttitle2010
rename subjectfield subjectfield2010
drop disciplinearea
keep subjecttitle2010 subjectfield2010 cipcode2010 stemdesignation
duplicates drop
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPmaster.dta",replace


* save continet data in dta form
import excel "$mydir\raw\continent",firstrow clear case(lower)
drop c d
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\continent.dta",replace

* save CIP-income data in dta form
import excel "$mydir\raw\CIP_income",firstrow clear case(lower)
drop if cipcode == .
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\cip_income.dta",replace

