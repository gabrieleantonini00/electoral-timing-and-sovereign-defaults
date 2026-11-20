*POLITICAL FACTORS DETERMINING GOVERNMENT UNWILLINGNESS TO PAY SOVEREIGN DEBT

*STATA CODE

use "datasetname.dta", clear

*DEVELOPING COUNTRIES ONLY (IMF STANDARDS)

keep if countrycode == "AFG" | countrycode == "ALB" | countrycode == "DZA" | countrycode == "AGO" | countrycode == "ATG" | countrycode == "ARG" | countrycode == "ARM" | countrycode == "ABW" | countrycode == "AZE" | countrycode == "BHS" | countrycode == "BHR" | countrycode == "BGD" | countrycode == "BRB" | countrycode == "BLR" | countrycode == "BLZ" | countrycode == "BEN" | countrycode == "BTN" | countrycode == "BOL" | countrycode == "BIH" | countrycode == "BWA" | countrycode == "BRA" | countrycode == "BRN" | countrycode == "BGR" | countrycode == "BFA" | countrycode == "BDI" | countrycode == "CPV" | countrycode == "KHM" | countrycode == "CMR" | countrycode == "CAF" | countrycode == "TCD" | countrycode == "CHL" | countrycode == "CHN" | countrycode == "COL" | countrycode == "COM" | countrycode == "COD" | countrycode == "COG" | countrycode == "CRI" | countrycode == "CIV" | countrycode == "DJI" | countrycode == "DMA" | countrycode == "DOM" | countrycode == "ECU" | countrycode == "EGY" | countrycode == "SLV" | countrycode == "GNQ" | countrycode == "ERI" | countrycode == "SWZ" | countrycode == "ETH" | countrycode == "FJI" | countrycode == "GAB" | countrycode == "GMB" | countrycode == "GEO" | countrycode == "GHA" | countrycode == "GRD" | countrycode == "GTM" | countrycode == "GIN" | countrycode == "GNB" | countrycode == "GUY" | countrycode == "HTI" | countrycode == "HND" | countrycode == "HUN" | countrycode == "IND" | countrycode == "IDN" | countrycode == "IRN" | countrycode == "IRQ" | countrycode == "JAM" | countrycode == "JOR" | countrycode == "KAZ" | countrycode == "KEN" | countrycode == "KIR" | countrycode == "XKX" | countrycode == "KWT" | countrycode == "KGZ" | countrycode == "LAO" | countrycode == "LBN" | countrycode == "LSO" | countrycode == "LBR" | countrycode == "LBY" | countrycode == "MDG" | countrycode == "MWI" | countrycode == "MYS" | countrycode == "MDV" | countrycode == "MLI" | countrycode == "MHL" | countrycode == "MRT" | countrycode == "MUS" | countrycode == "MEX" | countrycode == "FSM" | countrycode == "MDA" | countrycode == "MNG" | countrycode == "MNE" | countrycode == "MAR" | countrycode == "MOZ" | countrycode == "MMR" | countrycode == "NAM" | countrycode == "NRU" | countrycode == "NPL" | countrycode == "NIC" | countrycode == "NER" | countrycode == "NGA" | countrycode == "MKD" | countrycode == "OMN" | countrycode == "PAK" | countrycode == "PLW" | countrycode == "PAN" | countrycode == "PNG" | countrycode == "PRY" | countrycode == "PER" | countrycode == "PHL" | countrycode == "POL" | countrycode == "QAT" | countrycode == "ROU" | countrycode == "RUS" | countrycode == "RWA" | countrycode == "WSM" | countrycode == "STP" | countrycode == "SAU" | countrycode == "SEN" | countrycode == "SRB" | countrycode == "SYC" | countrycode == "SLE" | countrycode == "SLB" | countrycode == "SOM" | countrycode == "ZAF" | countrycode == "SSD" | countrycode == "LKA" | countrycode == "KNA" | countrycode == "LCA" | countrycode == "VCT" | countrycode == "SDN" | countrycode == "SUR" | countrycode == "SYR" | countrycode == "TJK" | countrycode == "TZA" | countrycode == "THA" | countrycode == "TLS" | countrycode == "TGO" | countrycode == "TON" | countrycode == "TTO" | countrycode == "TUN" | countrycode == "TUR" | countrycode == "TKM" | countrycode == "TUV" | countrycode == "UGA" | countrycode == "UKR" | countrycode == "ARE" | countrycode == "URY" | countrycode == "UZB" | countrycode == "VUT" | countrycode == "VEN" | countrycode == "VNM" | countrycode == "PSE" | countrycode == "YEM" | countrycode == "ZMB" | countrycode == "ZWE"

*PANEL SETTING 

drop country 
encode countrycode, gen(country)
xtset country year

drop if execrlc<1
drop chiefexright
drop chiefexleft
gen chiefexright = .
replace chiefexright = 1 if execrlc==1
replace chiefexright = 0 if execrlc==2 | execrlc==3
gen chiefexleft = .
replace chiefexleft = 1 if execrlc==3
replace chiefexleft = 0 if execrlc==1 | execrlc==2
gen chiefexcenter = .
replace chiefexcenter = 1 if execrlc==2
replace chiefexcenter = 0 if execrlc==1 | execrlc==3
gen leftdictatorship=1 if chiefexleft==1 & e_boix_regime==0
replace leftdictatorship=0 if chiefexleft==0 | e_boix_regime==1
gen rightdictatorship=1 if chiefexright==1 & e_boix_regime==0
replace rightdictatorship=0 if chiefexright==0 | e_boix_regime==1
gen centerdictatorship=1 if chiefexcenter==1 & e_boix_regime==0
replace centerdictatorship=0 if chiefexcenter==0 | e_boix_regime==1
gen rightcenter = . 
replace rightcenter = 1 if chiefexright==1|chiefexcenter==1
replace rightcenter = 0 if chiefexright==0 & chiefexcenter==0
gen rightcenterautocra = . 
replace rightcenterautocra = 1 if rightdictatorship==1|centerdictatorship==1
replace rightcenterautocra = 0 if rightdictatorship==0 & centerdictatorship==0


