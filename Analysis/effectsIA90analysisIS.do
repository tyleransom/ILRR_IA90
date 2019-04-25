*Effects of IA90 on Native College Major Choices
clear all
version 14.0
set matsize 11000
set maxvar  32767
set more off
capture log close
log using effectsIA90analysisIS.log, replace

global data_path "../Data/"
global table_path "../Tables/"
global outreg_path "M:\Immigrants\IA90_Native_Majors\Empirics\Outregs\"

local EY = int(10000*uniform()) // NO seed; needs to be random
!gunzip -fc ${data_path}acs_09_16.dat.gz > ${data_path}tmp`EY'.dat

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
  using ${data_path}tmp`EY'.dat ///
  if age>=25 & age<=55 & bpl<=56 & year>=2009 & year<=2016 
*extract includes years 2009-16 and ages 18+; no other restrictions 

!rm -f ${data_path}tmp`EY'.dat

tab year

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

qui tab bpl, gen(stdum)
gen trend = (yearage18-1984)/12

local statetrends = ""
forv st=1/51 {
    gen st`st'Xtrend = stdum`st'*trend
    local temp = "st`st'Xtrend"
    local statetrends : list statetrends | temp
}

local statetrends2 = ""
forv st=1/51 {
    gen st`st'Xtrend2 = stdum`st'*trend^2
    local temp = "st`st'Xtrend2"
    local statetrends2 : list statetrends2 | temp
}

local statetrends3 = ""
forv st=1/51 {
    gen st`st'Xtrend3 = stdum`st'*trend^3
    local temp = "st`st'Xtrend3"
    local statetrends3 : list statetrends3 | temp
}

gen     moved = statefip!=bpl

sort  yearage18 bpl
merge m:1 yearage18 bpl using ${data_path}statecontrols.dta
tab  _merge
drop if _merge==2
drop _merge
sort bpl
merge m:1 bpl using ${data_path}bpl_vars_80.dta
tab  _merge
drop _merge
gen     post91=0
replace post91=1 if yearage18>=1991
merge m:1 bpl using ${data_path}bpl_forshr_figure1.dta, keepusing(forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_00_2559) nogen
sum *shr* [aweight=perwt]

* Express exposure in 10pp units
foreach var of varlist *shr* {
    replace `var' = `var'*10
}

gen     forshr_16pl_stemo_80_2559_p91    = forshr_16pl_stemo_80_2559*post91
gen     forshr_16pl_stem2_80_2559_p91    = forshr_16pl_stem2_80_2559*post91
gen     forshr_16pl_nstem_80_2559_p91    = forshr_16pl_nstemo_80_2559*post91
gen     forshr_ed16plus_80_2559_p91      = forshr_ed16plus_80_2559*post91
gen     forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_00_90_2559*post91
gen     forshr_16pl_stemo_00_2559_p91    = forshr_16pl_stemo_00_2559*post91

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
gen     forshr_16pl_stemo_80_2559_1986=forshr_16pl_stemo_80_2559*y86
gen     forshr_16pl_stemo_80_2559_1987=forshr_16pl_stemo_80_2559*y87
gen     forshr_16pl_stemo_80_2559_1988=forshr_16pl_stemo_80_2559*y88
gen     forshr_16pl_stemo_80_2559_1989=forshr_16pl_stemo_80_2559*y89
gen     forshr_16pl_stemo_80_2559_1991=forshr_16pl_stemo_80_2559*y91
gen     forshr_16pl_stemo_80_2559_1992=forshr_16pl_stemo_80_2559*y92
gen     forshr_16pl_stemo_80_2559_1993=forshr_16pl_stemo_80_2559*y93
gen     forshr_16pl_stemo_80_2559_1994=forshr_16pl_stemo_80_2559*y94

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

preserve
    gen unemployed=0
    gen nilf=0
    replace unemployed=1 if empstat==2
    replace nilf=1       if empstat==3
    collapse stem_maj stemocc unemployed nilf lincearn [aweight=perwt] if inrange(yearage18,1986,1994), by(bpl yearage18 ed16plus female black)
    save ${data_path}outcome_means_86_94, replace
restore

preserve
    gen unemployed=0
    gen nilf=0
    replace unemployed=1 if empstat==2
    replace nilf=1       if empstat==3
    collapse stem_maj stemocc unemployed nilf lincearn [aweight=perwt] if inrange(yearage18,1986,1994), by(bpl yearage18 female black)
    save ${data_path}outcome_means_uncondBA_86_94, replace
restore

preserve
    gen unemployed=0
    gen nilf=0
    replace unemployed=1 if empstat==2
    replace nilf=1       if empstat==3
    collapse stemocc unemployed nilf lincearn [aweight=perwt] if inrange(yearage18,1986,1994), by(bpl yearage18 ed16plus stem_maj female black)
    save ${data_path}outcome_means_stem_maj_86_94, replace
restore




capture program drop first_coef
program first_coef
    syntax, in1(string) in2(string) OUTnames(string)
    local firstname : word 3 of `in1'
    
    forval j = 1/4 {
    local out`j' : word `j' of `outnames'
        if "`out`j''" == "" {
            local J = `j' - 1
            di "only `J' names in out(): 4 names expected"
            exit 498
        }
    }
    
    local trash : word 5 of `outnames'
    if "`trash'" != "" {
        di "trailing `trash' in out(): 4 names expected"
        exit 498
    }
    
    c_local `out4' = `in2'
    c_local `out1' = _b[`firstname']
    c_local `out2' = _se[`firstname']

    if "`degfree'" == "" local degfree = `in2'
    else local degfree = `e(df_r)'
    
    local Pvalue = 2 * ttail(`degfree', abs(_b[`firstname']/_se[`firstname']))
    if `Pvalue' <= 0.01         c_local `out3' "***"  
    else if `Pvalue' <= 0.05    c_local `out3' "**"
    else if `Pvalue' <= 0.1     c_local `out3' "*"
    else                        c_local `out3' " "
end

capture program drop first_coef_2SLS
program first_coef_2SLS
    syntax, in1(string) in2(string) OUTnames(string)
    local firstname : word 1 of `in1'
    
    forval j = 1/4 {
    local out`j' : word `j' of `outnames'
        if "`out`j''" == "" {
            local J = `j' - 1
            di "only `J' names in out(): 4 names expected"
            exit 498
        }
    }
    
    local trash : word 5 of `outnames'
    if "`trash'" != "" {
        di "trailing `trash' in out(): 4 names expected"
        exit 498
    }
    
    c_local `out4' = `in2'
    c_local `out1' = _b[`firstname']
    c_local `out2' = _se[`firstname']
    
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`firstname']/_se[`firstname']))
    if `Pvalue' <= 0.01         c_local `out3' "***"  
    else if `Pvalue' <= 0.05    c_local `out3' "**"
    else if `Pvalue' <= 0.1     c_local `out3' "*"
    else                        c_local `out3' " "
end

* sysuse auto, clear
* qui reghdfe price weight (length=head), absorb(rep78) stage(first)
* all_coefs_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1A se1A star1A N1A bf1A sef1A starf1A Fstat1A)

capture program drop all_coefs_2SLS
program all_coefs_2SLS
    syntax, in1(string) in2(string) OUTnames(string)
    local firstname : word 1 of `in1'
    
    forval j = 1/8 {
    local out`j' : word `j' of `outnames'
        if "`out`j''" == "" {
            local J = `j' - 1
            di "only `J' names in out(): 8 names expected"
            exit 498
        }
    }
    
    local trash : word 9 of `outnames'
    if "`trash'" != "" {
        di "trailing `trash' in out(): 8 names expected"
        exit 498
    }
    
    c_local `out4' = `in2'
    c_local `out1' = _b[`firstname']
    c_local `out2' = _se[`firstname']
    
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`firstname']/_se[`firstname']))
    if `Pvalue' <= 0.01         c_local `out3' "***"  
    else if `Pvalue' <= 0.05    c_local `out3' "**"
    else if `Pvalue' <= 0.1     c_local `out3' "*"
    else                        c_local `out3' " "

    c_local `out8' = `e(widstat)'
    qui est table reghdfe_first1
    matrix firststage = r(coef)
    c_local `out5' = firststage[1,1]
    c_local `out6' = sqrt(firststage[1,2])
    
    local Pvalue = 2 * ttail(e(df_r), abs(firststage[1,1]/sqrt(firststage[1,2])))
    if `Pvalue' <= 0.01         c_local `out7' "***"  
    else if `Pvalue' <= 0.05    c_local `out7' "**"
    else if `Pvalue' <= 0.1     c_local `out7' "*"
    else                        c_local `out7' " "
end

* first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
* first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11A b12A se11A se12A star11A star12A N1A)

capture program drop first_two_coefs
program first_two_coefs
    syntax, in1(string) in2(string) OUTnames(string)
    local firstname : word 3 of `in1'
    local secondname : word 4 of `in1'
    
    forval j = 1/7 {
    local out`j' : word `j' of `outnames'
        if "`out`j''" == "" {
            local J = `j' - 1
            di "only `J' names in out(): 7 names expected"
            exit 498
        }
    }
    
    local trash : word 8 of `outnames'
    if "`trash'" != "" {
        di "trailing `trash' in out(): 7 names expected"
        exit 498
    }
    
    c_local `out7' = `in2'
    c_local `out1' = _b[`firstname']
    c_local `out2' = _b[`secondname']
    c_local `out3' = _se[`firstname']
    c_local `out4' = _se[`secondname']
    
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`firstname']/_se[`firstname']))
    if `Pvalue' <= 0.01         c_local `out5' "***"  
    else if `Pvalue' <= 0.05    c_local `out5' "**"
    else if `Pvalue' <= 0.1     c_local `out5' "*"
    else                        c_local `out5' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`secondname']/_se[`secondname']))
    if `Pvalue' <= 0.01         c_local `out6' "***"  
    else if `Pvalue' <= 0.05    c_local `out6' "**"
    else if `Pvalue' <= 0.1     c_local `out6' "*"
    else                        c_local `out6' " "
end

* first_eight_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11A b12A b13A b14A b15A b16A b17A b18A se11A se12A se13A se14A se15A se16A se17A se18A star11A star12A star13A star14A star15A star16A star17A star18A N1A)
capture program drop first_eight_coefs
program first_eight_coefs
    syntax, in1(string) in2(string) OUTnames(string)
    local tester : word 3 of `in1'
    unab in1a : `tester'
    local firstname   : word 1 of `in1a'
    local secondname  : word 2 of `in1a'
    local thirdname   : word 3 of `in1a'
    local fourthname  : word 4 of `in1a'
    local fifthname   : word 5 of `in1a'
    local sixthname   : word 6 of `in1a'
    local seventhname : word 7 of `in1a'
    local eighthname  : word 8 of `in1a'
    
    forval j = 1/25 {
    local out`j' : word `j' of `outnames'
        if "`out`j''" == "" {
            local J = `j' - 1
            di "only `J' names in out(): 25 names expected"
            exit 498
        }
    }
    
    local trash : word 26 of `outnames'
    if "`trash'" != "" {
        di "trailing `trash' in out(): 25 names expected"
        exit 498
    }
    
    c_local `out25' = `in2'
    c_local `out1'  = _b[`firstname']
    c_local `out2'  = _b[`secondname']
    c_local `out3'  = _b[`thirdname']
    c_local `out4'  = _b[`fourthname']
    c_local `out5'  = _b[`fifthname']
    c_local `out6'  = _b[`sixthname']
    c_local `out7'  = _b[`seventhname']
    c_local `out8'  = _b[`eighthname']
    c_local `out9'  = _se[`firstname']
    c_local `out10' = _se[`secondname']
    c_local `out11' = _se[`thirdname']
    c_local `out12' = _se[`fourthname']
    c_local `out13' = _se[`fifthname']
    c_local `out14' = _se[`sixthname']
    c_local `out15' = _se[`seventhname']
    c_local `out16' = _se[`eighthname']
    
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`firstname']/_se[`firstname']))
    if `Pvalue' <= 0.01         c_local `out17' "***"  
    else if `Pvalue' <= 0.05    c_local `out17' "**"
    else if `Pvalue' <= 0.1     c_local `out17' "*"
    else                        c_local `out17' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`secondname']/_se[`secondname']))
    if `Pvalue' <= 0.01         c_local `out18' "***"  
    else if `Pvalue' <= 0.05    c_local `out18' "**"
    else if `Pvalue' <= 0.1     c_local `out18' "*"
    else                        c_local `out18' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`thirdname']/_se[`thirdname']))
    if `Pvalue' <= 0.01         c_local `out19' "***"  
    else if `Pvalue' <= 0.05    c_local `out19' "**"
    else if `Pvalue' <= 0.1     c_local `out19' "*"
    else                        c_local `out19' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`fourthname']/_se[`fourthname']))
    if `Pvalue' <= 0.01         c_local `out20' "***"  
    else if `Pvalue' <= 0.05    c_local `out20' "**"
    else if `Pvalue' <= 0.1     c_local `out20' "*"
    else                        c_local `out20' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`fifthname']/_se[`fifthname']))
    if `Pvalue' <= 0.01         c_local `out21' "***"  
    else if `Pvalue' <= 0.05    c_local `out21' "**"
    else if `Pvalue' <= 0.1     c_local `out21' "*"
    else                        c_local `out21' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`sixthname']/_se[`sixthname']))
    if `Pvalue' <= 0.01         c_local `out22' "***"  
    else if `Pvalue' <= 0.05    c_local `out22' "**"
    else if `Pvalue' <= 0.1     c_local `out22' "*"
    else                        c_local `out22' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`seventhname']/_se[`seventhname']))
    if `Pvalue' <= 0.01         c_local `out23' "***"  
    else if `Pvalue' <= 0.05    c_local `out23' "**"
    else if `Pvalue' <= 0.1     c_local `out23' "*"
    else                        c_local `out23' " "
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`eighthname']/_se[`eighthname']))
    if `Pvalue' <= 0.01         c_local `out24' "***"  
    else if `Pvalue' <= 0.05    c_local `out24' "**"
    else if `Pvalue' <= 0.1     c_local `out24' "*"
    else                        c_local `out24' " "
end






*Main analysis uses 4-year +- window and excludes early merit states (bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29: georgia, arkansas, north dakota, and missouri)
sum age if inrange(yearage18,1986,1994)
*restricts to persons ages 33-46

*Table: sum stats
*Post-91 Foreign Exposure
sum forshr_16pl_stem*_80_2559_p91 forshr_ed16plus_80_2559_p91   [aweight=perwt] if   inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
sum forshr_16pl_stemo_80_2559_p91  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local mu1  = `=`r(mean)'/10'
local sd1  = `=`r(sd)'/10'
local min1 = `=`r(min)'/10'
local max1 = `=`r(max)'/10'
sum forshr_16pl_stemo_80_2559_p91  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local mu2  = `=`r(mean)'/10'
local sd2  = `=`r(sd)'/10'
local min2 = `=`r(min)'/10'
local max2 = `=`r(max)'/10'
sum forshr_16pl_stemo_80_2559_p91  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local mu3  = `=`r(mean)'/10'
local sd3  = `=`r(sd)'/10'
local min3 = `=`r(min)'/10'
local max3 = `=`r(max)'/10'
sum forshr_16pl_stemo_80_2559_p91  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local mu4  = `=`r(mean)'/10'
local sd4  = `=`r(sd)'/10'
local min4 = `=`r(min)'/10'
local max4 = `=`r(max)'/10'

*Pre-91 Foreign Exposure
sum forshr_16pl_stem*_80_2559 forshr_ed16plus_80_2559   [aweight=perwt] if   inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
sum forshr_16pl_stemo_80_2559  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local pmu1  = `=`r(mean)'/10'
local psd1  = `=`r(sd)'/10'
local pmin1 = `=`r(min)'/10'
local pmax1 = `=`r(max)'/10'
sum forshr_16pl_stemo_80_2559  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local pmu2  = `=`r(mean)'/10'
local psd2  = `=`r(sd)'/10'
local pmin2 = `=`r(min)'/10'
local pmax2 = `=`r(max)'/10'
sum forshr_16pl_stemo_80_2559  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local pmu3  = `=`r(mean)'/10'
local psd3  = `=`r(sd)'/10'
local pmin3 = `=`r(min)'/10'
local pmax3 = `=`r(max)'/10'
sum forshr_16pl_stemo_80_2559  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local pmu4  = `=`r(mean)'/10'
local psd4  = `=`r(sd)'/10'
local pmin4 = `=`r(min)'/10'
local pmax4 = `=`r(max)'/10'


*Pre-91 Outcome Means for Education variables
sum stem_maj  ed16plus  business education health libarts socscience othermajor  computersci engineering technology biosciences physciences maths allotherstem   [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
sum stem_maj  ed16plus  business education health libarts socscience othermajor  computersci engineering technology biosciences physciences maths allotherstem   [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
sum stem_maj  ed16plus  business education health libarts socscience othermajor  computersci engineering technology biosciences physciences maths allotherstem   [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
sum stem_maj  ed16plus  business education health libarts socscience othermajor  computersci engineering technology biosciences physciences maths allotherstem   [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
*Pre-91 Outcome Means for STEM major
sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu1A  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu2A  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu3A  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu4A  = `r(mean)'
*Pre-91 Outcome Means for Bachelor's Degree
sum ed16plus  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu1B  = `r(mean)'
sum ed16plus  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu2B  = `r(mean)'
sum ed16plus  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu3B  = `r(mean)'
sum ed16plus  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
local mu4B  = `r(mean)'
*Pre-91 STEM mean conditional on ed16plus (which can be constructed from the ratio of the two variables so maybe only put in appendix with detailed majors?)
sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu1C  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu2C  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu3C  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu4C  = `r(mean)'
*Post-91 Outcome Means for STEM major
sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu1A  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu2A  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu3A  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu4A  = `r(mean)'
*Post-91 Outcome Means for Bachelor's Degree
sum ed16plus  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu1B  = `r(mean)'
sum ed16plus  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu2B  = `r(mean)'
sum ed16plus  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu3B  = `r(mean)'
sum ed16plus  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
local nu4B  = `r(mean)'
*Post-91 STEM mean conditional on ed16plus (which can be constructed from the ratio of the two variables so maybe only put in appendix with detailed majors?)
sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local nu1C  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local nu2C  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local nu3C  = `r(mean)'
sum stem_maj  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local nu4C  = `r(mean)'

