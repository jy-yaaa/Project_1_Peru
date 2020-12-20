******************************************************************************
* TABLE OF CONTENTS:						     					
* 1. INTRODUCTION
* 2. SET ENVIRONMENT
* 3. SPECIFY TRAINING/TEST AND PERFORM INITIAL PREDICTIONS
* 4. PERFORM CALCULATIONS FOR FIGURES
* 5. OUTPUT FIGURES

******************************************************************************

*** 1. INTRODUCTION ***
/*
Date created: 	December 24, 2017 (Updated October 1, 2018)
Created by: 	Aaron Berman 
Project: 		Universal Basic Incomes versus Targeted Transfers
PIs: 			Rema Hanna, Ben Olken
Description: 	Analyzes coded ENAHO data and outputs paper Figure 7.
Uses: 			cleandata.dta (Peru ENAHO version)
Creates: 		coded_test_data.dta, plotting_data.dta, coded_test_data with figure 7 variables.dta, Figure 7 graph
*/

*** 2. SET ENVIRONMENT ***

version 14.1 
set more off		
clear all			
pause on 			
capture log close 	

//setup 
*PLUG IN LOCAL FILE PATH HERE
*global surveypath = ".../181009 Programs to publish" 
global dopath = "$surveypath/Coding do files"
global datapath = "$surveypath/Data to use for Peru analysis"
global figurepath = "$surveypath/Paper Figures Combined"

if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

if "$dopath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

//set directory
cd "$datapath"

//open new ENAHO data
use "cleandata.dta"
duplicates drop



*** 3. SPECIFY TRAINING/TEST AND PERFORM INITIAL PREDICTIONS ***
set seed 83635628
generate random = runiform()
sort random 
generate training = ceil(2 * _n/_N) - 1
drop random 
***

//generate thresholds for 0.75x (extreme poor) and 1.5x (near poor) poverty line
gen povertyline75pct = 0.75*povertyline
gen povertyline150pct = 1.5*povertyline 

gen extreme_poor = (percapitaconsumption < povertyline75pct) //there are no missing values of percapitaconsumption
gen near_poor = (percapitaconsumption < povertyline150pct) //so no need to worry about misleading 0s

//regress ln consumption on asset dummies for TRAINING data only 
gen lnpercapitaconsumption = ln(percapitaconsumption)
reg lnpercapitaconsumption d_* if training == 1, vce(robust)
//predict ln consumption in the TEST set 
predict lncaphat if training == 0

//also predict percapitaconsumption in test set
reg percapitaconsumption d_* if training == 1, vce(robust)
predict percapitahat if training == 0

//predict percapitaconsumption with ADDED NOISE in test set for Figure 7
predict percapitahat_residuals if training == 0, residuals 
//don't want to use above 95th percentile residuals 
	sum percapitaconsumption, d
	gen sample_use = (percapitaconsumption < r(p95)) if training == 0
	replace percapitahat_residuals = . if sample_use == 0

//get standard deviation of residuals
egen percapitahat_residuals_sd = sd(percapitahat_residuals) if training == 0

//set seed for rnormal()
set seed 70043812
//generate new predicted per-capita consumption values (in test set) with added noise 
gen percapitahat_morenoise = percapitahat + percapitahat_residuals_sd*rnormal() if training == 0





*** 4. PERFORM CALCULATIONS FOR FIGURES ***
//drop training set so subsequent calculations run faster
drop if training == 1

//Inclusion/exclusion calculations
//first, create 101 different cutoff values corresponding to %iles of lncaphat.
gen c_0 = 0
forvalues i = 1/99 {
	egen c_`i' = pctile(lncaphat), p(`i') //already excludes those for whom lncaphat is missing 
}
egen c_100 = max(lncaphat)
replace c_100 = c_100 + 1 //adding 1 arbitrarily so that max value of lncaphat is actually captured/included 



//create local for overall program budget that can easily be tweaked later 
local national_num_households = 6750000
local program_budget_monthly = 880000000/12
	//this comes from Peruvian document regarding "Juntos" program budget 

//count number of households in (non-missing) predicted test set (for calculating proportions)
egen samplesize = count(lncaphat)

