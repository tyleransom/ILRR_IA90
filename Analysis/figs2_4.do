clear all
version 14.0
set matsize 11000
set maxvar  32767
set more off
capture log close
log using figs2_4.log, replace

global data_path "../Data/"
global graph_path "../Figures/"

!gunzip -fc ${data_path}acs_09_16.dat.gz > ${data_path}tmp.dat

quietly infix                  ///
  int     year        1-4      ///
  byte    datanum     5-6      ///
  double  serial      7-14     ///
  float   hhwt        15-24    ///
  byte    statefip    25-26    ///
  byte    gq          27-27    ///
  byte    ownershp    28-28    ///
  byte    ownershpd   29-30    ///
  int     pernum      31-34    ///
  float   perwt       35-44    ///
  byte    nchild      45-45    ///
  byte    nchlt5      46-46    ///
  byte    yngch       47-48    ///
  byte    sex         49-49    ///
  int     age         50-52    ///
  byte    marst       53-53    ///
  byte    race        54-54    ///
  int     raced       55-57    ///
  byte    hispan      58-58    ///
  int     hispand     59-61    ///
  int     bpl         62-64    ///
  long    bpld        65-69    ///
  byte    citizen     70-70    ///
  int     yrnatur     71-74    ///
  byte    yrsusa1     75-76    ///
  byte    language    77-78    ///
  int     languaged   79-82    ///
  byte    speakeng    83-83    ///
  byte    school      84-84    ///
  byte    educ        85-86    ///
  int     educd       87-89    ///
  byte    degfield    90-91    ///
  int     degfieldd   92-95    ///
  byte    degfield2   96-97    ///
  int     degfield2d  98-101   ///
  byte    empstat     102-102  ///
  byte    empstatd    103-104  ///
  int     occ1990     105-107  ///
  int     ind1990     108-110  ///
  byte    classwkr    111-111  ///
  byte    classwkrd   112-113  ///
  byte    wkswork2    114-114  ///
  byte    uhrswork    115-116  ///
  byte    workedyr    117-117  ///
  long    ftotinc     118-124  ///
  long    incwage     125-130  ///
  long    incearn     131-137  ///
  using ${data_path}tmp.dat ///
  if age>=25 & age<=55 & bpl<=56 & year>=2009 & year<=2016
*extract includes years 2009-14 and ages 18+; no other restrictions 

!rm -f ${data_path}tmp.dat

replace perwt    = perwt    / 100
gen     yearofbirth=year-age
gen     yearage18=yearofbirth+18
keep if yearage18>=1984 & yearage18<=1996
*Define individual controls
gen     ed16plus=0
replace ed16plus=1 if educd>=100
gen     female=sex-1
gen     male=1-female
gen     white=0
gen     black=0
replace white=1 if race==1 & hispan==0
replace black=1 if race==2 & hispan==0
recode  hispan 0=0 else=1
gen     raceg=0
replace raceg=1 if white==1
replace raceg=2 if black==1
replace raceg=3 if hispan==1

sort  yearage18 bpl
merge yearage18 bpl using ${data_path}statecontrols.dta
tab  _merge
drop if _merge==2
drop _merge
sort bpl
merge bpl using ${data_path}bpl_vars_80.dta
tab  _merge
drop _merge
gen     post91=0
replace post91=1 if yearage18>=1991
sum *shr* [aweight=perwt]
gen     z2forshr_16pl_stemo_80_2559_p91 = z2forshr_16pl_stemo_80_2559*post91
gen     z2forshr_16pl_stem2_80_2559_p91 = z2forshr_16pl_stem2_80_2559*post91
gen     z2forshr_ed16plus_80_2559_p91   = z2forshr_ed16plus_80_2559*post91

