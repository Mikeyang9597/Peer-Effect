use `allyrs', clear
keep if STEM==1
twoway lfit cip_per_international first_term_PhD , by(pgrm_ciptitle, col(4)) xtitle("First PhD Term") ytitle("% International Peers") xlabel(0(.1)1) ylabel(, angle(horizontal)) scheme(s2mono)