//generate dummies for if individual is included or excluded based on 101 different cutoffs
forvalues i = 0/100 {
	quietly{
		//dummy if household is included 
		gen incl_c_`i' = (lncaphat < c_`i') if !missing(lncaphat)
		//number of individuals included 
		gen num_incl_`i' = incl_c_`i' * h_hhsize if !missing(lncaphat)
		//inclusion error for poor, extreme poor, near poor curves 
		gen incl_error_normal`i' = (incl_c_`i' == 1) if !missing(lncaphat) & poor == 0
		gen incl_error_extreme`i' = (incl_c_`i' == 1) if !missing(lncaphat) & extreme_poor == 0
		gen incl_error_near`i' = (incl_c_`i' == 1) if !missing(lncaphat) & near_poor == 0

		//exclusion error for poor, extreme poor, near poor curves
		gen excl_error_normal`i' = (incl_c_`i' == 0) if !missing(lncaphat) & poor == 1
		gen excl_error_extreme`i' = (incl_c_`i' == 0) if !missing(lncaphat) & extreme_poor == 1
		gen excl_error_near`i' = (incl_c_`i' == 0) if !missing(lncaphat) & near_poor == 1

		//calculate total number and % of households included for each cutoff 
		egen households_incl_`i' = total(incl_c_`i')
		gen pct_households_incl_`i' = households_incl_`i' / samplesize 

		//calculate (NATIONAL) per-household benefits for each cutoff 
		gen national_hh_incl`i' = `national_num_households' * pct_households_incl_`i' 
		gen per_hh_benefits`i' = `program_budget_monthly' / national_hh_incl`i' 

		//for each household, sum per-capita consumption and per-capita benefits (if included for this cutoff)
		gen benefits_received_`i' = 0 if !missing(lncaphat)
		replace benefits_received_`i' = per_hh_benefits`i' if incl_c_`i' == 1
		gen percapita_benefits_received_`i' = benefits_received_`i' / h_hhsize
		gen income_`i' = percapitaconsumption + percapita_benefits_received_`i'

		//calculate individual CRRA utility 
		gen crra`i' = ((income_`i')^(-2))/(-2) if !missing(lncaphat)
	}
}

//generate percentile scores for ACTUAL percapitaconsumption for horizontal equity calculations 
sort percapitaconsumption
gen income_percentile = ((_n - 1)/ _N) * 100
replace income_percentile = floor(income_percentile)
replace income_percentile = . if missing(lncaphat) // want to exclude missing lncaphat FOR NOW 

