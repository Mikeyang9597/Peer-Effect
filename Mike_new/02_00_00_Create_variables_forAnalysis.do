****************************************************
*Create variables needed for analysis
****************************************************

*Input files:
local in "$mydir\clean_mike\main_in_ready.dta"

*main in
use `in', clear

***************************************************************************
*Clean up sample
***************************************************************************
***Drop students who start in Winter or Spring
drop if term_code_admit=="WI" | term_code_admit=="SP"
***Re-assign summer starts to fall
replace first_term_PhD=first_term_PhD+1 if term_code_admit=="SM"
*For summer starters, reassign firstQgpa to fall
replace firstQgpa=firstQgpa_AU if term_code=="SM"
drop firstQgpa_AU
drop if firstQgpa==.
*Deduct 1 quarter from time-to-PhD variable
replace yrstoPhD=yrstoPhD-.25 if term_code=="SM"

***Drop Youngstown and Medical U***
drop if inst_code=="YNGS" | inst_code=="MCOT"

***Drop transfer students***
*Also calculate % transfer in a program so that we can drop high-transfer programs later
egen per_transfer=mean(transfer_from), by(pgrm_cipcode2010_admit inst_code)
*egen temptag=tag(pgrm_cipcode2010_admit inst_code)
*codebook per_transfer if temptag==1
*Drop programs with >=20% transfer students, but can show robustness for dropping more or less
*For future robustness checks uncomment this line:
*gen todrop=(per_transfer>=`1')
gen todrop=(per_transfer>=.20)
drop if transfer_from==1
drop if todrop==1

**************************************************************
*Clean up various control variables and identifiers
**************************************************************
*STEM indicator
gen STEM=1 if pgrm_STEM_admit=="Graduate and Above" | pgrm_STEM_admit=="All Levels"
replace STEM=0 if pgrm_STEM_admit=="No Levels"
*Age variable
destring birth_yr, replace
gen age=yr_num_admit-birth_yr
gen age2=age*age
*Gender variable
gen female = 1 if sex == "F"
replace female = 0 if sex == "M"
drop sex
*international variable
gen international=race=="NR"
*encode string variables
encode pgrm_cipfield2010_admit, gen(field_num)
encode inst_code, gen(inst_num)
*replace race=unknown for international students
replace race="UK" if international==1
*race indicators
tab race, gen(race_ind)
*create CIP code-inst code identifier for fixed effects
egen cip_inst=group(pgrm_cipcode2010_admit inst_code)
egen field_inst=group(pgrm_cipfield2010_admit inst_code)



**************************************************************
*Create main outcome variables
**************************************************************
*Indicator for still enrolled in SP16
gen stillenrolled=last_term_PhD>68
replace stillenrolled=0 if everPhD==1
*Indicator for dropout
gen dropout=(everPhD==0)
replace dropout=0 if stillenrolled==1
*generate indicator for PhD within 5 years
gen PhDin5=(everPhD==1 & yrstoPhD<=5)
replace PhDin5=. if first_term_PhD>46
*generate indicator for PhD within 6 years
gen PhDin6=(everPhD==1 & yrstoPhD<=6)
replace PhDin6=. if first_term_PhD>=46

**Persistence variables:
*indicator for makes it to yr 2, yr3, etc
gen yrs_enrolled_PhD=yrstoPhD if everPhD==1
replace yrs_enrolled_PhD=(last_term_PhD-first_term_PhD+1)/4 if dropout==1
forval i = 1/6 {
local j =`i'+1
gen persist_to_yr`j'=(yrs_enrolled_PhD>`i' | everPhD==1 )
replace persist_to_yr`j'=. if first_term_PhD>66-4*(`i')
}

*drop if yrs_enrolled_PhD < 2