local k=1
foreach var in stemocc emp_stemocc employed workedly lincearn {
    *Pre-91 Outcomes Unconditional on Education
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
    local mu1a`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
    local mu2a`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
    local mu3a`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29)
    local mu4a`k' = `r(mean)'
    *Pre-91 Outcomes Conditional on ed16plus==1
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local mu1b`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local mu2b`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local mu3b`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local mu4b`k' = `r(mean)'
    *Pre-91 Outcomes Conditional on ed16plus==1 & stem_maj==1
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local mu1c`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local mu2c`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local mu3c`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local mu4c`k' = `r(mean)'
    *Pre-91 Outcomes Conditional on ed16plus==1 & stem_maj==1
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local mu1d`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local mu2d`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local mu3d`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local mu4d`k' = `r(mean)'
    local k = `=`k'+1'
}

local k=1
foreach var in stemocc emp_stemocc employed workedly lincearn {
    *Pre-91 Outcomes Unconditional on Education
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
    local nu1a`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
    local nu2a`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
    local nu3a`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
    local nu4a`k' = `r(mean)'
    *Pre-91 Outcomes Conditional on ed16plus==1
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local nu1b`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local nu2b`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local nu3b`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1
    local nu4b`k' = `r(mean)'
    *Pre-91 Outcomes Conditional on ed16plus==1 & stem_maj==1
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local nu1c`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local nu2c`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local nu3c`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
    local nu4c`k' = `r(mean)'
    *Pre-91 Outcomes Conditional on ed16plus==1 & stem_maj==1
    sum `var'  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local nu1d`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & black==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local nu2d`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local nu3d`k' = `r(mean)'
    sum `var'  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
    local nu4d`k' = `r(mean)'
    local k = `=`k'+1'
}

