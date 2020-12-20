* Based on 160212benclean
clear
clear mata
clear matrix
set mem 4g
cap set matsize 10000
set more off



if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
	}
	
cd "$surveypath/Data to use for analysis/"

u "121126 Clean Data with omitted categories.dta", clear
*use "121126 clean data",clear //use this if want to use full dataset without dropping omitted categories


* Clean Data
g provincecode = substr(desaid,1,2)
g districtcode = substr(desaid,1,4)
g urban = d_h_urban
g year = 2010 if date == "February 2010"
replace year = 2011 if date != "February 2010"

ren pov_line povertyline


ren kapita percapitaconsumption
ren poverty poor
label var poor "Dummy for being poor"
label var povertyline "Poverty line (specific to province, year, urban/rural)"

** AL: Keep 1 obs per HH
egen mis = rownonmiss(d_h_hhage0_30 d_h_hhage30_50 d_h_hhmale d_h_hhmarried d_h_hhwork d_h_hhagr d_h_hhind d_h_workstat1 d_h_workstat2 d_h_workstat3 d_h_workstat4 d_h_workstat5)
tab mis if nart==1
bys id_unique : gen N = _N
keep if (nart==1 & mis > 0) | N==1

keep id_unique province provincecode districtcode urban year date percapitaconsumption expend d_* pov_line* poor povertyline wert h_hhsize
duplicates drop

isid id_unique date

**Continue
keep province provincecode districtcode urban year date percapitaconsumption expend d_* pov_line* poor povertyline wert h_hhsize
outsheet using cleandata.csv,c replace nolabel

save "cleandata",replace