**************************************************************
* Create main treatment variables
**************************************************************
*** Create cohort-specific variables ***
local groups "field cip"
foreach x of local groups {
    if "`x'"=="field" {
        local groupvar="pgrm_cipfield2010_admit" 
    }
    else if "`x'"=="cip" {
        local groupvar="pgrm_cipcode2010_admit" 
    }

    * Create cohort size variable and log size
    egen `x'_cohort_size=count(id), by(`groupvar' inst_code first_term_PhD)
    
    * Create cohort gender composition variables
    egen `x'_num_female=sum(female), by(`groupvar' inst_code first_term_PhD)
    gen `x'_num_fem_peers=`x'_num_female
    replace `x'_num_fem_peers=`x'_num_female-1 if female==1
    gen `x'_per_female=`x'_num_female/(`x'_cohort_size) 
    gen `x'_per_fem_peers=`x'_num_female/(`x'_cohort_size-1) if female==0
    replace `x'_per_fem_peers=(`x'_num_female-1)/(`x'_cohort_size-1) if female==1

    * Create cohort international composition variables
    egen `x'_num_international=sum(international), by(`groupvar' inst_code first_term_PhD)
    gen `x'_num_int_peers=`x'_num_international
    replace `x'_num_int_peers=`x'_num_international-1 if international==1
    gen `x'_per_international=`x'_num_international/(`x'_cohort_size) 
    gen `x'_per_int_peers=`x'_num_international/(`x'_cohort_size-1) if international==0
    replace `x'_per_int_peers=(`x'_num_international-1)/(`x'_cohort_size-1) if international==1

    * Create cohort gender variables for second year of program
    egen `x'_num_female_yr2=sum(female*persist_to_yr2), by(`groupvar' inst_code first_term_PhD)
    egen `x'_cohort_size_yr2=sum(persist_to_yr2), by(`groupvar' inst_code first_term_PhD)
    gen `x'_per_female_yr2=`x'_num_female_yr2/(`x'_cohort_size_yr2)

    * Create cohort international variables for second year of program
    egen `x'_num_international_yr2=sum(international*persist_to_yr2), by(`groupvar' inst_code first_term_PhD)
    gen `x'_per_international_yr2=`x'_num_international_yr2/(`x'_cohort_size_yr2)
}

* Generate lag and lead cohort gender variables
sort cip_inst first_term_PhD
by cip_inst: gen lag_per_female=cip_per_female_yr2[_n-1] if first_term_PhD==first_term_PhD[_n-1]+4
bysort cip_inst first_term_PhD: replace lag_per_female=lag_per_female[1]
by cip_inst: gen lag_cohort_size=cip_cohort_size_yr2[_n-1] if first_term_PhD==first_term_PhD[_n-1]+4
bysort cip_inst first_term_PhD: replace lag_cohort_size=lag_cohort_size[1]

gsort cip_inst -first_term_PhD
by cip_inst: gen lead_per_female=cip_per_female[_n-1] if first_term_PhD==first_term_PhD[_n-1]-4
bysort cip_inst first_term_PhD (lead_per_female): replace lead_per_female=lead_per_female[1]
gsort cip_inst -first_term_PhD
by cip_inst: gen lead_cohort_size=cip_cohort_size[_n-1] if first_term_PhD==first_term_PhD[_n-1]-4
bysort cip_inst first_term_PhD (lead_cohort_size): replace lead_cohort_size=lead_cohort_size[1]

* Generate lag and lead cohort international variables
sort cip_inst first_term_PhD
by cip_inst: gen lag_per_international=cip_per_international_yr2[_n-1] if first_term_PhD==first_term_PhD[_n-1]+4
bysort cip_inst first_term_PhD: replace lag_per_international=lag_per_international[1]
by cip_inst: gen lag_cohort_size_international=cip_cohort_size_yr2[_n-1] if first_term_PhD==first_term_PhD[_n-1]+4
bysort cip_inst first_term_PhD: replace lag_cohort_size_international=lag_cohort_size_international[1]

