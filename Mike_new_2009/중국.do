


gen is_chinese = (cood == "China")

bysort inst_code pgrm_cipcode2010(is_chinese): gen has_chinese = sum(is_chinese)

bysort inst_code pgrm_cipcode2010: gen chinese_in_group = has_chinese[_N]

keep if chinese_in_group > 0
