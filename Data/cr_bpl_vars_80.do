version 14.0
set more off
clear all
set mem 2g
capture log close
log using cr_bpl_vars_80.log, replace

!gunzip -fc bpl_vars_80.dat.gz > tmp.dat

*1980
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
int     cntygp98  34-36    ///
int     conspuma  37-39    ///
byte    gq        40-40    ///
int     pernum    41-44    ///
float   perwt     45-54    ///
byte    sex       55-55    ///
int     age       56-58    ///
byte    marst     59-59    ///
byte    race      60-60    ///
int     raced     61-63    ///
byte    hispan    64-64    ///
int     hispand   65-67    ///
int     bpl       68-70    ///
long    bpld      71-75    ///
byte    citizen   76-76    ///
byte    school    77-77    ///
byte    educ      78-79    ///
int     educd     80-82    ///
byte    empstat   83-83    ///
byte    empstatd  84-85    ///
int     occ1990   86-88    ///
byte    wkswork1  89-90    ///
byte    wkswork2  91-91    ///
byte    uhrswork  92-93    ///
long    incwage   94-99    ///
long    incbus    100-105  ///
long    incfarm   106-111  ///
byte    pwstate2  112-113  ///
int     pwcntygp  114-116  ///
byte    quhrswor  117-117  ///
byte    qwkswork  118-118  ///
byte    qincbus   119-119  ///
byte    qincfarm  120-120  ///
byte    qincwage  121-121  ///
using tmp.dat  ///
if age>=25 & age<=59 & year==1980

!rm -f tmp.dat

replace perwt    = perwt    / 100

gen     ed16plus=0
gen     foreignborn=0
gen     asianborn=0
gen     latinborn=0
gen     africborn=0
gen     canukborn=0
gen     canadborn=0
gen     uk___born=0
gen     roe__born=0
gen     chinaborn=0
gen     indiaborn=0
gen     cjk__born=0
replace ed16plus=1 if educd>=100
replace foreignborn=1  if bpl>56
replace asianborn=1    if bpl>=500 & bpl<=599
replace latinborn=1    if bpl>=200 & bpl<=399
replace africborn=1    if bpl==600
replace canadborn=1    if bpl==150 
replace uk___born=1    if bpl>=410 & bpl<=414
replace canukborn=1    if bpl==150 | (bpl>=410 & bpl<=414)
replace roe__born=1    if bpl>=400 & (bpl<=405 | bpl>=419) & bpl<=499
replace chinaborn=1    if bpl==500
replace indiaborn=1    if bpl==521
replace cjk__born=1    if bpl>=500 & bpl<=502
gen     roa__born=asianborn - indiaborn - cjk__born
gen     oas__born=asianborn - indiaborn - chinaborn

sum *born

drop bpl
gen  bpl=statefip
*variables are defined to merge with ACS data via bpl
gen  native=1-foreignborn
sum

gen     stemocc=occ1990
recode  stemocc  44/64=1 66/83=1 229=1                  else=0
gen     stemocc2=occ1990
recode  stemocc2 44/64=1 66/83=1 229=1  84/89=1 96=1  113/116=1 127/128=1 else=0

