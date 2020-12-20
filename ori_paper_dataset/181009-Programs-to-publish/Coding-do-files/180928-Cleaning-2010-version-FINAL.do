/*
Purpose: Prepare povmap variable from Susenas
Based off 121120 Clean 2010 version
*/
set trace off
clear all
set mem 650m
set more off


if "$surveypath" == "" {
	display "Enter the directory, WITHOUT a final slash: " _request(surveypath)
	}
local surveypath = "$surveypath"
local surveypath = "`surveypath'/Susenas Data"



**********************************************************************************************************************
**********************************************************************************************************************
* Consumption Module * Consumption Module * Consumption Module * Consumption Module * Consumption Module
**********************************************************************************************************************
**********************************************************************************************************************

u "`surveypath'/ssn10feb_m/susenas10feb_43.dta", clear

gen id_unique = string(b1r1)+string(b1r2,"%02.0f")+string(b1r3,"%03.0f")+string(b1r4,"%03.0f")+string(b1r5)+string(b1r7,"%05.0f") + string(b1r8,"%02.0f")
gen desaid = string(b1r1,"%02.0f") + string(b1r2,"%02.0f") + string(b1r3,"%03.0f") + string(b1r4,"%03.0f") 
gen hhid = string(b1r1)+string(b1r2,"%02.0f")+string(b1r3,"%03.0f")+string(b1r4,"%03.0f")+string(b1r5)+string(b1r8,"%05.0f")

keep b1r1 id_unique desaid hhid expend kapita wert

tempfile consfile
sa `consfile', replace



**********************************************************************************************************************
**********************************************************************************************************************
* HH dataset * HH dataset * HH dataset * HH dataset * HH dataset * HH dataset * HH dataset * HH dataset * HH dataset 
**********************************************************************************************************************
**********************************************************************************************************************


use "`surveypath'/ssn10feb_k/susenas10feb_kr.dta", clear



*****************************************************************
* 0. Identifiers
***************************************************************

gen desaid = string(b1r1,"%02.0f") + string(b1r2,"%02.0f") + string(b1r3,"%03.0f") + string(b1r4,"%03.0f") 
gen hhid = string(b1r1)+string(b1r2,"%02.0f")+string(b1r3,"%03.0f")+string(b1r4,"%03.0f")+string(b1r5)+string(b1r8,"%05.0f")
gen id_unique = string(b1r1)+string(b1r2,"%02.0f")+string(b1r3,"%03.0f")+string(b1r4,"%03.0f")+string(b1r5)+string(b1r7,"%05.0f") + string(b1r8,"%02.0f")




***************************************************************
* 1. Urban
***************************************************************

	*1. Klasifikasi tempat tinggal: perkotaan/perdesaan
	gen h_urban=b1r5==1 if b1r5!=.
	lab var h_urban "Klasifikasi tempat tinggal: perkotaan/perdesaan"
	lab def h_urban 1"Perkotaan" 0"Perdesaan"
	lab val h_urban h_urban


***************************************************************
* 2. HH size
***************************************************************

	*2. HH size
	gen h_hhsize=b2r1
	lab var h_hhsize "Jumlah anggota rumah tangga"



***************************************************************
* 3. House status
***************************************************************
	
	*41. Status penguasaan bangunan tempat tinggal: Milik sendiri
	gen h_house1=b6r1==1 if b6r1!=7
	lab var h_house1 "Status penguasaan bangunan tempat tinggal: Milik sendiri"
	lab def h_house1 1"Milik sendiri" 0"Lainnya"
	lab val h_house1 h_house1

	*42. Status penguasaan bangunan tempat tinggal: Sewa/kontrak
	gen h_house2=inlist(b6r1,2,3) if b6r1!=7
	lab var h_house2 "Status penguasaan bangunan tempat tinggal: Sewa/kontrak"
	lab def h_house2 1"Sewa/kontrak" 0"Lainnya"
	lab val h_house2 h_house2

	*43. Status penguasaan bangunan tempat tinggal: Bebas sewa
	gen h_house3=b6r1==4 if b6r1!=7
	lab var h_house3 "Status penguasaan bangunan tempat tinggal: Bebas sewa"
	lab def h_house3 1"Bebas sewa" 0"Lainnya"
	lab val h_house3 h_house3

	*44. Status penguasaan bangunan tempat tinggal: Rumah dinas
	gen h_house4=b6r1==5 if b6r1!=7
	lab var h_house4 "Status penguasaan bangunan tempat tinggal: Rumah dinas"
	lab def h_house4 1"Rumah dinas" 0"Lainnya"
	lab val h_house4 h_house4

	*45. Status penguasaan bangunan tempat tinggal: Rumah keluarga
	gen h_house5=b6r1==6 if b6r1!=7
	lab var h_house5 "Status penguasaan bangunan tempat tinggal: Milik keluarga"
	lab def h_house5 1"Rumah keluarga" 0"Lainnya"
	lab val h_house5 h_house5
	* note: collectively exhaustive. 7, lainnya, coded missing.