*Pre-91 major rates for black men
qui sum computersci  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb1A  = `r(mean)'
qui sum engineering  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb2A  = `r(mean)'
qui sum technology   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb3A  = `r(mean)'
qui sum biosciences  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb4A  = `r(mean)'
qui sum physciences  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb5A  = `r(mean)'
qui sum maths        [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb6A  = `r(mean)'
qui sum allotherstem [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb7A  = `r(mean)'

qui sum business    [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb1B  = `r(mean)'
qui sum education   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb2B  = `r(mean)'
qui sum health      [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb3B  = `r(mean)'
qui sum libarts     [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb4B  = `r(mean)'
qui sum socscience  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb5B  = `r(mean)'
qui sum othermajor  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1998) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mumb6B  = `r(mean)'


capture file close Ttemp
file open Ttemp using "${table_path}Ttemp.tex", write replace
file write Ttemp "\begin{table}[ht]" _n 
file write Ttemp "\caption{Weighted Summary Statistics of Exposure, 1986--1989 cohorts}" _n 
file write Ttemp "\label{tab:sumStatsPost}" _n 
file write Ttemp "\centering" _n 
file write Ttemp "\begin{threeparttable}" _n 
file write Ttemp "\begin{tabular}{lcccc}" _n 
file write Ttemp "\toprule " _n 
file write Ttemp "Group & Mean & Std. Dev. & Min & Max \\" _n 
file write Ttemp "\midrule " _n 
file write Ttemp "Black Men    " " & " %4.3f (`pmu1') " & " %4.3f (`psd1') " & " %4.3f (`pmin1') " & " %4.3f (`pmax1') " \\ "  _n 
file write Ttemp "Black Women  " " & " %4.3f (`pmu2') " & " %4.3f (`psd2') " & " %4.3f (`pmin2') " & " %4.3f (`pmax2') " \\ "  _n 
file write Ttemp "White Men    " " & " %4.3f (`pmu3') " & " %4.3f (`psd3') " & " %4.3f (`pmin3') " & " %4.3f (`pmax3') " \\ "  _n 
file write Ttemp "White Women  " " & " %4.3f (`pmu4') " & " %4.3f (`psd4') " & " %4.3f (`pmin4') " & " %4.3f (`pmax4') " \\ "  _n 
file write Ttemp "\bottomrule " _n 
file write Ttemp "\end{tabular} " _n 
file write Ttemp "\end{threeparttable} " _n 
file write Ttemp "\end{table} " _n 
file close Ttemp



capture file close T1
file open T1 using "${table_path}T1.tex", write replace
file write T1 "\begin{table}[ht]" _n 
file write T1 "\caption{Weighted Summary Statistics of Outcome and Explanatory Variables}" _n 
file write T1 "\label{tab:sumStatsPost}" _n 
file write T1 "\centering" _n 
file write T1 "\resizebox{!}{.44\textheight}{" _n 
file write T1 "\begin{threeparttable}" _n 
file write T1 "\begin{tabular}{lcccc}" _n 
file write T1 "\multicolumn{5}{l}{\emph{Panel A: Foreign STEM Exposure Summary Statistics for 1991--1994 Cohorts}}\\ " _n 
file write T1 "\midrule " _n 
file write T1 "Group & Mean & Std. Dev. & Min & Max \\" _n 
file write T1 "\midrule " _n 
file write T1 "Black Men    " " & " %4.3f (`mu1') " & " %4.3f (`sd1') " & " %4.3f (`min1') " & " %4.3f (`max1') " \\ "  _n 
file write T1 "Black Women  " " & " %4.3f (`mu2') " & " %4.3f (`sd2') " & " %4.3f (`min2') " & " %4.3f (`max2') " \\ "  _n 
file write T1 "White Men    " " & " %4.3f (`mu3') " & " %4.3f (`sd3') " & " %4.3f (`min3') " & " %4.3f (`max3') " \\ "  _n 
file write T1 "White Women  " " & " %4.3f (`mu4') " & " %4.3f (`sd4') " & " %4.3f (`min4') " & " %4.3f (`max4') " \\ "  _n 
file write T1 "&&&&\\"  _n
file write T1 "\multicolumn{5}{l}{\emph{Panel B: Sample Means of Dependent Variables for 1986--1989 Cohorts}}\\" _n 
file write T1 "\midrule " _n 
file write T1 "         & Black           & Black        & White        & White       \\" _n 
file write T1 "Variable & Men             & Women        & Men          & Women       \\" _n 
file write T1 "\midrule " _n 
file write T1 "\emph{Main Education Variables}                         &       &        &       &       \\"  _n 
file write T1 "STEM Degree Unconditional on Education Level            & " %4.3f (`mu1A') " & " %4.3f (`mu2A') " & " %4.3f (`mu3A') " & " %4.3f (`mu4A') " \\ "  _n 
file write T1 "Bachelor's Degree Completion in Any Field               & " %4.3f (`mu1B') " & " %4.3f (`mu2B') " & " %4.3f (`mu3B') " & " %4.3f (`mu4B') " \\ "  _n 
file write T1 "STEM Degree Conditional on Bachelor's Completion        & " %4.3f (`mu1C') " & " %4.3f (`mu2C') " & " %4.3f (`mu3C') " & " %4.3f (`mu4C') " \\ "  _n 
file write T1 "                                                        &       &        &       &       \\"  _n 
file write T1 "\emph{Current STEM Employment}                          &       &        &       &       \\"  _n 
file write T1 "Conditional on Bachelor's Completion                    & " %4.3f (`mu1b2') " & " %4.3f (`mu2b2') " & " %4.3f (`mu3b2') " & " %4.3f (`mu4b2') " \\ "  _n 
file write T1 "Conditional on Bachelor's in STEM Field                 & " %4.3f (`mu1c2') " & " %4.3f (`mu2c2') " & " %4.3f (`mu3c2') " & " %4.3f (`mu4c2') " \\ "  _n 
file write T1 "Conditional on Bachelor's in Non-STEM Field             & " %4.3f (`mu1d2') " & " %4.3f (`mu2d2') " & " %4.3f (`mu3d2') " & " %4.3f (`mu4d2') " \\ "  _n 
file write T1 "                                                        &       &        &       &       \\"  _n 
file write T1 "\emph{Prior Year Employment}                            &       &        &       &       \\"  _n 
file write T1 "Conditional on Bachelor's Completion                    & " %4.3f (`mu1b4') " & " %4.3f (`mu2b4') " & " %4.3f (`mu3b4') " & " %4.3f (`mu4b4') " \\ "  _n 
file write T1 "Conditional on Bachelor's in STEM Field                 & " %4.3f (`mu1c4') " & " %4.3f (`mu2c4') " & " %4.3f (`mu3c4') " & " %4.3f (`mu4c4') " \\ "  _n 
file write T1 "Conditional on Bachelor's in Non-STEM Field             & " %4.3f (`mu1d4') " & " %4.3f (`mu2d4') " & " %4.3f (`mu3d4') " & " %4.3f (`mu4d4') " \\ "  _n 
file write T1 "&&&&\\"  _n
file write T1 "\multicolumn{5}{l}{\emph{Panel C: Sample Means of Dependent Variables for 1991--1994 Cohorts}}\\" _n 
file write T1 "\midrule " _n 
file write T1 "         & Black           & Black        & White        & White       \\" _n 
file write T1 "Variable & Men             & Women        & Men          & Women       \\" _n 
file write T1 "\midrule " _n 
file write T1 "\emph{Main Education Variables}                         &       &        &       &       \\"  _n 
file write T1 "STEM Degree Unconditional on Education Level            & " %4.3f (`nu1A') " & " %4.3f (`nu2A') " & " %4.3f (`nu3A') " & " %4.3f (`nu4A') " \\ "  _n 
file write T1 "Bachelor's Degree Completion in Any Field               & " %4.3f (`nu1B') " & " %4.3f (`nu2B') " & " %4.3f (`nu3B') " & " %4.3f (`nu4B') " \\ "  _n 
file write T1 "STEM Degree Conditional on Bachelor's Completion        & " %4.3f (`nu1C') " & " %4.3f (`nu2C') " & " %4.3f (`nu3C') " & " %4.3f (`nu4C') " \\ "  _n 
file write T1 "                                                        &       &        &       &       \\"  _n 
file write T1 "\emph{Current STEM Employment}                          &       &        &       &       \\"  _n 
file write T1 "Conditional on Bachelor's Completion                    & " %4.3f (`nu1b2') " & " %4.3f (`nu2b2') " & " %4.3f (`nu3b2') " & " %4.3f (`nu4b2') " \\ "  _n 
file write T1 "Conditional on Bachelor's in STEM Field                 & " %4.3f (`nu1c2') " & " %4.3f (`nu2c2') " & " %4.3f (`nu3c2') " & " %4.3f (`nu4c2') " \\ "  _n 
file write T1 "Conditional on Bachelor's in Non-STEM Field             & " %4.3f (`nu1d2') " & " %4.3f (`nu2d2') " & " %4.3f (`nu3d2') " & " %4.3f (`nu4d2') " \\ "  _n 
file write T1 "                                                        &       &        &       &       \\"  _n 
file write T1 "\emph{Prior Year Employment}                            &       &        &       &       \\"  _n 
file write T1 "Conditional on Bachelor's Completion                    & " %4.3f (`nu1b4') " & " %4.3f (`nu2b4') " & " %4.3f (`nu3b4') " & " %4.3f (`nu4b4') " \\ "  _n 
file write T1 "Conditional on Bachelor's in STEM Field                 & " %4.3f (`nu1c4') " & " %4.3f (`nu2c4') " & " %4.3f (`nu3c4') " & " %4.3f (`nu4c4') " \\ "  _n 
file write T1 "Conditional on Bachelor's in Non-STEM Field             & " %4.3f (`nu1d4') " & " %4.3f (`nu2d4') " & " %4.3f (`nu3d4') " & " %4.3f (`nu4d4') " \\ "  _n 
file write T1 "\bottomrule " _n 
file write T1 "\end{tabular} " _n 
file write T1 "\footnotesize Notes: By definition, the foreign STEM exposure variables in panel A all equal zero for the 1986--1989 cohorts. Means in panel B are useful for quantifying the relative magnitudes of the effects that we examine. A comparison of panels B and C is useful for gauging overall time differences in outcomes during our analysis window." _n 
file write T1 "\end{threeparttable} " _n 
file write T1 "}" _n 
file write T1 "\end{table} " _n 
file close T1





*TableA: effects on stem_maj unconditional on ed16plus
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable2.doc, replace se starlevels(10 5 1) starloc(1)
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
di `=`b1D'/`se1D''
di 2 * ttail(`e(df_r)', abs(`=`b1D'/`se1D''))
est sto regD
* outreg using ${outreg_path}IStable2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("TableA: effects on stem major unconditional on Education")

*TableB: effects on ed16plus
qui reg ed16plus forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable3.doc, replace se starlevels(10 5 1) starloc(1)
qui reg ed16plus forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg ed16plus forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg ed16plus forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable3.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("TableB: effects on college completion unconditional on Education")


*TableC: effects on stem_maj conditional on ed16plus==1
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable4.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("TableC: effects on stem major conditional on college completion")




capture file close T2
file open T2 using "${table_path}T2.tex", write replace
file write T2 "\begin{table}[ht]" _n 
file write T2 "\caption{Birth-State Foreign STEM Exposure and STEM Degree Completion}" _n 
file write T2 "\label{tab:STEMgradUncond}" _n 
file write T2 "\centering" _n 
file write T2 "\begin{threeparttable}" _n 
file write T2 "\begin{tabular}{lcccc}" _n 
file write T2 "\toprule " _n 
file write T2 "       & Black           & Black        & White        & White       \\" _n 
file write T2 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T2 "\midrule " _n 
file write T2 "\multicolumn{5}{l}{\emph{Panel A: STEM graduation, unconditional of education level}}\\ " _n 
file write T2 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " & " %4.3f (`b1D') "`star1D'" " \\ "  _n 
file write T2                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") & (" %4.3f  (`se1D') ") \\ "  _n 
file write T2 "Control mean"          " &  [" %4.3f (`mu1A') "] & [" %4.3f  (`mu2A') "] & [" %4.3f  (`mu3A')  "] & [" %4.3f  (`mu4A') "] \\ "  _n 
file write T2 "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " & " %9.0gc  (`N1D') " \\ "  _n 
file write T2 "&&&&\\"  _n
file write T2 "\multicolumn{5}{l}{\emph{Panel B: BA graduation}}\\ " _n 
file write T2 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T2                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T2 "Control mean"          " &  [" %4.3f (`mu1B') "] & [" %4.3f  (`mu2B') "] & [" %4.3f  (`mu3B')  "] & [" %4.3f  (`mu4B') "] \\ "  _n 
file write T2 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T2 "&&&&\\"  _n
file write T2 "\multicolumn{5}{l}{\emph{Panel C: STEM graduation, conditional on BA graduation}}\\ " _n 
file write T2 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T2                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T2 "Control mean"          " &  [" %4.3f (`mu1C') "] & [" %4.3f  (`mu2C') "] & [" %4.3f  (`mu3C')  "] & [" %4.3f  (`mu4C') "] \\ "  _n 
file write T2 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T2 "&&&&\\"  _n
file write T2 "\multicolumn{5}{l}{\emph{Additional controls included in each regression:}}\\ " _n 
file write T2 "Demographic characteristics       & Yes    & Yes & Yes & Yes \\" _n 
file write T2 "State characteristics             & Yes    & Yes & Yes & Yes \\" _n 
file write T2 "State-specific year age 18 trends & Yes    & Yes & Yes & Yes \\" _n 
file write T2 "\bottomrule " _n 
file write T2 "\end{tabular} " _n 
file write T2 "\footnotesize Notes: Dependent variable is an indicator for either \emph{(a)} graduating in a STEM field, unconditional on education level; \emph{(b)} graduating with a bachelor's degree in any field; or \emph{(c)} graduating with a bachelor's degree in a STEM field. Foreign STEM Exposure denotes the effect of a 10 percentage point increase in the share of foreign STEM workers on the dependent variable. Each coefficient is estimated from a separate linear probability model. The mean of the dependent variable for the control group is reported in brackets. *Statistically significant at the .10 level; ** at the .05 level." _n 
file write T2 "\end{threeparttable} " _n 
file write T2 "\end{table} " _n 
file close T2




*TableA: IV effects on stem_maj unconditional on ed16plus
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}tableIV2a.doc, replace se starlevels(10 5 1) starloc(1)
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}tableIV2a.doc, merge   se starlevels(10 5 1) starloc(1)
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}tableIV2a.doc, merge   se starlevels(10 5 1) starloc(1)
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}tableIV2a.doc, merge   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("TableA: effects on stem major unconditional on Education")


*TableB: IV effects on ed16plus
reghdfe ed16plus               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}tableIV2b.doc, replace se starlevels(10 5 1) starloc(1)
reghdfe ed16plus               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}tableIV2b.doc, merge   se starlevels(10 5 1) starloc(1)
reghdfe ed16plus               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}tableIV2b.doc, merge   se starlevels(10 5 1) starloc(1)
reghdfe ed16plus               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)              , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}tableIV2b.doc, merge   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("TableB: effects on college completion unconditional on Education")



*TableC: IV effects on stem_maj conditional on ed16plus
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}tableIV2c.doc, replace se starlevels(10 5 1) starloc(1)
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}tableIV2c.doc, merge   se starlevels(10 5 1) starloc(1)
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}tableIV2c.doc, merge   se starlevels(10 5 1) starloc(1)
reghdfe stem_maj               lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}tableIV2c.doc, merge   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("TableC: effects on stem major conditional on college completion")



capture file close T2IV
file open T2IV using "${table_path}T2IV.tex", write replace
file write T2IV "\begin{table}[ht]" _n 
file write T2IV "\caption{Instrumental Variable Effects of Birth-State Foreign STEM Exposure on STEM Degree Completion}" _n 
file write T2IV "\label{tab:ivSTEMgradUncond}" _n 
file write T2IV "\centering" _n 
file write T2IV "\begin{threeparttable}" _n 
file write T2IV "\begin{tabular}{lcccc}" _n 
file write T2IV "\toprule " _n 
file write T2IV "       & Black           & Black        & White        & White       \\" _n 
file write T2IV "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T2IV "\midrule " _n 
file write T2IV "\multicolumn{5}{l}{\emph{Panel A: STEM graduation, unconditional of education level}}\\ " _n 
file write T2IV "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " & " %4.3f (`b1D') "`star1D'" " \\ "  _n 
file write T2IV                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") & (" %4.3f  (`se1D') ") \\ "  _n 
file write T2IV "Control mean"          " &  [" %4.3f (`mu1A') "] & [" %4.3f  (`mu2A') "] & [" %4.3f  (`mu3A')  "] & [" %4.3f  (`mu4A') "] \\ "  _n 
file write T2IV "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " & " %9.0gc  (`N1D') " \\ "  _n 
file write T2IV "&&&&\\"  _n
file write T2IV "\multicolumn{5}{l}{\emph{Panel B: BA graduation}}\\ " _n 
file write T2IV "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T2IV                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T2IV "Control mean"          " &  [" %4.3f (`mu1B') "] & [" %4.3f  (`mu2B') "] & [" %4.3f  (`mu3B')  "] & [" %4.3f  (`mu4B') "] \\ "  _n 
file write T2IV "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T2IV "&&&&\\"  _n
file write T2IV "\multicolumn{5}{l}{\emph{Panel C: STEM graduation, conditional on BA graduation}}\\ " _n 
file write T2IV "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T2IV                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T2IV "Control mean"          " &  [" %4.3f (`mu1C') "] & [" %4.3f  (`mu2C') "] & [" %4.3f  (`mu3C')  "] & [" %4.3f  (`mu4C') "] \\ "  _n 
file write T2IV "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T2IV "\bottomrule " _n 
file write T2IV "\end{tabular} " _n 
file write T2IV "\footnotesize Notes: Dependent variable is an indicator for either \emph{(a)} graduating in a STEM field, unconditional on education level; \emph{(b)} graduating with a bachelor's degree in any field; or \emph{(c)} graduating with a bachelor's degree in a STEM field. Each coefficient is estimated from a different linear probability model using two-stage least squares, where 1990-2000 foreign STEM growth is instrumented by 1980 foreign STEM exposure. *Statistically significant at the .10 level." _n 
file write T2IV "\end{threeparttable} " _n 
file write T2IV "\end{table} " _n 
file close T2IV



*Table: Effects on other majors for black males conditional on college completion
qui reg business   forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable5.doc, replace se starlevels(10 5 1) starloc(1)
qui reg education  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable5.doc, append   se starlevels(10 5 1) starloc(1)
qui reg health     forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable5.doc, append   se starlevels(10 5 1) starloc(1)
qui reg libarts    forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable5.doc, append   se starlevels(10 5 1) starloc(1)
qui reg socscience forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1E se1E star1E N1E)
est sto regE
* outreg using ${outreg_path}IStable5.doc, append   se starlevels(10 5 1) starloc(1)
qui reg othermajor forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1F se1F star1F N1F)
est sto regF
* outreg using ${outreg_path}IStable5.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD regE regF, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table: Effects on other majors for black males unconditional on education")


capture file close T3
file open T3 using "${table_path}T3.tex", write replace
file write T3 "\begin{landscape}" _n 
file write T3 "\begin{table}[ht]" _n 
file write T3 "\caption{Foreign STEM Exposure and Non-STEM Degree Completion for Black Men  }" _n 
file write T3 "\label{tab:STEMleave}" _n 
file write T3 "\centering" _n 
file write T3 "\begin{threeparttable}" _n 
file write T3 "\begin{tabular}{lcccccc}" _n 
file write T3 "\toprule " _n 
file write T3 "                            &                 &              &              & Liberal      & Social       & Other       \\" _n 
file write T3 "Effect                      & Business        & Education    & Health       & Arts         & Sciences     & Majors      \\" _n 
file write T3 "\midrule " _n 
file write T3 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " & " %4.3f (`b1D') "`star1D'" " & " %4.3f (`b1E') "`star1E'" " & " %4.3f (`b1F') "`star1F'" " \\ "  _n 
file write T3                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") & (" %4.3f  (`se1D') ") & (" %4.3f  (`se1E') ") & (" %4.3f  (`se1F') ") \\ "  _n 
file write T3 "Control mean"          " &  [" %4.3f (`mumb1B') "] & [" %4.3f  (`mumb2B') "] & [" %4.3f  (`mumb3B')  "] & [" %4.3f  (`mumb4B') "] & [" %4.3f  (`mumb5B') "] & [" %4.3f  (`mumb6B') "] \\ "  _n 
file write T3 "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " & " %9.0gc  (`N1D') " & " %9.0gc  (`N1E') " & " %9.0gc  (`N1F') " \\ "  _n 
file write T3 "\bottomrule " _n 
file write T3 "\end{tabular} " _n 
file write T3 "\footnotesize Notes: Dependent variable is an indicator for graduating with a given non-STEM major, conditional on college graduation. The mean of the dependent variable for the control group is reported in brackets. Note that the bracketed control-group means sum to 100\% across columns of Tables \ref{tab:STEMleave} and \ref{tab:STEMdetail} \emph{combined}. See notes in Table \ref{tab:STEMgradUncond} for further details." _n 
file write T3 "\end{threeparttable} " _n 
file write T3 "\end{table} " _n 
file close T3



*Table: Effects on specific STEM majors for black males conditional on college completion
qui reg computersci forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable6.doc, replace se starlevels(10 5 1) starloc(1)
qui reg engineering forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable6.doc, append   se starlevels(10 5 1) starloc(1)
qui reg technology  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable6.doc, append   se starlevels(10 5 1) starloc(1)
qui reg biosciences forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable6.doc, append   se starlevels(10 5 1) starloc(1)
qui reg physciences forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1E se1E star1E N1E)
est sto regE
* outreg using ${outreg_path}IStable6.doc, append   se starlevels(10 5 1) starloc(1)
qui reg maths       forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1F se1F star1F N1F)
est sto regF
* outreg using ${outreg_path}IStable6.doc, append   se starlevels(10 5 1) starloc(1)
qui reg allotherstem forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1G se1G star1G N1G)
est sto regG
* outreg using ${outreg_path}IStable6.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD regE regF regG, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table: Effects on specific STEM majors for black males unconditional on education")



capture file close T4
file open T4 using "${table_path}T4.tex", write replace
file write T4 "\begin{table}[ht]" _n 
file write T4 "\caption{Foreign STEM Exposure and STEM Degree Sub-fields for Black Men}" _n 
file write T4 "\label{tab:STEMdetail}" _n 
file write T4 "\centering" _n 
file write T4 "\begin{threeparttable}" _n 
file write T4 "\begin{tabular}{lccccccc}" _n 
file write T4 "\toprule " _n 
file write T4 "                            & Computer     &              &              & Biological   & Physical     &              & All Other   \\" _n 
file write T4 "Effect                      & Science      & Engineering  & Technology   & Sciences     & Sciences     & Mathematics  & STEM        \\" _n 
file write T4 "\midrule " _n 
file write T4 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " & " %4.3f (`b1D') "`star1D'" " & " %4.3f (`b1E') "`star1E'" " & " %4.3f (`b1F') "`star1F'" " & " %4.3f (`b1G') "`star1G'" " \\ "  _n 
file write T4                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") & (" %4.3f  (`se1D') ") & (" %4.3f  (`se1E') ") & (" %4.3f  (`se1F') ") & (" %4.3f  (`se1G') ") \\ "  _n 
file write T4 "Control mean"          " &  [" %4.3f (`mumb1A') "] & [" %4.3f  (`mumb2A') "] & [" %4.3f  (`mumb3A')  "] & [" %4.3f  (`mumb4A') "] & [" %4.3f  (`mumb5A') "] & [" %4.3f  (`mumb6A') "] & [" %4.3f  (`mumb7A') "] \\ "  _n 
file write T4 "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " & " %9.0gc  (`N1D') " & " %9.0gc  (`N1E') " & " %9.0gc  (`N1F') " & " %9.0gc  (`N1G') " \\ "  _n 
file write T4 "\bottomrule " _n 
file write T4 "\end{tabular} " _n 
file write T4 "\footnotesize Notes: Dependent variable is an indicator for graduating with a given STEM major, conditional on college graduation. The sum of the coefficients in this table equals the coefficient reported in the first column of Table \ref{tab:STEMgradUncond} Panel C. See notes in Table \ref{tab:STEMgradUncond} for further details. ***Statistically significant at the .01 level." _n 
file write T4 "\end{threeparttable} " _n 
file write T4 "\end{table} " _n 
file write T4 "\end{landscape}" _n 
file close T4


*Table: effects on stemocc 
*a) unconditional on ed16plus
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable8.doc, replace se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table a: Effects on STEM occupation")
*b) conditional on ed16plus==1
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table b: Effects on STEM occupation conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table c: Effects on STEM occupation conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable8.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table d: Effects on STEM occupation conditional on Non-STEM college completion")



