clear
input str30 field foreign domestic
"CS"                        64.7 35.3
"Engineering"              58.1 41.9
"Math/Stats"               53.5 46.5
"Agriculture/Natural Sci" 42.6 57.4
"Physical Sci"             40.7 59.3
"Social Sci"               33.8 66.2
"Geo/Atmos/Ocean"          33.6 66.4
"Biological/Biomedical"    25.8 74.2
"Health Sci"               23.3 76.7
"Non-S&E"                  22.8 77.2
"Psychology"               9.7  90.3
end

* geo, health, bio 제외
drop if inlist(field, "Geo/Atmos/Ocean", "Health Sci", "Biological/Biomedical")

* 외국인 비율 높은 순서로 정렬
gsort -foreign

* 수평 누적 막대그래프
graph hbar foreign domestic, over(field, sort(1) descending label(labsize(vsmall))) ///
    stack bar(1, color(navy)) bar(2, color(gs12)) ///
    legend(order(1 "International (Visa)" 2 "Domestic") row(1) region(lcolor(none))) 
    xtitle("Share of Doctoral Degrees (%)", size(medsmall)) ///
    title("Citizenship Composition by Field (2021)", size(medium)) ///
    graphregion(color(white)) ///
    scheme(s1color)
