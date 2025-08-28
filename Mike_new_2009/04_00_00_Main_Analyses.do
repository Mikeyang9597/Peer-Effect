*04_00_00_Main_Analyses.do

*Input files:
local main "$mydir\clean_mike\Data_Preferred_Sample.dta"
local robust "$mydir\clean_mike\Data_for_Robustness.dta"
local allyrs "$mydir\clean_mike\Data_all_Years.dta"

global controls "cip_cohort_size c.age##c.age female cip_per_fem_peers race_ind1-race_ind4 race_ind6"
global controls_age "cip_cohort_size female race_ind1-race_ind4 race_ind6"
global FEs "i.first_term_PhD i.cip_inst"

***************************************************************************
*Table 1: Summary Statistics by CIP Code
***************************************************************************

*Make list of CIP Codes and main characteristics
*Include only those programs in the main estimation sample

*main in
use `main', clear
collapse (first) pgrm_cipfield pgrm_ciptitle mean_cohort_size cip_per_international , by(pgrm_cipcode inst_code)
collapse (first) pgrm_cipfield pgrm_ciptitle (mean) mean_cohort_size (mean)cip_per_international  (count) num_pgrms=mean_cohort_size, by(pgrm_cipcode)
sort mean_cohort_size

***************************************************************************
*Table 2: Cohort Characteristics
***************************************************************************

*Cohort Characteristics
*Panel A: Estimation sample
use `main', clear
summ STEM cip_cohort_size cip_num_international cip_per_international if cohort_tag==1

*Panel B: Estimation Sample + Non-STEM + Small Programs
use `robust', clear
summ STEM cip_cohort_size cip_num_international cip_per_international if cohort_tag==1

*Panel C: Full Sample, All Years
use `allyrs', clear
summ STEM cip_cohort_size cip_num_international cip_per_international if cohort_tag==1

***************************************************************************
* Table 3: Summary Statistics by Gender
***************************************************************************

use `main', clear  

* 추가 변수 생성
gen dropout_before_yr2 = 1 - persist_to_yr2
gen dropout_before_yr3 = 1 - persist_to_yr3
gen dropout_before_yr4 = 1 - persist_to_yr4
gen dropout_before_yr5 = 1 - persist_to_yr5
gen dropout_before_yr6 = 1 - persist_to_yr6
gen dropout_before_yr7 = 1 - persist_to_yr7
gen enrolledafter7 = persist_to_yr8 - PhDin7

foreach Y in 0 1 {
    di "--------------------------------------------------"
    di "Summary Statistics for international == `Y'"
    di "--------------------------------------------------"

    * Outcome variables
    summ   PhDin7  yrstoPhD dropout_before_yr2 dropout_before_yr3 dropout_before_yr4 dropout_before_yr5 dropout_before_yr6 dropout_before_yr7 enrolledafter7 yrs_enrolled_PhD if international == `Y'
    
    * Demographics/Controls
    summ age international if international == `Y'
    
    * Grades
    summ firstQgpa firstYrgpa if international == `Y'
}


***************************************************************************
*Figure 1: Trends in Cohort international Composition By Field
***************************************************************************

use `allyrs', clear
keep if STEM==1
drop if mean_cohort_size<=9
egen first_cohort=min(first_term_PhD), by(cip_inst)
drop if first_cohort>64
collapse (first) cip_per_international pgrm_cipfield inst_code, by(cip_inst first_term_PhD)
sort cip_inst first_term_PhD


capture confirm variable inst_num
if _rc encode inst_code, gen(inst_num)

* 2) 기관별 선 준비
levelsof inst_num, local(INSTS)

local plots ""
foreach k of local INSTS {
    local plots `plots' (line cip_per_international first_term_PhD if inst_num==`k', sort lwidth(vthin) lcolor(gs8) cmissing(n))
}

