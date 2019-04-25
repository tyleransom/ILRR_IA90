*Effects of IA90 on Native College Major Choices
clear all
version 14.0
set matsize 11000
set maxvar  32767
set more off
capture log close
log using effectsIA90analysisISdblplacebo.log, replace

global data_path "../Data/"
global table_path "../Tables/Placebo/"
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
keep if yearage18>=1979 & yearage18<=1994
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
gen trend = (yearage18-1979)/12

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
gen     p8689=0
replace p8689=1 if inrange(yearage18,1986,1989)
gen     p9194=0
replace p9194=1 if inrange(yearage18,1991,1994)
merge m:1 bpl using ${data_path}bpl_forshr_figure1.dta, keepusing(forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_00_2559) nogen
sum *shr* [aweight=perwt]

* Express exposure in 10pp units
foreach var of varlist *shr* {
    replace `var' = `var'*10
}

gen     forshr_16pl_stemo_80_2559_p8689  = forshr_16pl_stemo_80_2559*p8689
gen     forshr_16pl_stem2_80_2559_p8689  = forshr_16pl_stem2_80_2559*p8689
gen     forshr_16pl_nstem_80_2559_p8689  = forshr_16pl_nstemo_80_2559*p8689
gen     forshr_ed16plus_80_2559_p8689    = forshr_ed16plus_80_2559*p8689
gen     forshr_16pl_stemo0090_2559_p8689 = forshr_16pl_stemo_00_90_2559*p8689
gen     forshr_16pl_stemo_00_2559_p8689  = forshr_16pl_stemo_00_2559*p8689
gen     forshr_16pl_stemo_80_2559_p9194  = forshr_16pl_stemo_80_2559*p9194
gen     forshr_16pl_stem2_80_2559_p9194  = forshr_16pl_stem2_80_2559*p9194
gen     forshr_16pl_nstem_80_2559_p9194  = forshr_16pl_nstemo_80_2559*p9194
gen     forshr_ed16plus_80_2559_p9194    = forshr_ed16plus_80_2559*p9194
gen     forshr_16pl_stemo0090_2559_p9194 = forshr_16pl_stemo_00_90_2559*p9194
gen     forshr_16pl_stemo_00_2559_p9194  = forshr_16pl_stemo_00_2559*p9194

gen y81=0
gen y82=0
gen y83=0
gen y84=0
gen y85=0
gen y86=0
gen y87=0
gen y88=0
gen y89=0
gen y91=0
gen y92=0
gen y93=0
gen y94=0
replace y81=1 if yearage18==1981
replace y82=1 if yearage18==1982
replace y83=1 if yearage18==1983
replace y84=1 if yearage18==1984
replace y85=1 if yearage18==1985
replace y86=1 if yearage18==1986
replace y87=1 if yearage18==1987
replace y88=1 if yearage18==1988
replace y89=1 if yearage18==1989
replace y91=1 if yearage18==1991
replace y92=1 if yearage18==1992
replace y93=1 if yearage18==1993
replace y94=1 if yearage18==1994
gen     forshr_16pl_stemo_80_2559_1981=forshr_16pl_stemo_80_2559*y81
gen     forshr_16pl_stemo_80_2559_1982=forshr_16pl_stemo_80_2559*y82
gen     forshr_16pl_stemo_80_2559_1983=forshr_16pl_stemo_80_2559*y83
gen     forshr_16pl_stemo_80_2559_1984=forshr_16pl_stemo_80_2559*y84
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
    collapse stem_maj stemocc unemployed nilf lincearn [aweight=perwt] if inrange(yearage18,1981,1994), by(bpl yearage18 ed16plus female black)
    save ${data_path}outcome_means_86_94, replace
restore

preserve
    gen unemployed=0
    gen nilf=0
    replace unemployed=1 if empstat==2
    replace nilf=1       if empstat==3
    collapse stem_maj stemocc unemployed nilf lincearn [aweight=perwt] if inrange(yearage18,1981,1994), by(bpl yearage18 female black)
    save ${data_path}outcome_means_uncondBA_86_94, replace
restore

