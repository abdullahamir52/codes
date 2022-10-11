clear all
use "C:\Users\abdul\abdullahamir52\raw_data.dta" , clear
qui{
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

foreach j of numlist 1/4 {
foreach i of numlist 0/9 {
gen yq`i'`j' = 0
replace yq`i'`j' = 1 if (quarter_`j' == 1 & year_`i' == 1)  
}
}

gen yrqtr=0
foreach j of numlist 1/4 {
foreach i of numlist 30/49 {
replace yrqtr=10*(`i')+(`j') if (yob==`i' & qob ==`j')
}
}

gen group=1
replace group=2 if yob<=49 & yob >=40 

foreach j of varlist yq* {
		sum edu if (group==1 & `j'==1)
		scalar avg1`j' = r(mean)
}	
foreach j of varlist yq* {
		sum edu if (group==2 & `j'==1)
		scalar avg2`j' = r(mean)
		}

local a = 1
local b = 2
local c = 3
local f = 4 
gen MA = 0 
foreach i of numlist 0/8 {
		local k=(`i'+1) 
		replace MA = (avg1yq`i'`a'+avg1yq`i'`b'+avg1yq`i'`f'+avg1yq`k'`a')/4 if (mod(yrqtr,100)==`c' & group == 1)
		replace MA = (avg1yq`i'`b'+avg1yq`i'`c'+avg1yq`k'`a'+avg1yq`k'`b')/4 if (mod(yrqtr,100)==`f' & group == 1)
		replace MA = (avg1yq`i'`c'+avg1yq`i'`f'+avg1yq`k'`b'+avg1yq`k'`c')/4 if (mod(yrqtr,100)==`a' & group == 1)
		replace MA = (avg1yq`i'`f'+avg1yq`k'`a'+avg1yq`k'`c'+avg1yq`k'`f')/4 if (mod(yrqtr,100)==`b' & group == 1)
}
replace MA = (avg1yq91+avg1yq92+avg1yq94+avg2yq01)/4 if (mod(yrqtr,100)==93 & group == 1)
replace MA = (avg1yq92+avg1yq93+avg2yq01+avg2yq02)/4 if (mod(yrqtr,100)==94 & group == 1)

foreach i of numlist 0/8 {
		local k=(`i'+1) 
		replace MA = (avg2yq`i'`a'+avg2yq`i'`b'+avg2yq`i'`f'+avg2yq`k'`a')/4 if (mod(yrqtr,100)==`c' & group == 2)
		replace MA = (avg2yq`i'`b'+avg2yq`i'`c'+avg2yq`k'`a'+avg2yq`k'`b')/4 if (mod(yrqtr,100)==`f' & group == 2)
		replace MA = (avg2yq`i'`c'+avg2yq`i'`f'+avg2yq`k'`b'+avg2yq`k'`c')/4 if (mod(yrqtr,100)==`a' & group == 2)
		replace MA = (avg2yq`i'`f'+avg2yq`k'`a'+avg2yq`k'`c'+avg2yq`k'`f')/4 if (mod(yrqtr,100)==`b' & group == 2)
}
replace MA = (avg1yq93+avg1yq94+avg2yq02+avg2yq03)/4 if (mod(yrqtr,100)==1 & group == 2)
replace MA = (avg1yq94+avg2yq01+avg2yq03+avg2yq04)/4 if (mod(yrqtr,100)==2 & group == 2)

}
gen dev_edu = edu-MA
sum edu if (yrqtr>=303 & yrqtr<=394)
sum edu if (yrqtr>=401 & yrqtr<=492)

reg dev_edu quarter_1-quarter_3  if (group==1 & MA !=0)
reg dev_edu quarter_1-quarter_3  if (group==2 & MA !=0)
