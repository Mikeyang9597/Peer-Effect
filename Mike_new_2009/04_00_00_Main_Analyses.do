*04_00_00_Main_Analyses.do

*Input files:
local main "$mydir\clean_mike\Data_Preferred_Sample.dta"
local robust "$mydir\clean_mike\Data_for_Robustness.dta"
local allyrs "$mydir\clean_mike\Data_all_Years.dta"

global controls "cip_cohort_size c.age##c.age female race_ind1-race_ind4 race_ind6"
global controls_age "cip_cohort_size female race_ind1-race_ind4 race_ind6"
global FEs "i.first_term_PhD i.cip_inst"

***************************************************************************
*Table 1: Summary Statistics by CIP Code
***************************************************************************

*Make list of CIP Codes and main characteristics
*Include only those programs in the main estimation sample

*main in
use `main', clear
collapse (first) pgrm_cipfield  pgrm_ciptitle mean_cohort_size mean_per_female, by(pgrm_cipcode inst_code)
collapse (first) pgrm_cipfield  pgrm_ciptitle (mean) mean_cohort_size mean_per_female (count) num_pgrms=mean_cohort_size, by(pgrm_cipcode)
sort mean_per_female


***************************************************************************
*Table 2: Cohort Characteristics
***************************************************************************

*Cohort Characteristics
*Panel A: Estimation sample
use `main', clear
summ STEM cip_cohort_size cip_num_international cip_per_female if cohort_tag==1

*Panel B: Estimation Sample + Non-STEM + Small Programs
use `robust', clear
summ STEM cip_cohort_size cip_num_female cip_per_female if cohort_tag==1

*Panel C: Full Sample, All Years
use `allyrs', clear
summ STEM cip_cohort_size cip_num_female cip_per_female if cohort_tag==1

***************************************************************************
* Table 3: Summary Statistics by Gender
***************************************************************************

use `main', clear  

* 추가 변수 생성
gen dropout_by6 = 1 - persist_to_yr7
gen enrolledafter6 = persist_to_yr7 - PhDin6

foreach f in 0 1 {
    di "--------------------------------------------------"
    di "Summary Statistics for Female == `f'"
    di "--------------------------------------------------"

    * Outcome variables
    summ PhDin6 yrstoPhD dropout_by6 enrolledafter6 yrs_enrolled_PhD if female == `f'
    
    * Demographics/Controls
    summ age international if female == `f'
    
    * Grades
    summ firstQgpa firstYrgpa if female == `f'
}

***************************************************************************
*Table 4A: Effect of Cohort Gender Composition on Ph.D. Completion Within 6 Years
***************************************************************************
use `main', clear 
*Run using 3 different definitions of cohort gender composition
local int_comp "cip_per_int_peers"
foreach mainvar of local int_comp {
	quietly probit PhDin6 c.`mainvar'##i.international $controls $FEs, cluster(cip_inst) 
	*Effect of no int peers on int student
	margins, dydx(i.international) atmeans at(`mainvar'==0)
	*Effect of addtl int peers on domestic students and int students separately
	margins, dydx(`mainvar' ) atmeans over(international) post 
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[`mainvar':1.international] - _b[`mainvar':0.international]
}

***************************************************************************
*Table 4B: DDD Chinese Peer
***************************************************************************

use `main', clear

local mainvar "cip_per_china_peers"

    * DDD probit regression
    quietly probit PhDin6 c.`mainvar'##i.international##i.china $controls $FEs, cluster(cip_inst)

    * β₁: Int (non-Chinese) vs Domestic at 0% Chinese peers
	margins, dydx(i.international) atmeans over(china) at(`mainvar'==0)
		
	* β1+B2: Chinese vs international at 0% Chinese peers
	margins, dydx(i.china) atmeans over(international) at(`mainvar'==0)
	
	* β 3,4,5 : Peer effect diff: Chinese vs Intl non-Chinese"
    margins, dydx(`mainvar') atmeans over(china international) post
	lincom _b[`mainvar':0.china#1.international] - _b[`mainvar':0.china#0.international]
	lincom _b[`mainvar':1.china#1.international] - _b[`mainvar':0.china#1.international]

	
	
	use `main', clear 
*Run using 3 different definitions of cohort gender composition
local int_comp "per_same_county_peers"
foreach mainvar of local int_comp {
	probit PhDin6 c.`mainvar'##i.international $controls $FEs, cluster(cip_inst) 
	*Effect of no int peers on int student
	margins, dydx(i.international) atmeans at(`mainvar'==0)
	*Effect of addtl int peers on domestic students and int students separately
	margins, dydx(`mainvar' ) atmeans over(international) post 
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[`mainvar':1.international] - _b[`mainvar':0.international]
}


	
***************************************************************************
*Table 5: Effect of Cohort Gender Composition on Ph.D. Persistence
***************************************************************************
use `main', clear  
*For 5 outcome variables: persistence through year 2...6
local yvars "persist_to_yr2"
foreach y of local yvars {
	quietly probit `y' c.cip_per_fem_peers##i.female  $controls $FEs, cluster(cip_inst) 
	*Effect of no female peers on female student
	margins, dydx(i.female) atmeans at(cip_per_fem_peers==0)
	*Effect of addtl female peers on male students and female students separately
	margins, dydx(cip_per_fem_peers) atmeans over(female) post
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[cip_per_fem_peers:1.female] - _b[cip_per_fem_peers:0.female]
}

***************************************************************************
*Table 6: Effects of Cohort Gender Composition By Typically Male/Female Programs
***************************************************************************
use $main, clear
*First use definition of typically male programs: average cohort gender composition ≤ 36.7% female
forval g=0/1 {
	quietly probit PhDin6 c.cip_per_fem_peers##i.female  $controls $FEs if typically_male==`g', cluster(cip_inst) 
	*Effect of no female peers on female student
	margins, dydx(i.female) atmeans at(cip_per_fem_peers==0)
	*Effect of addtl female peers on male students and female students separately
	margins, dydx(cip_per_fem_peers) atmeans over(female) post
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[cip_per_fem_peers:1.female] - _b[cip_per_fem_peers:0.female]
}



*Second use definition of typically male programs: all programs in Engineering, Mathematics & Statistics, and Physics
gen typically_male2 = 0
replace typically_male2=1 if pgrm_cipfield=="Other Engineering"  | pgrm_cipfield=="Chemical Engineering" | pgrm_cipfield=="Computer Engineering"  | pgrm_cipfield=="Electrical, Electronics, and Communications Engineering" | pgrm_cipfield=="Materials Engineering" | pgrm_cipfield=="Mathematics and Statistics" | pgrm_cipfield=="Physics" | pgrm_cipfield=="Civil Engineering" | pgrm_cipfield=="Mechanical, Industrial, and Manufacturing Engineering" | pgrm_cipfield=="Physical Sciences" 
forval g=0/1 {
	quietly probit PhDin6 c.cip_per_fem_peers##i.female  $controls $FEs if typically_male2==`g', cluster(cip_inst) 
	*Effect of no female peers on female student
	margins, dydx(i.female) atmeans at(cip_per_fem_peers==0)
	*Effect of addtl female peers on male students and female students separately
	margins, dydx(cip_per_fem_peers) atmeans over(female) post
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[cip_per_fem_peers:1.female] - _b[cip_per_fem_peers:0.female]
}

