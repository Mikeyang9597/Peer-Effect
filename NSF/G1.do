clear
input year total visa_total
2001 40744 9812
2002 40031 9747
2003 40762 10597
2004 42122 11628
2005 43385 12832
2006 45620 14200
2007 48132 15123
2008 48776 15261
2009 49552 14736
2010 48028 13636
2011 48909 14235
2012 50943 14784
2013 52703 15674
2014 53986 15839
2015 54886 16129
2016 54809 16477
2017 54552 16288
2018 55080 17582
2019 55609 18324
2020 55224 18476
2021 52250 17638
end

* 도매스틱 계산 및 천 단위 변환
gen domestic = total - visa_total
gen visa_k = visa_total / 1000
gen domestic_k = domestic / 1000

* 누적 막대그래프
graph bar visa_k domestic_k, over(year, label(angle(45) labsize(small))) ///
    stack bar(1, color(navy)) bar(2, color(gs12)) ///
    legend(order(1 "International (Visa)" 2 "Domestic") row(1) region(lcolor(none))) ///
    ytitle("Doctoral Degrees (Thousands)", size(medsmall)) ///
    graphregion(color(white)) ///
    scheme(s1color)