capture file close T6
file open T6 using "${table_path}T6.tex", write replace
file write T6 "\begin{table}[ht]" _n 
file write T6 "\caption{Birth-State Foreign STEM Exposure and Recently Holding a STEM Occupation}" _n 
file write T6 "\label{tab:STEMoccAll}" _n 
file write T6 "\centering" _n 
file write T6 "\begin{threeparttable}" _n 
file write T6 "\begin{tabular}{lcccc}" _n 
file write T6 "\toprule " _n 
file write T6 "       & Black           & Black        & White        & White       \\" _n 
file write T6 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T6 "\midrule " _n 
file write T6 "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T6 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T6                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T6 "Control mean"          " &  [" %4.3f (`mu1b1') "] & [" %4.3f  (`mu2b1') "] & [" %4.3f  (`mu3b1')  "] & [" %4.3f  (`mu4b1') "] \\ "  _n 
file write T6 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T6 "&&&&\\"  _n
file write T6 "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T6 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T6                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T6 "Control mean"          " &  [" %4.3f (`mu1c1') "] & [" %4.3f  (`mu2c1') "] & [" %4.3f  (`mu3c1')  "] & [" %4.3f  (`mu4c1') "] \\ "  _n 
file write T6 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T6 "&&&&\\"  _n
file write T6 "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T6 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T6                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T6 "Control mean"          " &  [" %4.3f (`mu1d1') "] & [" %4.3f  (`mu2d1') "] & [" %4.3f  (`mu3d1')  "] & [" %4.3f  (`mu4d1') "] \\ "  _n 
file write T6 "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T6 "\bottomrule " _n 
file write T6 "\end{tabular} " _n 
file write T6 "\footnotesize Notes: Dependent variable is an indicator for recently holding a STEM occupation, conditional on various educational outcomes.  Compare with Table \ref{tab:STEMoccEmpAll}. **Statistically significant at the .05 level; *** at the .01 level." _n 
file write T6 "\end{threeparttable} " _n 
file write T6 "\end{table} " _n 
file close T6





*Table: effects on current employment in stemocc 
*a) unconditional on ed16plus
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table a: Effects on current STEM employment")
*b) conditional on ed16plus==1
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table b: Effects on current STEM employment, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table c: Effects on current STEM employment, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table d: Effects on current STEM employment, conditional on Non-STEM college completion")


capture file close T7
file open T7 using "${table_path}T7.tex", write replace
file write T7 "\begin{table}[ht]" _n 
file write T7 "\caption{Birth-State Foreign STEM Exposure and Current Employment in a STEM Occupation}" _n 
file write T7 "\label{tab:STEMoccEmpAll}" _n 
file write T7 "\centering" _n 
file write T7 "\begin{threeparttable}" _n 
file write T7 "\begin{tabular}{lcccc}" _n 
file write T7 "\toprule " _n 
file write T7 "       & Black           & Black        & White        & White       \\" _n 
file write T7 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T7 "\midrule " _n 
file write T7 "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T7 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T7                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T7 "Control mean"          " &  [" %4.3f (`mu1b2') "] & [" %4.3f  (`mu2b2') "] & [" %4.3f  (`mu3b2')  "] & [" %4.3f  (`mu4b2') "] \\ "  _n 
file write T7 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T7 "&&&&\\"  _n
file write T7 "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T7 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T7                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T7 "Control mean"          " &  [" %4.3f (`mu1c2') "] & [" %4.3f  (`mu2c2') "] & [" %4.3f  (`mu3c2')  "] & [" %4.3f  (`mu4c2') "] \\ "  _n 
file write T7 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T7 "&&&&\\"  _n
file write T7 "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T7 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T7                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T7 "Control mean"          " &  [" %4.3f (`mu1d2') "] & [" %4.3f  (`mu2d2') "] & [" %4.3f  (`mu3d2')  "] & [" %4.3f  (`mu4d2') "] \\ "  _n 
file write T7 "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T7 "\bottomrule " _n 
file write T7 "\end{tabular} " _n 
file write T7 "\footnotesize Notes: Dependent variable is an indicator for current employment in a STEM occupation, conditional on various educational outcomes.  See notes in Table \ref{tab:STEMgradUncond} for further details. **Statistically significant at the .05 level; *** at the .01 level." _n 
file write T7 "\end{threeparttable} " _n 
file write T7 "\end{table} " _n 
file close T7



*TableIV: IV effects on current employment in stemocc 
*a) unconditional on ed16plus
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, replace se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table a: Effects on current STEM employment")
*b) conditional on ed16plus==1
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table b: Effects on current STEM employment, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table c: Effects on current STEM employment, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable9.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table d: Effects on current STEM employment, conditional on Non-STEM college completion")




capture file close T7IV
file open T7IV using "${table_path}T7IV.tex", write replace
file write T7IV "\begin{table}[ht]" _n 
file write T7IV "\caption{IV Effects of Birth-State Foreign STEM Exposure on Current Employment in a STEM Occupation}" _n 
file write T7IV "\label{tab:ivSTEMoccEmpAll}" _n 
file write T7IV "\centering" _n 
file write T7IV "\begin{threeparttable}" _n 
file write T7IV "\begin{tabular}{lcccc}" _n 
file write T7IV "\toprule " _n 
file write T7IV "       & Black           & Black        & White        & White       \\" _n 
file write T7IV "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T7IV "\midrule " _n 
file write T7IV "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T7IV "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T7IV                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T7IV "Control mean"          " &  [" %4.3f (`mu1b2') "] & [" %4.3f  (`mu2b2') "] & [" %4.3f  (`mu3b2')  "] & [" %4.3f  (`mu4b2') "] \\ "  _n 
file write T7IV "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T7IV "&&&&\\"  _n
file write T7IV "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T7IV "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T7IV                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T7IV "Control mean"          " &  [" %4.3f (`mu1c2') "] & [" %4.3f  (`mu2c2') "] & [" %4.3f  (`mu3c2')  "] & [" %4.3f  (`mu4c2') "] \\ "  _n 
file write T7IV "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T7IV "&&&&\\"  _n
file write T7IV "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T7IV "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T7IV                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T7IV "Control mean"          " &  [" %4.3f (`mu1d2') "] & [" %4.3f  (`mu2d2') "] & [" %4.3f  (`mu3d2')  "] & [" %4.3f  (`mu4d2') "] \\ "  _n 
file write T7IV "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T7IV "\bottomrule " _n 
file write T7IV "\end{tabular} " _n 
file write T7IV "\footnotesize Notes: Dependent variable is an indicator for current employment in a STEM occupation, conditional on various educational outcomes.  See notes in Tables \ref{tab:STEMgradUncond} and \ref{tab:STEMoccEmpAll} for further details. *Statistically significant at the .10 level; *** at the .01 level." _n 
file write T7IV "\end{threeparttable} " _n 
file write T7IV "\end{table} " _n 
file close T7IV




*Table: cross-sectional comparisons
*separate cross-sections regressions by pre- and post-90 periods
*pre-90
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
*post-90
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1E se1E star1E N1E)
est sto regE
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1F se1F star1F N1F)
est sto regF
est table regA regB regC regD regE regF, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559) title("TableXa: Cross-sectional Effects on treatment and control groups")



capture file close TXa
file open TXa using "${table_path}TXa.tex", write replace
file write TXa "\begin{table}[ht]" _n 
file write TXa "\caption{Separate Cross-Section Regressions for Pre- and Post-1990 Cohorts}" _n 
file write TXa "\label{tab:xsSmall}" _n 
file write TXa "\centering" _n 
file write TXa "\begin{threeparttable}" _n 
file write TXa "\begin{tabular}{lccc}" _n 
file write TXa "\toprule " _n 
file write TXa "       & Black           & White        & White       \\" _n 
file write TXa "       & Male            & Male         & Female      \\" _n 
file write TXa "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TXa "\midrule " _n 
file write TXa "\multicolumn{4}{l}{\emph{Panel A: 1986--1989 Cohorts}}\\ " _n 
file write TXa "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TXa                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") \\ "  _n 
file write TXa "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TXa "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " \\ "  _n 
file write TXa "&&&\\"  _n
file write TXa "\multicolumn{4}{l}{\emph{Panel B: 1991--1994 Cohorts}}\\ " _n 
file write TXa "Foreign STEM Exposure" " & " %4.3f (`b1D') "`star1D'" " & " %4.3f (`b1E') "`star1E'" " & " %4.3f (`b1F') "`star1F'" " \\ "  _n 
file write TXa                         " &  (" %4.3f (`se1D') ") & (" %4.3f  (`se1E') ") & (" %4.3f  (`se1F')  ") \\ "  _n 
file write TXa "Control mean"          " &  [" %4.3f (`nu1C') "]        & [" %4.3f  (`nu3c2') "]       & [" %4.3f  (`nu4c4')  "] \\ "  _n 
file write TXa "\emph{N}"              " &  " %9.0gc (`N1D') " & " %9.0gc  (`N1E') " & " %9.0gc  (`N1F')  " \\ "  _n 
file write TXa "\bottomrule " _n 
file write TXa "\end{tabular} " _n 
file write TXa "\footnotesize Notes: This table presents cross-sectional versions of our main estimates, separately for pre- and post-1990 cohorts. To enable identification of the foreign exposure measure for each group, we drop the state fixed effects and state time trends from the model. Table \ref{tab:xsLarge} reports a broader set of results from this same specification. *Statistically significant at the .10 level; *** at the .01 level." _n 
file write TXa "\end{threeparttable} " _n 
file write TXa "\end{table} " _n 
file close TXa





*Table_large (Detailed Versions)
*2a STEM Majors
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1E se1E star1E N1E)
est sto regE
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1F se1F star1F N1F)
est sto regF
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1G se1G star1G N1G)
est sto regG
reg stem_maj     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1  , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1H se1H star1H N1H)
est sto regH
est table regA regB regC regD regE regF regG regH, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559) title("TableXb1: Cross-sectional Effects on treatment and control groups")


*2b emp_stemocc
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2E se2E star2E N2E)
est sto regE
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2F se2F star2F N2F)
est sto regF
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2G se2G star2G N2G)
est sto regG
reg emp_stemocc  forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2H se2H star2H N2H)
est sto regH
est table regA regB regC regD regE regF regG regH, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559) title("TableXb2: Cross-sectional Effects on treatment and control groups")


*2c workedly
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3E se3E star3E N3E)
est sto regE
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3F se3F star3F N3F)
est sto regF
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3G se3G star3G N3G)
est sto regG
reg workedly     forshr_16pl_stemo_80_2559   lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3H se3H star3H N3H)
est sto regH
est table regA regB regC regD regE regF regG regH, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559) title("TableXb3: Cross-sectional Effects on treatment and control groups")