*CHECK: CONTROLS MULTICOLLINEARITY

corr centralgovernmentdebtofgdp externaldebtstocksofgnidtdoddect inflationconsumerpricesannualfpc gdpgrowthannualnygdpmktpkdzg currentaccountbalanceofgdpbncabx gdppercapitacurrentusnygdppcapcd  gdppercapitacurrentusnygdppcapcd shorttermdebtoftotalreservesdtdo e_boix_regime fedfunds yrcurnt numvote opp1vote oppfrac govfrac eiec liec

*FURTHER CORRECTIONS

gen lcentralgovernmentdebtofgdp = ln(centralgovernmentdebtofgdp)
gen lgdppc = ln(gdppercapitacurrentusnygdppcapcd)
gen linflation = log(inflationconsumerpricesannualfpc)


*DEFAULT ON EXTERNAL DEBT AND PARTISANSHIP EFFECT

table (colname result) (command), command(_r_b _r_se: xtreg defaultex chiefexleft leftdictatorship rightcenterautocra legelec, vce(cluster countrycode)) command(_r_b _r_se: xtreg defaultex chiefexleft leftdictatorship rightcenterautocra legelec L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds , vce (cluster country)) command(_r_b _r_se: xtreg defaultex chiefexleft leftdictatorship rightcenterautocra legelec L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds , fe vce (cluster country)) command(_r_b _r_se: xtreg defaultex chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, fe vce (cluster country)) nformat(%05.3f) sformat("(%s)" _r_se) style(table-reg3)

. collect label levels command 1 "Base, Cluster Country" 2 "Controls, Cluster Country" 3 "Controls, Cluster Country, FE" 4 "Controls, Cluster Country, Time FE, FE" , modify
. collect style header command, level(label)
. collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b) shownote
. collect preview

collect export table1.xlsx

xtreg defaultex chiefexleft leftdictatorship rightcenterautocra legelec L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, vce(cluster countrycode) fe
tab countrycode if e(sample)


*DEFAULT ON OFFICIAL DEBT (PARIS CLUB) AND PARTISANSHIP EFFECT

table (colname result) (command), command(_r_b _r_se: xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra legelec, vce( cluster countrycode))  command(_r_b _r_se: xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec, vce (cluster country)) command(_r_b _r_se: xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec, fe vce (cluster country)) command(_r_b _r_se: xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, fe vce (cluster country)) nformat(%05.3f) sformat("(%s)" _r_se) style(table-reg3)

. collect label levels command 1 "(1)" 2 "(2)" 3 "(3)" 4 "(4)" , modify
. collect style header command, level(label)
. collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b) shownote
. collect preview

collect export table2.xlsx

xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, vce( cluster countrycode) fe
tab countrycode if e(sample)


*INSTRUMENTAL VARIABLE


*DEFAULT ON EXTERNAL DEBT AND PARTISANSHIP EFFECT


xi: xtivreg2 defaultex chiefexleft chiefexcenter leftdictatorship rightdictatorship centerdictatorship (legelec=L.legelectionnearness) L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe cluste(countrycode) first
xi: xtivreg2 defaultoff chiefexleft chiefexcenter leftdictatorship rightdictatorship centerdictatorship (legelec=L.legelectionnearness) L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe cluste(countrycode) first


xtreg defaultex chiefexleft chiefexcenter legelec L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe vce(cluste countrycode)

xtreg defaultoff chiefexleft chiefexcenter legelec L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe vce(cluste countrycode) 

xi: xtivreg2 defaultex chiefexleft chiefexcenter (legelec=L.legelectionnearness) L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe cluste(countrycode) first

xi: xtivreg2 defaultoff chiefexleft chiefexcenter (legelec=L.legelectionnearness) L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe cluste(countrycode) first


table (colname result) (command), command(_r_b _r_se: xtreg defaultex chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, fe vce (cluster country)) command(_r_b _r_se: xtreg defaultex chiefexleft) command(_r_b _r_se: xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, fe vce (cluster country)) command(_r_b _r_se: xtreg defaultoff chiefexleft) nformat(%05.3f) sformat("(%s)" _r_se) style(table-reg3)

. collect label levels command 1 "(1)" 2 "(2)" 3 "(3)" 4 "(4)" , modify
. collect style header command, level(label)
. collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b) shownote
. collect preview

collect export tablelast.xlsx


xtreg defaultex chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, fe vce (cluster country)

xi: xtivreg2 defaultex chiefexleft leftdictatorship rightcenterautocra (legelec=L.legelectionnearness) L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds i.year, fe cluster(countrycode) first

xtreg defaultoff chiefexleft leftdictatorship rightcenterautocra L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds legelec i.year, fe vce (cluster country)

xi: xtivreg2 defaultoff chiefexleft leftdictatorship rightcenterautocra (legelec=L.legelectionnearness) L.gdpgrowthannualnygdpmktpkdzg lgdppc L.linflation L.lcentralgovernmentdebtofgdp fedfunds  i.year, fe cluster(countrycode) first

