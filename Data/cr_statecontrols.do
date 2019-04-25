version 14.0
set more off
clear all
capture log close
log using cr_statecontrols.log, replace

!gunzip -fc statecontrols.dat.gz > tmp.dat

* CPS ASEC
set more off
clear
quietly infix                ///
  int     year        1-4      ///
  long    serial      5-9      ///
  float   hwtsupp     10-19    ///
  byte    statefip    20-21    ///
  byte    asecflag    22-22    ///
  double  hhincome    23-30    ///
  byte    month       31-32    ///
  byte    pernum      33-34    ///
  float   wtsupp      35-44    ///
  float   earnwt      45-54    ///
  byte    age         55-56    ///
  byte    sex         57-57    ///
  int     race        58-60    ///
  int     hispan      61-63    ///
  int     educ        64-66    ///
  int     higrade     67-69    ///
  byte    educ99      70-71    ///
  byte    empstat     72-73    ///
  int     occ1990     74-76    ///
  byte    wkswork1    77-78    ///
  int     uhrswork1   79-81    ///
  double  ftotval     82-91    ///
  long    incwage     92-98    ///
  byte    migsta1     99-100   ///
  byte    migsta5     101-102  ///
  byte    migrate1    103-103  ///
  byte    migrate5    104-105  ///
  byte    qhigrade    106-106  ///
  byte    quhrswork1  107-108  ///
  byte    qwkswork    109-109  ///
  byte    qincwage    110-110  ///
 using tmp.dat  
*This was extracted from IPUMS-CPS and includes the March CPS for years 1978-2011, but only a subset of these years (1986-1994 for the main specification) are used in our analysis.
*The initial extract includes the full sample.

!rm -f tmp.dat

replace hwtsupp  = hwtsupp  / 10000
replace wtsupp   = wtsupp   / 100
replace earnwt   = earnwt   / 10000
rename  wtsupp perwt

drop if perwt==0
egen tag=tag(year serial)
tab  tag
bysort state year: egen medhhincome_ipums_styr_wk=median(hhincome) if tag==1
bysort state year: egen medhhincome_ipums_styr=max(medhhincome_ipums_styr_wk) 
drop tag *_wk
sum medhhincome

drop if age<25 | age>54
drop if wkswork1<35
drop if uhrswork1<35
drop if incwage==0
sum q*
drop if qhigrade==4 | quhrswork1==1 | qwkswork==1 | qincwage~=0
tab higrade
keep if educ99==10 | educ99==14 | higrade==150 | higrade==190

gen ed12=0
gen ed16=0
replace ed12=1 if educ99==10 | higrade==150
replace ed16=1 if educ99==14 | higrade==190

gen  wage = incwage/(wkswork1*uhrswork1)
gen lwage =ln(wage)

gen female=sex-1

replace race=888 if hispan>0
recode  race 100=1 200=2 888=3 650/652=4 else=5

tab statefip, gen(stated)
tab age     , gen(aged)
tab race    , gen(raced)
drop stated1 aged1 raced1

reg lwage aged* raced* female  [pweight=perwt] 
predict res, residuals

bysort statefip year: egen totwted12=total(perwt*ed12)
bysort statefip year: egen totwted16=total(perwt*ed16)

bysort statefip year: egen meanlwage_ed12=total(perwt*ed12*res/totwted12)
bysort statefip year: egen meanlwage_ed16=total(perwt*ed16*res/totwted16)

gen lreturn_to_ba_styr = meanlwage_ed16 - meanlwage_ed12
sum lreturn

egen tag=tag(year statefip)
tab  tag
keep if tag==1

keep statefip year lreturn_to_ba_styr medhhincome_ipums_styr
sum
*note that some "returns" are less than one
sort statefip year
save                      cpsvars_styr.dta, replace





use                       age18pop_styr.dta, clear
rename bpl statefip
rename yearage18 year
sort  statefip year
merge 1:1 statefip year using unemprate_styr
drop _merge
sort  statefip year
merge 1:1 statefip year using cpsvars_styr.dta
drop _merge
sort  statefip year
sum
gen lnpop18=ln(popage18)
gen lnmedhhinc18=ln(medhhincome_ipums_styr)
rename year yearage18
rename statefip bpl
drop statename
sort yearage18 bpl
clonevar yearage17 = yearage18
clonevar yearage19 = yearage18
clonevar yearage20 = yearage18
saveold                 statecontrols.dta, replace

log close
