clear all
version 14.0
* set mem 5g
set matsize 11000
set maxvar  32767
set more off
capture log close
log using bpl_forshr_figure1.log, replace

global data_path  "../Data/"
global graph_path "../Figures/"

use ${data_path}bpl_forshr_figure1.dta, clear
gen _merge = 1
statastates, nogen fips(bpl)
labmask bpl, values(state_abbrev)
drop state_abbrev state_name _merge

*----------------------------------------------------------------------
* First stage: 1980 foreign STEM share on 1990-2000 foreign STEM growth
*----------------------------------------------------------------------
qui reg forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559
* find the dependent variable
local eq "1990 to 2000 foreign STEM share growth ="
* choose a nice display format for the constant
local eq "`eq' `: di  %7.2f _b[_cons]'"
* should we add or subtract
local eq "`eq' `=cond(_b[forshr_16pl_stemo_80_2559]>0, "+", "-")'"
* we already chose the plus or minus sign
* so we need to strip a minus sign when it is there
local eq "`eq' `:di %6.2f abs(_b[forshr_16pl_stemo_80_2559])'*(1980 foreign STEM share)"
* add the error term
local eq "`eq' + {&epsilon}; R{superscript:2} ="
* choose a nice display format for the R2
local eq "`eq' `:di %7.3f `e(r2)''"
twoway (scatter forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559, mlab(bpl) m(i)) (lfit forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559), legend(label(1 "States") label(2 "Fitted values") cols(2) symxsize(10) keygap(1)) ytitle("Growth in foreign STEM share, 1990 to 2000",height(8)) xtitle("Foreign STEM share, 1980",height(5)) ylabel(-.05(.05).15) xlabel(0(.05).25) graphregion(color(white)) note("`eq'")
graph export ${graph_path}fig1.eps, replace
reg forshr_16pl_stemo_00_90_2559 forshr_16pl_stemo_80_2559, robust


log close
