clear all
version 14.0
set matsize 11000
set maxvar  32767
set more off
capture log close
log using master_script.log, replace

**** Dependencies:
** Data files that are too big to store on GitHub:
* bpl_vars_80.dat.gz (1980 Census 5% sample)
* forshr_vars_80_10.dat.gz (1980, 1990, 2000 5% Census samples; 2010 ACS 1% sample)
* statecontrols.dat.gz (March CPS, 1978-2011)
* acs_09_16.dat.gz (2009-2016 ACS)

* Create data
cd Data
do cr_foreign_shares.do
do cr_bpl_vars_80.do
do cr_statecontrols.do

* Do analyses
cd ../Analysis
do bpl_forshr_figure1.do
do figs2_4.do
do effectsIA90analysisIS.do
do effectsIA90analysisISplacebo.do
do effectsIA90analysisISdblplacebo.do

* Results will be found in Tables/*.tex (for tables) or Figures/*.eps (for figures)

log close