***************************************************************
* 4. Floor/Wall/Roof type
***************************************************************


	*47. Jenis lantai: bukan tanah
	gen h_tfloor=b6r4==1 if b6r4!=.
	lab var h_tfloor "Jenis lantai: bukan tanah"
	lab def h_tfloor 1"Bukan tanah/bukan bambu" 0"Lainnya"


	*48. Jenis dinding terluas: Tembok
	gen h_twall1=b6r3==1 if b6r3!=.
	lab var h_twall1 "Jenis dinding terluas: tembok"
	lab def h_twall1 1"Tembok" 0"Lainnya"
	lab val h_twall1 h_twall1

	*49. Jenis dinding terluas: kayu
	gen h_twall2=b6r3==2 if b6r3!=.
	lab var h_twall2 "Jenis dinding terluas: kayu"
	lab def h_twall2 1"Kayu" 0"Lainnya"
	lab val h_twall2 h_twall2
	
	gen h_twall3=inlist(b6r3,3,4) if b6r3!=.		

	
	*50. Jenis atap terluas: beton, genteng
	gen h_troof1=inlist(b6r2,1,2) if b6r2!=.
	lab var h_troof1 "Jenis atap terluas: beton, genteng"
	lab def h_troof1 1"Beton/genteng" 0"Lainnya"
	lab val h_troof1 h_troof1

	*51. Jenis atap terluas: seng
	gen h_troof2=b6r2==4 if b6r2!=.
	lab var h_troof2 "Jenis atap terluas: seng"
	lab def h_troof2 1"Seng" 0"Lainnya"
	lab val h_troof2 h_troof2

	*52. Jenis atap terluas: asbes
	gen h_troof3=b6r2==5 if b6r2!=.
	lab var h_troof3 "Jenis atap terluas: asbes"
	lab def h_troof3 1"Asbes" 0"Lainnya"
	lab val h_troof3 h_troof3

	*53. Jenis atap terluas: sirap
	gen h_troof4=b6r2==3 if b6r2!=.
	lab var h_troof4 "Jenis atap terluas: sirap"
	lab def h_troof4 1"Sirap" 0"Lainnya"
	lab val h_troof4 h_troof4
	
	gen h_troof5=inlist(b6r2,6,7)	



***************************************************************
* 5. Water characteristics
***************************************************************

	*54. Sumber air minum bersih: air kemasan
	gen h_dwater1=inlist(b6r6a,1,2) if b6r6a!=.
	lab var h_dwater1 "Sumber air minum bersih: air kemasan"
	lab def h_dwater1 1"Air kemasan" 0"Lainnya"
	lab val h_dwater1 h_dwater1

	*55. Sumber air minum bersih: ledeng
	gen h_dwater2=inlist(b6r6a,3,4) if b6r6a!=.
	lab var h_dwater2 "Sumber air minum bersih: ledeng"
	lab def h_dwater2 1"Ledeng" 0"Lainnya"
	lab val h_dwater2 h_dwater2

	*56. Sumber air minum bersih: sumur bor/pompa
	gen h_dwater3=b6r6a==5 if b6r6a!=.
	lab var h_dwater3 "Sumber air minum bersih: sumur bor/pompa"
	lab def h_dwater3 1"Sumur bor/pompa" 0"Lainnya"
	lab val h_dwater3 h_dwater3

	*57. Sumber air minum bersih: sumur terlindung
	gen h_dwater4=b6r6a==6 if b6r6a!=.
	lab var h_dwater4 "Sumber air minum bersih: sumur terlindung"
	lab def h_dwater4 1"Sumur terlindung" 0"Lainnya"
	lab val h_dwater4 h_dwater4

	*58. Sumber air minum bersih: sumur tak terlindung
	gen h_dwater5=b6r6a==7 if b6r6a!=.
	lab var h_dwater5 "Sumber air minum bersih: sumur tak telindung"
	lab def h_dwater5 1"Sumur tak terlindung" 0"Lainnya"
	lab val h_dwater5 h_dwater5
	
	gen h_dwater6=inrange(b6r6a,8,12) if b6r6a!=.


	*59. Cara memperoleh air minum: membeli
	gen h_pwater=(b6r8==1) if b6r8!=.
	lab var h_pwater "Cara memperoleh air minum: membeli"
	lab def h_pwater 1"Membeli" 0"Lainnya"
	lab val h_pwater h_dwater1


