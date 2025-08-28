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

*Does % cohort international affect first year grades?
*Column 1
areg firstQgpa  c.cip_per_int_peers##i.international $controls i.first_term_PhD, cluster(cip_inst) absorb(cip_inst)
lincom  _b[cip_per_int_peers]+ _b[1.international#c.cip_per_int_peers]
*Column 2
areg firstYrgpa  c.cip_per_int_peers##i.international $controls i.first_term_PhD, cluster(cip_inst) absorb(cip_inst)
lincom  _b[cip_per_int_peers]+ _b[1.international#c.cip_per_int_peers]
*Column 3
areg firstYrgpa   c.cip_per_int_peers##i.international firstQgpa $controls i.first_term_PhD, cluster(cip_inst) absorb(cip_inst)
lincom  _b[cip_per_int_peers]+ _b[1.international#c.cip_per_int_peers]

