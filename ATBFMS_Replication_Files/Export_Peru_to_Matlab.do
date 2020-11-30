******************************************************************************
* TABLE OF CONTENTS:						     					
* 1. INTRODUCTION
* 2. SET ENVIRONMENT
* 3. SPECIFY TRAINING/TEST SAMPLES
* 4. OUTPUT TO MATLAB

******************************************************************************

*** 1. INTRODUCTION ***
/*
Date created: 	September 12, 2019
Edited by:      Damian Kozbur
Project:        Testing-Based Forward Model Selection
Description:    Outputs a Matlab file for TBFMS welfare analysis
Uses: 			cleandata.dta (Peru ENAHO version)
Creates: 		peru_matlab_export.csv


*Note:  This code is based heavily on the replication file "181001 peru paper figures.do" 

*Reference:

File name:      181001 peru paper figures.do

Date created: 	December 24, 2017 (Updated October 1, 2018)
Created by: 	Aaron Berman 
Project: 		Universal Basic Incomes versus Targeted Transfers
PIs: 			Rema Hanna, Ben Olken
Description: 	Analyzes coded ENAHO data and outputs paper Figure 7.

Journal Reference:  R. Hanna and B. A. Olken. Universal basic incomes versus targeted transfers: Anti-poverty programs in developing countries. Journal of Economic Perspectives, 32(4):201–26, 2018.

*Note: Section 2 from this file and Section 2 from the reference file "181001 peru paper figures.do" are identical and require identical inputs.    
*Note: Section 3 from this file contains a strict exerpt of Section 2 from the reference file "181001 peru paper figures.do."   


*Note:  The Journal Reference (Hanna and Olken 2018) contains additional information about generating the input file.

**************************************************************************************************

*USAGE : 

*To use this file, first create the file "cleandata.dta" (Peru ENAHO version)
*Directions for creating this file are identical to those for the Hanna & Olken reference






*/




*** 2. SET ENVIRONMENT ***

version 14.1 
set more off		
clear all			
pause on 			
capture log close 	

//setup 
*The file "cleandata.dta" must be in the working directory.


//open new ENAHO data
use "cleandata.dta"
duplicates drop



*** 3. SPECIFY TRAINING/TEST ***
set seed 83635628
generate random = runiform()
sort random 
generate training = ceil(2 * _n/_N) - 1
drop random 

//generate ln consumption 
gen lnpercapitaconsumption = ln(percapitaconsumption)

//predict ln consumption in the TEST set 
reg lnpercapitaconsumption d_* if training == 1, vce(robust)
predict lncaphat_OLS 

//also predict consumption in the TEST set 
reg percapitaconsumption d_* if training == 1, vce(robust)
predict percapitahat_OLS 

***


*** 3. OUTPUT TO MATLAB ***
gen id_for_matlab = _n
outsheet lnpercapitaconsumption d_* training percapitaconsumption poor h_hhsize id_for_matlab hhid lncaphat_OLS percapitahat_OLS using peru_matlab_export.csv , comma replace















