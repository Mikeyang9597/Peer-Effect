*CIP code
import excel "$mydir\raw\discipline_subject_CIP_Nov2011",clear firstrow case(lower)
rename subjectcode pgrm_subj_code
rename subjecttitle subjecttitle2010
rename subjectfield subjectfield2010

save "\\chrr\vr\profiles\syang\Desktop\clean_mike\CIPmaster.dta",replace