//calculate horizontal equity by percentile for each cutoff value 
forvalues i = 0/100 { //NOTE: THIS STEP TAKES A LONG TIME. Could abbreviate to i= 0(10)100 for faster runtime
	quietly {
		//initialize inclusion/exclusion PERCENTAGES given cutoff i 
		gen included_within_band`i' = 0 if !missing(income_percentile)
		gen excluded_within_band`i' = 0 if !missing(income_percentile)

		//iterate through each income percentile and calculate percentage included within +/- 5%, given cutoff i 
		forvalues j = 0/99 {
			local jminus5 = `j' - 5
			local jplus5 = `j' + 5

			egen pct_included = mean(incl_c_`i') if income_percentile >= `jminus5' & income_percentile <= `jplus5'
			replace included_within_band`i' = pct_included if income_percentile == `j' 
			replace excluded_within_band`i' = 1 - pct_included if income_percentile == `j' 

			drop pct_included

			local numloops = `i'*100 + `j'
			noisily display "`numloops'"  
		}

		gen pct_treated_different`i' = included_within_band`i' if incl_c_`i' == 0
		replace pct_treated_different`i' = excluded_within_band`i' if incl_c_`i' == 1
	}
}


//incorporate discontinuous jump in per-household benefits and welfare for ubi only 
gen bonus_perhh = 2.235/12
	//note: this comes from costs of 4.7million USD / year
	//multiplied by 3.21 soles/USD
	//divided by 12 in order to make sure we are dealing with montly benefits
gen bonus_percapita = bonus_perhh / h_hhsize

//for per-household benefits discontinuity 
gen disc_per_hh_benefits100 = per_hh_benefits100 + bonus_perhh if !missing(lncaphat)

//for per-capita consumption / social welfare discontinuity 
gen disc_income_100 = income_100 + bonus_percapita if !missing(lncaphat)
gen disc_crra100 = ((disc_income_100)^(-2))/(-2) if !missing(lncaphat)

//save the coded test dataset as-is
save "coded_test_data", replace 

//calculate inclusion/exclusion error rate and total number of HH/individuals included for each cutoff value 
collapse (mean) incl_error_* excl_error_* included_within_band* excluded_within_band* pct_treated_different* national_hh_incl* per_hh_benefits* disc_per_hh_benefits* (sum) incl_c_* num_incl_* crra* disc_crra*

//reshape long so we have 1 observation (inclusion error, 1-exclusion error) for each cutoff point 
gen nth = (_n)
reshape long incl_error_normal incl_error_near incl_error_extreme excl_error_normal excl_error_near excl_error_extreme incl_c_ num_incl_ ///
				national_hh_incl per_hh_benefits disc_per_hh_benefits crra disc_crra included_within_band excluded_within_band pct_treated_different, i(nth) j(cutoff)
drop nth 

rename incl_c_ households_included
rename num_incl_ individuals_included

//calculate 1-exclusion rate for plotting on y-axis 
foreach x of varlist excl_error_normal excl_error_near excl_error_extreme {
	gen oneminus_`x' = 1 - `x'
}

//incorporate discontinuity for UBI
gen per_hh_benefits_with_disc = per_hh_benefits
replace per_hh_benefits_with_disc = disc_per_hh_benefits if cutoff == 100 

gen crra_with_disc = crra 
replace crra_with_disc = disc_crra if cutoff == 100 

replace disc_per_hh_benefits = per_hh_benefits[101] if cutoff == 99
replace disc_crra = crra[101] if cutoff == 99
gen x_disc = 1

//gen equity measure
gen horizontal_equity = 1 - pct_treated_different

//save data with plot points 
save "plotting_data", replace 





*** 5. OUTPUT FIGURES ***
//Note: in this file, we only output Figure 7, which is specific to Peru
cd "$figurepath"

//reopen "coded_test_data"
cd "$datapath"
use "coded_test_data", clear

//Figure 7: Expected tax rate given 1x poverty line cutoff (NOTE THIS IS NOT 1.5x AS IN INDONESIA)
gen receive_benefit = (percapitahat < povertyline) if !missing(percapitahat)
//fit lpoly function to (estimated) benefit receipt status, for 1x targeting
lpoly receive_benefit percapitaconsumption if sample_use == 1 & !missing(percapitahat), bw(75) generate(prob_receive_benefit) at(percapitaconsumption)
//take first derivative numerically
dydx prob_receive_benefit percapitaconsumption if sample_use == 1 & !missing(percapitahat), generate(derivative_prob_receive)
//benefit amount: 100 soles/month per household 
gen benefit_amount = 100 if !missing(derivative_prob_receive)
//generate variable to plot 
gen tax = -1 * derivative_prob_receive * benefit_amount


//do same calculations with "more noise" version of percapitahat
gen receive_benefit_morenoise = (percapitahat_morenoise < povertyline) if !missing(percapitahat_morenoise)
//fit lpoly function to (estimated) benefit receipt status  
lpoly receive_benefit_morenoise percapitaconsumption if sample_use == 1 & !missing(percapitahat_morenoise), bw(75) generate(prob_receive_benefit_morenoise) at(percapitaconsumption)
//take first derivative numerically
dydx prob_receive_benefit_morenoise percapitaconsumption if sample_use == 1 & !missing(percapitahat), generate(deriv_prob_receive_morenoise)
//generate variable to plot 
gen tax_morenoise = -1 * deriv_prob_receive_morenoise * benefit_amount
//save
save "coded_test_data with figure 7 variables", replace



//plot and save
cd "$figurepath"

//Implied tax rate, comparing normal vs. "more noise" version 
twoway (lpoly tax percapitaconsumption if sample_use == 1, bw(75)) (lpoly tax_morenoise percapitaconsumption if sample_use == 1, bw(75)), ///
 		ytitle(Implied Tax Rate) yline(0, lwidth(medthin) lcolor(black)) xtitle(Monthly per-capita household consumption (S.)) title(Peru) legend(order(1 "Normal OLS Prediction" 2 "OLS Prediction with Doubled Noise")) ///
		xscale(range(0 1200)) xlabel(0 300 600 900 1200) graphregion(color(white))
		
graph export "Figure 7 Peru normal and added noise_whitebg.png", replace 
graph export "Figure 7 Peru normal and added noise_whitebg.eps", replace 
graph export "Figure 7 Peru.eps", replace 
