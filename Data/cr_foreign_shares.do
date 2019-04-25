version 14.0
set more off
clear all
set mem 2g
capture log close
log using cr_foreign_shares.log, replace

!gunzip -fc forshr_vars_80_10.dat.gz > tmp.dat

*1980 (5%), 1990 (5%), 2000 (5%), 2010 (ACS) samples
set more off
clear
quietly infix                ///
  int     year      1-4      ///
  byte    datanum   5-6      ///
  double  serial    7-14     ///
  float   hhwt      15-24    ///
  byte    statefip  25-26    ///
  int     metarea   27-29    ///
  int     metaread  30-33    ///
  long    puma      34-38    ///
  int     conspuma  39-41    ///
  byte    gq        42-42    ///
  int     pernum    43-46    ///
  float   perwt     47-56    ///
  byte    sex       57-57    ///
  int     age       58-60    ///
  byte    marst     61-61    ///
  byte    race      62-62    ///
  int     raced     63-65    ///
  byte    hispan    66-66    ///
  int     hispand   67-69    ///
  int     bpl       70-72    ///
  long    bpld      73-77    ///
  byte    citizen   78-78    ///
  byte    school    79-79    ///
  byte    educ      80-81    ///
  int     educd     82-84    ///
  byte    empstat   85-85    ///
  byte    empstatd  86-87    ///
  int     occ1990   88-90    ///
  byte    wkswork1  91-92    ///
  byte    wkswork2  93-93    ///
  byte    uhrswork  94-95    ///
  long    incbus    96-101   ///
  long    incfarm   102-107  ///
  long    incearn   108-114  ///
  byte    pwstate2  115-116  ///
  int     pwcntygp  117-119  ///
  int     pwpuma    120-122  ///
  long    pwpuma00  123-127  ///
  byte    quhrswor  128-128  ///
  byte    qwkswork  129-129  ///
  byte    qincbus   130-130  ///
  byte    qincfarm  131-131  ///
  byte    qincwage  132-132  ///
  using tmp.dat  ///
  if age>=25 & age<=59
*1980-2000 census 5% and 2010 ACS; ages 18+; no other restrictions

!rm -f tmp.dat

replace perwt    = perwt    / 100

gen     ed16plus=0
gen     foreignborn=0
replace ed16plus=1     if educd>=100
replace foreignborn=1  if bpl>56
gen  native=1-foreignborn
drop bpl
gen  bpl=statefip

gen     stemocc=occ1990
recode  stemocc  44/64=1 66/83=1 229=1                  else=0
gen     nonstem=1-stemocc
gen     stemocc2=occ1990
recode  stemocc2 44/64=1 66/83=1 229=1  84/89=1 96=1  113/116=1 127/128=1 else=0
gen     nonstem2=1-stemocc2

