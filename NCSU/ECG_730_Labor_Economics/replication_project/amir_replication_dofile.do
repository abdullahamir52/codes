/*
Code by Chowdhury Amir Abdullah
abdullahamir52@gmail.com, cabdull@ncsu.edu
*/

clear all
cls
set more off

cd "C:\Users\abdul\Self-Employment and Migration Evidence from Mexico"

use life174.dta, clear

keep if sex==1 /* keeping men */
drop sex 
drop country 
drop doyr1 dodur1 doplace1 dostate1 doocc1 doyrl dodurl doplacel dostatel dooccl dowagel dobyl dotrips
drop fedtx sstax rsuper rowner 
drop if age<17 | age>65  /* keeping age 17-65 */
drop if usyr1<1965 /* dropping first year of US migration <1965 */ 
drop if usdoc1==9999 /* dropping how many documentation used during first US migration, MMP asks about this */
drop if occup==9999 |  occup==8888  /* dropping N/A occupation */
drop if jobstate==9999 /* dropping N/A jobstate  */
keep if statebrn<33 /* keeping state numbers below 33 */
tempfile temp1
save `temp1', replace

bys commun surveypl surveyyr hhnum: keep if _n==1   /* to keep only one observations for a household */
gen id=_n
sort commun surveypl surveyyr hhnum
tempfile temp2
save `temp2', replace

use `temp1', clear
sort commun surveypl surveyyr hhnum
merge m:1 commun surveypl surveyyr hhnum using `temp2'
drop _merge
sort id year

drop if educ==9999  /* dropping N/A education */
gen ed6=0
replace ed6=1 if educ<=6  /* Schooling < 7   */
gen ed11=0
replace ed11=1 if educ>6 & educ<12   /* 6 < Schooling < 12   */
gen ed12=0
replace ed12=1 if educ==12   /* Schooling = 12   */
gen ed13=0
replace ed13=1 if educ>=13 & educ<30  /* Schooling > 12   */

gen age1=age/10  /* dividing age by 10 */
gen age_sq=age1*age1  /* squaring (age/10) */


gen d65t70=0 
replace d65t70=1 if year<1971  /* migration before 1971 */
gen d71t80=0
replace d71t80=1 if year>1970 & year<1981  /* migration 1971-1980*/
gen d81t90=0
replace d81t90=1 if year>1980 & year<1991  /* migration 1981-1990*/
gen d91t00=0
replace d91t00=1 if year>1990 & year<2001  /* migration 1991-2000*/
gen d01t10=0
replace d01t10=1 if year>2000 & year<2011  /* migration 2001-2010*/
gen d11t19=0
replace d11t19=1 if year>2010  /* migration after 2010*/

gen dbus=0
replace dbus=1 if business!=0

/*  */
sort id year
gen prevloc=jobstate[_n-1] if id==id[_n-1] & year==year[_n-1]+1  /* if current id = previous id and current year = previous year, then replace prevloc with jobstate */
drop if jobstate==8888 | prevloc==. | prevloc==8888 | prevloc==9999 | jobstate==0 | prevloc==0 | jobstate>199 | prevloc>199
gen inusa=jobstate>50 /* are you in the us or not  */
gen usprev=prevloc>50 /* were you in the us previously or not */

gen smig=1 if usdoc1<=15 /* migration with docs */
replace smig=0 if usdoc1==8888 /* migration without docs */
gen slegmig=0 
replace slegmig=1 if (usdoc1!=8 & usdoc1<100) /* legal migration */
gen sillegalmig=0 
replace sillegalmig=1 if usdoc1==8  /* illegal migration */
gen moved=(usprev==0 & inusa==1)
gen migro=moved
replace migro=. if jobstate[_n-1]>50 & moved==0
drop if year<1965
gen legmigrant=0 
replace legmigrant=1 if (migro==1 & usdoc1!=8 & usdoc1<100)   /* legal migration */
gen illegalmigrant=0 
replace illegalmigrant=1 if (migro==1 & usdoc1==8)   /* illegal migration */
gen catmigrant=1 if legmigrant==1    /* legal migrant */
replace catmigrant=2 if illegalmigrant==1  /* illegal migrant */
replace catmigrant=0 if migro==0  /* Non-migrant */

bysort id (year): gen csum = sum(moved)
gen exp=csum
replace exp=0 if (migro==1 & moved==1 & csum==1)
replace exp=1 if csum>1

gen parmig=0
replace parmig=1 if (fausmig==1 | mousmig==1)  /* Parent has migration experience or not */

xtset id year
save dataset.dta, replace

