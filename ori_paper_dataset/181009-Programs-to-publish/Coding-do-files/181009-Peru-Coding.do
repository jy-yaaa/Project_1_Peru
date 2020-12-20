******************************************************************************
* TABLE OF CONTENTS:						     					
* 1. INTRODUCTION
* 2. SET ENVIRONMENT
* 3. CODING 2010 DATA
* 4. CODING 2011 DATA
* 5. APPEND AND SAVE

******************************************************************************

*** 1. INTRODUCTION ***
/*
Date created: 	January 3, 2018 (Updated October 9, 2018)
Created by: 	Aaron Berman 
Project: 		Universal Basic Incomes versus Targeted Transfers
PIs: 			Rema Hanna, Ben Olken
Description: 	Cleans 2010/2011 ENAHO survey data from Peru
Uses: 			[Downloaded Peru ENAHO survey data]
Creates: 		cleandata.dta
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
global datapath = "$surveypath/Peru ENAHO Data"
global analysispath = "$surveypath/Data to use for Peru analysis"

if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

if "$dopath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

//set directory
cd "$datapath"


*** 3. CODING 2010 DATA ***
cd "$datapath\2010"

***open household module 1 (Características de la Vivienda y del Hogar)
use "279-Modulo01\enaho01-2010-100.dta", clear 

//create new "year" variable because of off character in what is supposed to be año
gen year = "2010"
rename mes month 

//create unique household id variable
gen hhid = conglome + vivienda + hogar 
isid hhid //confirm that hhid uniquely identifies observations 

//want to keep only households with at least partial completion (result == 1 or 2)
keep if result == 1 | result == 2

//coding primary type of fuel used for cooking
gen d_fuel_other = 		(p113a == 7)
gen d_fuel_wood =		(p113a == 6) 
gen d_fuel_coal = 		(p113a == 5) 
gen d_fuel_kerosene =	(p113a == 4)
gen d_fuel_gas = 		(p113a == 2 | p113a == 3) 
gen d_fuel_electric = 	(p113a == 1)
gen d_fuel_none = 		(p1138 == 1)

//coding primary water source 
//ignore "t110" variable, which adds extraneous category (part of "other" here)
gen d_water_other = 	(p110 == 7)
gen d_water_river = 	(p110 == 6)
gen d_water_well  = 	(p110 == 5)
gen d_water_truck = 	(p110 == 4)
gen d_water_pylon = 	(p110 == 3)
gen d_water_outside = 	(p110 == 2)
gen d_water_inside = 	(p110 == 1)

//coding drainage source
gen d_drain_none = 		(p111 == 6)
gen d_drain_river = 	(p111 == 5)
gen d_drain_cesspool = 	(p111 == 4)
gen d_drain_septic = 	(p111 == 3)
gen d_drain_outside = 	(p111 == 2)
gen d_drain_inside = 	(p111 == 1)

//coding wall type 
gen d_wall_other = 		(p102 == 9) if !missing(p102)
gen d_wall_woodmat = 	(p102 == 7 | p102 == 8) if !missing(p102)
gen d_wall_stonemud = 	(p102 == 6) if !missing(p102)
gen d_wall_quincha = 	(p102 == 5) if !missing(p102)
gen d_wall_tapia = 		(p102 == 4) if !missing(p102)
gen d_wall_adobe = 		(p102 == 3) if !missing(p102)
gen d_wall_stonecement = (p102 == 2) if !missing(p102)
gen d_wall_brickcement = (p102 == 1) if !missing(p102)

//coding roof type 
gen d_roof_other = 		(p103a == 8) if !missing(p103a)
gen d_roof_straw = 		(p103a == 7) if !missing(p103a)
gen d_roof_mat 	 = 		(p103a == 6) if !missing(p103a)
gen d_roof_platecane = 	(p103a == 5 | p103a == 4) if !missing(p103a)
gen d_roof_tile  = 		(p103a == 3) if !missing(p103a)
gen d_roof_wood  = 		(p103a == 2) if !missing(p103a)
gen d_roof_concrete = 	(p103a == 1) if !missing(p103a)

//coding floor type
gen d_floor_other = 	(p103 == 7) if !missing(p103)
gen d_floor_earth = 	(p103 == 6) if !missing(p103)
gen d_floor_cement = 	(p103 == 5) if !missing(p103)
gen d_floor_wood = 		(p103 == 4) if !missing(p103)
gen d_floor_tile = 		(p103 == 3) if !missing(p103)
gen d_floor_sheets = 	(p103 == 2) if !missing(p103)
gen d_floor_parquet = 	(p103 == 1) if !missing(p103)

//coding electricity
gen d_electricity = 	(p1121 == 1)

//coding telephone
gen d_telephone   = 	(p1141 == 1)

//coding internet and TV cable
//NOTE: *NOT* INCLUDED IN FINAL REGRESSIONS, JUST CODING FOR LUXURY GOODS CATEGORY
gen internet = 			(p1144 == 1)
gen cable = 			(p1143 == 1)

//keep only necessary variables 
keep hhid year month p104 d_* internet cable

tempfile hh_1_2010
save `hh_1_2010', replace 


***open household education module (3)
use "279-Modulo03\enaho01a-2010-300.dta", clear 

//create unique household id variable 
gen hhid = conglome + vivienda + hogar 

//coding head of household's education level 
bysort hhid (codperso): gen head_educ = p301a[1]
//coding maxiumum household education level 
bysort hhid: egen max_educ = max(p301a)
//collapse to only one observation per household 
collapse (mean) head_educ max_educ, by(hhid)

//dummies for head of household's education level 
gen d_h_educ_none = (head_educ == 1) if !missing(head_educ)
gen d_h_educ_pre = (head_educ == 2) if !missing(head_educ)
gen d_h_educ_prim = (head_educ == 3 | head_educ == 4) if !missing(head_educ)
gen d_h_educ_sec = (head_educ == 5 | head_educ == 6) if !missing(head_educ)
gen d_h_educ_higher_nouni = (head_educ == 7 | head_educ == 8) if !missing(head_educ)
gen d_h_educ_higher_uni = (head_educ == 9 | head_educ == 10) if !missing(head_educ)
gen d_h_educ_post = (head_educ == 11) if !missing(head_educ)

//dummies for max education level 
gen d_max_educ_none = (max_educ == 1) if !missing(max_educ)
gen d_max_educ_prim = (max_educ == 3 | max_educ == 4) if !missing(max_educ)
gen d_max_educ_sec = (max_educ == 5 | max_educ == 6) if !missing(max_educ)
gen d_max_educ_higher_nouni = (max_educ == 7 | max_educ == 8) if !missing(max_educ)
gen d_max_educ_higher_uni = (max_educ == 9 | max_educ == 10) if !missing(max_educ)

//keep only necessary variables 
keep hhid d_* head_educ max_educ 

tempfile hh_3_2010
save `hh_3_2010', replace 


***open household health module (4)
use "279-Modulo04\enaho01a-2010-400.dta", clear 

//create unique household id variable 
gen hhid = conglome + vivienda + hogar 

//coding number of HH members affiliated with health insurance
egen programs_enrolled = rowtotal(p4191-p4198)
gen affiliated_insurance = (programs_enrolled > 0) if !missing(programs_enrolled)
replace affiliated_insurance = 0 if p4199 == 1
bysort hhid: egen num_affiliated = total(affiliated_insurance)
collapse num_affiliated, by(hhid)
//dummies 
gen d_insurance_0 = (num_affiliated == 0) if !missing(num_affiliated)
gen d_insurance_1 = (num_affiliated == 1) if !missing(num_affiliated)
gen d_insurance_2 = (num_affiliated == 2) if !missing(num_affiliated)
gen d_insurance_3 = (num_affiliated == 3) if !missing(num_affiliated)
gen d_insurance_4plus = (num_affiliated > 3) if !missing(num_affiliated)

//keep only necessary variables 
keep hhid num_affiliated d_*

tempfile hh_4_2010
save `hh_4_2010', replace 


***open household equipment module (18)
use "279-Modulo18\enaho01-2010-612.dta", clear 

//create unique household id variable 
gen hhid = conglome + vivienda + hogar 

//code for owning computer, refrigerator, and washer
keep if p612n == 7 | p612n == 12 | p612n == 13

keep hhid p612n p612 
reshape wide p612, i(hhid) j(p612n)

gen computer = (p6127 == 1) if !missing(p6127)
gen refrigerator = (p61212 == 1) if !missing(p61212)
gen washer = (p61213 == 1) if !missing(p61213)

//keep only new dummy variables 
keep hhid computer refrigerator washer 

tempfile hh_18_2010
save `hh_18_2010', replace

***open household "summary" module (34)
use "279-Modulo34\sumaria-2010.dta", clear

//create unique household id variable for merge 
gen hhid = conglome + vivienda + hogar

//keep only relevant variables 
keep hhid dominio estrato mieperho gashog2d linea pobreza

//now merge with all previous tempfiles 
merge 1:1 hhid using `hh_1_2010' //all should merge successfully 
	drop _merge
merge 1:1 hhid using `hh_3_2010'
	drop _merge 
merge 1:1 hhid using `hh_4_2010'
	drop _merge
merge 1:1 hhid using `hh_18_2010'
	drop _merge

//coding household crowding (HH members per room)
gen crowding = mieperho / p104
//dummies
gen d_crowd_lessthan1 = (crowding < 1) if !missing(crowding)
gen d_crowd_1to2 = (crowding >= 1 & crowding < 2) if !missing(crowding)
gen d_crowd_2to4 = (crowding >= 2 & crowding < 4) if !missing(crowding)
gen d_crowd_4to6 = (crowding >= 4 & crowding < 6) if !missing(crowding)
gen d_crowd_6plus = (crowding >= 6) if !missing(crowding)


//coding luxury goods 
egen luxury_goods = rowtotal(internet cable computer refrigerator washer), missing 
//dummies 
gen d_lux_0 = (luxury_goods == 0) if !missing(luxury_goods)
gen d_lux_1 = (luxury_goods == 1) if !missing(luxury_goods)
gen d_lux_2 = (luxury_goods == 2) if !missing(luxury_goods)
gen d_lux_3 = (luxury_goods == 3) if !missing(luxury_goods)
gen d_lux_4 = (luxury_goods == 4) if !missing(luxury_goods)
gen d_lux_5 = (luxury_goods == 5) if !missing(luxury_goods)


//coding household per capita consumption (monthly)
gen percapitaconsumption = gashog2d / (12 * mieperho)
rename mieperho h_hhsize //need to rename to align with Susenas data 

//coding household urban/rural status (not strictly necessary but helpful)
gen urban = (estrato <= 6)

//coding household poverty status 
rename linea povertyline
gen poor = (percapitaconsumption < povertyline)

//order variables so hhid, year, and month come first 
order hhid year month, first 
//and dummies all come last 
order d_*, last 


tempfile full_2010
save `full_2010', replace 







*** 4. CODING 2011 DATA ***
cd "$datapath\2011"

***open household module 1 (Características de la Vivienda y del Hogar)
use "291-Modulo01\enaho01-2011-100.dta", clear 

//create new "year" variable because of off character in what is supposed to be año
gen year = "2011"
rename mes month 

//create unique household id variable
gen hhid = conglome + vivienda + hogar 
isid hhid //confirm that hhid uniquely identifies observations 

//want to keep only households with at least partial completion (result == 1 or 2)
keep if result == 1 | result == 2

//coding primary type of fuel used for cooking	
gen d_fuel_other = 		(p113a == 7)
gen d_fuel_wood =		(p113a == 6) 
gen d_fuel_coal = 		(p113a == 5) 
gen d_fuel_kerosene =	(p113a == 4)
gen d_fuel_gas = 		(p113a == 2 | p113a == 3) 
gen d_fuel_electric = 	(p113a == 1)
gen d_fuel_none = 		(p1138 == 1)

//coding primary water source 
//ignore "t110" variable, which adds extraneous category (part of "other" here)
gen d_water_other = 	(p110 == 7)
gen d_water_river = 	(p110 == 6)
gen d_water_well  = 	(p110 == 5)
gen d_water_truck = 	(p110 == 4)
gen d_water_pylon = 	(p110 == 3)
gen d_water_outside = 	(p110 == 2)
gen d_water_inside = 	(p110 == 1)

//coding drainage source
//note: there is an extraneous unlabeled category "7" in the raw data, but to avoid dropping these households altogether,
//simply do not code a dummy for them in this category 
gen d_drain_none = 		(p111 == 6)
gen d_drain_river = 	(p111 == 5)
gen d_drain_cesspool = 	(p111 == 4)
gen d_drain_septic = 	(p111 == 3)
gen d_drain_outside = 	(p111 == 2)
gen d_drain_inside = 	(p111 == 1)

//coding wall type 
//note need to account for 489 missing values here
gen d_wall_other = 		(p102 == 9) if !missing(p102)
gen d_wall_woodmat = 	(p102 == 7 | p102 == 8) if !missing(p102)
gen d_wall_stonemud = 	(p102 == 6) if !missing(p102)
gen d_wall_quincha = 	(p102 == 5) if !missing(p102)
gen d_wall_tapia = 		(p102 == 4) if !missing(p102)
gen d_wall_adobe = 		(p102 == 3) if !missing(p102)
gen d_wall_stonecement = (p102 == 2) if !missing(p102)
gen d_wall_brickcement = (p102 == 1) if !missing(p102)

//coding roof type 
//need to account for 489 missing values
gen d_roof_other = 		(p103a == 8) if !missing(p103a)
gen d_roof_straw = 		(p103a == 7) if !missing(p103a)
gen d_roof_mat 	 = 		(p103a == 6) if !missing(p103a)
gen d_roof_platecane = 	(p103a == 5 | p103a == 4) if !missing(p103a)
gen d_roof_tile  = 		(p103a == 3) if !missing(p103a)
gen d_roof_wood  = 		(p103a == 2) if !missing(p103a)
gen d_roof_concrete = 	(p103a == 1) if !missing(p103a)

//coding floor type
//need to account for 489 missing values 
gen d_floor_other = 	(p103 == 7) if !missing(p103)
gen d_floor_earth = 	(p103 == 6) if !missing(p103)
gen d_floor_cement = 	(p103 == 5) if !missing(p103)
gen d_floor_wood = 		(p103 == 4) if !missing(p103)
gen d_floor_tile = 		(p103 == 3) if !missing(p103)
gen d_floor_sheets = 	(p103 == 2) if !missing(p103)
gen d_floor_parquet = 	(p103 == 1) if !missing(p103)

//coding electricity
gen d_electricity = 	(p1121 == 1)

//coding telephone
gen d_telephone   = 	(p1141 == 1)

//coding internet and TV cable
//NOTE: *NOT* INCLUDED IN FINAL REGRESSIONS, JUST CODING FOR LUXURY GOODS CATEGORY
gen internet = 			(p1144 == 1)
gen cable = 			(p1143 == 1)

//keep only necessary variables 
keep hhid year month p104 d_* internet cable

tempfile hh_1_2011
save `hh_1_2011', replace 


***open household education module (3)
use "291-Modulo03\enaho01a-2011-300.dta", clear 

//create unique household id variable 
gen hhid = conglome + vivienda + hogar 

//coding head of household's education level 
bysort hhid (codperso): gen head_educ = p301a[1]
//coding maxiumum household education level 
bysort hhid: egen max_educ = max(p301a)
//collapse to only one observation per household 
collapse (mean) head_educ max_educ, by(hhid)

//dummies for head of household's education level 
gen d_h_educ_none = (head_educ == 1) if !missing(head_educ)
gen d_h_educ_pre = (head_educ == 2) if !missing(head_educ)
gen d_h_educ_prim = (head_educ == 3 | head_educ == 4) if !missing(head_educ)
gen d_h_educ_sec = (head_educ == 5 | head_educ == 6) if !missing(head_educ)
gen d_h_educ_higher_nouni = (head_educ == 7 | head_educ == 8) if !missing(head_educ)
gen d_h_educ_higher_uni = (head_educ == 9 | head_educ == 10) if !missing(head_educ)
gen d_h_educ_post = (head_educ == 11) if !missing(head_educ)

//dummies for max education level 
gen d_max_educ_none = (max_educ == 1) if !missing(max_educ)
gen d_max_educ_prim = (max_educ == 3 | max_educ == 4) if !missing(max_educ)
gen d_max_educ_sec = (max_educ == 5 | max_educ == 6) if !missing(max_educ)
gen d_max_educ_higher_nouni = (max_educ == 7 | max_educ == 8) if !missing(max_educ)
gen d_max_educ_higher_uni = (max_educ == 9 | max_educ == 10) if !missing(max_educ)

//keep only necessary variables 
keep hhid d_* head_educ max_educ 

tempfile hh_3_2011
save `hh_3_2011', replace 


***open household health module (4)
use "291-Modulo04\Enaho01A-2011-400.dta", clear 

//create unique household id variable 
gen hhid = conglome + vivienda + hogar 

//coding number of HH members affiliated with health insurance
egen programs_enrolled = rowtotal(p4191-p4198)
gen affiliated_insurance = (programs_enrolled > 0) if !missing(programs_enrolled)
replace affiliated_insurance = 0 if p4199 == 1
bysort hhid: egen num_affiliated = total(affiliated_insurance)
collapse num_affiliated, by(hhid)
//dummies 
gen d_insurance_0 = (num_affiliated == 0) if !missing(num_affiliated)
gen d_insurance_1 = (num_affiliated == 1) if !missing(num_affiliated)
gen d_insurance_2 = (num_affiliated == 2) if !missing(num_affiliated)
gen d_insurance_3 = (num_affiliated == 3) if !missing(num_affiliated)
gen d_insurance_4plus = (num_affiliated > 3) if !missing(num_affiliated)

//keep only necessary variables 
keep hhid num_affiliated d_*

tempfile hh_4_2011
save `hh_4_2011', replace 


***open household equipment module (18)
use "291-Modulo18\enaho01-2011-612.dta", clear 

//create unique household id variable 
gen hhid = conglome + vivienda + hogar 

//code for owning computer, refrigerator, and washer
keep if p612n == 7 | p612n == 12 | p612n == 13

keep hhid p612n p612 
reshape wide p612, i(hhid) j(p612n)

gen computer = (p6127 == 1) if !missing(p6127)
gen refrigerator = (p61212 == 1) if !missing(p61212)
gen washer = (p61213 == 1) if !missing(p61213)

//keep only new dummy variables 
keep hhid computer refrigerator washer 

tempfile hh_18_2011
save `hh_18_2011', replace

***open household "summary" module (34)
use "291-Modulo34\sumaria-2011.dta", clear

//create unique household id variable for merge 
gen hhid = conglome + vivienda + hogar

//keep only relevant variables 
keep hhid dominio estrato mieperho gashog2d linea pobreza

//now merge with all previous tempfiles 
merge 1:1 hhid using `hh_1_2011' //all should merge successfully 
	drop _merge
merge 1:1 hhid using `hh_3_2011'
	drop _merge 
merge 1:1 hhid using `hh_4_2011'
	drop _merge
merge 1:1 hhid using `hh_18_2011'
	drop _merge


//coding household crowding (HH members per room)
gen crowding = mieperho / p104
//dummies
gen d_crowd_lessthan1 = (crowding < 1) if !missing(crowding)
gen d_crowd_1to2 = (crowding >= 1 & crowding < 2) if !missing(crowding)
gen d_crowd_2to4 = (crowding >= 2 & crowding < 4) if !missing(crowding)
gen d_crowd_4to6 = (crowding >= 4 & crowding < 6) if !missing(crowding)
gen d_crowd_6plus = (crowding >= 6) if !missing(crowding)


//coding luxury goods 
egen luxury_goods = rowtotal(internet cable computer refrigerator washer), missing 
//dummies 
gen d_lux_0 = (luxury_goods == 0) if !missing(luxury_goods)
gen d_lux_1 = (luxury_goods == 1) if !missing(luxury_goods)
gen d_lux_2 = (luxury_goods == 2) if !missing(luxury_goods)
gen d_lux_3 = (luxury_goods == 3) if !missing(luxury_goods)
gen d_lux_4 = (luxury_goods == 4) if !missing(luxury_goods)
gen d_lux_5 = (luxury_goods == 5) if !missing(luxury_goods)


//coding household per capita consumption (monthly)
gen percapitaconsumption = gashog2d / (12 * mieperho)
rename mieperho h_hhsize //need to rename to align with Susenas data 

//coding household urban/rural status
gen urban = (estrato <= 6)

//coding household poverty status 
rename linea povertyline
gen poor = (percapitaconsumption < povertyline)



*** 5. APPEND AND SAVE***
append using `full_2010'

//order variables so hhid, year, and month come first 
order hhid year month, first 
//and dummies all come last 
order d_*, last 

//sort
sort year hhid 

//save
cd "$analysispath"
save "cleandata.dta", replace

