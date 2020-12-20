/************************************************************************************
181009 Indonesia Coding Master.do
Calls the files used to create cleandata.dta and cleandata.csv,
which are household-level Susenas data, including household weights.
************************************************************************************/

** Setup
//ENTER LOCAL FILE PATHS HERE
*global surveypath = ".../181009 Programs to publish"
global dopath = "$surveypath/Coding do files"

//

if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}

if "$dopath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
}
**


** Do files
* Code 2010 Susenas data
do "$dopath/180928 Cleaning 2010 version FINAL.do"
/*	out: "$surveypath/Coded/feb.dta"		*/

* Code 2011 Susenas data
do "$dopath/180928 Clean 2011 version FINAL.do"
/*	out: 	"$surveypath/Coded/mar.dta"
			"$surveypath/Coded/jun.dta"
			"$surveypath/Coded/sep.dta"		*/
	
* Combine Susenas data
do "$dopath/180928 final coding.do"
/*  in: 	"$surveypath/Susenas Data/BPS_2010.csv"
			"$surveypath/Susenas Data/BPS_2011.csv"
			"$surveypath/Susenas Data/podes2011-desakor_Ben/ppls11_pdsmay8_kd.dta"
			"$surveypath/Coded/feb.dta"
			"$surveypath/Coded/mar.dta"
			"$surveypath/Coded/jun.dta"
			"$surveypath/Coded/sep.dta"
			
	out: 	"$surveypath/Data to use for analysis/121126 Clean Data.dta"
			"$surveypath/Data to use for analysis/121126 Clean Data with omitted categories.dta" */

* Final Steps
do "$dopath/180928benclean.do"
/*  in: 	"$surveypath/Data to use for analysis/121126 Clean Data with omitted categories.dta"

	out: 	"$surveypath/Data to use for analysis/cleandata.dta"
			"$surveypath/Data to use for analysis/cleandata.csv" 	*/

exit 