sum year stem* [aweight=perwt]
sum year stem* [aweight=perwt] if educd>=101
bysort bpl: egen double totwt_80_2559           =total(perwt)
bysort bpl: egen double pct_ed16plus_80_2559    =total(perwt*ed16plus        /totwt_80_2559)
bysort bpl: egen double pct_foreign_80_2559     =total(perwt*foreignborn     /totwt_80_2559)
bysort bpl: egen double pct_ed16plus_for_80_2559=total(perwt*ed16plus*foreign/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_asi_80_2559=total(perwt*ed16plus*asianborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_chi_80_2559=total(perwt*ed16plus*chinaborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_ind_80_2559=total(perwt*ed16plus*indiaborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_lat_80_2559=total(perwt*ed16plus*latinborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_afr_80_2559=total(perwt*ed16plus*africborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_cjk_80_2559=total(perwt*ed16plus*cjk__born/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_roa_80_2559=total(perwt*ed16plus*roa__born/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_oas_80_2559=total(perwt*ed16plus*oas__born/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_cuk_80_2559=total(perwt*ed16plus*canukborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_roe_80_2559=total(perwt*ed16plus*roe__born/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_can_80_2559=total(perwt*ed16plus*canadborn/totwt_80_2559)
bysort bpl: egen double pct_ed16plus_uks_80_2559=total(perwt*ed16plus*uk___born/totwt_80_2559)

bysort bpl: egen double pct_16pl_stemo_all_80_2559=total(perwt*ed16plus*stemocc         /totwt_80_2559)
bysort bpl: egen double pct_16pl_stem2_all_80_2559=total(perwt*ed16plus*stemocc2        /totwt_80_2559)
bysort bpl: egen double pct_16pl_stemo_for_80_2559=total(perwt*ed16plus*stemocc *foreign/totwt_80_2559)
bysort bpl: egen double pct_16pl_stem2_for_80_2559=total(perwt*ed16plus*stemocc2*foreign/totwt_80_2559)

bysort bpl: egen double pct_16pl_nstemo_all_80_2559=total(perwt*ed16plus*(1-stemocc )        /totwt_80_2559)
bysort bpl: egen double pct_16pl_nstem2_all_80_2559=total(perwt*ed16plus*(1-stemocc2)        /totwt_80_2559)
bysort bpl: egen double pct_16pl_nstemo_for_80_2559=total(perwt*ed16plus*(1-stemocc )*foreign/totwt_80_2559)
bysort bpl: egen double pct_16pl_nstem2_for_80_2559=total(perwt*ed16plus*(1-stemocc2)*foreign/totwt_80_2559)

bysort bpl: egen double natwt_80_2559             =total(perwt*native)
bysort bpl: egen double natpct_ed16plus_80_2559   =total(perwt*ed16plus*native            /natwt_80_2559)
bysort bpl: egen double natpct_all_16stemo_80_2559=total(perwt*ed16plus*native*stemocc    /natwt_80_2559)
bysort bpl: egen double natpct_all_16nstem_80_2559=total(perwt*ed16plus*native*(1-stemocc)/natwt_80_2559)
gen              double natpct_16pl_stemo_80_2559 =natpct_all_16stemo_80_2559/natpct_ed16plus_80_2559
gen              double natpct_16pl_nstem_80_2559 =natpct_all_16nstem_80_2559/natpct_ed16plus_80_2559
sum natpct*

egen tag=tag(bpl)
tab  tag
keep if tag==1
keep bpl pct_* totwt_80 nat*

gen afrshr_ed16plus_80_2559 = pct_ed16plus_afr_80_2559/pct_ed16plus_80_2559
gen asishr_ed16plus_80_2559 = pct_ed16plus_asi_80_2559/pct_ed16plus_80_2559
gen canshr_ed16plus_80_2559 = pct_ed16plus_can_80_2559/pct_ed16plus_80_2559
gen chishr_ed16plus_80_2559 = pct_ed16plus_chi_80_2559/pct_ed16plus_80_2559
gen cjkshr_ed16plus_80_2559 = pct_ed16plus_cjk_80_2559/pct_ed16plus_80_2559
gen cukshr_ed16plus_80_2559 = pct_ed16plus_cuk_80_2559/pct_ed16plus_80_2559
gen forshr_ed16plus_80_2559 = pct_ed16plus_for_80_2559/pct_ed16plus_80_2559
gen indshr_ed16plus_80_2559 = pct_ed16plus_ind_80_2559/pct_ed16plus_80_2559
gen latshr_ed16plus_80_2559 = pct_ed16plus_lat_80_2559/pct_ed16plus_80_2559
gen oasshr_ed16plus_80_2559 = pct_ed16plus_oas_80_2559/pct_ed16plus_80_2559
gen roashr_ed16plus_80_2559 = pct_ed16plus_roa_80_2559/pct_ed16plus_80_2559
gen roeshr_ed16plus_80_2559 = pct_ed16plus_roe_80_2559/pct_ed16plus_80_2559
gen uksshr_ed16plus_80_2559 = pct_ed16plus_uks_80_2559/pct_ed16plus_80_2559

gen forshr_16pl_stemo_80_2559 = pct_16pl_stemo_for_80_2559/pct_16pl_stemo_all_80_2559
gen forshr_16pl_stem2_80_2559 = pct_16pl_stem2_for_80_2559/pct_16pl_stem2_all_80_2559

gen forshr_ed_16pl_stemo_80_2559 = pct_16pl_stemo_for_80_2559/pct_ed16plus_80_2559
gen forshr_ed_16pl_stem2_80_2559 = pct_16pl_stem2_for_80_2559/pct_ed16plus_80_2559

gen forshr_all_16pl_stemo_80_2559 = pct_16pl_stemo_for_80_2559
gen forshr_all_16pl_stem2_80_2559 = pct_16pl_stem2_for_80_2559

gen forshr_16pl_nstemo_80_2559 = pct_16pl_nstemo_for_80_2559/pct_16pl_nstemo_all_80_2559
gen forshr_16pl_nstem2_80_2559 = pct_16pl_nstem2_for_80_2559/pct_16pl_nstem2_all_80_2559

gen forshr_ed_16pl_nstemo_80_2559 = pct_16pl_nstemo_for_80_2559/pct_ed16plus_80_2559
gen forshr_ed_16pl_nstem2_80_2559 = pct_16pl_nstem2_for_80_2559/pct_ed16plus_80_2559

gen forshr_all_16pl_nstemo_80_2559 = pct_16pl_nstemo_for_80_2559
gen forshr_all_16pl_nstem2_80_2559 = pct_16pl_nstem2_for_80_2559

foreach frag in afrshr asishr canshr chishr cjkshr cukshr forshr indshr latshr oasshr roashr roeshr uksshr {
	qui sum `frag'_ed16plus_80_2559
	qui gen z_`frag'_ed16plus_80_2559 = `frag'_ed16plus_80_2559/`r(sd)'
	qui gen z2`frag'_ed16plus_80_2559 = `frag'_ed16plus_80_2559/`=2*`r(sd)''
}

qui sum forshr_16pl_stemo_80_2559
qui gen z_forshr_16pl_stemo_80_2559 = forshr_16pl_stemo_80_2559/`r(sd)'
qui gen z2forshr_16pl_stemo_80_2559 = forshr_16pl_stemo_80_2559/`=2*`r(sd)''
qui sum forshr_16pl_stem2_80_2559
qui gen z_forshr_16pl_stem2_80_2559 = forshr_16pl_stem2_80_2559/`r(sd)'
qui gen z2forshr_16pl_stem2_80_2559 = forshr_16pl_stem2_80_2559/`=2*`r(sd)''

qui sum forshr_ed_16pl_stemo_80_2559
qui gen z_forshr_ed_16pl_stemo_80_2559 = forshr_ed_16pl_stemo_80_2559/`r(sd)'
qui gen z2forshr_ed_16pl_stemo_80_2559 = forshr_ed_16pl_stemo_80_2559/`=2*`r(sd)''
qui sum forshr_ed_16pl_stem2_80_2559
qui gen z_forshr_ed_16pl_stem2_80_2559 = forshr_ed_16pl_stem2_80_2559/`r(sd)'
qui gen z2forshr_ed_16pl_stem2_80_2559 = forshr_ed_16pl_stem2_80_2559/`=2*`r(sd)''

qui sum forshr_all_16pl_stemo_80_2559
qui gen z_forshr_all_16pl_stemo_80_2559 = forshr_all_16pl_stemo_80_2559/`r(sd)'
qui gen z2forshr_all_16pl_stemo_80_2559 = forshr_all_16pl_stemo_80_2559/`=2*`r(sd)''
qui sum forshr_all_16pl_stem2_80_2559
qui gen z_forshr_all_16pl_stem2_80_2559 = forshr_all_16pl_stem2_80_2559/`r(sd)'
qui gen z2forshr_all_16pl_stem2_80_2559 = forshr_all_16pl_stem2_80_2559/`=2*`r(sd)''

qui sum forshr_16pl_nstemo_80_2559
qui gen z_forshr_16pl_nstemo_80_2559 = forshr_16pl_nstemo_80_2559/`r(sd)'
qui gen z2forshr_16pl_nstemo_80_2559 = forshr_16pl_nstemo_80_2559/`=2*`r(sd)''
qui sum forshr_16pl_nstem2_80_2559
qui gen z_forshr_16pl_nstem2_80_2559 = forshr_16pl_nstem2_80_2559/`r(sd)'
qui gen z2forshr_16pl_nstem2_80_2559 = forshr_16pl_nstem2_80_2559/`=2*`r(sd)''

qui sum forshr_ed_16pl_nstemo_80_2559
qui gen z_forshr_ed_16pl_nstemo_80_2559 = forshr_ed_16pl_nstemo_80_2559/`r(sd)'
qui gen z2forshr_ed_16pl_nstemo_80_2559 = forshr_ed_16pl_nstemo_80_2559/`=2*`r(sd)''
qui sum forshr_ed_16pl_nstem2_80_2559
qui gen z_forshr_ed_16pl_nstem2_80_2559 = forshr_ed_16pl_nstem2_80_2559/`r(sd)'
qui gen z2forshr_ed_16pl_nstem2_80_2559 = forshr_ed_16pl_nstem2_80_2559/`=2*`r(sd)''

qui sum forshr_all_16pl_nstemo_80_2559
qui gen z_forshr_all_16pl_nstemo_80_2559 = forshr_all_16pl_nstemo_80_2559/`r(sd)'
qui gen z2forshr_all_16pl_nstemo_80_2559 = forshr_all_16pl_nstemo_80_2559/`=2*`r(sd)''
qui sum forshr_all_16pl_nstem2_80_2559
qui gen z_forshr_all_16pl_nstem2_80_2559 = forshr_all_16pl_nstem2_80_2559/`r(sd)'
qui gen z2forshr_all_16pl_nstem2_80_2559 = forshr_all_16pl_nstem2_80_2559/`=2*`r(sd)''

sort bpl
saveold bpl_vars_80.dta, replace
sum
corr   forshr_16pl_stem*_80_2559 *shr_ed16plus_80_2559
gsort -forshr_16pl_stemo_80_2559
list bpl forshr*

log close