capture file close TXb
file open TXb using "${table_path}TXb.tex", write replace
file write TXb "\begin{table}[ht]" _n 
file write TXb "\caption{Separate Cross-Section Regressions for Pre- and Post-1990 Cohorts}" _n 
file write TXb "\label{tab:xsLarge}" _n 
file write TXb "\centering" _n 
file write TXb "\begin{threeparttable}" _n 
file write TXb "\begin{tabular}{lcccc}" _n 
file write TXb "\toprule " _n 
file write TXb "       & Black           & Black        & White        & White       \\" _n 
file write TXb "Effect & Men             & Women        & Men          & Women       \\" _n 
file write TXb "\midrule " _n 
file write TXb "\multicolumn{5}{l}{\emph{Panel A: STEM Major, 1986--1989 Cohorts}}\\ " _n 
file write TXb "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " & " %4.3f (`b1D') "`star1D'" " \\ "  _n 
file write TXb                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") & (" %4.3f  (`se1D') ") \\ "  _n 
file write TXb "Control mean"          " &  [" %4.3f (`mu1C') "] & [" %4.3f  (`mu2C') "] & [" %4.3f  (`mu3C')  "] & [" %4.3f  (`mu4C') "] \\ "  _n 
file write TXb "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " & " %9.0gc  (`N1D') " \\ "  _n 
file write TXb "&&&&\\"  _n
file write TXb "\multicolumn{5}{l}{\emph{Panel B: STEM Major, 1991--1994 Cohorts}}\\ " _n 
file write TXb "Foreign STEM Exposure" " & " %4.3f (`b1E') "`star1E'" " & " %4.3f (`b1F') "`star1F'" " & " %4.3f (`b1G') "`star1G'" " & " %4.3f (`b1H') "`star1H'" " \\ "  _n 
file write TXb                         " &  (" %4.3f (`se1E') ") & (" %4.3f  (`se1F') ") & (" %4.3f  (`se1G')  ") & (" %4.3f  (`se1H') ") \\ "  _n 
file write TXb "Control mean"          " &  [" %4.3f (`nu1C') "] & [" %4.3f  (`nu2C') "] & [" %4.3f  (`nu3C')  "] & [" %4.3f  (`nu4C') "] \\ "  _n 
file write TXb "\emph{N}"              " &  " %9.0gc (`N1E') " & " %9.0gc  (`N1F') " & " %9.0gc  (`N1G')  " & " %9.0gc  (`N1H') " \\ "  _n 
file write TXb "&&&&\\"  _n
file write TXb "\multicolumn{5}{l}{\emph{Panel C: STEM Occupation given STEM BA, 1986--1989 Cohorts}}\\ " _n 
file write TXb "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write TXb                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write TXb "Control mean"          " &  [" %4.3f (`mu1c2') "] & [" %4.3f  (`mu2c2') "] & [" %4.3f  (`mu3c2')  "] & [" %4.3f  (`mu4c2') "] \\ "  _n 
file write TXb "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write TXb "&&&&\\"  _n
file write TXb "\multicolumn{5}{l}{\emph{Panel D: STEM Occupation given STEM BA, 1991--1994 Cohorts}}\\ " _n 
file write TXb "Foreign STEM Exposure" " & " %4.3f (`b2E') "`star2E'" " & " %4.3f (`b2F') "`star2F'" " & " %4.3f (`b2G') "`star2G'" " & " %4.3f (`b2H') "`star2H'" " \\ "  _n 
file write TXb                         " &  (" %4.3f (`se2E') ") & (" %4.3f  (`se2F') ") & (" %4.3f  (`se2G')  ") & (" %4.3f  (`se2H') ") \\ "  _n 
file write TXb "Control mean"          " &  [" %4.3f (`nu1c2') "] & [" %4.3f  (`nu2c2') "] & [" %4.3f  (`nu3c2')  "] & [" %4.3f  (`nu4c2') "] \\ "  _n 
file write TXb "\emph{N}"              " &  " %9.0gc (`N2E') " & " %9.0gc  (`N2F') " & " %9.0gc  (`N2G')  " & " %9.0gc  (`N2H') " \\ "  _n 
file write TXb "&&&&\\"  _n
file write TXb "\multicolumn{5}{l}{\emph{Panel E: Worked Last Year given STEM BA, 1986--1989 Cohorts}}\\ " _n 
file write TXb "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write TXb                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write TXb "Control mean"          " &  [" %4.3f (`mu1c4') "] & [" %4.3f  (`mu2c4') "] & [" %4.3f  (`mu3c4')  "] & [" %4.3f  (`mu4c4') "] \\ "  _n 
file write TXb "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write TXb "&&&&\\"  _n
file write TXb "\multicolumn{5}{l}{\emph{Panel F: Worked Last Year given STEM BA, 1991--1994 Cohorts}}\\ " _n 
file write TXb "Foreign STEM Exposure" " & " %4.3f (`b3E') "`star3E'" " & " %4.3f (`b3F') "`star3F'" " & " %4.3f (`b3G') "`star3G'" " & " %4.3f (`b3H') "`star3H'" " \\ "  _n 
file write TXb                         " &  (" %4.3f (`se3E') ") & (" %4.3f  (`se3F') ") & (" %4.3f  (`se3G')  ") & (" %4.3f  (`se3H') ") \\ "  _n 
file write TXb "Control mean"          " &  [" %4.3f (`nu1c4') "] & [" %4.3f  (`nu2c4') "] & [" %4.3f  (`nu3c4')  "] & [" %4.3f  (`nu4c4') "] \\ "  _n 
file write TXb "\emph{N}"              " &  " %9.0gc (`N3E') " & " %9.0gc  (`N3F') " & " %9.0gc  (`N3G')  " & " %9.0gc  (`N3H') " \\ "  _n 
file write TXb "\bottomrule " _n 
file write TXb "\end{tabular} " _n 
file write TXb "\footnotesize Notes: This table is a more detailed version of Table \ref{tab:xsSmall}. See Table \ref{tab:xsSmall} for further details. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TXb "\end{threeparttable} " _n 
file write TXb "\end{table} " _n 
file close TXb




*Table: effects on current employment probability
*a) unconditional on ed16plus
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable10.doc, replace se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table0a: Effects on current employment probability")
*b) conditional on ed16plus==1
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table0b: Effects on current employment probability, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table0c: Effects on current employment probability, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
qui reg employed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable10.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table0d: Effects on current employment probability, conditional on Non-STEM college completion")





capture file close T8
file open T8 using "${table_path}T8.tex", write replace
file write T8 "\begin{table}[ht]" _n 
file write T8 "\caption{Birth-State Foreign STEM Exposure and Current Employment Probability}" _n 
file write T8 "\label{tab:empProb}" _n 
file write T8 "\centering" _n 
file write T8 "\begin{threeparttable}" _n 
file write T8 "\begin{tabular}{lcccc}" _n 
file write T8 "\toprule " _n 
file write T8 "       & Black           & Black        & White        & White       \\" _n 
file write T8 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T8 "\midrule " _n 
file write T8 "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T8 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T8                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T8 "Control mean"          " &  [" %4.3f (`mu1b3') "] & [" %4.3f  (`mu2b3') "] & [" %4.3f  (`mu3b3')  "] & [" %4.3f  (`mu4b3') "] \\ "  _n 
file write T8 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T8 "&&&&\\"  _n
file write T8 "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T8 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T8                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T8 "Control mean"          " &  [" %4.3f (`mu1c3') "] & [" %4.3f  (`mu2c3') "] & [" %4.3f  (`mu3c3')  "] & [" %4.3f  (`mu4c3') "] \\ "  _n 
file write T8 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T8 "&&&&\\"  _n
file write T8 "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T8 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T8                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T8 "Control mean"          " &  [" %4.3f (`mu1d3') "] & [" %4.3f  (`mu2d3') "] & [" %4.3f  (`mu3d3')  "] & [" %4.3f  (`mu4d3') "] \\ "  _n 
file write T8 "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T8 "\bottomrule " _n 
file write T8 "\end{tabular} " _n 
file write T8 "\footnotesize Notes: Dependent variable is an indicator for being currently employed, conditional on various educational outcomes.  Compare with Table \ref{tab:ProbLY}." _n 
file write T8 "\end{threeparttable} " _n 
file write T8 "\end{table} " _n 
file close T8



*Table: effects on prior year employment probability
*a) unconditional on ed16plus
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable11.doc, replace se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table a: Effects on prior year employment probability")
*b) conditional on ed16plus==1
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table b: Effects on prior year employment probability, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table c: Effects on prior year employment probability, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table d: Effects on prior year employment probability, conditional on Non-STEM college completion")





capture file close T9
file open T9 using "${table_path}T9.tex", write replace
file write T9 "\begin{table}[ht]" _n 
file write T9 "\caption{Birth-State Foreign STEM Exposure and Prior Year Employment Probability}" _n 
file write T9 "\label{tab:ProbLY}" _n 
file write T9 "\centering" _n 
file write T9 "\begin{threeparttable}" _n 
file write T9 "\begin{tabular}{lcccc}" _n 
file write T9 "\toprule " _n 
file write T9 "       & Black           & Black        & White        & White       \\" _n 
file write T9 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T9 "\midrule " _n 
file write T9 "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T9 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T9                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T9 "Control mean"          " &  [" %4.3f (`mu1b4') "] & [" %4.3f  (`mu2b4') "] & [" %4.3f  (`mu3b4')  "] & [" %4.3f  (`mu4b4') "] \\ "  _n 
file write T9 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T9 "&&&&\\"  _n
file write T9 "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T9 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T9                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T9 "Control mean"          " &  [" %4.3f (`mu1c4') "] & [" %4.3f  (`mu2c4') "] & [" %4.3f  (`mu3c4')  "] & [" %4.3f  (`mu4c4') "] \\ "  _n 
file write T9 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T9 "&&&&\\"  _n
file write T9 "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T9 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T9                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T9 "Control mean"          " &  [" %4.3f (`mu1d4') "] & [" %4.3f  (`mu2d4') "] & [" %4.3f  (`mu3d4')  "] & [" %4.3f  (`mu4d4') "] \\ "  _n 
file write T9 "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T9 "\bottomrule " _n 
file write T9 "\end{tabular} " _n 
file write T9 "\footnotesize Notes: Dependent variable is an indicator for being employed in the prior year, conditional on various educational outcomes.  See notes in Table \ref{tab:STEMgradUncond} for further details. **Statistically significant at the .05 level; *** at the .01 level." _n 
file write T9 "\end{threeparttable} " _n 
file write T9 "\end{table} " _n 
file close T9


*TableIV: effects on prior year employment probability
*a) unconditional on ed16plus
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto reghdfeA
* outreghdfe using ${outreghdfe_path}IStable11.doc, replace se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto reghdfeB
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto reghdfeC
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto reghdfeD
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table reghdfeA reghdfeB reghdfeC reghdfeD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table a: Effects on prior year employment probability")
*b) conditional on ed16plus==1
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto reghdfeA
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto reghdfeB
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto reghdfeC
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto reghdfeD
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table reghdfeA reghdfeB reghdfeC reghdfeD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table b: Effects on prior year employment probability, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto reghdfeA
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto reghdfeB
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto reghdfeC
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto reghdfeD
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table reghdfeA reghdfeB reghdfeC reghdfeD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table c: Effects on prior year employment probability, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto reghdfeA
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto reghdfeB
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto reghdfeC
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
reghdfe workedly lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (forshr_16pl_stemo_00_90_2559_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, vce(cluster bpl) absorb(bpl##c.yearage18)
first_coef_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto reghdfeD
* outreghdfe using ${outreghdfe_path}IStable11.doc, append   se starlevels(10 5 1) starloc(1)
est table reghdfeA reghdfeB reghdfeC reghdfeD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_00_90_2559_p91) title("Table d: Effects on prior year employment probability, conditional on Non-STEM college completion")





capture file close T9IV
file open T9IV using "${table_path}T9IV.tex", write replace
file write T9IV "\begin{table}[ht]" _n 
file write T9IV "\caption{IV Effects of Birth-State Foreign STEM Exposure on Prior Year Employment Probability}" _n 
file write T9IV "\label{tab:ivProbLY}" _n 
file write T9IV "\centering" _n 
file write T9IV "\begin{threeparttable}" _n 
file write T9IV "\begin{tabular}{lcccc}" _n 
file write T9IV "\toprule " _n 
file write T9IV "       & Black           & Black        & White        & White       \\" _n 
file write T9IV "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T9IV "\midrule " _n 
file write T9IV "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T9IV "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T9IV                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T9IV "Control mean"          " &  [" %4.3f (`mu1b4') "] & [" %4.3f  (`mu2b4') "] & [" %4.3f  (`mu3b4')  "] & [" %4.3f  (`mu4b4') "] \\ "  _n 
file write T9IV "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T9IV "&&&&\\"  _n
file write T9IV "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T9IV "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T9IV                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T9IV "Control mean"          " &  [" %4.3f (`mu1c4') "] & [" %4.3f  (`mu2c4') "] & [" %4.3f  (`mu3c4')  "] & [" %4.3f  (`mu4c4') "] \\ "  _n 
file write T9IV "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T9IV "&&&&\\"  _n
file write T9IV "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T9IV "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T9IV                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T9IV "Control mean"          " &  [" %4.3f (`mu1d4') "] & [" %4.3f  (`mu2d4') "] & [" %4.3f  (`mu3d4')  "] & [" %4.3f  (`mu4d4') "] \\ "  _n 
file write T9IV "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T9IV "\bottomrule " _n 
file write T9IV "\end{tabular} " _n 
file write T9IV "\footnotesize Notes: Dependent variable is an indicator for being employed in the prior year, conditional on various educational outcomes.  See notes in Tables \ref{tab:STEMgradUncond} and \ref{tab:ProbLY} for further details. ** Statistically significant at the .05 level; *** at the .01 level." _n 
file write T9IV "\end{threeparttable} " _n 
file write T9IV "\end{table} " _n 
file close T9IV


*Table allIV: IV details for three main effects
clonevar fs_stem_00_90_p91 = forshr_16pl_stemo_00_90_2559_p91
*a) Black men
reghdfe stem_maj    lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (fs_stem_00_90_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1              , vce(cluster bpl) absorb(bpl##c.yearage18) stage(first)
all_coefs_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1A se1A star1A N1A bf1A sef1A starf1A Fstat1A)
*b) White men
reghdfe emp_stemocc lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (fs_stem_00_90_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18) stage(first)
all_coefs_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1B se1B star1B N1B bf1B sef1B starf1B Fstat1B)
*c) White women
reghdfe workedly    lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*  (fs_stem_00_90_p91 = forshr_16pl_stemo_80_2559_p91)  [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, vce(cluster bpl) absorb(bpl##c.yearage18) stage(first)
all_coefs_2SLS, in1(`e(endogvars)') in2(`e(N)') out(b1C se1C star1C N1C bf1C sef1C starf1C Fstat1C)



capture file close TallIV
file open TallIV using "${table_path}TallIV.tex", write replace
file write TallIV "\begin{table}[ht]" _n 
file write TallIV "\caption{Instrumental Variable Estimates for Main Findings}" _n 
file write TallIV "\label{tab:tallIV}" _n 
file write TallIV "\centering" _n 
file write TallIV "\begin{threeparttable}" _n 
file write TallIV "\begin{tabular}{lccc}" _n 
file write TallIV "\toprule " _n 
file write TallIV "       & Black           & White        & White       \\" _n 
file write TallIV "       & Male            & Male         & Female      \\" _n 
file write TallIV "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TallIV "\midrule " _n 
file write TallIV "\multicolumn{4}{l}{\emph{Panel A: First-Stage Results}}\\ " _n 
file write TallIV "1980 Foreign STEM Exposure"      " & " %4.3f (`bf1A') "`starf1A'" " & " %4.3f (`bf1B') "`starf1B'" " & " %4.3f (`bf1C') "`starf1C'" " \\ "  _n 
file write TallIV                            "      &  (" %4.3f (`sef1A') ")        & (" %4.3f  (`sef1B') ")        & (" %4.3f  (`sef1C') ") \\ "  _n 
file write TallIV "\midrule " _n 
file write TallIV "\emph{F}-statistic"       "      &  " %7.3f (`Fstat1A') "          & " %7.3f  (`Fstat1B') "          & " %7.3f  (`Fstat1C') " \\ "  _n 
file write TallIV "Stock-Yogo critical value for    &                              &                              &\\"  _n
file write TallIV "10\% maximal IV size             &  16.38        & 16.38        & 16.38 \\ "  _n 
file write TallIV "\midrule " _n 
file write TallIV "                         &                              &                              &\\"  _n
file write TallIV "\multicolumn{4}{l}{\emph{Panel B: Second-Stage Results}}\\ " _n 
file write TallIV "2000--1990 Change in Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TallIV                                          " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TallIV "Control mean"                           " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TallIV "\emph{N}"                               " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TallIV "\bottomrule " _n 
file write TallIV "\end{tabular} " _n 
file write TallIV "\footnotesize Notes: The second-stage explanatory variable is the predicted 1990-2000 change in the foreign STEM share, and the instrument is the 1980 foreign STEM share, both interacted with the post-1990 dummy. The unconditional relationship for the first-stage is illustrated in Figure \ref{fig:scatterplot}. The dependent variables and control variables are the same as Table \ref{tab:STEMgradUncond} Panel C for black men, Table \ref{tab:STEMoccEmpAll} Panel B for white men, and Table \ref{tab:ProbLY} Panel B for white women. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TallIV "\end{threeparttable} " _n 
file write TallIV "\end{table} " _n 
file close TallIV


*Table: effects on log earnings in previous year
*a) unconditional on ed16plus
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable12.doc, replace se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table a: Effects on log earnings in previous year")
*b) conditional on ed16plus==1
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table b: Effects on log earnings in previous year, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table c: Effects on log earnings in previous year, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
qui reg lincearn forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable12.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table d: Effects on log earnings in previous year, conditional on Non-STEM college completion")





capture file close T10
file open T10 using "${table_path}T10.tex", write replace
file write T10 "\begin{table}[ht]" _n 
file write T10 "\caption{Birth-State Foreign STEM Exposure and Log Earnings}" _n 
file write T10 "\label{tab:logEarnings}" _n 
file write T10 "\centering" _n 
file write T10 "\begin{threeparttable}" _n 
file write T10 "\begin{tabular}{lcccc}" _n 
file write T10 "\toprule " _n 
file write T10 "       & Black           & Black        & White        & White       \\" _n 
file write T10 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write T10 "\midrule " _n 
file write T10 "\multicolumn{5}{l}{\emph{Panel A: Conditional on college graduation in any field}}\\ " _n 
file write T10 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write T10                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write T10  "Control mean"         " &  [" %4.3f (`mu1b5') "] & [" %4.3f  (`mu2b5') "] & [" %4.3f  (`mu3b5')  "] & [" %4.3f  (`mu4b5') "] \\ "  _n 
file write T10 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write T10 "&&&&\\"  _n
file write T10 "\multicolumn{5}{l}{\emph{Panel B: Conditional on college graduation in a STEM field}}\\ " _n 
file write T10 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write T10                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write T10  "Control mean"         " &  [" %4.3f (`mu1c5') "] & [" %4.3f  (`mu2c5') "] & [" %4.3f  (`mu3c5')  "] & [" %4.3f  (`mu4c5') "] \\ "  _n 
file write T10 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write T10 "&&&&\\"  _n
file write T10 "\multicolumn{5}{l}{\emph{Panel C: Conditional on college graduation in a non-STEM field}}\\ " _n 
file write T10 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write T10                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write T10  "Control mean"         " &  [" %4.3f (`mu1d5') "] & [" %4.3f  (`mu2d5') "] & [" %4.3f  (`mu3d5')  "] & [" %4.3f  (`mu4d5') "] \\ "  _n 
file write T10 "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write T10 "\bottomrule " _n 
file write T10 "\end{tabular} " _n 
file write T10 "\footnotesize Notes: Dependent variable is the log of total earned income from the year prior to the survey, conditional on various educational outcomes. See notes in Table \ref{tab:STEMgradUncond} for further details." _n 
file write T10 "\end{threeparttable} " _n 
file write T10 "\end{table} " _n 
file close T10


*Sensitivity Analysis for Main Results Begins Here



*Table S0: Removing state trends
*a) Baseline result
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS1.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S0a: Baseline result")
*b) No state trends
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S0b: No state trends")
est table regA regB regC, b(%9.6f) se(%9.6f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S0b: No state trends (more decimals)")
*c) Model selection of state trends
pdslasso stem_maj    forshr_16pl_stemo_80_2559_p91 (lnpop18 unemprate_styr lnmedhhinc18 stdum* yeardum* agedum* yearbirthdum* `statetrends' `statetrends2') [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl) post(pds) partial(stdum* lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*) rlasso lopt(lalt tolopt(1e-5) tolups(1e-6) maxupsiter(500))
di  _b["forshr_16pl_stemo_80_2559_p91"]
local btemp  =  _b["forshr_16pl_stemo_80_2559_p91"]
di _se["forshr_16pl_stemo_80_2559_p91"]
local setemp = _se["forshr_16pl_stemo_80_2559_p91"]
first_coef, in1("regress stem_maj forshr_16pl_stemo_80_2559_p91") in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA

pdslasso emp_stemocc forshr_16pl_stemo_80_2559_p91 (lnpop18 unemprate_styr lnmedhhinc18 stdum* yeardum* agedum* yearbirthdum* `statetrends' `statetrends2')  [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl) post(pds) partial(stdum* lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*) rlasso lopt(lalt tolopt(1e-5) tolups(1e-6) maxupsiter(500))
di  _b["forshr_16pl_stemo_80_2559_p91"]
di _se["forshr_16pl_stemo_80_2559_p91"]
first_coef, in1("regress emp_stemocc forshr_16pl_stemo_80_2559_p91") in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB

pdslasso workedly    forshr_16pl_stemo_80_2559_p91 (lnpop18 unemprate_styr lnmedhhinc18 stdum* yeardum* agedum* yearbirthdum* `statetrends' `statetrends2') [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl) post(pds) partial(stdum* lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*) rlasso lopt(lalt tolopt(1e-5) tolups(1e-6) maxupsiter(500))
di  _b["forshr_16pl_stemo_80_2559_p91"]
di _se["forshr_16pl_stemo_80_2559_p91"]
first_coef, in1("regress workedly forshr_16pl_stemo_80_2559_p91") in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S0b: Model select linear, quadratic state trends")

capture file close TA0
file open TA0 using "${table_path}TA0.tex", write replace
file write TA0 "\begin{table}[ht]" _n 
file write TA0 "\caption{Remove time trends}" _n 
file write TA0 "\label{tab:ta0}" _n 
file write TA0 "\centering" _n 
file write TA0 "\begin{threeparttable}" _n 
file write TA0 "\begin{tabular}{lccc}" _n 
file write TA0 "\toprule " _n 
file write TA0 "       & Black           & White        & White       \\" _n 
file write TA0 "       & Male            & Male         & Female      \\" _n 
file write TA0 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA0 "\midrule " _n 
file write TA0 "\multicolumn{4}{l}{\emph{Panel A: Baseline result}}\\ " _n 
file write TA0 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TA0                         " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TA0 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA0 "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA0 "                         &                              &                              &\\"  _n
file write TA0 "\multicolumn{4}{l}{\emph{Panel B: No state trends}}\\ " _n 
file write TA0 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " \\ "  _n 
file write TA0                         " &  (" %4.3f (`se2A') ")        & (" %4.3f  (`se2B') ")        & (" %4.3f  (`se2C') ") \\ "  _n 
file write TA0 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA0 "\emph{N}"              " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA0 "                         &                              &                              &\\"  _n
file write TA0 "\multicolumn{4}{l}{\emph{Panel C: Model selection of linear \& quadratic state trends}}\\ " _n 
file write TA0 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " \\ "  _n 
file write TA0                         " &  (" %4.3f (`se3A') ")        & (" %4.3f  (`se3B') ")        & (" %4.3f  (`se3C') ") \\ "  _n 
file write TA0 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA0 "\emph{N}"              " &  " %9.0gc (`N3A') "          & " %9.0gc  (`N3B') "          & " %9.0gc  (`N3C') " \\ "  _n 
file write TA0 "\bottomrule " _n 
file write TA0 "\end{tabular} " _n 
file write TA0 "\footnotesize Notes: Panel A reproduces the estimates from column 1 of Table \ref{tab:STEMgradUncond} Panel C, the column 3 of Table \ref{tab:STEMoccEmpAll} Panel B, and the column 4 of Table \ref{tab:ProbLY} Panel B. Panel B presents estimates without state trends. Panels C and D presents estimates using the model selection method of \citet{belloni_al2014} and implementation by \citet{pdslasso18}, where the model selects among linear and quadratic state trends. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA0 "\end{threeparttable} " _n 
file write TA0 "\end{table} " _n 
file close TA0


*Table S1: Increasing number of pre- and post-IA90 cohorts
*a) five years before and after
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1985,1995) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS1.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1985,1995) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1985,1995) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S1a: Increase band to +/- 5 years")
*b) six years before and after
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1984,1996) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1984,1996) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1984,1996) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S1b: Increase band to +/- 6 years")
*c) five years before including 1990 and four years after
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994)                           & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994)                           & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994)                           & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStableS1.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S1c: five years before (including 1990) and four years after")