* 3) 그림 그리기
twoway `plots', by(pgrm_cipfield, col(4) compact note("")) yscale(range(0 1)) ylabel(0(.1)1, angle(horizontal) nogrid) xlabel(#10, angle(45)) xtitle("First PhD Term") ytitle("% International Peers") legend(off) scheme(s2mono)




***************************************************************************
*Figure 2: Correlation Between Cohort Gender Composition and Covariates (Demeaned)
***************************************************************************

use `allyrs', clear
*keep if STEM==1
drop if mean_cohort_size<=9
*drop programs that start after 2009
egen first_cohort=min(first_term_PhD), by(cip_inst)
drop if first_cohort>64
*calculate all demeaned covariates
*already have mean_cohort_size and mean_per_female
local covariates "age international race_ind6 female firstYrgpa" 
foreach x of local covariates {
egen pgrm_mean_`x'=mean(`x'), by(pgrm_cipcode2010_admit inst_code)
egen cohort_mean_`x'=mean(`x'), by(pgrm_cipcode2010_admit inst_code first_term_PhD)
gen demeaned_`x'=cohort_mean_`x'-pgrm_mean_`x'
}
gen demeaned_cohort_size=cip_cohort_size-mean_cohort_size
*Keep one obs per cohort
keep if cohort_tag==1
*Drop cohorts after 2013
drop if first_term_PhD>64

*Panel (a): corr between cohort size and international composition
reg demeaned_cohort_size demeaned_per_international 
matrix bhat=e(b)
local x : display %4.2f = bhat[1,1]
test _b[demeaned_per_international]=0
local pval  : display %5.3f = r(p)
twoway scatter demeaned_cohort_size demeaned_per_international || lfit demeaned_cohort_size demeaned_per_international, xtitle("% Cohort International - Program Avg % International") ytitle("Cohort Size - Program Avg Cohort Size") legend(label(1 "Demeaned Cohort Size")) text(5 0.3 "coef: `x'" "p-value: `pval'") graphregion(color(white)) bgcolor(white)

*Panel (b): corr between cohort age and international composition
regress demeaned_age demeaned_per_international 
matrix bhat=e(b)
local x : display %4.2f = bhat[1,1]
test _b[demeaned_per_international]=0
local pval  : display %5.3f = r(p)
twoway scatter demeaned_age demeaned_per_international || lfit demeaned_age demeaned_per_international, xtitle("% Cohort International - Program Avg % International") ytitle("Cohort Avg Age - Program Avg Age") legend(label(1 "Demeaned Cohort Age")) text(30 0.3 "coef: `x'" "p-value: `pval'") graphregion(color(white)) bgcolor(white)

*Panel (c): corr between cohort foreign-born composition and international composition
regress demeaned_female demeaned_per_international 
matrix bhat=e(b)
local x : display %4.2f = bhat[1,1]
test _b[demeaned_per_international]=0
local pval  : display %5.3f = r(p)
twoway scatter demeaned_female demeaned_per_international || lfit demeaned_female demeaned_per_international, xtitle("% Cohort International - Program Avg % International") ytitle("% Cohort female - Program Avg % female") legend(label(1 "Demeaned Cohort % Foreign")) text(0.4 0.3 "coef: `x'" "p-value: `pval'") graphregion(color(white)) bgcolor(white)

*Panel (d): corr between cohort foreign-born composition and international composition
regress demeaned_firstYrgpa demeaned_per_international 
matrix bhat=e(b)
local x : display %4.2f = bhat[1,1]
test _b[demeaned_per_international]=0
local pval  : display %5.3f = r(p)
twoway scatter demeaned_firstYrgpa demeaned_per_international || lfit demeaned_firstYrgpa demeaned_per_international, xtitle("% Cohort International - Program Avg % International") ytitle("% Cohort firstYrgpa  - Program Avg % firstYrgpa ") legend(label(1 "Demeaned Cohort % Foreign")) text(0.4 0.3 "coef: `x'" "p-value: `pval'") graphregion(color(white)) bgcolor(white)