bysort bpl year: egen double totwt_yr_2559              =total(perwt)
bysort bpl year: egen double n_ed16plus_all_yr_2559     =total(perwt*ed16plus        )
bysort bpl year: egen double n_ed16plus_for_yr_2559     =total(perwt*ed16plus*foreign)
bysort bpl year: egen double n_16pl_stemo_all_yr_2559   =total(perwt*ed16plus*stemocc         )
bysort bpl year: egen double n_16pl_stem2_all_yr_2559   =total(perwt*ed16plus*stemocc2        )
bysort bpl year: egen double n_16pl_stemo_for_yr_2559   =total(perwt*ed16plus*foreign*stemocc )
bysort bpl year: egen double n_16pl_stem2_for_yr_2559   =total(perwt*ed16plus*foreign*stemocc2)
bysort bpl year: egen double n_16pl_nstem_all_yr_2559   =total(perwt*ed16plus*nonstem         )
bysort bpl year: egen double n_16pl_nstem2_all_yr_2559  =total(perwt*ed16plus*nonstem2        )
bysort bpl year: egen double n_16pl_nstem_for_yr_2559   =total(perwt*ed16plus*foreign*nonstem )
bysort bpl year: egen double n_16pl_nstem2_for_yr_2559  =total(perwt*ed16plus*foreign*nonstem2)
bysort bpl year: egen double pct_ed16plus_all_yr_2559   =total(perwt*ed16plus        /totwt_yr_2559)
bysort bpl year: egen double pct_ed16plus_for_yr_2559   =total(perwt*ed16plus*foreign/totwt_yr_2559)
bysort bpl year: egen double pct_16pl_stemo_all_yr_2559 =total(perwt*ed16plus*stemocc         /totwt_yr_2559)
bysort bpl year: egen double pct_16pl_stem2_all_yr_2559 =total(perwt*ed16plus*stemocc2        /totwt_yr_2559)
bysort bpl year: egen double pct_16pl_stemo_for_yr_2559 =total(perwt*ed16plus*foreign*stemocc /totwt_yr_2559)
bysort bpl year: egen double pct_16pl_stem2_for_yr_2559 =total(perwt*ed16plus*foreign*stemocc2/totwt_yr_2559)
bysort bpl year: egen double pct_16pl_nstem_all_yr_2559 =total(perwt*ed16plus*nonstem         /totwt_yr_2559)
bysort bpl year: egen double pct_16pl_nstem2_all_yr_2559=total(perwt*ed16plus*nonstem2        /totwt_yr_2559)
bysort bpl year: egen double pct_16pl_nstem_for_yr_2559 =total(perwt*ed16plus*foreign*nonstem /totwt_yr_2559)
bysort bpl year: egen double pct_16pl_nstem2_for_yr_2559=total(perwt*ed16plus*foreign*nonstem2/totwt_yr_2559)
* bysort bpl year: egen double totwt_nstem_80_2559       =total(perwt*nonstem)
* bysort bpl year: egen double pct_nstem_foreign_80_2559 =total(perwt*nonstem*foreignborn/totwt_nstem_80_2559)
* bysort bpl year: egen double totwt_nstem2_80_2559      =total(perwt*nonstem2)
* bysort bpl year: egen double pct_nstem2_foreign_80_2559=total(perwt*nonstem2*foreignborn/totwt_nstem2_80_2559)

tab year, sum(n_16pl_stemo_for_yr_2559)
tab year, sum(n_ed16plus_for_yr_2559)

bysort bpl year: egen double natwt_yr_2559             =total(perwt*native)
bysort bpl year: egen double natpct_ed16plus_yr_2559   =total(perwt*ed16plus*native         /natwt_yr_2559)
bysort bpl year: egen double natpct_all_16stemo_yr_2559=total(perwt*ed16plus*native*stemocc /natwt_yr_2559)
gen                   double natpct_16pl_stemo_yr_2559 =natpct_all_16stemo_yr_2559/natpct_ed16plus_yr_2559
bysort bpl year: egen double natpct_all_16nstem_yr_2559=total(perwt*ed16plus*native*nonstem/natwt_yr_2559)
gen                   double natpct_16pl_nstem_yr_2559 =natpct_all_16nstem_yr_2559/natpct_ed16plus_yr_2559
sum natpct*  

egen tag=tag(bpl year)
tab  tag
keep if tag==1
keep bpl year pct_* n_* totwt_yr natpct*

gen forshr_ed16plus_yr_2559       = pct_ed16plus_for_yr_2559   /pct_ed16plus_all_yr_2559
gen forshr_16pl_stemo_yr_2559     = pct_16pl_stemo_for_yr_2559 /pct_16pl_stemo_all_yr_2559
gen forshr_16pl_stem2_yr_2559     = pct_16pl_stem2_for_yr_2559 /pct_16pl_stem2_all_yr_2559
gen forshr_16pl_nstem_yr_2559     = pct_16pl_nstem_for_yr_2559 /pct_16pl_nstem_all_yr_2559
gen forshr_16pl_nstem2_yr_2559    = pct_16pl_nstem2_for_yr_2559/pct_16pl_nstem2_all_yr_2559

