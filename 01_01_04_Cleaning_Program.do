*01_01_04_program.do

local program_desc “$mydir\raw\dim_academic_program.dta”

use `program_desc’, clear

keep if inlist(degree_level_code, "17" )

*mark the programs 
rename degree_level_code degree_cert_level_code
rename academic_program_key pgrm_code
destring pgrm_code, replace
egen ever17=max(degree_cert_level_code=="17"), by(pgrm_code campus_key)

bysort pgrm_code : keep if _n == 1

save “\\chrr\vr\profiles\syang\Desktop\clean\clean_program.dta”,replace