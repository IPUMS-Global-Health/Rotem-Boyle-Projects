*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"
clear
use 01_dhs_household_legs.dta if hhnvalsmax==1




**********************
*** Using dhsid and collapse for the household file ***
**********************

* wealthqhh - household wealth index in quintiles, from hh form
* 1=poorest; 2=poorer; 3=middle; 4=richer; 5=richest; 8=missing (there are only 2 cases)
replace wealthqhh =. if wealthqhh==8

*recode drinkwtr (1000 1100 1110 1120 = 1 yes) (1200/6000 = 0 no) (9998=.), gen(pipedwtr)
*label variable pipedwtr "had own piped water"
*drop drinkwtr


* cropland and pastureland - missing values
replace cropland =. if cropland==-998
replace pastureland=. if pastureland==-998
* replace ndvi_00 =. if ndvi_00==-.999

recode urbanhh (2 = 0) (1 = 1)


* Copy variable labels before collapse 
* https://www.stata.com/support/faqs/data-management/keeping-same-variable-with-collapse/ 
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}

*collapse wealthqhh battles_tot_l1 battles_l1 battles_tot_l2 battles_l2 battles_tot_p1 ///
*battles_p1 stuntingnewwho wastingnewwho popdensity_s five_battles_l1 five_battles_l2 five_battles_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1 woedyears20 menedyears20 pipedwtr cropland pastureland, by(dhsid country year geo*)

collapse wealthqhh battles_l1 battles_l2 battles_p1 popdensity_s five_battles_l1 five_battles_l2 five_battles_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1 cropland pastureland urbanhh, by(dhsid country year geo* )



* Attach the saved labels after collapse - for this to work the original variable names should be kept
foreach v of var * {
        label var `v' "`l`v''"
}

* Renaming the variables
* rename (wealthqhh wealthshh t_battles_l1 di_battles_l1 t_battles_l2 di_battles_l2 t_battles_p1 di_battles_p1 stuntingnewwho wastingnewwho popdensity popdensity_log di_five_battles_l1 di_five_battles_l2 di_five_battles_p1 di_riots_l1 di_riots_l2 di_riots_p1 di_civ_violence_l1 di_civ_violence_l2 di_civ_violence_p1) (avgwealthqhh avgwealthshh avgbattles_l1 pctbattles_l1 avgbattles_l2 pctbattles_l2 avgbattles_p1 pctbattles_p1 pctstuntingnewwho pctwastingnewwho avgpopdensity avgpopdensity_log pctbattles_five_l1 pctbattles_five_l2 pctbattles_five_p1 pctriots_l1 pctriots_l2 pctriots_p1 pctciv_violence_l1 pctciv_violence_l2 pctciv_violence_p1)

label define battles_l1l 0 "no battles" 1 "battles"
label values battles_l1 battles_l1l

* label define pctbattles_l2l 0 "no battles" 1 "battles"
label values battles_l2 battles_l1l

* label define pctbattles_p1l 0 "no battles" 1 "battles"
label values battles_p1 battles_l1l

* label define pctbattles_five_l1l 0 "no battles" 1 "battles"
label values five_battles_l1 battles_l1l

* label define pctbattles_five_l2l 0 "no battles" 1 "battles"
label values five_battles_l2 battles_l1l

* label define pctbattles_five_p1l 0 "no battles" 1 "battles"
label values five_battles_p1 battles_l1l

label define riots_l1l 0 "no riots" 1 "riots"
label values riots_l1 riots_l1l

* label define pctriots_l2l 0 "no riots" 1 "riots"
label values riots_l2 riots_l1l

* label define pctriots_p1l 0 "no riots" 1 "riots"
label values riots_p1 riots_l1l

label define civ_violence_l1l 0 "no violence against civilians" 1 "violence against civilians"
label values civ_violence_l1 civ_violence_l1

* label define pctciv_violence_l2l 0 "no violence against civilians" 1 "violence against civilians"
label values civ_violence_l2 civ_violence_l1

* label define pctciv_violence_p1l 0 "no violence against civilians" 1 "violence against civilians"
label values civ_violence_p1 civ_violence_l1


replace urbanhh =. if urbanhh>0 & urbanhh<1
label define urbanl 0 "rural" 1 "urban"
label values urbanhh urbanl


* Create subnational region variable with labels **


decode(country), gen(ct)
levelsof ct, local(ctstring)

foreach var of varlist geo* {
gen `var'_copy = `var'
}
drop geo_cm2004_2011_copy
drop geo_gn1999_2012_copy geo_gn2005_2012_copy
drop geoalt_mw2010_2016_copy
drop geoalt_ng2008_2013_copy
replace geo_rw1992_2005_copy = . if year == 2005
* see that rw is ok
drop geo_tz1991_2015_copy
*drop geo_ug2006_2011_copy
*my change:
drop geo_ug2006_2016_copy
***drop geo_eg1988_2014_copy
drop geoalt_eg1988_2014
drop geoalt_ls2004_2014_copy
drop geo_ml1987_2012_copy
drop geo_nm1992_2013_copy
drop geo_sn2012_2014_copy geo_sn2015_2016_copy

foreach var of varlist geo_bj1996_2011-geo_zw1994_2015 {
decode `var', gen(`var'str)
}
drop geo_cm2004_2011str
drop geo_gn1999_2012str geo_gn2005_2012str
drop geoalt_mw2010_2016str
drop geoalt_ng2008_2013str
replace geo_rw1992_2005str = "" if year == 2005
drop geo_tz1991_2015str
* drop geo_ug2006_2011str
*my change:
drop geo_ug2006_2016str
***drop geo_eg1988_2014str
*drop geo_gn1999_2012str
*drop geo_gn2005_2012str
drop geoalt_ls2004_2014str
drop geo_ml1987_2012str
drop geo_nm1992_2013str
drop geo_sn2012_2014str geo_sn2015_2016str

egen region_temp = rowmax(geo_*_copy geoalt_*_copy)
drop geo_*copy geoalt*_copy

gen subnational = country*100 + region_temp
replace subnational = country*100 if subnational == .


egen region_label_t_gen = concat(geo*str)
gen region_label_gen = ct + " " + substr(region_label_t_gen,1,30)
egen idregion_gen = group(region_label_gen)
label variable idregion_gen "Subnational region identifier - general"

sort subnational
lab def subnational_gen 1 "temp"
levelsof(idregion_gen), local(levels)

foreach l of local levels {
gen temp = ""
replace temp = region_label_gen if idregion_gen == `l'
levelsof(temp), local(templabel)
lab def reg_label_gen `l' `templabel', modify
drop temp
}
label values idregion_gen reg_label_gen
label variable region_label_gen "Full subnational region labels - general"
drop subnational geo*str region_temp region_label_t_gen ct region_label_gen geo*

** End general region creation **


** Save to a new file
save 02_dhs_household_collapse2, replace