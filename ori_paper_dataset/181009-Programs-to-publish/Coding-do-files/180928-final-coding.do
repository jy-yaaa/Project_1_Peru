**Creating a dataset to look at consumption levels for households**
* Based on 160212 final codin
**Katherine Durlacher**
**May 10 2012**

clear all
pause on
set seed 5678429
set sortseed 248593
set mem 500m
set more off 


if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
	}
cd "$surveypath"
local surveypath = "$surveypath"


* 0. INSHEET POVERTY LINE DATA *************************************

foreach year in 2010 2011 {
insheet using "`surveypath'/Susenas Data/BPS_`year'.csv", comma clear
keep province pov_line_urb pov_line_rur perc_poor*
ren pov_line_urb pov_line_urban_`year'
ren pov_line_rur pov_line_rural_`year'
foreach var of varlist perc_* {
ren `var' `var'`year'
}
replace pov_line_urban_`year' = subinstr(pov_line_urban_`year'," ","",.)
replace pov_line_rural_`year' = subinstr(pov_line_rural_`year'," ","",.)
replace pov_line_rural_`year' = "" if pov_line_rural_`year'=="-"
destring pov_line*, replace
tempfile bps`year'
sa `bps`year''
}


* 1. APPEND AND MERGE *************************************

u "`surveypath'/Susenas Data/Coded/mar.dta", clear
append using "`surveypath'/Susenas Data/Coded/jun.dta"
append using "`surveypath'/Susenas Data/Coded/sep.dta"
append using "`surveypath'/Susenas Data/Coded/feb.dta"

*merge in Podes* 
merge m:1 desaid using "`surveypath'/Susenas Data/podes2011-desakor_Ben/ppls11_pdsmay8_kd.dta"
keep if _m==3
drop _m


* 2. DUMMY VARIABLES *************************************
* A. HH HEAD AGE
**HH head age, h_hhage, h_hhage2-quadratic version **
gen d_h_hhage0_30 = .
replace d_h_hhage0_30 = 0 if h_hhage != .
replace d_h_hhage0_30 = 1 if h_hhage != . & h_hhage <=30
label var d_h_hhage0_30 "hh head age less than/equal to 30"

gen d_h_hhage30_50 = .
replace d_h_hhage30_50 = 0 if h_hhage != .
replace d_h_hhage30_50 = 1 if h_hhage != . & h_hhage >30 & h_hhage <=50
label var d_h_hhage30_50 "hh head age 31-50"

gen d_h_hhage50 = .
replace d_h_hhage50 = 0 if h_hhage != .
replace d_h_hhage50 = 1 if h_hhage != . & h_hhage >50
label var d_h_hhage50 "hh head age 51+"

assert d_h_hhage0_30+d_h_hhage30_50+d_h_hhage50 == 1 | (d_h_hhage0_30==. & d_h_hhage30_50==. & d_h_hhage50 == .)


* B. HH SEX AND MARITAL STATUS
**HH head sex: male, h_hhmale**
gen d_h_hhmale = h_hhmale
label var d_h_hhmale "HH is male"

**HH marital status:married, h_hhmarried**
gen d_h_hhmarried = h_hhmarried
label var d_h_hhmarried "HH is married"



* C. HH SIZE
**Household size: h_hhsize* **
gen d_h_hhsize0_2 = .
replace d_h_hhsize0_2 = 0 if h_hhsize != .
replace d_h_hhsize0_2 = 1 if h_hhsize != . & h_hhsize <=2
label var d_h_hhsize0_2 "Household size 0-2"

gen d_h_hhsize2_4 = .
replace d_h_hhsize2_4 = 0 if h_hhsize != .
replace d_h_hhsize2_4 = 1 if h_hhsize != . & h_hhsize >=3 & h_hhsize < 5
label var d_h_hhsize2_4 "Household size 3-4"

gen d_h_hhsize4 = .
replace d_h_hhsize4 = 0 if h_hhsize != .
replace d_h_hhsize4 = 1 if h_hhsize != . & h_hhsize >4
label var d_h_hhsize4 "Household size more than 4"
assert d_h_hhsize0_2+d_h_hhsize2_4+d_h_hhsize4==1 | (d_h_hhsize0_2==. & d_h_hhsize2_4 == . & d_h_hhsize4==.)



* D. DEPENDENTS
**Dependency Ratio, h_depratio, h_nage14, h_nage65p**
**1 child**
gen d_h_depend_c1 = .
replace d_h_depend_c1 = 0 if h_nage14 != .
replace d_h_depend_c1 = 1 if h_nage14 == 1

**2 children**
gen d_h_depend_c2 = .
replace d_h_depend_c2 = 0 if h_nage14 != .
replace d_h_depend_c2 = 1 if h_nage14 == 2

**>2 children**
gen d_h_depend_c3m = .
replace d_h_depend_c3m = 0 if h_nage14 != .
replace d_h_depend_c3m = 1 if h_nage14 > 2 & h_nage14 != .
assert d_h_depend_c1+d_h_depend_c2+d_h_depend_c3m==0 | d_h_depend_c1+d_h_depend_c2+d_h_depend_c3m==1 | h_nage14==.

**hh member >65, h_nage65p**
gen d_h_depend_p65 = .
replace d_h_depend_p65 = 0 if h_nage65p != .
replace d_h_depend_p65 = 1 if h_nage65p > 0 & h_nage65p != .

label var d_h_depend_c1 "1 dependent child"
label var d_h_depend_c2 "2 dependent children"
label var d_h_depend_c3m "3 or more dependent children"
label var d_h_depend_p65 "Dependent older than 65"



* E. EDUCATION 
**maxeduc in 2011**
**Education attainment**
foreach var of varlist h_hhedu_none h_hhsd h_hhsmp h_hhsma h_hhdip1_s3 h_hhmaxedsmp h_hhmaxedsma h_hhmaxedsd h_hhmaxeddip1_s3 {
	gen d_`var' = `var'
	}
label var d_h_hhmaxedsd "Highest ed. level of anyone in HH: SD"
label var d_h_hhsd "Highest ed. level of HH head: elementary"
label var d_h_hhsmp "Highest ed. level of HH head: junior high"
label var d_h_hhsma "Highest ed. level of HH head: high school"
label var d_h_hhdip1_s3 "Highest ed. level of HH head: tertiary"
label var d_h_hhmaxedsmp "Highest ed. level of anyone in HH: junior high"
label var d_h_hhmaxedsma "Highest ed. level of anyone in HH: high school"
label var d_h_hhmaxeddip1_s3 "Highest ed. level of anyone in HH: tertiary"
label var d_h_hhedu_none "Highest ed HHH: None"



* F. CHILDREN'S EDUCATION
**Children enrolled in tertiary ed"
gen d_h_childdip1_s3_1 = .
replace d_h_childdip1_s3_1 = 0 if h_nchilddip1_s3 != .
replace d_h_childdip1_s3_1 = 1 if h_nchilddip1_s3 == 1

gen d_h_childdip1_s3_2 = .
replace d_h_childdip1_s3_2 = 0 if h_nchilddip1_s3 != .
replace d_h_childdip1_s3_2 = 1 if h_nchilddip1_s3 == 2

gen d_h_childdip1_s3_3 = .
replace d_h_childdip1_s3_3 = 0 if h_nchilddip1_s3 != .
replace d_h_childdip1_s3_3 = 1 if h_nchilddip1_s3 >= 3 & h_nchilddip1_s3 != .

label var d_h_childdip1_s3_1 "1 child in tertiary ed"
label var d_h_childdip1_s3_2 "2 child in tertiary ed"
label var d_h_childdip1_s3_3 "3 or more children in tertiary ed"
assert d_h_childdip1_s3_1+d_h_childdip1_s3_2+d_h_childdip1_s3_3==1 | d_h_childdip1_s3_1+d_h_childdip1_s3_2+d_h_childdip1_s3_3==0 | h_nchilddip1_s3==.




* G. OCCUPATION OF HH HEAD
***Occupation of HHH***
*hhh works*
gen d_h_hhwork = h_hhwork
gen d_h_hhagr = h_hhagr
gen d_h_hhind = h_hhind
gen d_h_hhserv = h_hhserv

label var d_h_hhwork "HHH works"
label var d_h_hhagr "HHH works in agriculture sector"
label var d_h_hhind "HHH works in industry sector"
label var d_h_hhserv "HHH works in service sector"

forv x = 1/6 {
gen d_h_workstat`x' = h_workstat`x'
}

label var d_h_workstat1 "HHH self employed"
label var d_h_workstat2 "HHH self employed w/ unpaid empl"
label var d_h_workstat3 "HHH self employed w/ paid empl"
label var d_h_workstat4 "HHH employee"
la var d_h_workstat5 "Unpaid family worker"
la var d_h_workstat6 "Freelance or casual laborer"

g temp = 0
forv x = 1/6 {
replace temp = temp+d_h_workstat`x'
}
assert temp==1 if d_h_hhwork==1
drop temp



* H HOUSING ETC
***Housing and Facilities***
gen d_h_troof1 = h_troof1
gen d_h_troof2 = h_troof2
gen d_h_troof3 = h_troof3
gen d_h_troof4 = h_troof4

label var d_h_troof1 "Roof: Concrete, roof tile"
label var d_h_troof2 "Roof: Shingle (sirap)"
label var d_h_troof3 "Roof: Zinc"
label var d_h_troof4 "Roof: Asbestos"

gen d_h_troof5=h_troof5
lab var d_h_troof5 "Roof: Thatch, Other"

g temp = 0
forv x = 1/5 {
replace temp = temp+d_h_troof`x'
}
assert temp==1 if d_h_troof1!=.
drop temp


* Wall
gen d_h_twall1 = h_twall1
gen d_h_twall2 = h_twall2

label var d_h_twall1 "Walls: Cement"
label var d_h_twall2 "Walls: Wood"

gen d_h_twall3= h_twall3
lab var d_h_twall3 "Wall:bamboo/others"

g temp = 0
forv x = 1/3 {
replace temp = temp+d_h_twall`x'
}
assert temp==1 if d_h_twall1!=.
drop temp


* Floor
gen d_h_tfloor = h_tfloor
label var d_h_tfloor "Floor: not soil"


* Housing type
gen d_h_house1 = h_house1
gen d_h_house2 = h_house2
gen d_h_house3 = h_house3
gen d_h_house4 = h_house4
gen d_h_house5 = h_house5

label var d_h_house1 "House Owned"
label var d_h_house2 "House Rented"
label var d_h_house3 "House - official"
label var d_h_house4 "House occupied for free"
label var d_h_house5 "House owned by parents/relatives"

g temp = 0
forv x = 1/5 {
replace temp = temp+d_h_house`x'
}
assert temp==1 if d_h_house1!=.
drop temp


* Drinking water
gen d_h_dwater1 = h_dwater1
gen d_h_dwater2 = h_dwater2
gen d_h_dwater3 = h_dwater3
gen d_h_dwater4 = h_dwater4
gen d_h_dwater5 = h_dwater5
gen d_h_dwater6 = h_dwater6

label var d_h_dwater1 "Drinking water: mineral/bottle"
label var d_h_dwater2 "Drinking water: tap"
label var d_h_dwater3 "Drinking water: drill/pump"
label var d_h_dwater4 "Drinking water: protected well"
label var d_h_dwater5 "Drinking water: unprotected well"
label var d_h_dwater6 "Drinking water: spring/river/rain/others"

g temp = 0
forv x = 1/6 {
replace temp = temp+d_h_dwater`x'
}
assert temp==1 if d_h_dwater1!=.
drop temp

gen d_h_pwater = h_pwater 
label var d_h_pwater "HH pays for drinking water"


* Toilet
gen d_h_toilet1 = h_toilet1
gen d_h_toilet2 = h_toilet2
gen d_h_toilet3 = h_toilet3

label var d_h_toilet1 "Toilet: private"
label var d_h_toilet2 "Toilet: shared/public"
label var d_h_toilet3 "Toilet: none"

g temp = 0
forv x = 1/3 {
replace temp = temp+d_h_toilet`x'
}
assert temp==1 if d_h_toilet1!=.
drop temp


* Septic
gen d_h_septic = h_septic1
label var d_h_septic "Septic tank"


* Lighting
g d_h_lighting1 = h_lighting1
g d_h_lighting2 = h_lighting2
g d_h_lighting3 = h_lighting3
g d_h_lighting4 = h_lighting4

la var d_h_lighting1 "PLN electricity with meter"
la var d_h_lighting2 "PLN electricity w/o meter"
la var d_h_lighting3 "non-PLN electricity"
la var d_h_lighting4 "Gas, candles, other"

g temp = 0
forv x = 1/4 {
replace temp = temp+d_h_lighting`x'
}
assert temp==1 if d_h_lighting1!=.
drop temp



* I. ASSETS
***Asset Ownership***
gen d_h_aset_fridge = h_aset_fridge
gen d_h_aset_gas = h_aset_gas
gen d_h_aset_motorcycle = h_aset_motorcycle
gen d_h_aset_bicycle = h_aset_bicycle

label var d_h_aset_fridge "HH has a fridge"
label var d_h_aset_gas "HH has a 12 kg or more gas tube"
label var d_h_aset_motorcycle "HH has a motorcycle"
label var d_h_aset_bicycle "HH has a bicycle"




*poverty line variables
* J. URBAN

**dummy urban-rural var**
gen d_h_urban = h_urban
label define urban_lab 1 "urban" 0 "rural"
label val d_h_urban urban_lab
label var d_h_urban "Urban-1, Rural-0"




* 4. FOR PODES DATA ********************************************
*******for Podes data************
gen d_pds_road = pds_road
label var d_pds_road "Asphalt road"

gen d_pds_sma = pds_sma
label var d_pds_sma "SMA - senior high school"

gen d_pds_smp = pds_smp
label var d_pds_smp "SMP - junior high school"

gen d_pds_sd = pds_sd
label var d_pds_sd "SD - elementary school"


gen d_pds_puskesmas = pds_puskesmas
label var d_pds_puskesmas "Puskesmas - health facility"

gen d_pds_polindes = pds_polindes
label var d_pds_polindes "Polindes - health facility"

gen d_pds_doctor = pds_doctor
label var d_pds_doctor "Doctor"

gen d_pds_bidan = pds_bidan
label var d_pds_bidan "Midwife"

gen d_pds_office = pds_office
label var d_pds_office "Post office"

gen d_pds_credit = pds_credit
label var d_pds_credit "Credit facility"


****pds_distance create 4 dummies based on distance quartiles****
xtile pds_distance_quar = pds_distance, nq(4)

gen d_pds_dist1 = 0 if pds_distance_quar != .
replace d_pds_dist1 = 1 if pds_distance_quar == 1
gen d_pds_dist2 = 0 if pds_distance_quar != .
replace d_pds_dist2 = 1 if pds_distance_quar == 2
gen d_pds_dist3 = 0 if pds_distance_quar != .
replace d_pds_dist3 = 1 if pds_distance_quar == 3
gen d_pds_dist4 = 0 if pds_distance_quar != .
replace d_pds_dist4 = 1 if pds_distance_quar == 4

label var d_pds_dist1 "1st quartile: Dist. nearest city/district center"
label var d_pds_dist2 "2nd quartile: Dist. nearest city/district center"
label var d_pds_dist3 "3rd quartile: Dist. nearest city/district center"
label var d_pds_dist4 "4th quartile: Dist. nearest city/district center"

drop pds_distance_quar




cap g d_h_urban = h_urban

gen feb2010 = 0 if date != ""
replace feb2010 = 1 if date == "February 2010"
gen mar2011 = 0 if date != ""
replace mar2011 = 1 if date == "March 2011"
gen jun2011 = 0 if date != ""
replace jun2011 = 1 if date == "June 2011"
gen sep2011 = 0 if date != ""
replace sep2011 = 1 if date == "September 2011"

label define yesno 0 "No" 1 "Yes"




* 5. MERGE WITH POVERTY LINE

*creating a string province variable*
gen province = ""
replace province = "Aceh" if b1r1 == 11
replace province = "Jawa Barat" if b1r1 == 32
replace province = "Kalimantan Timur" if b1r1 == 64
replace province = "Sumatera Utara" if b1r1 == 12
replace province = "Jawa Tengah" if b1r1 == 33
replace province = "Sulawesi Utara" if b1r1 == 71
replace province = "Sumatera Barat" if b1r1 == 13
replace province = "DI Yogyakarta" if b1r1 == 34
replace province = "Sulawesi Tengah" if b1r1 == 72
replace province = "Riau" if b1r1 == 14
replace province = "Jawa Timur" if b1r1 == 35
replace province = "Sulawesi Selatan" if b1r1 == 73
replace province = "Jambi" if b1r1 == 15
replace province = "Banten" if b1r1 == 36
replace province = "Sulawesi Tenggara" if b1r1 == 74
replace province = "Sumatera Selatan" if b1r1 == 16
replace province = "Bali" if b1r1 == 51
replace province = "Gorontalo" if b1r1 == 75
replace province = "Bengkulu" if b1r1 == 17
replace province = "Nusa Tenggara Barat" if b1r1 == 52
replace province = "Sulawesi Barat" if b1r1 == 76
replace province = "Lampung" if b1r1 == 18
replace province = "Nusa Tenggara Timur" if b1r1 == 53
replace province = "Maluku" if b1r1 == 81
replace province = "Bangka Belitung" if b1r1 == 19
replace province = "Kalimantan Barat" if b1r1 == 61
replace province = "Maluku Utara" if b1r1 == 82
replace province = "Kepulauan Riau" if b1r1 == 21
replace province = "Kalimantan Tengah" if b1r1 == 62
replace province = "Papua Barat" if b1r1 == 91
replace province = "DKI Jakarta" if b1r1 == 31
replace province = "Kalimantan selatan" if b1r1 == 63
replace province = "Papua" if b1r1 == 94




merge m:1 province using `bps2010'
assert _m!=1
tab province _m if _m!=3
drop if _m==2
drop _m

merge m:1 province using  `bps2011'
assert _m!=1
tab province _m if _m!=3
drop if _m==2
drop _m

tab b1r1 if province==""
count if province==""

assert d_h_urban==1 if province=="DKI Jakarta"



*determine whether the hh is under the poverty line, based on year and urban/rural*
gen poverty_2010 = .
gen poverty_2011 = .

label var expend "total household monthly expenditure"
label var kapita "per-capita houseld monthly expenditure"

*2011 & 2010 b1r5 1-urban 2-rural*
g poverty_rur = 0 if d_h_urban==0 & kapita!=.
g poverty_urb = 0 if d_h_urban==1 & kapita!=.
replace poverty_rur = 1 if kapita < pov_line_rural_2010 & d_h_urban==0 & feb2010==1
replace poverty_rur = 1 if kapita < pov_line_rural_2011 & d_h_urban==0 & (mar2011==1 | jun2011==1 | sep2011==1)
replace poverty_urb = 1 if kapita < pov_line_urban_2010 & d_h_urban==1 & feb2010==1
replace poverty_urb = 1 if kapita < pov_line_urban_2011 & d_h_urban==1 & (mar2011==1 | jun2011==1 | sep2011==1)
replace poverty_2010 = 0 if d_h_urban!=. & kapita!=. & feb2010==1
replace poverty_2011 = 0 if d_h_urban!=. & kapita!=. & (mar2011==1 | jun2011==1 | sep2011==1)

replace poverty_2010 = 1 if kapita < pov_line_urban_2010 & d_h_urban == 1 & feb2010==1
replace poverty_2010 = 1 if kapita < pov_line_rural_2010 & d_h_urban == 0 & feb2010==1
replace poverty_2011 = 1 if kapita < pov_line_urban_2011 & d_h_urban == 1 & (mar2011==1 | jun2011==1 | sep2011==1)
replace poverty_2011 = 1 if kapita < pov_line_rural_2011 & d_h_urban == 0 & (mar2011==1 | jun2011==1 | sep2011==1)



*now when we just include the appropriate years*
gen poverty = 0 if d_h_urban != . & kapita!=.
replace poverty = 1 if poverty_2010 == 1 & feb2010 == 1
replace poverty = 1 if poverty_2011 == 1 & mar2011 == 1
replace poverty = 1 if poverty_2011 == 1 & jun2011 == 1
replace poverty = 1 if poverty_2011 == 1 & sep2011 == 1

g pov_line = pov_line_rural_2010 if d_h_urban==0 & feb2010==1
replace pov_line = pov_line_rural_2011 if d_h_urban==0 & (mar2011==1 | jun2011==1 | sep2011==1)
replace pov_line = pov_line_urban_2010 if d_h_urban==1 & feb2010==1
replace pov_line = pov_line_urban_2011 if d_h_urban==1 & (mar2011==1 | jun2011==1 | sep2011==1)

tab poverty
tab date poverty

order province id_unique hhid desaid date poverty pov_line* kapita expend



save "`surveypath'/Data to use for analysis/121126 Clean Data.dta", replace



* omitting categories
drop d_h_hhage50
drop d_h_hhsize4
drop d_h_hhedu_none
drop d_h_hhserv
drop d_h_workstat6
drop d_h_house5
drop d_h_troof5
drop d_h_twall3
drop d_h_dwater6
drop d_h_lighting4
drop d_h_toilet3

save "`surveypath'/Data to use for analysis/121126 Clean Data with omitted categories.dta", replace