***************************************************************
* 6. Lighting
***************************************************************

	*60. Sumber penerangan: listrik PLN dg meteran
	gen h_lighting1=b6r10==1 if b6r10!=.
	lab var h_lighting1 "Sumber penerangan: listrik PLN dg meteran"
	lab def h_lighting1 1"Listrik PLN dg meteran" 0"Lainnya"
	lab val h_lighting1 h_lighting1

	*61. Sumber penerangan: listrik PLN tanpa meteran
	gen h_lighting2=b6r10==2 if b6r10!=.
	lab var h_lighting2 "Sumber penerangan: listrik PLN tanpa meteran"
	lab def h_lighting2 1"Listrik PLN tanpa meteran" 0"Lainnya"
	lab val h_lighting2 h_lighting2

	*62. Sumber penerangan: Listrik non-PLN
	gen h_lighting3=b6r10==3 if b6r10!=.
	lab var h_lighting3 "Sumber penerangan: listrik non-PLN"
	lab def h_lighting3 1"Listrik non-PLN" 0"Lainnya"
	lab val h_lighting3 h_lighting3

	*63. Sumber penerangan: petromak/aladin
	gen h_lighting4=inrange(b6r10,4,6) if b6r10!=.	
	lab var h_lighting4 "Sumber penerangan: petromak/aladin"
	lab def h_lighting4 1"Petromak/aladin" 0"Lainnya"
	lab val h_lighting4 h_lighting4


***************************************************************
* 7. Toilet / Septic
***************************************************************

	*64. Fasilitas tempat BAB: pribadi
	gen h_toilet1=b6r9a==1 if b6r9a!=.
	lab var h_toilet1 "Fasilitas tempat BAB: pribadi"
	lab def h_toilet1 1"Pribadi" 0"Lainnya"
	lab val h_toilet1 h_toilet1

	*65. Fasilitas tempat BAB: umum/bersama
	gen h_toilet2=inlist(b6r9a,2,3) if b6r9a!=.
	lab var h_toilet2 "Fasilitas tempat BAB: umum/bersama"
	lab def h_toilet2 1"Umum/bersama" 0"Lainnya"
	lab val h_toilet2 h_toilet2
	
	gen h_toilet3=b6r9a==4 if b6r9a!=.
	

	*66. Tempat pembuangan akhir tinja: septic tank
	gen h_septic1=b6r9c==1 & b6r9c!=.
	lab var h_septic1 "Tempat pembuangan akhir tinja: septic tank"
	lab def h_septic1 1"Septic tank" 0"Lainnya"
	lab val h_septic1 h_septic1