merge m:1 year using us_unemployment.dta
drop _merge
merge m:1 year using mx_gdp_pc.dta
drop _merge
gen log_mx_gdp=log(mx_real_gpdpc)

*amir extensions

gen trump=0
replace trump=1 if year>2015

* variable renamed
label variable ed6 "Schooling 6"
label variable ed11 "Schooling 7-11"
label variable ed12 "Schooling 12"
label variable ed13 "Schooling 13 and up"
label variable age1 "age divided by 10"
label variable age_sq "age1 squared"
label variable d65t70 "year 1965 - 70"
label variable d71t80 "year 1971 - 80"
label variable d81t90 "year 1981 - 90"
label variable d91t00 "year 1991 - 2000"
label variable d01t10 "year 2001 - 2010"
label variable d11t19 "year 2011 - 2019"
label variable dbus "Self-employed"
label variable prevloc "Previous Location"
label variable inusa "In the US or not"
label variable usprev "Previously in the US or not"
label variable smig "migrant"
label variable slegmig "legal migrant"
label variable sillegalmig "illegal migrant"
label variable migro "Migration or not"
label variable catmigrant "migrant variable"
label variable parmig "Parents migrant or not"
label variable trump "Before or after the election of trump"

save dataset.dta, replace



*Table 1 Summary Statistics

clear all
cls
set more off
use dataset.dta, clear

bys id: egen maxschool=max(educ)
bys id: egen maxdbus=max(dbus)
gen ageatmig=age if year==usyr1
bys id: egen maxageatmig=max(ageatmig)
bys id: egen maxparentmig=max(parmig)

mlogit catmigrant i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.exp i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id) nolog
eret li
gen byte sample=e(sample)
keep if sample==1
bys id: keep if _n==1

gen maxed6=0
replace maxed6=1 if maxschool<=6
gen maxed11=0
replace maxed11=1 if maxschool>6 & maxschool<12
gen maxed12=0
replace maxed12=1 if maxschool==12 
gen maxed13=0
replace maxed13=1 if maxschool>=13 & maxschool<8000

sort id 
ta smig
ta slegmig
ta sillegalmig

ta maxdbus if smig==0
ta maxdbus if slegmig==1
ta maxdbus if sillegalmig==1
ta maxdbus 

ta maxed6 if smig==0
ta maxed11 if smig==0
ta maxed12 if smig==0
ta maxed13 if smig==0

ta maxed6 if slegmig==1
ta maxed11 if slegmig==1
ta maxed12 if slegmig==1
ta maxed13 if slegmig==1

ta maxed6 if sillegalmig==1
ta maxed11 if sillegalmig==1
ta maxed12 if sillegalmig==1
ta maxed13 if sillegalmig==1

ta maxed6 
ta maxed11 
ta maxed12 
ta maxed13 

sum maxageatmig if slegmig==1
sum maxageatmig if sillegalmig==1
sum maxageatmig


*Table 2 Self-Employment and Migration Decisions

clear all
cls
set more off
use dataset.dta, clear

probit migro i.dbus [pw=weight], vce(cluster id)
margins, dydx(*) post
est sto probitv1

probit migro i.dbus age1 age_sq [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv2

probit migro i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv3

probit migro i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv4

probit migro i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv5

probit migro i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv6

probit migro i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.exp us_unemp log_mx_gdp i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv7

esttab probitv1 probitv2 probitv3 probitv4 using migprobits_1.tex, se star(* 0.1 ** 0.05 *** 0.01) replace
esttab probitv5 probitv6 probitv7  using migprobits_2.tex, se star(* 0.1 ** 0.05 *** 0.01) replace


probit migro i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.exp us_unemp log_mx_gdp i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id) nolog
margins, dydx(*) post
est sto probitv7

*Table 3 Legal Status, Self-Employment, and Migration

mlogit catmigrant i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.exp us_unemp log_mx_gdp i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id)
margins, dydx(*) predict(outcome(0)) post
est sto Stays

mlogit catmigrant i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.exp us_unemp log_mx_gdp i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id)
margins, dydx(*) predict(outcome(1)) post
est sto Moves_legally

mlogit catmigrant i.dbus age1 age_sq i.ed11 i.ed12 i.ed13 i.married i.parmig i.exp us_unemp log_mx_gdp i.d71t80 i.d81t90 i.d91t00 i.d01t10 i.d11t19 [pw=weight], vce(cluster id)
margins, dydx(*) predict(outcome(2)) post
est sto Moves_illegally

esttab Stays Moves_legally Moves_illegally using mlogits.tex, se star(* 0.1 ** 0.05 *** 0.01) replace 