gsort cip_inst -first_term_PhD
by cip_inst: gen lead_per_international=cip_per_international[_n-1] if first_term_PhD==first_term_PhD[_n-1]-4
bysort cip_inst first_term_PhD (lead_per_international): replace lead_per_international=lead_per_international[1]
gsort cip_inst -first_term_PhD
by cip_inst: gen lead_cohort_size_international=cip_cohort_size[_n-1] if first_term_PhD==first_term_PhD[_n-1]-4
bysort cip_inst first_term_PhD (lead_cohort_size_international): replace lead_cohort_size_international=lead_cohort_size_international[1]

* Create min, mean, and max cipcode size
egen cohort_tag=tag(cip_inst first_term_PhD)
egen mean_cohort_size=mean(cip_cohort_size) if cohort_tag==1, by(pgrm_cipcode2010_admit inst_code)
bysort cip_inst (cohort_tag): replace mean_cohort_size=mean_cohort_size[_N]
egen min_cohort_size=min(cip_cohort_size), by(pgrm_cipcode2010_admit inst_code)
egen max_cohort_size=max(cip_cohort_size), by(pgrm_cipcode2010_admit inst_code)

* Create mean percent female & deviations from mean
egen mean_per_female=mean(cip_per_female) if cohort_tag==1, by(pgrm_cipcode2010_admit inst_code)
bysort cip_inst (cohort_tag): replace mean_per_female=mean_per_female[_N]
gen demeaned_per_female=cip_per_female-mean_per_female
egen above_avg_female=cut(demeaned_per_female), at(-1, 0 ,1) label

* Create mean percent international & deviations from mean
egen mean_per_international=mean(cip_per_international) if cohort_tag==1, by(pgrm_cipcode2010_admit inst_code)
bysort cip_inst (cohort_tag): replace mean_per_international=mean_per_international[_N]
gen demeaned_per_international=cip_per_international-mean_per_international
egen above_avg_international=cut(demeaned_per_international), at(-1, 0 ,1) label

* Create ratio and logratio of women-to-men
gen ratioFM=cip_num_female/(cip_cohort_size-cip_num_female)
gen logratio=log(ratioFM)

* Create ratio and logratio of international-to-domestic
gen ratioIM=cip_num_international/(cip_cohort_size-cip_num_international)
gen logratioIM=log(ratioIM)

* Deviations from mean for lag and lead cohorts
gen demeaned_lag_per_female=lag_per_female-mean_per_female
gen demeaned_lead_per_female=lead_per_female-mean_per_female
egen lag_above_avg_female=cut(demeaned_lag_per_female), at(-1, 0 ,1) label
egen lead_above_avg_female=cut(demeaned_lead_per_female), at(-1, 0 ,1) label

gen demeaned_lag_per_international=lag_per_international-mean_per_international
gen demeaned_lead_per_international=lead_per_international-mean_per_international
egen lag_above_avg_international=cut(demeaned_lag_per_international), at(-1, 0 ,1) label
egen lead_above_avg_international=cut(demeaned_lead_per_international), at(-1, 0 ,1) label



*Calculate average age for each program-cohort
egen cip_cohort_age=mean(age), by(pgrm_cipcode2010 inst_code first_term_PhD)

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\Data_all_Years.dta",replace
********************************************************************************

*Main sample is 2005-2009 (cohorts for whom Phdin6 is defined)
drop if first_term_PhD>42

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\Data_for_Robustness.dta",replace
********************************************************************************
***************************************************************

*Preferred sample is STEM AND size>9 only
keep if STEM==1
drop if mean_cohort_size<=9
*Define Typically Male/Typically Female Sample
egen programtag=tag(cip_inst)
codebook mean_per_female if programtag
*%female: mean=37.7; median=36.7; p75=50.3
gen typically_male=(mean_per_female<=.498425)

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\Data_Preferred_Sample.dta",replace
********************************************************************************