keep bpl year forshr* natpct* n_*
sort bpl year
saveold bpl_forshr_vars_yr.dta, v(11) replace






use bpl_forshr_vars_yr.dta, clear
keep if year==1980
rename n_16pl_stemo_for_yr_2559   n_16pl_stemo_for_80_2559
rename n_16pl_stem2_for_yr_2559   n_16pl_stem2_for_80_2559
rename n_16pl_nstem_for_yr_2559   n_16pl_nstem_for_80_2559
rename n_16pl_nstem2_for_yr_2559  n_16pl_nstem2_for_80_2559
rename n_ed16plus_for_yr_2559     n_ed16plus_for_80_2559
rename forshr_16pl_stemo_yr_2559  forshr_16pl_stemo_80_2559
rename forshr_16pl_stem2_yr_2559  forshr_16pl_stem2_80_2559
rename forshr_16pl_nstem_yr_2559  forshr_16pl_nstem_80_2559
rename forshr_16pl_nstem2_yr_2559 forshr_16pl_nstem2_80_2559
rename forshr_ed16plus_yr_2559    forshr_ed16plus_80_2559

qui sum forshr_16pl_stemo_80_2559
qui gen z_forshr_16pl_stemo_80_2559 = forshr_16pl_stemo_80_2559/`r(sd)'
qui gen z2forshr_16pl_stemo_80_2559 = forshr_16pl_stemo_80_2559/`=2*`r(sd)''
qui sum forshr_16pl_stem2_80_2559
qui gen z_forshr_16pl_stem2_80_2559 = forshr_16pl_stem2_80_2559/`r(sd)'
qui gen z2forshr_16pl_stem2_80_2559 = forshr_16pl_stem2_80_2559/`=2*`r(sd)''
qui sum forshr_16pl_nstem_80_2559
qui gen z_forshr_16pl_nstem_80_2559 = forshr_16pl_nstem_80_2559/`r(sd)'
qui gen z2forshr_16pl_nstem_80_2559 = forshr_16pl_nstem_80_2559/`=2*`r(sd)''
qui sum forshr_16pl_nstem2_80_2559
qui gen z_forshr_16pl_nstem2_80_2559 = forshr_16pl_nstem2_80_2559/`r(sd)'
qui gen z2forshr_16pl_nstem2_80_2559 = forshr_16pl_nstem2_80_2559/`=2*`r(sd)''
qui sum forshr_ed16plus_80_2559
qui gen z_forshr_ed16plus_80_2559 = forshr_ed16plus_80_2559/`r(sd)'
qui gen z2forshr_ed16plus_80_2559 = forshr_ed16plus_80_2559/`=2*`r(sd)''

drop year
sort bpl
saveold bpl_forshr_vars_80.dta, v(11) replace

use bpl_forshr_vars_yr.dta, clear
keep if year==1990
rename n_16pl_stemo_for_yr_2559   n_16pl_stemo_for_90_2559
rename n_16pl_stem2_for_yr_2559   n_16pl_stem2_for_90_2559
rename n_16pl_nstem_for_yr_2559   n_16pl_nstem_for_90_2559
rename n_16pl_nstem2_for_yr_2559  n_16pl_nstem2_for_90_2559
rename n_ed16plus_for_yr_2559     n_ed16plus_for_90_2559
rename forshr_16pl_stemo_yr_2559  forshr_16pl_stemo_90_2559
rename forshr_16pl_stem2_yr_2559  forshr_16pl_stem2_90_2559
rename forshr_16pl_nstem_yr_2559  forshr_16pl_nstem_90_2559
rename forshr_16pl_nstem2_yr_2559 forshr_16pl_nstem2_90_2559
rename forshr_ed16plus_yr_2559    forshr_ed16plus_90_2559
rename natpct_ed16plus_yr_2559    natpct_ed16plus_90_2559
rename natpct_all_16stemo_yr_2559 natpct_all_16stemo_90_2559
rename natpct_16pl_stemo_yr_2559  natpct_16pl_stemo_90_2559
rename natpct_all_16nstem_yr_2559 natpct_all_16nstem_90_2559
rename natpct_16pl_nstem_yr_2559  natpct_16pl_nstem_90_2559
drop year
sort bpl
saveold bpl_forshr_vars_90.dta, v(11) replace

use bpl_forshr_vars_yr.dta, clear
keep if year==2000
rename n_16pl_stemo_for_yr_2559   n_16pl_stemo_for_00_2559
rename n_16pl_stem2_for_yr_2559   n_16pl_stem2_for_00_2559
rename n_16pl_nstem_for_yr_2559   n_16pl_nstem_for_00_2559
rename n_16pl_nstem2_for_yr_2559  n_16pl_nstem2_for_00_2559
rename n_ed16plus_for_yr_2559     n_ed16plus_for_00_2559
rename forshr_16pl_stemo_yr_2559  forshr_16pl_stemo_00_2559
rename forshr_16pl_stem2_yr_2559  forshr_16pl_stem2_00_2559
rename forshr_16pl_nstem_yr_2559  forshr_16pl_nstem_00_2559
rename forshr_16pl_nstem2_yr_2559 forshr_16pl_nstem2_00_2559
rename forshr_ed16plus_yr_2559    forshr_ed16plus_00_2559
drop year
sort bpl
saveold bpl_forshr_vars_00.dta, v(11) replace



use             bpl_forshr_vars_80.dta, clear
sort  bpl
merge bpl using bpl_forshr_vars_90.dta
tab  _merge
drop _merge
sort  bpl
merge bpl using bpl_forshr_vars_00.dta
tab  _merge
drop _merge
gen forshr_16pl_stemo_00_90_2559 = forshr_16pl_stemo_00_2559 - forshr_16pl_stemo_90_2559
gen forshr_16pl_nstem_00_90_2559 = forshr_16pl_nstem_00_2559 - forshr_16pl_nstem_90_2559


reg  forshr_16pl_stemo_00_2559   forshr_16pl_stemo_90_2559, robust
*forshr_16pl_stemo_00_2559 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
*forshr_16pl_stemo_90_2559 |   1.381127   .0637117    21.68   0.000     1.253094    1.509161
corr forshr_16pl_stemo_00_2559   forshr_16pl_stemo_90_2559
*0.9350

twoway (scatter forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559) (lfit forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559) 
reg forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559, robust
*forshr_16pl_stemo_00_90~9 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
*forshr_16pl_stemo_80_2559 |   .4670311   .0879695     5.31   0.000     .2902497    .6438125
*R2=0.3379

keep bpl forshr_16pl_stemo_00_2559 forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559 forshr_16pl_nstem_80_2559 forshr_ed16plus_80_2559 n_16pl_stemo_for_80_2559 n_16pl_stem2_for_80_2559 n_16pl_nstem_for_80_2559 n_16pl_nstem2_for_80_2559 n_ed16plus_for_80_2559
saveold bpl_forshr_figure1.dta, v(11) replace



twoway (scatter forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559) (lfit forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559) if  bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29
reg forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559 if  bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29, robust
*forshr_16pl_stemo_00~2559 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
*forshr_16pl_stemo_80_2559 |   .5238719   .0801163     6.54   0.000     .3625095    .6852343
*R2=0.4075

twoway (scatter forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559) (lfit forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559) 
reg forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559, robust
*forshr_16pl_stemo_00_90~9 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
*forshr_16pl_stemo_80_2559 |   .4670311   .0879695     5.31   0.000     .2902497    .6438125
*R2=0.3379

log close
