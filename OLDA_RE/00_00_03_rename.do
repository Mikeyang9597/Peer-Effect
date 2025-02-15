*00_00_03_rename.do

*replace degree_cert_level_desc="Doctoral degree" if degree_cert_level_code=="09" & yr_num>2010
rename degree_cert_level_code pgrm_level_code
*rename degree_name_code pgrm_degree_code
*rename degree_concentration_desc pgrm_concentrate_desc
*rename degree_cert_level_desc pgrm_level_desc
*drop min_completion_time_yrs min_completion_cr_hours program_rec_status_code active_flag 
