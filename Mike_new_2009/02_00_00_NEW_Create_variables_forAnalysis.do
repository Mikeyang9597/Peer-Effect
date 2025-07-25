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
***Re-assign cohort starts
drop if term_code_admit=="WI" | term_code_admit=="SP"
replace first_term_PhD=first_term_PhD+1 if term_code_admit=="SM"

*For summer starters, reassign firstQgpa to fall
replace firstQgpa=firstQgpa_AU if term_code=="SM"
drop firstQgpa_AU
drop if firstQgpa==.

*Deduct 1 quarter from time-to-PhD variable
replace yrstoPhD=yrstoPhD-.25 if term_code=="SM"

***Drop Youngstown and Medical U***
drop if inst_code=="YNGS" | inst_code=="MCOT"

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
drop yr_num_admit birth_yr
*Gender variable
gen female = 1 if sex == "F"
replace female = 0 if sex == "M"
drop sex
*encode string variables
encode pgrm_cipfield2010_admit, gen(field_num)
encode inst_code, gen(inst_num)
tab race, gen(race_ind)
*create CIP code-inst code identifier for fixed effects
egen cip_inst=group(pgrm_cipcode2010_admit inst_code)
egen field_inst=group(pgrm_cipfield2010_admit inst_code)


**************************************************************
*Create main outcome variables
**************************************************************
*Indicator for still enrolled in SP23
gen stillenrolled=last_term_PhD > 90
replace stillenrolled=0 if everPhD==1
*Indicator for dropout
gen dropout=(everPhD==0)
replace dropout=0 if stillenrolled==1
*generate indicator for PhD within 5 years
gen PhDin5=(everPhD==1 & yrstoPhD<=5)
replace PhDin5=. if first_term_PhD>72
*generate indicator for PhD within 6 years
gen PhDin6=(everPhD==1 & yrstoPhD<=6)
replace PhDin6=. if first_term_PhD>=68
*generate indicator for PhD within 7 years
gen PhDin7=(everPhD==1 & yrstoPhD<=7)
replace PhDin7=. if first_term_PhD>=64
*generate indicator for PhD within 8 years
gen PhDin8=(everPhD==1 & yrstoPhD<=8)
replace PhDin8=. if first_term_PhD>=60


**Persistence variables:
*indicator for makes it to yr 2, yr3, etc
gen yrs_enrolled_PhD=yrstoPhD if everPhD==1
replace yrs_enrolled_PhD=(last_term_PhD-first_term_PhD+1)/4 if dropout==1
forval i = 1/6 {
local j =`i'+1
gen persist_to_yr`j'=(yrs_enrolled_PhD>`i' | everPhD==1 )
replace persist_to_yr`j'=. if first_term_PhD>80-4*(`i')
}


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
    
    * Gender composition
    egen `x'_num_female=sum(female), by(`groupvar' inst_code first_term_PhD)
    gen `x'_num_fem_peers=`x'_num_female
    replace `x'_num_fem_peers=`x'_num_female-1 if female==1
    gen `x'_per_female=`x'_num_female/(`x'_cohort_size) 
    gen `x'_per_fem_peers=`x'_num_female/(`x'_cohort_size-1) if female==0
    replace `x'_per_fem_peers=(`x'_num_female-1)/(`x'_cohort_size-1) if female==1

    * International composition
    egen `x'_num_international=sum(international), by(`groupvar' inst_code first_term_PhD)
    gen `x'_num_int_peers=`x'_num_international
    replace `x'_num_int_peers=`x'_num_international-1 if international==1
    gen `x'_per_international=`x'_num_international/(`x'_cohort_size) 
    gen `x'_per_int_peers=`x'_num_international/(`x'_cohort_size-1) if international==0
    replace `x'_per_int_peers=(`x'_num_international-1)/(`x'_cohort_size-1) if international==1


    * Year 2 Gender
    egen `x'_num_female_yr2=sum(female*persist_to_yr2), by(`groupvar' inst_code first_term_PhD)
    egen `x'_cohort_size_yr2=sum(persist_to_yr2), by(`groupvar' inst_code first_term_PhD)
    gen `x'_per_female_yr2=`x'_num_female_yr2/(`x'_cohort_size_yr2)

    * Year 2 International
    egen `x'_num_international_yr2=sum(international*persist_to_yr2), by(`groupvar' inst_code first_term_PhD)
    gen `x'_per_international_yr2=`x'_num_international_yr2/(`x'_cohort_size_yr2)

}



*same_country_peer
bysort pgrm_cipcode2010_admit inst_code first_term_PhD cood: gen same_country_count = _N 
replace same_country_count = . if unknown == 1

gen unknown_flag = (unknown == 1)
egen num_unknown = total(unknown_flag), by(pgrm_cipcode2010_admit inst_code first_term_PhD)


gen same_country_share = same_country_count / (cip_cohort_size - num_unknown)
gen same_country_peers = same_country_count - 1 
gen same_country_peer_share = same_country_peers / (cip_cohort_size - 1 - num_unknown)
rename same_country_peer_share per_same_county_peers
gen same_country_indicator = 0
replace same_country_indicator = 1 if same_country_count > 1


bysort pgrm_cipcode2010_admit inst_code first_term_PhD continent_num: gen same_continent_count = _N 
gen same_continent_share = same_continent_count / (cip_cohort_size - num_unknown)
gen same_continent_peers = same_continent_count - 1 
gen same_continent_peer_share = same_continent_peers / (cip_cohort_size - 1 - num_unknown)
rename same_continent_peer_share per_same_continent_peers
gen same_continent_indicator = 0
replace same_continent_indicator = 1 if same_continent_count > 1






* Lag & Lead gender composition
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

* Lag & Lead international
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


* Cohort stats
egen cohort_tag=tag(cip_inst first_term_PhD)
egen mean_cohort_size=mean(cip_cohort_size) if cohort_tag==1, by(pgrm_cipcode2010_admit inst_code)
bysort cip_inst (cohort_tag): replace mean_cohort_size=mean_cohort_size[_N]
egen min_cohort_size=min(cip_cohort_size), by(pgrm_cipcode2010_admit inst_code)
egen max_cohort_size=max(cip_cohort_size), by(pgrm_cipcode2010_admit inst_code)





* Female deviation
egen mean_per_female=mean(cip_per_female) if cohort_tag==1, by(pgrm_cipcode2010_admit inst_code)
bysort cip_inst (cohort_tag): replace mean_per_female=mean_per_female[_N]
gen demeaned_per_female=cip_per_female-mean_per_female
egen above_avg_female=cut(demeaned_per_female), at(-1, 0 ,1) label

* International deviation
egen mean_per_international=mean(cip_per_international) if cohort_tag==1, by(pgrm_cipcode2010_admit inst_code)
bysort cip_inst (cohort_tag): replace mean_per_international=mean_per_international[_N]
gen demeaned_per_international=cip_per_international-mean_per_international
egen above_avg_international=cut(demeaned_per_international), at(-1, 0 ,1) label




* Lag/Lead deviations
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

*Main sample is 2009-2016 (cohorts for whom Phdin6 is defined)
drop if first_term_PhD>68
drop if first_term_PhD<32 
*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\Data_for_Robustness.dta",replace
********************************************************************************
***************************************************************

*Preferred sample is STEM AND size>9 only
keep if STEM==1
drop if mean_cohort_size<=9

*save
save "\\chrr\vr\profiles\syang\Desktop\clean_mike\Data_Preferred_Sample.dta",replace
********************************************************************************
