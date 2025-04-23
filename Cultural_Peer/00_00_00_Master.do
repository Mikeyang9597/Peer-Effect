********************************************************************************
*00_00_00_Master.do
********************************************************************************

* Setting directory
global mydir "\\chrr\vr\profiles\syang\Desktop"
global 	codedir 	"\\chrr\vr\profiles\syang\Desktop\do"
cd "$mydir"
clear
set more off

********************************************************************************

do "$codedir/00_01_01_term_index.do"

do "$codedir/00_00_01_clean_VB.do"
do "$codedir/00_00_02_clean_demo_VB.do"
do "$codedir/00_00_03_clean_degree_VB.do"
do "$codedir/00_00_04_clean_program.do"
do "$codedir/01_00_01_merge_demo.do"
do "$codedir/01_00_02_collapse.do"
do "$codedir/01_00_03_merege_degree.do"
do "$codedir/02_00_01_gen_vars_VB.do"


do "$codedir/00_00_01_clean_mike.do"
do "$codedir/00_00_02_clean_demo.do"
do "$codedir/00_00_03_clean_degree.do"
do "$codedir/00_00_04_clean_program.do"
do "$codedir/01_00_01_merge_demo.do"
do "$codedir/01_00_02_collapse.do"
do "$codedir/01_00_03_merege_degree.do"
do "$codedir/02_00_01_gen_vars.do"