preserve
    gen unemployed=0
    gen nilf=0
    replace unemployed=1 if empstat==2
    replace nilf=1       if empstat==3
    collapse stemocc unemployed nilf lincearn [aweight=perwt] if inrange(yearage18,1981,1994), by(bpl yearage18 ed16plus stem_maj female black)
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
    
    local Pvalue = 2 * ttail(e(df_r), abs(_b[`firstname']/_se[`firstname']))
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

*Sensitivity Analysis for Main Results Begins Here
qui sum stem_maj  [aweight=perwt] if ed16plus & female==0 & black==1 & inrange(yearage18,1982,1985) & ~inlist(bpl,13,5,38,29)
local mu1A  = `r(mean)'
qui sum emp_stemocc  [aweight=perwt] if stem_maj & female==0 & black==0 & inrange(yearage18,1982,1985) & ~inlist(bpl,13,5,38,29)
local mu2A  = `r(mean)'
qui sum workedly  [aweight=perwt] if stem_maj & female==1 & black==0 & inrange(yearage18,1982,1985) & ~inlist(bpl,13,5,38,29)
local mu3A  = `r(mean)'

*Table: Main Results Using Base Specification
qui reg stem_maj forshr_16pl_stemo_80_2559_p8689 forshr_16pl_stemo_80_2559_p9194 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  black==1    & inrange(yearage18,1982,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 , cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11A b12A se11A se12A star11A star12A N1A)
est sto regA
* outreg using ${outreg_path}IStableS0.doc, replace se starlevels(10 5 1) starloc(1)
qui reg emp_stemocc  forshr_16pl_stemo_80_2559_p8689 forshr_16pl_stemo_80_2559_p9194 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==0 &  white==1    & inrange(yearage18,1982,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11B b12B se11B se12B star11B star12B N1B)
est sto regB
* outreg using ${outreg_path}IStableS0.doc, append   se starlevels(10 5 1) starloc(1)
qui reg workedly forshr_16pl_stemo_80_2559_p8689 forshr_16pl_stemo_80_2559_p9194 i.bpl##c.yearage18  lnpop18 unemprate_styr lnmedhhinc18 yeardum* agedum* yearbirthdum*   [aweight=perwt] if female==1 &  white==1    & inrange(yearage18,1982,1994) & ~inlist(yearage18,1990) & ~inlist(bpl,13,5,38,29) & ed16plus==1 & stem_maj==1, cluster(bpl)
first_two_coefs, in1(`e(cmdline)') in2(`e(N)') out(b11C b12C se11C se12C star11C star12C N1C)
est sto regC
* outreg using ${outreg_path}IStableS0.doc, append   se starlevels(10 5 1) starloc(1)
est table regA regB regC , b(%9.3f) se(%9.3f) stats(N) keep(forshr_16pl_stemo_80_2559_p*) title("Table S000: Re-print main results on black male STEM major, white male STEM occupation, white female employment")

capture file close TA00
file open TA00 using "${table_path}TA000.tex", write replace
file write TA00 "\begin{table}[ht]" _n 
file write TA00 "\caption{Treatment of pre-1990 cohorts}" _n 
file write TA00 "\label{tab:ta000}" _n 
file write TA00 "\centering" _n 
file write TA00 "\begin{threeparttable}" _n 
file write TA00 "\begin{tabular}{lccc}" _n 
file write TA00 "\toprule " _n 
file write TA00 "       & Black           & White        & White       \\" _n 
file write TA00 "       & Male            & Male         & Female      \\" _n 
file write TA00 "Effect & STEM BA         & STEM Occ.    & Prior Yr Empl.\\" _n 
file write TA00 "\midrule " _n 
file write TA00 "Foreign STEM Exposure, 86-89 cohorts" " & " %4.3f (`b11A') "`star11A'" " & " %4.3f (`b11B') "`star11B'" " & " %4.3f (`b11C') "`star11C'" " \\ "  _n 
file write TA00                         " &  (" %4.3f (`se11A') ")        & (" %4.3f  (`se11B') ")        & (" %4.3f  (`se11C') ") \\ "  _n 
file write TA00 "Foreign STEM Exposure, 91-94 cohorts" " & " %4.3f (`b12A') "`star12A'" " & " %4.3f (`b12B') "`star12B'" " & " %4.3f (`b12C') "`star12C'" " \\ "  _n 
file write TA00                         " &  (" %4.3f (`se12A') ")        & (" %4.3f  (`se12B') ")        & (" %4.3f  (`se12C') ") \\ "  _n 
file write TA00 "Control mean"          " &  [" %4.3f (`mu1A') "]           & [" %4.3f  (`mu2A') "]         & [" %4.3f  (`mu3A')  "] \\ "  _n 
file write TA00 "\emph{N}"              " &  " %9.0gc (`N1A') "          & " %9.0gc  (`N1B') "          & " %9.0gc  (`N1C') " \\ "  _n 
file write TA00 "\bottomrule " _n 
file write TA00 "\end{tabular} " _n 
file write TA00 "\footnotesize Note: This table presents results from a setting where we consider individuals who turn 18 years old between 1982-1994, with 1990 as the year the policy was instituted. Individuals turning 18 in 1986-1989 are considered to be one treatment group, those turning 18 in 1991-1994 as a different treatment group, and those turning 18 in 1982-1985 serve as controls. The reported estimates should be compared with those reported in the first column of Table \ref{tab:STEMgradUncond} Panel C, the third column of Table \ref{tab:STEMoccEmpAll} Panel B, and the last column of Table \ref{tab:ProbLY} Panel B." _n 
file write TA00 "\end{threeparttable} " _n 
file write TA00 "\end{table} " _n 
file close TA00



log close
