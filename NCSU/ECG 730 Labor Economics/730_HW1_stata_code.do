clear all
cd "C:\Users\abdul\abdullahamir52\NCSU\2nd year\3rd semester\730 Labor\Homework 1 - Gruber Replication"
use "cpsmay74.dta", clear
append using "C:\Users\abdul\abdullahamir52\NCSU\2nd year\3rd semester\730 Labor\Homework 1 - Gruber Replication\cpsmay75.dta"
append using "C:\Users\abdul\abdullahamir52\NCSU\2nd year\3rd semester\730 Labor\Homework 1 - Gruber Replication\cpsmay77.dta"
append using "C:\Users\abdul\abdullahamir52\NCSU\2nd year\3rd semester\730 Labor\Homework 1 - Gruber Replication\cpsmay78.dta"

run var_name_change

keep x9 x67 x68 x70 x200 x188
keep if (x9 == 33 | x9 == 31 | x9 == 32 | x9 == 22 | x9 == 21 | x9 == 12 | x9 == 11 | x9 == 53)
label define state_name 33 "Illinois33" 31 "Ohio31" 32 "Indiana32" 22 "New Jersey22" 21 "New York21" 12 "Connecticut12" 11 "Massachusetts11" 53 "North Carolina53"
label values x9 state_name

rename x9 state
rename x67 age
rename x68 married
rename x70 sex
rename x200 year
rename x188 wage

drop if wage == -99
keep if (age > 19 &  age < 41)
keep if sex==2
drop if (married==4 | married==5)

gen lnwage= ln(wage/100)

gen state_treat = 0
replace state_treat = 1 if (state == 21 | state == 22 | state == 33) 
gen yr_treat = 0
replace yr_treat = 1 if (year == 1977 | year == 1978)


save "gruber_1994.dta", replace

diff lnwage, treated(state_treat) period(yr_treat) 
sum lnwage if (state_treat == 1 & yr_treat == 0)
sum lnwage if (state_treat == 1 & yr_treat == 1)
sum lnwage if (state_treat == 0 & yr_treat == 0)
sum lnwage if (state_treat == 0 & yr_treat == 1)