qui sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1985,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu5bm  = `r(mean)'
qui sum emp_stemocc [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1985,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu5wm  = `r(mean)'
qui sum workedly [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1985,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu5wf  = `r(mean)'
qui sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1984,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu6bm  = `r(mean)'
qui sum emp_stemocc [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1984,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu6wm  = `r(mean)'
qui sum workedly [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1984,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu6wf  = `r(mean)'
qui sum stem_maj  [aweight=perwt] if female==0 & black==1 & inrange(yearage18,1986,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mua5bm  = `r(mean)'
qui sum emp_stemocc [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mua5wm  = `r(mean)'
qui sum workedly [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mua5wf  = `r(mean)'


capture file close TA1
file open TA1 using "${table_path}TA1.tex", write replace
file write TA1 "\begin{table}[ht]" _n 
file write TA1 "\caption{Robustness of length of time horizon}" _n 
file write TA1 "\label{tab:ta1}" _n 
file write TA1 "\centering" _n 
file write TA1 "\begin{threeparttable}" _n 
file write TA1 "\begin{tabular}{lccc}" _n 
file write TA1 "\toprule " _n 
file write TA1 "       & Black           & White        & White       \\" _n 
file write TA1 "       & Male            & Male         & Female      \\" _n 
file write TA1 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA1 "\midrule " _n 
file write TA1 "\multicolumn{4}{l}{\emph{Panel A: Five years before and after}}\\ " _n 
file write TA1 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TA1                         " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TA1 "Control mean"          " &  [" %4.3f (`mu5bm') "]        & [" %4.3f  (`mu5wm') "] & [" %4.3f  (`mu5wf')  "] \\ "  _n 
file write TA1 "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA1 "                         &                              &                              &\\"  _n
file write TA1 "\multicolumn{4}{l}{\emph{Panel B: Six years before and after}}\\ " _n 
file write TA1 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " \\ "  _n 
file write TA1                         " &  (" %4.3f (`se2A') ")        & (" %4.3f  (`se2B') ")        & (" %4.3f  (`se2C') ") \\ "  _n 
file write TA1 "Control mean"          " &  [" %4.3f (`mu6bm') "]        & [" %4.3f  (`mu6wm') "] & [" %4.3f  (`mu6wf')  "] \\ "  _n 
file write TA1 "\emph{N}"              " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA1 "                         &                              &                              &\\"  _n
file write TA1 "\multicolumn{4}{l}{\emph{Panel C: Five years before (including 1990) and four years after}}\\ " _n 
file write TA1 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " \\ "  _n 
file write TA1                         " &  (" %4.3f (`se3A') ")        & (" %4.3f  (`se3B') ")        & (" %4.3f  (`se3C') ") \\ "  _n 
file write TA1 "Control mean"          " &  [" %4.3f (`mua5bm') "]        & [" %4.3f  (`mua5wm') "] & [" %4.3f  (`mua5wf')  "] \\ "  _n 
file write TA1 "\emph{N}"              " &  " %9.0gc (`N3A') "          & " %9.0gc  (`N3B') "          & " %9.0gc  (`N3C') " \\ "  _n 
file write TA1 "\bottomrule " _n 
file write TA1 "\end{tabular} " _n 
file write TA1 "\footnotesize Notes: This table presents sensitivity of our results as we change the number of birth cohorts in the sample. Panel A includes those turning 18 between 1985 and 1995 (excluding 1990). Panel B includes year age 18 cohorts between 1994 and 1996 (excluding 1990). Panel C includes those turning 18 between 1986 and 1994, including 1990. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA1 "\end{threeparttable} " _n 
file write TA1 "\end{table} " _n 
file close TA1





*Table S2: Altering Sample of States Included
gen     regionbpl=bpl
recode  regionbpl 1=3 2=4 4=4 5=3 6=4 8=4 9=1 10=3 11=3 12=3 13=3 15=4 16=4 17=2 18=2 19=2 20=2 21=3 22=3 23=1 24=3 25=1 26=2 27=2 28=3 29=2 30=4 31=2 32=4 33=1 34=1 35=4 36=1 37=3 38=2 39=2 40=3 41=4 42=1 44=1 45=3 46=2 47=3 48=3 49=4 50=1 51=3 53=4 54=3 55=2 56=4
gen     smallstate=0
replace smallstate=1 if inlist(bpl,2,10,11,15,16,30,32,33,38,44,46,50,56)
*a) Excluding California
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,6) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,6) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,6) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table a: Exclude California")
*b) Excluding Florida
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,12) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,12) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,12) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table b: Exclude Florida")
*c) Excluding Illinois
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,17) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,17) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,17) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table c: Exclude Illinois")
*d) Excluding New York
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table d: Exclude New York")
*e) Excluding Texas
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,48) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b5A se5A star5A N5A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,48) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b5B se5B star5B N5B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,48) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b5C se5C star5C N5C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table e: Exclude Texas")
*f) Excluding Washington
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,53) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b6A se6A star6A N6A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,53) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b6B se6B star6B N6B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,53) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b6C se6C star6C N6C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table f: Exclude Washington")
*g) Including merit states
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990)   & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b9A se9A star9A N9A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990)  & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b9B se9B star9B N9B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990)  & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b9C se9C star9C N9C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table g: Include merit states")
*h) Excluding 13 small states with less than one million population in 1980
*Alaska, Delaware, DC, Hawaii, Idaho, Montana, Nevada, New Hampshire, North Dakota, Rhode Island, South Dakota, Vermont, and Wyoming
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & smallstate==0 & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b10A se10A star10A N10A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & smallstate==0 & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b10B se10B star10B N10B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & smallstate==0 & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b10C se10C star10C N10C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table h: Exclude small states (Alaska, Delaware, DC, Hawaii, Idaho, Montana, Nevada, New Hampshire, North Dakota, Rhode Island, South Dakota, Vermont, and Wyoming)")
*i) Excluding New York and state trends
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl  c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b11A se11A star11A N11A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl  c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b11B se11B star11B N11B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl  c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b11C se11C star11C N11C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table i: Exclude New York and state trends")
*j) Excluding New York and lengthening policy window
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1985,1995) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b12A se12A star12A N12A)
est sto regA
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1985,1995) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b12B se12B star12B N12B)
est sto regB
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1985,1995) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29,36) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b12C se12C star12C N12C)
est sto regC
* outreg using ${outreg_path}IStableS2.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table j: Exclude New York and lengthen policy window")


capture file close TA2
file open TA2 using "${table_path}TA2.tex", write replace
file write TA2 "\begin{table}[ht]" _n 
file write TA2 "\caption{Robustness of exclusion or inclusion of various states}" _n 
file write TA2 "\label{tab:ta2}" _n 
file write TA2 "\centering" _n 
file write TA2 "\resizebox{!}{.42\textheight}{" _n 
file write TA2 "\begin{threeparttable}" _n 
file write TA2 "\begin{tabular}{lccc}" _n 
file write TA2 "\toprule " _n 
file write TA2 "       & Black           & White        & White       \\" _n 
file write TA2 "       & Male            & Male         & Female      \\" _n 
file write TA2 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA2 "\midrule " _n 
file write TA2 "\multicolumn{4}{l}{\emph{Panel A: Excluding California}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel B: Excluding Florida}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se2A') ")        & (" %4.3f  (`se2B') ")        & (" %4.3f  (`se2C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel C: Excluding Illinois}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se3A') ")        & (" %4.3f  (`se3B') ")        & (" %4.3f  (`se3C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N3A') "          & " %9.0gc  (`N3B') "          & " %9.0gc  (`N3C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel D: Excluding New York}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se4A') ")        & (" %4.3f  (`se4B') ")        & (" %4.3f  (`se4C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N4A') "          & " %9.0gc  (`N4B') "          & " %9.0gc  (`N4C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel E: Excluding Texas}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b5A') "`star5A'" " & " %4.3f (`b5B') "`star5B'" " & " %4.3f (`b5C') "`star5C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se5A') ")        & (" %4.3f  (`se5B') ")        & (" %4.3f  (`se5C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N5A') "          & " %9.0gc  (`N5B') "          & " %9.0gc  (`N5C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel F: Excluding Washington}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b6A') "`star6A'" " & " %4.3f (`b6B') "`star6B'" " & " %4.3f (`b6C') "`star6C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se6A') ")        & (" %4.3f  (`se6B') ")        & (" %4.3f  (`se6C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N6A') "          & " %9.0gc  (`N6B') "          & " %9.0gc  (`N6C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel G: Including merit states}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b9A') "`star9A'" " & " %4.3f (`b9B') "`star9B'" " & " %4.3f (`b9C') "`star9C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se9A') ")        & (" %4.3f  (`se9B') ")        & (" %4.3f  (`se9C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N9A') "          & " %9.0gc  (`N9B') "          & " %9.0gc  (`N9C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel H: Excluding 13 smallest states}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b10A') "`star10A'" " & " %4.3f (`b10B') "`star10B'" " & " %4.3f (`b10C') "`star10C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se10A') ")        & (" %4.3f  (`se10B') ")        & (" %4.3f  (`se10C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N10A') "          & " %9.0gc  (`N10B') "          & " %9.0gc  (`N10C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel I: Exclude NY and state trends}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b11A') "`star11A'" " & " %4.3f (`b11B') "`star11B'" " & " %4.3f (`b11C') "`star11C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se11A') ")        & (" %4.3f  (`se11B') ")        & (" %4.3f  (`se11C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N11A') "          & " %9.0gc  (`N11B') "          & " %9.0gc  (`N11C') " \\ "  _n 
file write TA2 "                         &                              &                              &\\"  _n
file write TA2 "\multicolumn{4}{l}{\emph{Panel J: Exclude NY, lengthen policy window}}\\ " _n 
file write TA2 "Foreign STEM Exposure" " & " %4.3f (`b12A') "`star12A'" " & " %4.3f (`b12B') "`star12B'" " & " %4.3f (`b12C') "`star12C'" " \\ "  _n 
file write TA2                         " &  (" %4.3f (`se12A') ")        & (" %4.3f  (`se12B') ")        & (" %4.3f  (`se12C') ") \\ "  _n 
file write TA2 "\emph{N}"              " &  " %9.0gc (`N12A') "          & " %9.0gc  (`N12B') "          & " %9.0gc  (`N12C') " \\ "  _n 
file write TA2 "\bottomrule " _n 
file write TA2 "\end{tabular} " _n 
file write TA2 "\footnotesize Notes: This table presents estimates of our three primary findings under various sample selection alternatives. We sequentially exclude the most popular immigrant destinations, as well as the 13 smallest states (each of which had population of less than 1 million in 1980). We also include the merit states and present sensitivity analyses for when New York is excluded. Due to space constraints, we exclude reports of the control group's average outcome. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA2 "\end{threeparttable} " _n 
file write TA2 "} " _n 
file write TA2 "\end{table} " _n 
file close TA2


*Table S3: Altering Specification of State Control Variables
sort  bpl
merge bpl using ${data_path}bpl_forshr_vars_90.dta
tab  _merge
drop _merge
gen     natpct_16pl_stemo_80_2559_p91 = natpct_16pl_stemo_80_2559*post91
gen     natpct_16pl_stemo_90_2559_p91 = natpct_16pl_stemo_90_2559*post91
*a) Adding control for 1980 share of native college graduates in the state employed in STEM occupations interacted with the post-IA90 dummy
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18 natpct_16pl_stemo_80_2559_p91 lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS3.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18 natpct_16pl_stemo_80_2559_p91 lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18 natpct_16pl_stemo_80_2559_p91 lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S3a: Adding control for 1980 share of native college graduates in the state employed in STEM occupations interacted with the post-IA90 dummy")
*b) Adding control for 1990 share of native college graduates in the state employed in STEM occupations interacted with the post-IA90 dummy
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18 natpct_16pl_stemo_90_2559_p91 lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18 natpct_16pl_stemo_90_2559_p91 lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18 natpct_16pl_stemo_90_2559_p91 lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S3b: Adding control for 1990 share of native college graduates in the state employed in STEM occupations interacted with the post-IA90 dummy")
*c) excluding state control variables
qui reg stem_maj forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18                                      yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18                                       yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18                                      yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS3.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S3c: excluding state control variables")


