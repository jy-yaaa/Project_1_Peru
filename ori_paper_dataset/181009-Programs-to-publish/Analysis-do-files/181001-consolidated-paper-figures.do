******************************************************************************
* TABLE OF CONTENTS:						     					
* 1. INTRODUCTION
* 2. SET ENVIRONMENT
* 3. CODING AND OUTPUT FOR FIGURES 4-6, COMBINED INDONESIA/PERU
* 4. CODING AND OUTPUT FOR FIGURE 3 (INCOME PREDICTION PLOT), INDONESIA/PERU SEPARATE

******************************************************************************

*** 1. INTRODUCTION ***
/*
Date created: 	July 23, 2018 (Updated October 9, 2018)
Created by: 	Aaron Berman 
Project: 		Universal Basic Incomes versus Targeted Transfers
PIs: 			Rema Hanna, Ben Olken
Description: 	Creates Figures 3-6 for Paper
Uses: 			plotting_data.dta and coded_test_data.dta for each country
Creates: 		.png and .eps files for Figures 3-6 and Appendix Figures 
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
global datapathperu = "$surveypath/Data to use for Peru analysis"
global datapathindo = "$surveypath/Data to use for analysis"
global figurepath = "$surveypath/Paper Figures Combined"

if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

if "$dopath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

//locals for running segments of code
local mainfigs = 1 //run for Figure 4-6
local predictionfig = 1 //run for Figure 3 (prediction plots)


*** 3. CODING AND OUTPUT FOR FIGURES 4-6, COMBINED INDONESIA/PERU ***
if `mainfigs' == 1 {
	//set directory
	cd "$datapathperu"

	//open peru data
	use "plotting_data.dta", clear

	//label peru variables as such, keep cutoff as-is for merge 
	foreach x of varlist incl_error_normal-horizontal_equity {
		rename `x' peru_`x'
	}

	tempfile peru_plotting 
	save `peru_plotting', replace 

	//open indonesia data 
	cd "$datapathindo"
	use "plotting_data.dta", clear 

	//merge in peru data 
	merge 1:1 cutoff using `peru_plotting'
	drop _merge 

	cd "$figurepath"
	
	//Figure 4 Panel A: ROC Curve (Main Figure: 1.5x poverty line for Indonesia, 1x poverty for Peru)
	twoway (line oneminus_excl_error_near incl_error_near) (line peru_oneminus_excl_error_normal peru_incl_error_normal) ///
	 	(line incl_error_normal incl_error_normal, lcolor(black) lwidth(thin) lpattern(dash)), ytitle(1 - Exclusion Error) xtitle(Inclusion Error) ///
	 	xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) legend(order(1 "Indonesia" 2 "Peru" 3 "45° line")) xsize(6) ysize(6) aspect(1) graphregion(color(white))

	graph export "ROC Indonesia Peru_main_whitebg.png", replace 
	graph export "ROC Indonesia Peru_main_whitebg.eps", replace
	graph export "Figure 4 Panel A.eps", replace 

	//Figure 4 Panel A: ROC Curve (Appendix Figure: 1x poverty line)
	twoway (line oneminus_excl_error_normal incl_error_normal) (line peru_oneminus_excl_error_normal peru_incl_error_normal) ///
	 	(line incl_error_normal incl_error_normal, lcolor(black) lwidth(thin) lpattern(dash)), ytitle(1 - Exclusion Error) xtitle(Inclusion Error) ///
	 	xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) legend(order(1 "Indonesia" 2 "Peru" 3 "45° line")) xsize(6) ysize(6) graphregion(color(white))

	graph export "ROC_Indonesia_Peru_poverty_line_whitebg.png", replace
	graph export "ROC_Indonesia_Peru_poverty_line_whitebg.eps", replace 

	//Figure 4 Panel A: ROC Curve (Appendix Figure: 1.5x poverty line)
	twoway (line oneminus_excl_error_near incl_error_near) (line peru_oneminus_excl_error_near peru_incl_error_near) ///
	 	(line incl_error_normal incl_error_normal, lcolor(black) lwidth(thin) lpattern(dash)), ytitle(1 - Exclusion Error) xtitle(Inclusion Error) ///
	 	xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) legend(order(1 "Indonesia" 2 "Peru" 3 "45° line")) xsize(6) ysize(6) graphregion(color(white))

	graph export "ROC_Indonesia_Peru_near_poor_whitebg.png", replace
	graph export "ROC_Indonesia_Peru_near_poor_whitebg.eps", replace 

	//Figure 4 Panel A: ROC Curve (Appendix Figure: 0.75x poverty line)
	twoway (line oneminus_excl_error_extreme incl_error_extreme) (line peru_oneminus_excl_error_extreme peru_incl_error_extreme) ///
	 	(line incl_error_normal incl_error_normal, lcolor(black) lwidth(thin) lpattern(dash)), ytitle(1 - Exclusion Error) xtitle(Inclusion Error) ///
	 	xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) legend(order(1 "Indonesia" 2 "Peru" 3 "45° line")) xsize(6) ysize(6) graphregion(color(white))

	graph export "ROC_Indonesia_Peru_extreme_poor_whitebg.png", replace
	graph export "ROC_Indonesia_Peru_extreme_poor_whitebg.eps", replace 




	***
	//Figure 4 Panel B: Per-household monthly benefits (Main Figure: 1.5x poverty line for Indonesia, 1x poverty for Peru)
	twoway (line per_hh_benefits incl_error_near if incl_error_near > 0.02) (line disc_per_hh_benefits x_disc, lcolor(navy)) ///
		(line peru_per_hh_benefits peru_incl_error_normal if peru_incl_error_normal > 0.02, lcolor(maroon) yaxis(2)) (line peru_disc_per_hh_benefits peru_x_disc, lcolor(maroon) yaxis(2)), ///
		ytitle(Per-household monthly benefits (Indonesian rupiah), axis(1)) ytitle(Per-household monthly benefits (Peruvian soles), axis(2)) yscale(range(0 120) axis(2)) ///
		ytitle(, margin(vsmall)) ylabel(, labsize(small)) ylabel(0 20 40 60 80 100 120, axis(2)) xtitle(Inclusion Error) ///
		xtitle(, margin(vsmall)) xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) legend(order(1 "Indonesia" 3 "Peru")) graphregion(color(white))

	graph export "Per-household benefits Indonesia Peru_main_whitebg.png", replace
	graph export "Per-household benefits Indonesia Peru_main_whitebg.eps", replace
	graph export "Figure 4 Panel B.eps", replace



	***
	//Figure 5: Social Welfare (CRRA Utility)
	twoway (line crra incl_error_near) (line peru_crra peru_incl_error_normal, yaxis(2) lcolor(maroon)) (line disc_crra x_disc, lcolor(navy)) ///
		(line peru_disc_crra peru_x_disc, yaxis(2) lcolor(maroon)), ytitle(CRRA Utility - Indonesia) ylabel(, labsize(small)) ///
		ytitle(CRRA Utility - Peru, axis(2)) ylabel(, labsize(small) axis(2)) xline(0.07348197, lwidth(vvvthin) lpattern(vshortdash) ///
		lcolor(navy)) xtitle(Inclusion Error) xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) xline(0.06425334, lwidth(vvvthin) lpattern(vshortdash) lcolor(maroon)) legend(order(1 "Indonesia" 3 "Peru")) graphregion(color(white))

	graph export "CRRA Social Welfare Indonesia Peru_whitebg.png", replace
	graph export "CRRA Social Welfare Indonesia Peru_whitebg.eps", replace
	graph export "Figure 5.eps", replace



	***
	//Figure 6: Horizontal Equity 
	twoway (line horizontal_equity incl_error_near) (line peru_horizontal_equity peru_incl_error_normal), ytitle(Horizontal Equity) ylabel(0(0.2)1) ///
		xtitle(Inclusion Error) xline(0.42723262, lwidth(vvthin) lpattern(dash) lcolor(maroon)) xline(0.2928, lwidth(vvthin) lpattern(dash) lcolor(navy)) ///
		yline(0.75324702, lwidth(vvvthin) lpattern(vshortdash) lcolor(maroon)) yline(0.6883, lwidth(vvvthin) lpattern(vshortdash) lcolor(navy)) ///
		xlabel(0 0.2 0.4 0.6 0.8 1 "1 = UBI", labsize(small)) legend(order(1 "Indonesia" 2 "Peru")) graphregion(color(white))


	graph export "Horizontal Equity Indonesia Peru_whitebg.png", replace
	graph export "Horizontal Equity Indonesia Peru_whitebg.eps", replace
	graph export "Figure 6.eps", replace
}



*** 4. CODING AND OUTPUT FOR FIGURE 3 (INCOME PREDICTION PLOT), INDONESIA/PERU SEPARATE ***
if `predictionfig' == 1 {
	***INDONESIA
	//per-capita consumption (non-log)
	cd "$datapathindo"
	use "coded_test_data.dta", clear

	//only need to keep a few variables
	keep percapitaconsumption percapitahat lnpercapitaconsumption lncaphat

	forv x = 1/2 {
		local sample: word `x' of "full" "sampled"
		if `x' == 2 {
			set seed 28202456
			sample 10
		}

		//log per-capita consumption
		preserve
		sum lnpercapitaconsumption, d
		//variables for vertical lines
		local min = `r(min)'
		gen p25 = `r(p25)'
		gen p50 = `r(p50)'
		gen p75 = `r(p75)'
		gen p90 = `r(p90)'
		gen p95 = `r(p95)'
		local p99 = `r(p99)'
		local max = `r(max)'
		egen p33 = pctile(lnpercapitaconsumption), p(33)

		//generate variable for 45-degree line
		gen degree45 = lnpercapitaconsumption
		replace degree45 = 10 in 1
		count 
		local numobs = `r(N)'
		if `x' == 2 {
			replace degree45 = ((7.35/`numobs') * _n) + 10  
		}
		
		//generate variables for vertical/horizontal lines 
		gen vlnpercapitaconsumption = lnpercapitaconsumption
		replace vlnpercapitaconsumption = 10 in 1

		
		//plot with c = 25th/30th/50th percentile 
		cd "$figurepath"
		forv i = 1/1 {
			local pct: word `i' of "p33" //change this list as necessary

		 	twoway (scatter lnpercapitaconsumption lncaphat, mcolor(midblue) msize(vsmall)) (line degree45 degree45, lpattern(dash) lcolor(black) lwidth(thin)) (line vlnpercapitaconsumption `pct', lcolor(black)) ///
			(line `pct' vlnpercapitaconsumption, lcolor(black)), xscale(range(10 17)) yscale(range(10 17)) xlabel(#7) ylabel(#7) aspect(1) xsize(6) ysize(6) legend(off) ///
			ytitle(Actual log per-capita monthly consumption (Rp.)) ///
		 	xtitle(Predicted log per-capita monthly consumption (Rp.)) xlabel(, labsize(small)) ylabel(, labsize(small)) ///
		 	text(14 10 "Inclusion error", size(small) placement(e)) ///
		 	text(11 10 "Correct inclusion", size(small) placement(e)) ///
		 	text(14 14.5 "Correct exclusion", size(small) placement(e)) ///
		 	text(11 14 "Exclusion error", size(small) placement(e)) ///
		 	title(Indonesia) graphregion(color(white))

		 	graph export "indonesia log income prediction_cutoff `pct' `sample'_whitebg.png", replace
		 	graph export "indonesia log income prediction_cutoff `pct' `sample'_whitebg.eps", replace
		 	if "`sample'" == "sampled" {
		 		graph export "Figure 3 Indonesia.eps", replace
		 	}

		}
		restore
	}



	***PERU
	cd "$datapathperu"
	use "coded_test_data.dta", clear 

	//only need to keep a few variables
	keep percapitaconsumption percapitahat lnpercapitaconsumption lncaphat

	forv x = 1/2 {
		local sample: word `x' of "full" "sampled"
		if `x' == 2 {
			set seed 28620546
			sample 50
		}

		
		//log per-capita consumption
		preserve
		sum lnpercapitaconsumption, d
		//variables for vertical lines
		local min = `r(min)'
		gen p25 = `r(p25)'
		gen p50 = `r(p50)'
		gen p75 = `r(p75)'
		gen p90 = `r(p90)'
		gen p95 = `r(p95)'
		local p99 = `r(p99)'
		local max = `r(max)'
		egen p28 = pctile(lnpercapitaconsumption), p(28)

		//generate variable for 45-degree line
		gen degree45 = lnpercapitaconsumption
		count 
		local numobs = `r(N)'
		if `x' == 2 {	
			replace degree45 = ((8/`numobs') * _n) + 2  
		}

		//generate variables for vertical lines 
		gen vlnpercapitaconsumption = lnpercapitaconsumption
		replace vlnpercapitaconsumption = 2 in 1
		replace vlnpercapitaconsumption = 10 in `numobs'

		//plot with c = 25th/50th/75th percentile 
		cd "$figurepath"
		forv i = 1/1 {
			local pct: word `i' of "p28"

		 	twoway (scatter lnpercapitaconsumption lncaphat, mcolor(midblue) msize(vsmall)) (line degree45 degree45, lpattern(dash) lcolor(black) lwidth(thin)) (line vlnpercapitaconsumption `pct', lcolor(black)) ///
			(line `pct' vlnpercapitaconsumption, lcolor(black)), ///
			xscale(range(2 10)) yscale(range(2 10)) xlabel(#8) ylabel(#8) aspect(1) xsize(6) ysize(6) legend(off) ///
			ytitle(Actual log per-capita monthly consumption (S.)) ///
		 	xtitle(Predicted log per-capita monthly consumption (S.)) xlabel(, labsize(small)) ylabel(, labsize(small)) ///
		 	text(6 2 "Inclusion error", size(small) placement(e)) ///
		 	text(3 2 "Correct inclusion", size(small) placement(e)) ///
		 	text(6 7 "Correct exclusion", size(small) placement(e)) ///
		 	text(3 6.5 "Exclusion error", size(small) placement(e)) ///
		 	title(Peru) graphregion(color(white))

		 	graph export "peru log income prediction_cutoff `pct' `sample' whitebg.png", replace
		 	graph export "peru log income prediction_cutoff `pct' `sample' whitebg.eps", replace
		 	if "`sample'" == "sampled" {
		 		graph export "Figure 3 Peru.eps", replace
		 	}

		}
		restore

	}
}