***************************************************************
* 8. Assets
***************************************************************

	*70. Aset: Sepeda
	gen h_aset_bicycle=b7r4a==1 if b7r4a!=.
	lab var h_aset_bicycle "Aset: sepeda"
	lab def h_aset_bicycle 1"Ya" 0"Tidak"
	lab val h_aset_bicycle h_aset_bicycle

	*72. Aset: Lemari es
	gen h_aset_fridge=b7r4b==1  if b7r4b!=.
	lab var h_aset_fridge "Aset: lemari es"
	lab def h_aset_fridge 1"Ya" 0"Tidak"
	lab val h_aset_fridge h_aset_fridge

	*73. Aset: gas
	gen h_aset_gas=b7r4c==1 if b7r4c!=.
	lab var h_aset_gas "Aset: Tabung gas >=12 kg"
	lab def h_aset_gas 1"Ya" 0"Tidak"
	lab val h_aset_gas h_aset_gas

	*74. Aset: Sepeda motor
	gen h_aset_motorcycle=b7r4d==1 if b7r4d!=.
	lab var h_aset_motorcycle "Aset: Sepeda motor"
	lab def h_aset_motorcycle 1"Ya" 0"Tidak"
	lab val h_aset_motorcycle h_aset_motorcycle


tempfile hhfile
sa `hhfile', replace




**********************************************************************************************************************
**********************************************************************************************************************
* Individual dataset * Individual dataset * Individual dataset * Individual dataset * Individual dataset *
**********************************************************************************************************************
**********************************************************************************************************************


****************************************************************/
* Indicator from Susenas Core Individu
	use "`surveypath'/ssn10feb_k/susenas10feb_ki",clear




*****************************************************************
* 0. Identifiers
***************************************************************

gen desaid = string(b1r1,"%02.0f") + string(b1r2,"%02.0f") + string(b1r3,"%03.0f") + string(b1r4,"%03.0f") 
gen hhid = string(b1r1)+string(b1r2,"%02.0f")+string(b1r3,"%03.0f")+string(b1r4,"%03.0f")+string(b1r5)+string(b1r8,"%05.0f")
gen id_unique = string(b1r1)+string(b1r2,"%02.0f")+string(b1r3,"%03.0f")+string(b1r4,"%03.0f")+string(b1r5)+string(b1r7,"%05.0f") + string(b1r8,"%02.0f")
isid id_unique nart



***************************************************************
* 1. Age
***************************************************************

	*4. Umur KRT
	gen h_hhage=umur if hb==1
	lab var h_hhage "Umur KRT"


***************************************************************
* 2. Gender
***************************************************************

	*6. Kepala RT laki-laki
	gen h_hhmale=jk==1 if hb==1 & jk!=.
	lab var h_hhmale "Kepala rumah tangga laki-laki"
	lab def h_hhmale 1"Laki-laki" 0"Perempuan"
	lab val h_hhmale h_hhmale

***************************************************************
* 3. Marital status
***************************************************************

	*7. Status perkawinan KRT
	gen h_hhmarried=kwn==2 if hb==1 & kwn!=.
	lab var h_hhmarried "Status perkawinan KRT"
	lab def h_hhmarried 1"Kawin" 0"Lainnya"
	lab val h_hhmarried h_hhmarried

***************************************************************
* 4. Dependents
***************************************************************

	*8. Jumlah anggota rumah tangga <= 14 tahun
	bys id_unique: egen h_nage14=sum(umur<=14)
	lab var h_nage14 "Jumlah anggota rumah tangga berumur <= 14 tahun"

	*9. Jumlah anggota rumah tangga >= 65 tahun
	bys id_unique: egen h_nage65p=sum(umur>64 & umur <.)
	lab var h_nage65p "Jumlah anggota rumah tangga berumur >= 65 tahun"


***************************************************************
* 5. Education
***************************************************************

g edlevel = 0 if b5r13==1 | b5r18==1
replace edlevel = 1 if inrange(b5r18,2,3)
replace edlevel = 2 if inrange(b5r18,4,5)
replace edlevel = 3 if inrange(b5r18,6,8)
replace edlevel = 4 if inrange(b5r18,9,12)

bys id_unique: egen maxedu = max(edlevel)

forv x = 1/2 {
local a : word `x' of edlevel maxedu 
local b : word `x' of h_hh h_hhmaxed
g `b'none = (`a'==0)
g `b'sd = (`a'==1)
g `b'smp = (`a'==2)
g `b'sma = (`a'==3)
g `b'dip1_s3 = (`a'==4)
}
ren h_hhnon h_hhedu_none

	*21. Jumlah ART bersekolah di D1 - S3
	bys id_unique: egen h_nchilddip1_s3=sum(b5r13==2 & inrange(b5r16,8,11))
	lab var h_nchilddip1_s3 "Jumlah ART bersekolah di D1 - S3"