gen y86=0
gen y87=0
gen y88=0
gen y89=0
gen y90=0
gen y91=0
gen y92=0
gen y93=0
gen y94=0
replace y86=1 if yearage18==1986
replace y87=1 if yearage18==1987
replace y88=1 if yearage18==1988
replace y89=1 if yearage18==1989
replace y90=1 if yearage18==1990
replace y91=1 if yearage18==1991
replace y92=1 if yearage18==1992
replace y93=1 if yearage18==1993
replace y94=1 if yearage18==1994
gen     z2forshr_16pl_stemo_80_2559_1986=z2forshr_16pl_stemo_80_2559*y86
gen     z2forshr_16pl_stemo_80_2559_1987=z2forshr_16pl_stemo_80_2559*y87
gen     z2forshr_16pl_stemo_80_2559_1988=z2forshr_16pl_stemo_80_2559*y88
gen     z2forshr_16pl_stemo_80_2559_1989=z2forshr_16pl_stemo_80_2559*y89
gen     z2forshr_16pl_stemo_80_2559_1991=z2forshr_16pl_stemo_80_2559*y91
gen     z2forshr_16pl_stemo_80_2559_1992=z2forshr_16pl_stemo_80_2559*y92
gen     z2forshr_16pl_stemo_80_2559_1993=z2forshr_16pl_stemo_80_2559*y93
gen     z2forshr_16pl_stemo_80_2559_1994=z2forshr_16pl_stemo_80_2559*y94

gen     stem1maj=degfieldd
recode  stem1maj  1100=0    1101=0  1102=0  1103=1  1104=1  1105=1  1106=1  1199=0  1300=1  1301=1  1302=1  1303=0  1401=0  1501=0  1900=0  1901=0  1902=0  1903=0  1904=0  2001=1  2100=1  2101=1  2102=1  2105=1  2106=1  2107=1  2201=0  2300=0  2301=0  2303=0  2304=0  2305=0  2306=0  2307=0  2308=0  2309=0  2310=0  2311=0  2312=0  2313=0  2314=0  2399=0  2400=1  2401=1  2402=1  2403=1  2404=1  2405=1  2406=1  2407=1  2408=1  2409=1  2410=1  2411=1  2412=1  2413=1  2414=1  2415=1  2416=1  2417=1  2418=1  2419=1  2499=1  2500=1  2501=1  2502=1  2503=1  2504=1  2599=1  2600=0  2601=0  2602=0  2603=0  2901=0  3200=0  3201=0  3202=0  3300=0  3301=0  3302=0  3400=0  3401=0  3402=0  3501=0  3600=1  3601=1  3602=1  3603=1  3604=1  3605=1  3606=1  3607=1  3608=1  3609=1  3611=1  3699=1  3700=1  3701=1  3702=1  3801=1  4000=0  4001=0  4002=1  4003=1  4005=1  4006=1  4007=0  4008=0  4101=0  4801=0  4901=0  5000=1  5001=1  5002=1  5003=1  5004=1  5005=1  5006=1  5007=1  5008=1  5098=1  5102=1  5200=0  5201=0  5202=0  5203=0  5205=0  5206=0  5299=0  5301=0  5400=0  5401=0  5402=0  5403=0  5404=0  5500=0  5501=0  5502=0  5503=0  5504=0  5505=0  5506=0  5507=0  5599=0  5601=0  5701=0  5801=0  5901=1  6000=0  6001=0  6002=0  6003=0  6004=0  6005=0  6006=0  6007=0  6099=0  6100=0  6102=0  6103=0  6104=0  6105=0  6106=1  6107=0  6108=1  6109=0  6110=0  6199=0  6200=0  6201=0  6202=1  6203=0  6204=0  6205=0  6206=0  6207=0  6209=0  6210=0  6211=0  6212=1  6299=0  6402=0  6403=0
gen     stem2maj=degfield2d
recode  stem2maj  1100=0    1101=0  1102=0  1103=1  1104=1  1105=1  1106=1  1199=0  1300=1  1301=1  1302=1  1303=0  1401=0  1501=0  1900=0  1901=0  1902=0  1903=0  1904=0  2001=1  2100=1  2101=1  2102=1  2105=1  2106=1  2107=1  2201=0  2300=0  2301=0  2303=0  2304=0  2305=0  2306=0  2307=0  2308=0  2309=0  2310=0  2311=0  2312=0  2313=0  2314=0  2399=0  2400=1  2401=1  2402=1  2403=1  2404=1  2405=1  2406=1  2407=1  2408=1  2409=1  2410=1  2411=1  2412=1  2413=1  2414=1  2415=1  2416=1  2417=1  2418=1  2419=1  2499=1  2500=1  2501=1  2502=1  2503=1  2504=1  2599=1  2600=0  2601=0  2602=0  2603=0  2901=0  3200=0  3201=0  3202=0  3300=0  3301=0  3302=0  3400=0  3401=0  3402=0  3501=0  3600=1  3601=1  3602=1  3603=1  3604=1  3605=1  3606=1  3607=1  3608=1  3609=1  3611=1  3699=1  3700=1  3701=1  3702=1  3801=1  4000=0  4001=0  4002=1  4003=1  4005=1  4006=1  4007=0  4008=0  4101=0  4801=0  4901=0  5000=1  5001=1  5002=1  5003=1  5004=1  5005=1  5006=1  5007=1  5008=1  5098=1  5102=1  5200=0  5201=0  5202=0  5203=0  5205=0  5206=0  5299=0  5301=0  5400=0  5401=0  5402=0  5403=0  5404=0  5500=0  5501=0  5502=0  5503=0  5504=0  5505=0  5506=0  5507=0  5599=0  5601=0  5701=0  5801=0  5901=1  6000=0  6001=0  6002=0  6003=0  6004=0  6005=0  6006=0  6007=0  6099=0  6100=0  6102=0  6103=0  6104=0  6105=0  6106=1  6107=0  6108=1  6109=0  6110=0  6199=0  6200=0  6201=0  6202=1  6203=0  6204=0  6205=0  6206=0  6207=0  6209=0  6210=0  6211=0  6212=1  6299=0  6402=0  6403=0
egen    stem_maj=rowmax(stem1maj stem2maj)
replace stem_maj=0 if educd<100

