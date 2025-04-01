clear
input str20 country se nonse
"China"         54645 4785
"India"         22617 1352
"South Korea"    9822 3641
"Iran"           6696  443
"Taiwan"         5389  999
"Turkey"         3947  887
"Canada"         3304 1441
"Saudi Arabia"   2267  776
"Bangladesh"     2211  134
"Mexico"         1831  354
end

* S&E 분야 박사 수 기준으로 내림차순 정렬
gsort -se

* 수평 누적 막대그래프 그리기
graph hbar (sum) se nonse, ///
    over(country, sort(1) descending label(labsize(vsmall))) ///
    stack ///
    bar(1, color(navy)) ///
    bar(2, color(gs12)) ///
    legend(order(1 "S&E Fields" 2 "Non-S&E Fields") row(1) region(lcolor(none))) ///
    graphregion(color(white)) ///
    scheme(s1color)