capture file close TA3
file open TA3 using "${table_path}TA3.tex", write replace
file write TA3 "\begin{table}[ht]" _n 
file write TA3 "\caption{Robustness of specification of state controls}" _n 
file write TA3 "\label{tab:ta3}" _n 
file write TA3 "\centering" _n 
file write TA3 "\begin{threeparttable}" _n 
file write TA3 "\begin{tabular}{lccc}" _n 
file write TA3 "\toprule " _n 
file write TA3 "       & Black           & White        & White       \\" _n 
file write TA3 "       & Male            & Male         & Female      \\" _n 
file write TA3 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA3 "\midrule " _n 
file write TA3 "\multicolumn{4}{l}{\emph{Panel A: Adding 1980 share BA working in STEM}}\\ " _n 
file write TA3 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TA3                         " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TA3 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA3 "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA3 "                         &                              &                              &\\"  _n
file write TA3 "\multicolumn{4}{l}{\emph{Panel B: Adding 1990 share BA working in STEM}}\\ " _n 
file write TA3 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " \\ "  _n 
file write TA3                         " &  (" %4.3f (`se2A') ")        & (" %4.3f  (`se2B') ")        & (" %4.3f  (`se2C') ") \\ "  _n 
file write TA3 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA3 "\emph{N}"              " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA3 "                         &                              &                              &\\"  _n
file write TA3 "\multicolumn{4}{l}{\emph{Panel C: Excluding state control variables}}\\ " _n 
file write TA3 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " \\ "  _n 
file write TA3                         " &  (" %4.3f (`se3A') ")        & (" %4.3f  (`se3B') ")        & (" %4.3f  (`se3C') ") \\ "  _n 
file write TA3 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA3 "\emph{N}"              " &  " %9.0gc (`N3A') "          & " %9.0gc  (`N3B') "          & " %9.0gc  (`N3C') " \\ "  _n 
file write TA3 "\bottomrule " _n 
file write TA3 "\end{tabular} " _n 
file write TA3 "\footnotesize Notes: Panel A adds as an additional control the 1980 share of native college graduates in the state employed in STEM occupations interacted with the post-IA90 dummy. Panel B adds as an additional control the 1990 share of native college graduates in the state employed in STEM occupations interacted with the post-IA90 dummy. Panel C excludes all time-varying state control variables. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA3 "\end{threeparttable} " _n 
file write TA3 "\end{table} " _n 
file close TA3


*Table S4: Alternative definitions for foreign STEM exposure
gen l_forshr_16pl_stemo_80_2559     = ln(forshr_16pl_stemo_80_2559)
gen l_forshr_16pl_stemo_80_2559_p91 = l_forshr_16pl_stemo_80_2559*post91
sum forshr_16pl_stem*_80_2559_p91  forshr_ed16plus_80_2559_p91  l_forshr_16pl_stemo_80_2559_p91   [aweight=perwt] if female<=1 & (black==1 | white==1) & inrange(yearage18,1991,1994) & ~inlist(bpl,13,5,38,29)
*a) using forshr_16pl_stem2_80_2559_p91
qui reg stem_maj forshr_16pl_stem2_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStableS4.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stem2_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stem2_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stem2_80_2559_p91) title("Table S4a: Define Foreign STEM exposure according to broader STEM definition")
*b) using forshr_ed16plus_80_2559_p91
qui reg stem_maj forshr_ed16plus_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_ed16plus_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_ed16plus_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(forshr_ed16plus_80_2559_p91) title("Table S4b: Define Foreign STEM exposure according to broader college employment share instead of STEM emp. share")
*c) using nstem share
reg stem_maj forshr_16pl_nstem_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg emp_stemocc forshr_16pl_nstem_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg workedly forshr_16pl_nstem_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
*d) using l_forshr_16pl_stemo_80_2559_p90
qui reg stem_maj l_forshr_16pl_stemo_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  l_forshr_16pl_stemo_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly l_forshr_16pl_stemo_80_2559_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStableS4.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC, b(%9.3f) se(%9.3f) stats(N) keep(l_forshr_16pl_stemo_80_2559_p91) title("Table S4c: Estimate baseline exposure in logs instead of levels")


capture file close TA4
file open TA4 using "${table_path}TA4.tex", write replace
file write TA4 "\begin{table}[ht]" _n 
file write TA4 "\caption{Alternative definitions for foreign STEM exposure}" _n 
file write TA4 "\label{tab:ta4}" _n 
file write TA4 "\centering" _n 
file write TA4 "\begin{threeparttable}" _n 
file write TA4 "\begin{tabular}{lccc}" _n 
file write TA4 "\toprule " _n 
file write TA4 "       & Black           & White        & White       \\" _n 
file write TA4 "       & Male            & Male         & Female      \\" _n 
file write TA4 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA4 "\midrule " _n 
file write TA4 "\multicolumn{4}{l}{\emph{Panel A: Alternate definition of STEM occupations}}\\ " _n 
file write TA4 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TA4                         " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TA4 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA4 "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA4 "                         &                              &                              &\\"  _n
file write TA4 "\multicolumn{4}{l}{\emph{Panel B: 1980 share college of graduates instead of 1980 share of STEM workers}}\\ " _n 
file write TA4 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " \\ "  _n 
file write TA4                         " &  (" %4.3f (`se2A') ")        & (" %4.3f  (`se2B') ")        & (" %4.3f  (`se2C') ") \\ "  _n 
file write TA4 "Control mean"          " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA4 "\emph{N}"              " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA4 "                         &                              &                              &\\"  _n
file write TA4 "\multicolumn{4}{l}{\emph{Panel C: 1980 share of non-STEM workers instead of 1980 share of STEM workers}}\\ " _n 
file write TA4 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " \\ "  _n 
file write TA4                         " &  (" %4.3f (`se4A') ")        & (" %4.3f  (`se4B') ")        & (" %4.3f  (`se4C') ") \\ "  _n 
file write TA4 "\emph{N}"              " &  " %9.0gc (`N4A') "          & " %9.0gc  (`N4B') "          & " %9.0gc  (`N4C') " \\ "  _n 
* file write TA4 "                         &                              &                              &\\"  _n
* file write TA4 "\multicolumn{4}{l}{\emph{Panel C: Log 1980 share of STEM workers}}\\ " _n 
* file write TA4 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " \\ "  _n 
* file write TA4                         " &  (" %4.3f (`se3A') ")        & (" %4.3f  (`se3B') ")        & (" %4.3f  (`se3C') ") \\ "  _n 
* file write TA4 "\emph{N}"              " &  " %9.0gc (`N3A') "          & " %9.0gc  (`N3B') "          & " %9.0gc  (`N3C') " \\ "  _n 
file write TA4 "\bottomrule " _n 
file write TA4 "\end{tabular} " _n 
file write TA4 "\footnotesize Notes: This table presents estimates using alternative definitions of foreign STEM exposure. Panel A considers a broader set of STEM occupations (see Table \ref{tab:occCodes}). Panel B considers using the 1980 share of college graduates rather than the 1980 share of college graduates working in STEM occupations. Panel C uses the 1980 share of college graduates working in non-STEM occupations. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA4 "\end{threeparttable} " _n 
file write TA4 "\end{table} " _n 
file close TA4



*Discrete Treatment Based on Exposure State Groups

*Unweighted/roughly equal number of states per group
egen tagbpl=tag(bpl)
tab  tagbpl
tab forshr_16pl_stemo_80_2559 if tagbpl==1 & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29

gen     forshr_g1=0
gen     forshr_g2=0
gen     forshr_g3=0
replace forshr_g1=1 if forshr_16pl_stemo_80_2559< 0.599
replace forshr_g2=1 if forshr_16pl_stemo_80_2559>=0.599 & forshr_16pl_stemo_80_2559<1.20
replace forshr_g3=1 if forshr_16pl_stemo_80_2559>=1.20
gen     forshr_g=1 if forshr_g1==1
replace forshr_g=2 if forshr_g2==1
replace forshr_g=3 if forshr_g3==1
sum forshr_g* if tagbpl==1  & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29
tab forshr_g  if tagbpl==1  & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29
*(16,16, and 15) states in the groups
gen forshr_g2_p91=forshr_g2*post91
gen forshr_g3_p91=forshr_g3*post91


reg stem_maj forshr_g2_p91 forshr_g3_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29)  & ed16plus==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11A b12A se11A se12A star11A star12A N1A)
* outreg using ${outreg_path}IStableS4b.doc, replace se starlevels(10 5 1) starloc(1)
reg emp_stemocc  forshr_g2_p91 forshr_g3_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11B b12B se11B se12B star11B star12B N1B)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg workedly forshr_g2_p91 forshr_g3_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11C b12C se11C se12C star11C star12C N1C)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)


*Weighted groups with differing numbers of states
tab forshr_16pl_stemo_80_2559  [aweight=perwt]  if (black==1 | white==1) & yearage18>=1991 & yearage18<=1994 & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29

gen     forshr_g1b=0
gen     forshr_g2b=0
gen     forshr_g3b=0
replace forshr_g1b=1 if forshr_16pl_stemo_80_2559< 0.899
replace forshr_g2b=1 if forshr_16pl_stemo_80_2559>=0.899 & forshr_16pl_stemo_80_2559<1.27
replace forshr_g3b=1 if forshr_16pl_stemo_80_2559>=1.27
gen     forshr_gb=1 if forshr_g1b==1
replace forshr_gb=2 if forshr_g2b==1
replace forshr_gb=3 if forshr_g3b==1
sum forshr_g*b if tagbpl==1  & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29
tab forshr_gb  if tagbpl==1  & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29
*(25, 13, and 9) states in these groups
gen forshr_g2b_p91=forshr_g2b*post91
gen forshr_g3b_p91=forshr_g3b*post91

reg stem_maj forshr_g2b_p91 forshr_g3b_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b21A b22A se21A se22A star21A star22A N2A)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg emp_stemocc  forshr_g2b_p91 forshr_g3b_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b21B b22B se21B se22B star21B star22B N2B)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg workedly forshr_g2b_p91 forshr_g3b_p91   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b21C b22C se21C se22C star21C star22C N2C)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)


*Two groups with 24 and 23 states
gen     forshr_gc=0
replace forshr_gc=1 if forshr_16pl_stemo_80_2559>0.8
tab forshr_gc  if tagbpl==1  & bpl~=13 & bpl~=5 & bpl~=38 & bpl~=29
gen     forshr_gc_p91=forshr_gc*post91

reg stem_maj forshr_gc_p91                   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg emp_stemocc  forshr_gc_p91                   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)
reg workedly forshr_gc_p91                   i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
* outreg using ${outreg_path}IStableS4b.doc, append   se starlevels(10 5 1) starloc(1)


capture file close TA5
file open TA5 using "${table_path}TA5.tex", write replace
file write TA5 "\begin{table}[ht]" _n 
file write TA5 "\caption{Discrete Treatment Based on Exposure State Groups}" _n 
file write TA5 "\label{tab:ta5}" _n 
file write TA5 "\centering" _n 
file write TA5 "\begin{threeparttable}" _n 
file write TA5 "\begin{tabular}{lccc}" _n 
file write TA5 "\toprule " _n 
file write TA5 "       & Black           & White        & White       \\" _n 
file write TA5 "       & Male            & Male         & Female      \\" _n 
file write TA5 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA5 "\midrule " _n 
file write TA5 "Medium Foreign STEM Exposure" " & " %4.3f (`b21A') "`star21A'" " & " %4.3f (`b21B') "`star21B'" " & " %4.3f (`b21C') "`star21C'" " \\ "  _n 
file write TA5                                " &  (" %4.3f (`se21A') ")        & (" %4.3f  (`se21B') ")        & (" %4.3f  (`se21C') ") \\ "  _n 
file write TA5 "High Foreign STEM Exposure"   " & " %4.3f (`b22A') "`star22A'" " & " %4.3f (`b22B') "`star22B'" " & " %4.3f (`b22C') "`star22C'" " \\ "  _n 
file write TA5                                " &  (" %4.3f (`se22A') ")        & (" %4.3f  (`se22B') ")        & (" %4.3f  (`se22C') ") \\ "  _n 
file write TA5 "Control mean"                 " &  [" %4.3f (`mu1C') "]        & [" %4.3f  (`mu3c2') "]       & [" %4.3f  (`mu4c4')  "] \\ "  _n 
file write TA5 "\emph{N}"                     " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA5 "\bottomrule " _n 
file write TA5 "\end{tabular} " _n 
file write TA5 "\footnotesize Notes: This table estimates our main regression model using a discretized version of exposure. States are classified as low-, medium-, or high-exposure based on terciles of the exposure distribution. The coefficients reported represent the change in the outcome variable by moving across exposure terciles (either from low to medium or from low to high). *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA5 "\end{threeparttable} " _n 
file write TA5 "\end{table} " _n 
file close TA5



*Additional Analysis for STEM occ outcomes using broader definition
gen     stemocc2=occ1990
recode  stemocc2 44/64=1 66/83=1 229=1  84/89=1 96=1  113/116=1 127/128=1 else=0
gen     emp_stemocc2 = employed*stemocc2
gen     stemocc_engine=0
gen     stemocc_comput=0
gen     stemocc_matsci=0
replace stemocc_engine=1 if occ1990>=44 & occ1990<=59  & employed
replace stemocc_comput=1 if occ1990==64 | occ1990==229 & employed
replace stemocc_matsci=1 if occ1990>=66 & occ1990<=83  & employed
gen     stemocc_engcom=stemocc_engine+stemocc_comput

local k=7
sum emp_stemocc2  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu1b`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu2b`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu3b`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1
local mu4b`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
local mu1d`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
local mu2d`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
local mu3d`k' = `r(mean)'
sum emp_stemocc2  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0
local mu4d`k' = `r(mean)'


*STEM college instructors are empty codes in the 2009-2016 ACS.
*a) unconditional on ed16plus
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable8S.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) , cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S8a: STEM occupation using broader definition")
*b) conditional on ed16plus==1
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S8b: STEM occupation using broader definition, conditional on college completion")
*c) conditional on ed16plus==1 & stem_maj==1
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S8c: STEM occupation using broader definition, conditional on STEM college completion")
*d) conditional on ed16plus==1 & stem_maj==0
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4A se4A star4A N4A)
est sto regA
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4B se4B star4B N4B)
est sto regB
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4C se4C star4C N4C)
est sto regC
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc2 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==0, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b4D se4D star4D N4D)
est sto regD
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S8d: STEM occupation using broader definition, conditional on Non-STEM college completion")

