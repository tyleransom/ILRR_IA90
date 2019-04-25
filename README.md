# ACS-immigration
## Master script
By executing the script `master_script.do`, a user can replicate all results, provided s/he has the necessary dependencies (i.e. extremely large data files that are not distributable via GitHub, but are included in the supplementary materials at the journal's website). Specifically, these files are:

* `acs_09_16.dat.gz` (ACS microdata for years 2009-2016)
* `bpl_vars_80.dat.gz` (1980 Census 5% sample for computing foreign exposure in 1980)
* `forshr_vars_80_10.dat.gz` (1980, 1990, and 2000 Censuses 5% samples, plus 2010 ACS 1% sample, for computing decadal changes in foreign exposure)
* `statecontrols.dat.gz` (1978-2011 March CPS, for computing time-varying state characteristics)

One may also download the raw microdata from the IPUMS-USA and IPUMS-CPS websites if desired. To do so, follow these steps, which correspond to the compressed `.dat` files listed above:

* Download detailed demographic and labor market data from IPUMS-USA for the ACS years 2009-2016. Select individuals aged 18 or more.  The list of variables is included in the top section of the file `Analysis/effectsIA90analysisIS.do`.
* Download detailed demographic and labor market data from IPUMS-USA for the 1980 census. Select individuals aged 18 or more. The list of variables is included in the top section of the file `Data/cr_bpl_vars_80.do`.
* Download demographic and labor market data from IPUMS-USA for the years 1980, 1990, 2000, and 2010. Select individuals aged 18 or more. The list of variables is included in the top section of the file `Data/cr_foreign_shares.do`.
* Download data from IPUMS-CPS for the CPS (ASEC) years 1978-2011. The list of variables is included in the top section of the file `Data/cr_statecontrols.do`.