***************************************************************
* 6. Occupation
***************************************************************


	*29. Status KRT bekerja/membantu bekerja
	gen h_hhwork=b5r24!=. if hb==1			
	lab var h_hhwork "Status KRT bekerja/membantu bekerja"
	lab def h_hhwork 1"Bekerja" 0"Lainnya"
	lab val h_hhwork h_hhwork


	*30. Lapangan pekerjaan KRT: Pertanian
	gen h_hhagr=inlist(b5r24,1,3) if hb==1 & b5r24!=18 & b5r24!=.
	lab var h_hhagr "Lapangan pekerjaan KRT: Pertanian"
	lab def h_hhagr 1"Pertanian" 0"Lainnya"
	lab val h_hhagr h_hhagr

	*31. Lapangan pekerjaan KRT: Industri
	gen h_hhind=inlist(b5r24,2,4,5,6) if hb==1 & b5r24!=18 & b5r24!=.
	lab var h_hhind "Lapangan pekerjaan KRT: Industri"
	lab def h_hhind 1"Industri" 0"Lainnya"
	lab val h_hhind h_hhind

	*32. Lapangan pekerjaan KRT: Jasa
	gen h_hhserv=inrange(b5r24,7,17) if hb==1 & b5r24!=18 & b5r24!=.			
	lab var h_hhserv "Lapangan pekerjaan KRT: Pertanian"
	lab def h_hhserv 1"Jasa" 0"Lainnya"
	lab val h_hhserv h_hhserv
	

	*36. Status/kedudukan KRT dalam pekerjaan utama: berusaha sendiri
	gen h_workstat1=b5r25==1 if hb==1 & h_hhwork==1
	lab var h_workstat1 "Status KRT dlm pekerjaan utama: berusaha sendiri"
	lab def h_workstat1 1"Berusaha sendiri" 0"Lainnya"
	lab val h_workstat1 h_workstat1

	*37. Status/kedudukan KRT dalam pekerjaan utama: berusaha sendiri dibantu pekerja sementara
	gen h_workstat2=b5r25==2 if hb==1 & h_hhwork==1
	lab var h_workstat2 "Status KRT dlm pekerjaan utama: berusaha sendiri dibantu pekerja tidak tetap"
	lab def h_workstat2 1"Berusaha sendiri dibantu pekerja tidak tetap" 0"Lainnya"
	lab val h_workstat2 h_workstat2

	*38. Status/kedudukan KRT dalam pekerjaan utama: berusaha sendiri dibantu pekerja tetap
	gen h_workstat3=b5r25==3 if hb==1 & h_hhwork==1
	lab var h_workstat3 "Status KRT dlm pekerjaan utama: berusaha sendiri dibantu pekerja tidak tetap"
	lab def h_workstat3 1"Berusaha sendiri dibantu pekerja tidak tetap" 0"Lainnya"
	lab val h_workstat3 h_workstat3

	*37. Status/kedudukan KRT dalam pekerjaan utama: buruh/karyawan/pegawai
	gen h_workstat4=b5r25==4 if hb==1 & h_hhwork==1
	lab var h_workstat4 "Status KRT dlm pekerjaan utama: buruh/karyawan/pegawai"
	lab def h_workstat4 1"Buruh/karyawan/pegawai" 0"Lainnya"
	lab val h_workstat4 h_workstat4

	gen h_workstat5=b5r25==5 if hb==1 & h_hhwork==1
	
	gen h_workstat6=b5r25==6 if hb==1 & h_hhwork==1	
	



**********************************************************************************************************************
**********************************************************************************************************************
* Merging * Merging * Merging * Merging * Merging * Merging * Merging * Merging * Merging * Merging * Merging *
**********************************************************************************************************************
**********************************************************************************************************************

merge m:1 id_unique using `hhfile'
assert _m==3
drop _m
merge m:1 id_unique using `consfile'
assert _m==3
drop _m

g date = "February 2010"

cap rename fwt wert


sa "`surveypath'/Coded/feb.dta", replace


