clear all
use "C:\Users\abdul\abdullahamir52\raw_data.dta" , clear
qui {
rename v1 age
rename v4 edu
rename v18 qob
rename v27 yob
keep age edu qob yob
drop if yob>50

foreach v of numlist 0/9 {
	gen year_`v' = 0
	replace year_`v' = 1 if inlist(yob,(20+`v'),(30+`v'),(40+`v'))
}

foreach i of numlist 1/4 {
	gen quarter_`i'=0
	replace quarter_`i'=1 if qob==`i'
}

gen group=1
replace group=2 if yob<=49 & yob >=40 

foreach j of numlist 1/4 {
foreach i of numlist 0/9 {
gen yq`i'`j' = 0
replace yq`i'`j' = 1 if (quarter_`j' == 1 & year_`i' == 1)  
}
}

foreach j of varlist yq* {
		sum edu if (group==1 & `j'==1)
		scalar avg1`j' = r(mean)
}	
foreach j of varlist yq* {
		sum edu if (group==2 & `j'==1)
		scalar avg2`j' = r(mean)
		}

gen MA = 0 
foreach i of numlist 0/8 {
		local c=(`i'+1) 
		replace MA = (avg1yq`i'1+avg1yq`i'2+avg1yq`i'4+avg1yq`c'1)/4 if (qob==3 & group == 1)
		replace MA = (avg1yq`i'2+avg1yq`i'3+avg1yq`c'1+avg1yq`c'2)/4 if (qob==4 & group == 1)
		replace MA = (avg1yq`i'3+avg1yq`i'4+avg1yq`c'2+avg1yq`c'3)/4 if (qob==1 & group == 1)
		replace MA = (avg1yq`i'4+avg1yq`c'1+avg1yq`c'3+avg1yq`c'4)/4 if (qob==2 & group == 1)
}
replace MA = (avg1yq91+avg1yq92+avg1yq94+avg2yq01)/4 if (qob==93 & group == 1)
replace MA = (avg1yq92+avg1yq93+avg2yq01+avg2yq02)/4 if (qob==94 & group == 1)

foreach i of numlist 0/8 {
		local c=(`i'+1) 
		replace MA = (avg2yq`i'1+avg2yq`i'2+avg2yq`i'4+avg2yq`c'1)/4 if (qob==3 & group == 2)
		replace MA = (avg2yq`i'2+avg2yq`i'3+avg2yq`c'1+avg2yq`c'2)/4 if (qob==4 & group == 2)
		replace MA = (avg2yq`i'3+avg2yq`i'4+avg2yq`c'2+avg2yq`c'3)/4 if (qob==1 & group == 2)
		replace MA = (avg2yq`i'4+avg2yq`c'1+avg2yq`c'3+avg2yq`c'4)/4 if (qob==2 & group == 2)
}
replace MA = (avg1yq93+avg1yq94+avg2yq02+avg2yq03)/4 if (qob==1 & group == 2)
replace MA = (avg1yq94+avg2yq01+avg2yq03+avg2yq04)/4 if (qob==2 & group == 2)
}

gen dev_edu = edu-MA
sum edu if ( (yob>=30 & qob>=3) & (yob<=39 & qob<=4) )
sum edu if ( (yob>=40 & qob>=1) & (yob<=49 & qob<=2))
reg dev_edu quarter_1-quarter_3  if (group==1 & MA !=0)
reg dev_edu quarter_1-quarter_3  if (group==2 & MA !=0)