***************************************************************************
*Table 4A: 
***************************************************************************
use `main', clear 
*keep if mean_cohort_size > 10
*keep if cip_per_int_peers > 0.8
*keep if cip_per_int_peers <= 0.2
*keep if demeaned_per_international <= 0
*keep if demeaned_per_international >= .148649
*keep if demeaned_per_international <= .174917
*keep if STEM == 0
*Run using 3 different definitions of cohort international students composition
local int_comp "cip_per_int_peers"
foreach mainvar of local int_comp {
	probit PhDin7 c.`mainvar'##i.international $controls $FEs , cluster(cip_inst) 
	*Effect of no int peers on int student
	margins, dydx(i.international) atmeans at(`mainvar'==0)
	*Effect of addtl int peers on domestic students and int students separately
	margins, dydx(`mainvar' ) atmeans over(international) post 
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[`mainvar':1.international] - _b[`mainvar':0.international]
}


use `main', clear 
reghdfe PhDin7 c.cip_per_int_peers##i.international#i.cip_per_int_peers_cut10 $controls, absorb($FEs) vce(cluster cip_inst)

* 구간 1 (11)
lincom c.cip_per_int_peers#1.cip_per_int_peers_cut3 + 1.international#1.cip_per_int_peers_cut3#c.cip_per_int_peers

* 구간 2 (12)
lincom c.cip_per_int_peers#2.cip_per_int_peers_cut3 + 1.international#2.cip_per_int_peers_cut3#c.cip_per_int_peers

* 구간 3 (13)
lincom c.cip_per_int_peers#3.cip_per_int_peers_cut3 + 1.international#3.cip_per_int_peers_cut3#c.cip_per_int_peers



*local yvars "persist_to_yr2 persist_to_yr3 persist_to_yr4 persist_to_yr5 persist_to_yr6 persist_to_yr7"
use `main', clear 
reghdfe persist_to_yr4 c.cip_per_int_peers##i.international#i.cip_per_int_peers_cut3 $controls, absorb($FEs) vce(cluster cip_inst)


***************************************************************************
*Table 4A: 
***************************************************************************
use `main', clear 

gen year = .
forvalues i = 32(4)64 {
    local y = (`i' - 28) / 4
    replace year = `y' if first_term_PhD == `i'
}

*Run using 3 different definitions of cohort gender composition
local int_comp "cip_per_int_peers"
foreach mainvar of local int_comp {
	probit PhDin7 c.`mainvar'##i.international##i.year $controls $FEs , cluster(cip_inst) 
}


***************************************************************************
*Table 4A: 
***************************************************************************
use `main', clear
drop if first_term_PhD < 48 
*Run using 3 different definitions of cohort gender composition
local int_comp "per_same_continent_peers"
foreach mainvar of local int_comp {
	probit PhDin7 c.`mainvar'##i.continent_num $controls $FEs, cluster(cip_inst) 
	*Effect of no int peers on int student
	margins, dydx(i.continent_num) atmeans at(`mainvar'==0)
	*Effect of addtl int peers on domestic students and int students separately
	margins, dydx(`mainvar') atmeans over(continent_num) post 

}


***************************************************************************
*Table 5: Effect of Cohort Gender Composition on Ph.D. Persistence
***************************************************************************
use `main', clear  
*keep if STEM == 0
*keep if cip_per_int_peers > 0.5
*keep if cip_per_int_peers <= 0.6
*For 5 outcome variables: persistence through year 2...6
*local yvars "persist_to_yr2 persist_to_yr3 persist_to_yr4 persist_to_yr5 persist_to_yr6 persist_to_yr7"
local yvars "persist_to_yr7"
foreach y of local yvars {
	 probit `y' c.cip_per_int_peers##i.international  $controls $FEs, cluster(cip_inst) 
	*Effect of no female peers on female student
	margins, dydx(i.international) atmeans at(cip_per_int_peers==0)
	*Effect of addtl female peers on male students and female students separately
	margins, dydx(cip_per_int_peers) atmeans over(international) post
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[cip_per_int_peers:1.international] - _b[cip_per_int_peers:0.international]
}

use `main', clear 
reghdfe persist_to_yr3 c.cip_per_int_peers##i.international $controls, absorb($FEs) vce(cluster cip_inst)


***************************************************************************
*Table 6: Effects of Cohort Gender Composition By Typically Male/Female Programs
***************************************************************************
use `main', clear  
	quietly probit PhDin7 c.cip_per_int_peers##i.international  $controls $FEs if typically_international==0, cluster(cip_inst) 
	*Effect of no female peers on female student
	margins, dydx(i.international) atmeans at(cip_per_int_peers==0)
	*Effect of addtl female peers on male students and female students separately
	margins, dydx(cip_per_int_peers) atmeans over(international) post
	*Differential effect of addtl female peers on female students vs. male students
	lincom _b[cip_per_int_peers:1.international] - _b[cip_per_int_peers:0.international]



