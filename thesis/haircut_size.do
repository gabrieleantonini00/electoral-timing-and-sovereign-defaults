*POLITICAL FACTORS DETERMINING GOVERNMENT UNWILLINGNESS TO PAY SOVEREIGN DEBT: HAIRCUTS SIZE

*PANEL SETTING 

drop country 
encode countrycode, gen(country)
xtset country year


gen chiefexright = .
replace chiefexright = 1 if execrlc==1
replace chiefexright = 0 if execrlc==2 | execrlc==3
gen chiefexleft = .
replace chiefexleft = 1 if execrlc==3
replace chiefexleft = 0 if execrlc==1 | execrlc==
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
replace Haircuthsz = 0 if Haircuthsz==. & year>1969 & year<2014

*RESULTS

xtreg Haircuthsz chiefexleft leftdictatorship rightcenterautocra L.iir fedfunds L.gdpgrowthannualnygdpmktpkdzg i.year, fe vce (cluster countrycode)

table (colname result) (command), command(_r_b _r_se: xtreg Haircuthsz chiefexleft leftdictatorship rightcenterautocra, vce(cluster countrycode)) command(_r_b _r_se: xtreg Haircuthsz chiefexleft leftdictatorship rightcenterautocra L.iir fedfunds L.gdpgrowthannualnygdpmktpkdzg, vce (cluster countrycode)) command(_r_b _r_se: xtreg Haircuthsz chiefexleft leftdictatorship rightcenterautocra L.iir fedfunds L.gdpgrowthannualnygdpmktpkdzg, fe vce (cluster countrycode)) command(_r_b _r_se: xtreg Haircuthsz chiefexleft leftdictatorship rightcenterautocra L.iir fedfunds L.gdpgrowthannualnygdpmktpkdzg i.year, fe vce (cluster countrycode)) nformat(%05.3f) sformat("(%s)" _r_se) style(table-reg3)

. collect label levels command 1 "(1)" 2 "(2)" 3 "(3)" 4 "(4)" , modify
. collect style header command, level(label)
. collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b) shownote
. collect preview

*EXPORTING RESULTS

collect export haircutsresults.xlsx
