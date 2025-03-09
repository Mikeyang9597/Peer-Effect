*CIP code
*CIP 2011
import excel "$mydir\raw\discipline_subject_CIP_Nov2011",clear firstrow case(lower)
rename subjectcode cipcode2010
drop disciplinearea subjectfield subjecttitle

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIP2010.dta",replace

import excel "$mydir\raw\prior_HEI_subject_codes",clear firstrow case(lower)
rename subjectcode cipcode2010
rename subjecttitle subjecttitle_
rename subjectfield subjectfield_
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIP2000.dta",replace

import excel "$mydir\raw\CIPCrosswalk2010to2020",clear firstrow case(lower)
replace cipcode2020=round(cipcode2020*10000)
replace cipcode2010=round(cipcode2010*10000)
*remove duplicates
duplicates drop cipcode2020 cipcode2010, force
duplicates tag cipcode2020, gen(dup)
drop if dup>0 & action=="New"
drop dup
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPcrosswalk2000to2010.dta",replace


**********************************************************
*Merge all together
**********************************************************
use "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPcrosswalk2000to2010.dta", clear

merge m:1 cipcode2010 using "$mydir\clean_mike\CIP2010.dta"
keep if _merge == 3
drop textchange _merge ciptitle2010 action _merge

*merge in 2010 CIP
merge m:1 cipcode2010 using "$mydir\clean_mike\CIP2000.dta"
keep if _merge == 3
drop _merge cipcode2010 subjecttitle_

rename cipcode2020  cipcode2010
rename ciptitle2020 subjecttitle2010
rename subjectfield subjectfield2010
duplicates drop

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPmaster.dta",replace