gen     business=0
gen     education=0
gen     health=0
gen     libarts=0
gen     socscience=0
gen     othermajor=0
replace business=1   if stem_maj==0 & (degfield==62)
replace education=1  if stem_maj==0 & (degfield==23)
replace health=1     if stem_maj==0 & (degfield==61)
replace libarts=1    if stem_maj==0 & (degfield==15 | degfield==19 | degfield==26 | degfield==33 | degfield==34 | degfield==35 | degfield==40 | degfield==48 | degfield==49 | degfield==60 | degfield==64)
replace socscience=1 if stem_maj==0 & (degfield==32 | degfield==52 | degfield==53 | degfield==54 | degfield==55)
replace othermajor=1 if stem_maj==0 & (degfield==11 | degfield==13 | degfield==56 | degfield==57 | degfield==58   |   degfield==14 | degfield==22 | degfield==41   |  degfield==29)

gen     computersci=0
gen     engineering=0
gen     technology =0
gen     biosciences=0
gen     physciences=0
gen     maths=0
replace computersci=1 if degfield==21
replace engineering=1 if degfield==24
replace technology =1 if degfield==25
replace biosciences=1 if degfield==36
replace physciences=1 if degfield==50
replace maths=1       if degfield==37
gen     allotherstem= stem_maj - computersci - engineering - technology - biosciences - physciences - maths

tab year       , gen(yeardum)
tab age        , gen(agedum)
tab yearofbirth, gen(yearbirthdum)
drop yeardum1 agedum1 yearbirthdum1 

gen     stemocc=occ1990
recode  stemocc  44/64=1 66/83=1 229=1                  else=0
gen     employed=0
replace employed=1 if empstat==1
gen     emp_stemocc=employed*stemocc
gen     workedly=0
replace workedly=1 if workedyr==3
gen     lincearn=ln(incearn)

egen tagbpl=tag(bpl)
gen     forshr_gc=0
replace forshr_gc=1 if forshr_16pl_stemo_80_2559>=0.120
tab forshr_gc  if tagbpl & !inlist(bpl,13,5,38,29), sum(forshr_16pl_stemo_80_2559)