capture file close TA9
file open TA9 using "${table_path}TA9.tex", write replace
file write TA9 "\begin{table}[ht]" _n 
file write TA9 "\caption{Additional analysis for STEM occupational outcomes using broader definition}" _n 
file write TA9 "\label{tab:TA9}" _n 
file write TA9 "\centering" _n 
file write TA9 "\begin{threeparttable}" _n 
file write TA9 "\begin{tabular}{lcccc}" _n 
file write TA9 "\toprule " _n 
file write TA9 "       & Black           & Black        & White        & White       \\" _n 
file write TA9 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write TA9 "\midrule " _n 
file write TA9 "\multicolumn{5}{l}{\emph{Panel A: Works in STEM occupation, conditional on BA graduation}}\\ " _n 
file write TA9 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write TA9                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write TA9 "Control mean"          " &  [" %4.3f (`mu1b7') "] & [" %4.3f  (`mu2b7') "] & [" %4.3f  (`mu3b7')  "]  & [" %4.3f  (`mu4b7')  "]\\ "  _n 
file write TA9 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write TA9 "&&&&\\"  _n
file write TA9 "\multicolumn{5}{l}{\emph{Panel B: Works in STEM occupation, conditional on STEM BA graduation}}\\ " _n 
file write TA9 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write TA9                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write TA9 "Control mean"          " &  [" %4.3f (`mu1c7') "] & [" %4.3f  (`mu2c7') "] & [" %4.3f  (`mu3c7')  "]  & [" %4.3f  (`mu4c7')  "]\\ "  _n 
file write TA9 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write TA9 "&&&&\\"  _n
file write TA9 "\multicolumn{5}{l}{\emph{Panel C: Works in STEM occupation, conditional on non-STEM BA graduation}}\\ " _n 
file write TA9 "Foreign STEM Exposure" " & " %4.3f (`b4A') "`star4A'" " & " %4.3f (`b4B') "`star4B'" " & " %4.3f (`b4C') "`star4C'" " & " %4.3f (`b4D') "`star4D'" " \\ "  _n 
file write TA9                         " &  (" %4.3f (`se4A') ") & (" %4.3f  (`se4B') ") & (" %4.3f  (`se4C')  ") & (" %4.3f  (`se4D') ") \\ "  _n 
file write TA9 "Control mean"          " &  [" %4.3f (`mu1d7') "] & [" %4.3f  (`mu2d7') "] & [" %4.3f  (`mu3d7')  "]  & [" %4.3f  (`mu4d7')  "]\\ "  _n 
file write TA9 "\emph{N}"              " &  " %9.0gc (`N4A') " & " %9.0gc  (`N4B') " & " %9.0gc  (`N4C')  " & " %9.0gc  (`N4D') " \\ "  _n 
file write TA9 "\bottomrule " _n 
file write TA9 "\end{tabular} " _n 
file write TA9 "\footnotesize Notes: This table presents results similar to Table \ref{tab:STEMoccEmpAll}, but where current STEM occupation is more broadly defined (see Table \ref{tab:occCodes}). *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA9 "\end{threeparttable} " _n 
file write TA9 "\end{table} " _n 
file close TA9

*Detailed STEM occs for STEM Graduates
local k=8
sum stemocc_engine  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum stemocc_engine  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum stemocc_engine  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum stemocc_engine  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'
local k=9
sum stemocc_comput  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum stemocc_comput  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum stemocc_comput  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum stemocc_comput  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'
local k=0
sum stemocc_matsci  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum stemocc_matsci  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum stemocc_matsci  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum stemocc_matsci  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'

qui reg stemocc_engine forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc_comput forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc_matsci forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S8e: White male detailed STEM occupation, conditional on STEM college completion")

qui reg stemocc_engine forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc_comput forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg stemocc_matsci forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable8S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S8f: White female detailed STEM occupation, conditional on STEM college completion")

sum *stemocc* [aweight=perwt]  if (black==1 | white==1)  & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj & emp_stemocc==1
*84% of STEM jobs are in engineering and computers so not surprising that effects are concentrated there.


capture file close TA9a
file open TA9a using "${table_path}TA9a.tex", write replace
file write TA9a "\begin{table}[ht]" _n 
file write TA9a "\caption{Detailed STEM occupation employment for STEM graduates}" _n 
file write TA9a "\label{tab:TA9a}" _n 
file write TA9a "\centering" _n 
file write TA9a "\begin{threeparttable}" _n 
file write TA9a "\begin{tabular}{lccc}" _n 
file write TA9a "\toprule " _n 
file write TA9a " & Engineering  & Computers & Math \& Science \\" _n 
file write TA9a "\midrule " _n 
file write TA9a "\multicolumn{4}{l}{\emph{Panel A: White Men}}\\ " _n 
file write TA9a "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " \\ "  _n 
file write TA9a                         " &  (" %4.3f (`se1A') ")        & (" %4.3f  (`se1B') ")        & (" %4.3f  (`se1C') ") \\ "  _n 
file write TA9a "Control mean"          " &  [" %4.3f (`mu3c8') "]       & [" %4.3f  (`mu3c9') "]       & [" %4.3f  (`mu3c0')  "] \\ "  _n 
file write TA9a "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA9a "                         &                              &                              &\\"  _n
file write TA9a "\multicolumn{4}{l}{\emph{Panel B: White Women}}\\ " _n 
file write TA9a "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " \\ "  _n 
file write TA9a                         " &  (" %4.3f (`se2A') ")        & (" %4.3f  (`se2B') ")        & (" %4.3f  (`se2C') ") \\ "  _n 
file write TA9a "Control mean"          " &  [" %4.3f (`mu4c8') "]       & [" %4.3f  (`mu4c9') "]       & [" %4.3f  (`mu4c0')  "] \\ "  _n 
file write TA9a "\emph{N}"              " &  " %9.0gc (`N2A') "          & " %9.0gc  (`N2B') "          & " %9.0gc  (`N2C') " \\ "  _n 
file write TA9a "\bottomrule " _n 
file write TA9a "\end{tabular} " _n 
file write TA9a "\footnotesize Notes: This table decomposes the effects reported in Panel B of Table \ref{tab:STEMoccEmpAll} for white men and women. Here, each dependent variable is a dummy for being employed in a specific STEM occupation (rather than any STEM occupation as considered in Table \ref{tab:STEMoccEmpAll}). The sum of the coefficients across columns equals the coefficient reported in Panel B of Table \ref{tab:STEMoccEmpAll}. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA9a "\end{threeparttable} " _n 
file write TA9a "\end{table} " _n 
file close TA9a



*Additional Analysis for Employment of STEM graduates
gen unemployed=0
gen nilf=0
replace unemployed=1 if empstat==2
replace nilf=1       if empstat==3

local k=8
sum unemployed  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum unemployed  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum unemployed  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum unemployed  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'
local k=9
sum nilf  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum nilf  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum nilf  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum nilf  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'

qui reg unemployed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1A se1A star1A N1A)
est sto regA
* outreg using ${outreg_path}IStable10S.doc, replace se starlevels(10 5 1) starloc(1)
qui reg unemployed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1B se1B star1B N1B)
est sto regB
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg unemployed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1C se1C star1C N1C)
est sto regC
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg unemployed forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b1D se1D star1D N1D)
est sto regD
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S9a: Unemployment, conditional on STEM college completion")
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg nilf       forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2A se2A star2A N2A)
est sto regA
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg nilf       forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2B se2B star2B N2B)
est sto regB
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg nilf       forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2C se2C star2C N2C)
est sto regC
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg nilf       forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b2D se2D star2D N2D)
est sto regD
* outreg using ${outreg_path}IStable10S.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S9b: NILF, conditional on STEM college completion")

gen     worked5=0
replace worked5=1 if workedyr==2 | workedyr==3

local k=0
sum worked5  [aweight=perwt] if female==0 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu1c`k' = `r(mean)'
sum worked5  [aweight=perwt] if female==1 & white==0 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu2c`k' = `r(mean)'
sum worked5  [aweight=perwt] if female==0 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu3c`k' = `r(mean)'
sum worked5  [aweight=perwt] if female==1 & white==1 & inrange(yearage18,1986,1989) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
local mu4c`k' = `r(mean)'

qui reg worked5 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3A se3A star3A N3A)
est sto regA
* outreg using ${outreg_path}IStable11S.doc, replace se starlevels(10 5 1) starloc(1)
qui reg worked5 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  black==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3B se3B star3B N3B)
est sto regB
* outreg using ${outreg_path}IStable11S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg worked5 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3C se3C star3C N3C)
est sto regC
* outreg using ${outreg_path}IStable11S.doc, append   se starlevels(10 5 1) starloc(1)
qui reg worked5 forshr_16pl_stemo_80_2559_p91 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_coef, in1(`e(cmdline)') in2(`e(N)') out(b3D se3D star3D N3D)
est sto regD
* outreg using ${outreg_path}IStable11S.doc, append   se starlevels(10 5 1) starloc(1)
tab workedyr [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1986,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1
est table regA regB regC regD , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p91) title("Table S9c: worked last 5 years, conditional on STEM college completion")


capture file close TA10
file open TA10 using "${table_path}TA10.tex", write replace
file write TA10 "\begin{table}[ht]" _n 
file write TA10 "\caption{Employment outcomes, conditional on graduation in a STEM field}" _n 
file write TA10 "\label{tab:TA10}" _n 
file write TA10 "\centering" _n 
file write TA10 "\begin{threeparttable}" _n 
file write TA10 "\begin{tabular}{lcccc}" _n 
file write TA10 "\toprule " _n 
file write TA10 "       & Black           & Black        & White        & White       \\" _n 
file write TA10 "Effect & Men             & Women        & Men          & Women       \\" _n 
file write TA10 "\midrule " _n 
file write TA10 "\multicolumn{5}{l}{\emph{Panel A: Unemployment, conditional on STEM BA graduation}}\\ " _n 
file write TA10 "Foreign STEM Exposure" " & " %4.3f (`b1A') "`star1A'" " & " %4.3f (`b1B') "`star1B'" " & " %4.3f (`b1C') "`star1C'" " & " %4.3f (`b1D') "`star1D'" " \\ "  _n 
file write TA10                         " &  (" %4.3f (`se1A') ") & (" %4.3f  (`se1B') ") & (" %4.3f  (`se1C')  ") & (" %4.3f  (`se1D') ") \\ "  _n 
file write TA10 "Control mean"          " &  [" %4.3f (`mu1c8') "] & [" %4.3f  (`mu2c8') "] & [" %4.3f  (`mu3c8')  "]  & [" %4.3f  (`mu4c8')  "]\\ "  _n 
file write TA10 "\emph{N}"              " &  " %9.0gc (`N1A') " & " %9.0gc  (`N1B') " & " %9.0gc  (`N1C')  " & " %9.0gc  (`N1D') " \\ "  _n 
file write TA10 "&&&&\\"  _n
file write TA10 "\multicolumn{5}{l}{\emph{Panel B: Not in Labor Force, conditional on STEM BA graduation}}\\ " _n 
file write TA10 "Foreign STEM Exposure" " & " %4.3f (`b2A') "`star2A'" " & " %4.3f (`b2B') "`star2B'" " & " %4.3f (`b2C') "`star2C'" " & " %4.3f (`b2D') "`star2D'" " \\ "  _n 
file write TA10                         " &  (" %4.3f (`se2A') ") & (" %4.3f  (`se2B') ") & (" %4.3f  (`se2C')  ") & (" %4.3f  (`se2D') ") \\ "  _n 
file write TA10 "Control mean"          " &  [" %4.3f (`mu1c9') "] & [" %4.3f  (`mu2c9') "] & [" %4.3f  (`mu3c9')  "]  & [" %4.3f  (`mu4c9')  "]\\ "  _n 
file write TA10 "\emph{N}"              " &  " %9.0gc (`N2A') " & " %9.0gc  (`N2B') " & " %9.0gc  (`N2C')  " & " %9.0gc  (`N2D') " \\ "  _n 
file write TA10 "&&&&\\"  _n
file write TA10 "\multicolumn{5}{l}{\emph{Panel C: Worked at all in last five years, conditional on STEM BA}}\\ " _n 
file write TA10 "Foreign STEM Exposure" " & " %4.3f (`b3A') "`star3A'" " & " %4.3f (`b3B') "`star3B'" " & " %4.3f (`b3C') "`star3C'" " & " %4.3f (`b3D') "`star3D'" " \\ "  _n 
file write TA10                         " &  (" %4.3f (`se3A') ") & (" %4.3f  (`se3B') ") & (" %4.3f  (`se3C')  ") & (" %4.3f  (`se3D') ") \\ "  _n 
file write TA10 "Control mean"          " &  [" %4.3f (`mu1c0') "] & [" %4.3f  (`mu2c0') "] & [" %4.3f  (`mu3c0')  "]  & [" %4.3f  (`mu4c0')  "]\\ "  _n 
file write TA10 "\emph{N}"              " &  " %9.0gc (`N3A') " & " %9.0gc  (`N3B') " & " %9.0gc  (`N3C')  " & " %9.0gc  (`N3D') " \\ "  _n 
file write TA10 "\bottomrule " _n 
file write TA10 "\end{tabular} " _n 
file write TA10 "\footnotesize Notes: Dependent variable is an indicator for either \emph{(a)} unemployment; \emph{(b)} not participating in labor force; or \emph{(c)} working at all in the previous five years. All samples are conditional on graduation in a STEM field. *Statistically significant at the .10 level; ** at the .05 level; *** at the .01 level." _n 
file write TA10 "\end{threeparttable} " _n 
file write TA10 "\end{table} " _n 
file close TA10



log close
