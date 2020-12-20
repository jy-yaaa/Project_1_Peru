******************************************************************************
* TABLE OF CONTENTS:						     					*
* 1. INTRODUCTION
* 2. SET ENVIRONMENT
* 3. INDONESIA PREDICTIVE REGRESSION
* 4. PERU PREDICTIVE REGRESSION
******************************************************************************

*** 1. INTRODUCTION ***
/*
Date created: 	July 23, 2018 (Updated October 1, 2018)
Created by: 	Aaron Berman (aberman.hks@gmail.com)
Project: 		Universal Basic Incomes versus Targeted Transfers
PIs: 			Rema Hanna, Ben Olken
Description: 	Creates income prediction regression tables for Indonesia and Peru
				(Appendix Tables 1 and 2)
Uses: 			cleandata.dta for each country
Creates: 		Indonesia predictive.tex, Peru predictive.tex
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
global latex = "$surveypath/Paper Figures Combined/latex"

if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

if "$dopath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}




*** 3. INDONESIA PREDICTIVE REGRESSION ***
//set directory
cd "$datapathindo"

//open new Susenas data
use "cleandata.dta", clear 

*duplicates report 
duplicates drop //drop 1 pure duplicate observation


//SPECIFY TRAINING/TEST DATA
set seed 19047130
generate random = runiform()
sort random 
generate training = ceil(2 * _n/_N) - 1
drop random 

//regress ln consumption on asset dummies for TRAINING data only 
gen lnpercapitaconsumption = ln(percapitaconsumption)
eststo indonesia: reg lnpercapitaconsumption d_* if training == 1, vce(robust)
pause
//add control mean 
summ lnpercapitaconsumption if training == 1
estadd scalar control_mean `r(mean)'


//output Indonesia table 
cd "$latex"

#delimit ;
esttab indonesia 
	using "Indonesia predictive.tex", booktabs label se
	b(%12.3f)
	se(%12.3f)
	starlevels(* .10 ** .05 *** .01)
	mlabels("Log per-capita consumption")
	varlab(d_h_hhage0_30 "Household head age $\leq 30$" 
			d_h_hhage30_50 "Household head age 30-50" 
			d_h_hhmale "Household head is male"
			d_h_hhmarried "Household head is married" 
			d_h_hhsize0_2 "Household size: 1-2 people"
			d_h_hhsize2_4 "Household size: 3-4 people" 
			d_h_depend_c1 "Household has 1 dependent child"
			d_h_depend_c2 "Household has 2 dependent children" 
			d_h_depend_c3m "Household has 3 or more dependent children"
			d_h_depend_p65 "Household has dependent over age 65" 
			d_h_hhsd "Highest education of HH head: elementary"
			d_h_hhsmp "Highest education of HH head: junior high" 
			d_h_hhsma "Highest education of HH head: high school" 
			d_h_hhdip1_s3 "Highest education of HH head: tertiary" 
			d_h_hhmaxedsmp "Highest education of anyone in HH: junior high" 
			d_h_hhmaxedsma "Highest education of anyone in HH: high school"
			d_h_hhmaxedsd "Highest education of anyone in HH: elementary" 
			d_h_hhmaxeddip1_s3 "Highest education of anyone in HH: tertiary" 
			d_h_childdip1_s3_1 "Household has 1 child in tertiary educ."
			d_h_childdip1_s3_2 "Household has 2 children in tertiary educ."
			d_h_childdip1_s3_3 "Household has 3 children in tertiary educ."
			d_h_hhagr "Household head works in agricultural sector"
			d_h_hhind "Household head works in industry sector"
			d_h_workstat1 "Household head is self-employed"
			d_h_workstat2 "Household head is self-employed w/ unpaid employees"
			d_h_workstat3 "Household head is self-employed w/ paid employees"
			d_h_workstat4 "Household head is an employee"
			d_h_workstat5 "Household head an unpaid family worker"
			d_h_troof1 "Roof type: concrete or roof tile"
			d_h_troof2 "Roof type: shingle (sirap)"
			d_h_troof3 "Roof type: zinc"
			d_h_troof4 "Roof type: asbestos"
			d_h_twall1 "Wall type: cement"
			d_h_twall2 "Wall type: wood"
			d_h_tfloor "Household has non-soil floor"
			d_h_house1 "House is owned"
			d_h_house2 "House is rented"
			d_h_house3 "House is rented/occupied for free"
			d_h_house4 "House is official residence"
			d_h_dwater1 "Drinking water source: mineral/bottle"
			d_h_dwater2 "Drinking water source: tap/plubming"
			d_h_dwater3 "Drinking water source: drill/pump"
			d_h_dwater4 "Drinking water source: protected well"
			d_h_dwater5 "Drinking water source: unprotected well"
			d_h_pwater "Household pays for drinking water"
			d_h_toilet1 "Household has private toilet"
			d_h_toilet2 "Household uses shared/public toilet"
			d_h_septic "Household has septic tank"
			d_h_lighting1 "Electricity from PLN with meter"
			d_h_lighting2 "Electricity from PLN without meter"
			d_h_lighting3 "Non-PLN electricity"
			d_h_aset_fridge "Household has refrigerator"
			d_h_aset_gas "Household has 12kg+ gas tube"
			d_h_aset_motorcycle "Household has a motorcycle"
			d_h_aset_bicycle "Household has a bicycle"
			d_h_urban "Household in urban area"
			d_pds_road "Village has asphalt road"
			d_pds_sma "Village has senior high school"
			d_pds_smp "Village has junior high school"
			d_pds_sd "Village has elementary school"
			d_pds_puskesmas "Village has \emph{puskesmas} health facility"
			d_pds_polindes "Village has \emph{polindes} health facility"
			d_pds_doctor "Village has doctor"
			d_pds_bidan "Village has bidan/midwife"
			d_pds_office "Village has post office"
			d_pds_credit "Village has credit facility"
			d_pds_dist2 "Dist. to nearest city center: 2nd quartile"
			d_pds_dist3 "Dist. to nearest city center: 3rd quartile"
			d_pds_dist4 "Dist. to nearest city center: 4th quartile")
	order(d_h_hhage0_30 d_h_hhage30_50 d_h_hhmale d_h_hhmarried d_h_hhsize0_2 d_h_hhsize2_4 d_h_depend_c1 d_h_depend_c2 d_h_depend_c3m d_h_depend_p65
		d_h_hhsd d_h_hhsmp d_h_hhsma d_h_hhdip1_s3 d_h_hhmaxedsd)
	r2
	nocons
	gaps
	scalars("control_mean Control Mean")
	nonotes
	noomitted
	fragment
	replace;

#delimit cr




*** 4. PERU PREDICTIVE REGRESSION ***

//set directory
cd "$datapathperu"


//open new ENAHO data
use "cleandata.dta", clear
duplicates drop

//SPECIFY TRAINING/TEST DATA
set seed 83635628
generate random = runiform()
sort random 
generate training = ceil(2 * _n/_N) - 1
drop random 

//regress ln consumption on asset dummies for TRAINING data only 
gen lnpercapitaconsumption = ln(percapitaconsumption)

//specify varlist for control over omitted categories 
ds d_*
local allvars `r(varlist)'
local exclude = "d_fuel_other d_water_other d_wall_other d_roof_other d_floor_other d_insurance_0 d_crowd_lessthan1 d_lux_0 d_h_educ_none"
local regvars: list allvars - exclude 

eststo peru: reg lnpercapitaconsumption `regvars' if training == 1, vce(robust)

//add control mean 
summ lnpercapitaconsumption if training == 1
estadd scalar control_mean `r(mean)'


//output Peru table 
cd "$latex"

#delimit ;
esttab peru 
	using "Peru predictive.tex", booktabs label se
	b(%12.3f)
	se(%12.3f)
	starlevels(* .10 ** .05 *** .01)
	mlabels("Log per-capita consumption")
	varlab(d_fuel_other "Household uses other fuel for cooking" 
			d_fuel_wood "Household uses wood fuel for cooking"
			d_fuel_coal "Household uses coal fuel for cooking"
			d_fuel_kerosene "Household uses kerosene fuel for cooking"
			d_fuel_gas "Household uses gas fuel for cooking"
			d_fuel_none "Household does not cook"
			d_fuel_electric "Household uses electricity for cooking"
			d_water_other "Water source: other"
			d_water_river "Water source: river"
			d_water_well "Water source: well"
			d_water_truck "Water source: water truck"
			d_water_pylon "Water source: pylon"
			d_water_outside "Water source: public network outside HH"
			d_water_inside "Water source: public network inside HH"
			d_drain_none "Drainage source: none"
			d_drain_river "Drainage source: river"
			d_drain_cesspool "Drainage source: cesspool"
			d_drain_septic "Drainage source: septic tank"
			d_drain_outside "Drainage source: public network outside HH"
			d_drain_inside "Drainage source: public network inside HH"
			d_wall_other "Wall type: other"
			d_wall_woodmat "Wall type: wood or mat"
			d_wall_stonemud "Wall type: stone or mud"
			d_wall_quincha "Wall type: \emph{quincha}"
			d_wall_tapia "Wall type: \emph{tapia} (rammed earth)"
			d_wall_adobe "Wall type: adobe"
			d_wall_stonecement "Wall type: stone with lime or cement"
			d_wall_brickcement "Wall type: brick or cement block"
			d_roof_other "Roof type: other"
			d_roof_straw "Roof type: straw"
			d_roof_platecane "Roof type: iron or cane"
			d_roof_tile "Roof type: tile"
			d_roof_wood "Roof type: wood"
			d_roof_concrete "Roof type: concrete"
			d_roof_mat "Roof type: mat"
			d_floor_other "Floor type: other"
			d_floor_earth "Floor type: earth"
			d_floor_cement "Floor type: cement"
			d_floor_wood "Floor type: wood"
			d_floor_tile "Floor type: tile"
			d_floor_sheets "Floor type: sheet metal"
			d_floor_parquet "Floor type: parquet"
			d_electricity "Household has electricity"
			d_telephone "Household has telephone"
			d_h_educ_none "Highest education of HH head: none"
			d_h_educ_pre "Highest education of HH head: pre-school"
			d_h_educ_prim "Highest education of HH head: primary"
			d_h_educ_sec "Highest education of HH head: secondary"
			d_h_educ_higher_nouni "Highest education of HH head: tertiary (non-univ.)"
			d_h_educ_higher_uni "Highest education of HH head: tertiary (univ.)"
			d_h_educ_post "Highest education of HH head: post-graduate"
			d_max_educ_none "Highest education of anyone in HH: none"
			d_max_educ_prim "Highest education of anyone in HH: primary"
			d_max_educ_sec "Highest education of anyone in HH: secondary"
			d_max_educ_higher_nouni "Highest education of anyone in HH: tertiary (non-univ.)"
			d_max_educ_higher_uni "Highest education of anyone in HH: tertiary (univ.)"
			d_insurance_0 "0 HH members affiliated w/ health insurance"
			d_insurance_1 "1 HH member affiliated w/ health insurance"
			d_insurance_2 "2 HH members affiliated w/ health insurance"
			d_insurance_3 "3 HH members affiliated w/ health insurance"
			d_insurance_4plus "4+ HH members affiliated w/ health insurance"
			d_crowd_lessthan1 "<1 household member per room"
			d_crowd_1to2 "1-2 household members per room"
			d_crowd_2to4 "2-4 household members per room"
			d_crowd_4to6 "4-6 household members per room"
			d_crowd_6plus "6+ household members per room"
			d_lux_0 "0 of 5 luxury goods owned"
			d_lux_1 "1 of 5 luxury goods owned"
			d_lux_2 "2 of 5 luxury goods owned"
			d_lux_3 "3 of 5 luxury goods owned"
			d_lux_4 "4 of 5 luxury goods owned"
			d_lux_5 "5 of 5 luxury goods owned")
	order(d_crowd_1to2 d_crowd_2to4 d_crowd_4to6 d_crowd_6plus d_electricity d_telephone
			d_lux_1 d_lux_2 d_lux_3 d_lux_4 d_lux_5)
	r2
	nocons
	gaps
	scalars("control_mean Control Mean")
	nonotes
	noomitted
	fragment
	replace;

#delimit cr