drop if !inlist(raceg,1,2)
drop if inlist(bpl,13,5,38,29)

*----------------------------------------------------------------------------
* Graph outcomes (bin scatter) by cohort for highly affected and less highly affected areas
*----------------------------------------------------------------------------
foreach outcome in stem_maj {
    if "`outcome'"=="stem_maj" {
        local outc = "STEM"
        local outclbl = "STEM majors"
    }
    forv b = 0/1 {
        forv m = 0/1 {
            if "`m'"=="1" {
                local em = "m"
            }
            else {
                local em = "f"
            }
            if "`b'"=="1" {
                local bee = "b"
                local raceCond = "black==1"
            }
            else {
                local bee = "w"
                local raceCond = "white==1"
            }
            
            binscatter `outcome' yearage18 if female==`=1-`m'' & black==`b' & inrange(yearage18,1986,1994) & ed16plus==1 [aweight=perwt], line(connect) xline(1990.5) by(forshr_gc) mcolors("khaki" "navy") lcolors("khaki" "navy") legend(label(1 "Low-exposure areas") label(2 "High-exposure areas") cols(2) symxsize(10) keygap(1)) ytitle("Percent `outclbl'", height(8)) xtitle("Year age 18", height(5)) xlabel(1986(1)1994) graphregion(color(white)) // ylabel(-.05(.05).15) 
            graph export ${graph_path}fig2_`bee'`em'_`outc'_BA.eps, replace
        }
    }
}

foreach outcome in emp_stemocc {
    if "`outcome'"=="stemocc" {
        local outc = "STEMocc"
        local outclbl = "working in STEM occupation"
    }
    forv b = 0/1 {
        forv m = 0/1 {
            if "`m'"=="1" {
                local em = "m"
            }
            else {
                local em = "f"
            }
            if "`b'"=="1" {
                local bee = "b"
                local raceCond = "black==1"
            }
            else {
                local bee = "w"
                local raceCond = "white==1"
            }
            
            binscatter `outcome' yearage18 if female==`=1-`m'' & black==`b' & inrange(yearage18,1986,1994) & ed16plus==1 & stem_maj==1 [aweight=perwt], line(connect) xline(1990.5) by(forshr_gc) mcolors("khaki" "navy") lcolors("khaki" "navy") legend(label(1 "Low-exposure areas") label(2 "High-exposure areas") cols(2) symxsize(10) keygap(1)) ytitle("Percent `outclbl'", height(8)) xtitle("Year age 18", height(5)) xlabel(1986(1)1994) graphregion(color(white)) // ylabel(-.05(.05).15) 
            graph export ${graph_path}fig3_`bee'`em'_`outc'_stemBA.eps, replace
        }
    }
}

foreach outcome in workedly {
    if "`outcome'"=="workedly" {
        local outc = "LFPly"
        local outclbl = "employed in previous year"
    }
    forv b = 0/1 {
        forv m = 0/1 {
            if "`m'"=="1" {
                local em = "m"
            }
            else {
                local em = "f"
            }
            if "`b'"=="1" {
                local bee = "b"
                local raceCond = "black==1"
            }
            else {
                local bee = "w"
                local raceCond = "white==1"
            }
            
            binscatter `outcome' yearage18 if female==`=1-`m'' & black==`b' & inrange(yearage18,1986,1994) & ed16plus==1 & stem_maj==1 [aweight=perwt], line(connect) xline(1990.5) by(forshr_gc) mcolors("khaki" "navy") lcolors("khaki" "navy") legend(label(1 "Low-exposure areas") label(2 "High-exposure areas") cols(2) symxsize(10) keygap(1)) ytitle("Percent `outclbl'", height(8)) xtitle("Year age 18", height(5)) xlabel(1986(1)1994) graphregion(color(white)) // ylabel(-.05(.05).15) 
            graph export ${graph_path}fig4_`bee'`em'_`outc'_stemBA.eps, replace
        }
    }
}



log close
