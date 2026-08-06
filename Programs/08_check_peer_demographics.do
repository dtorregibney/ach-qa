* 08_check_peer_demographics.do
* Purpose: check whether the 10 schools flagged is_peer_school actually have a similar racial
* composition to Globe Academy (the user's stated criterion for "similar peers" — race and FRPL;
* FRPL isn't in this dataset at all, so only the race dimension can be verified here). Derives
* each school's racial composition from its race-subgroup test counts as a percent of its
* "All"-subgroup test count.
*
* ASSUMPTION: prefer ELA as the representative subject (broadest participation), but two peer
* schools (Tucker Middle, Willis A. Sutton Middle) have no ELA rows in this file at all — only
* SocStud. Falling back to whatever subject IS available for those two, rather than silently
* dropping them, since dropping schools from a "check the peer list" analysis would defeat the
* point of the check.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"
do "00_paths.do"

capture log close
log using "$logpath/08_check_peer_demographics.log", replace

use "$datapath/modified/milestones_clean.dta", clear

keep if is_dli_school == 1 | is_peer_school == 1 | instn_name == "GLOBE Academy Charter School I"

* Pick the best-available subject per school: ELA if present, else whichever subject IS present.
gen byte subj_priority = 1 if subject == "ELA"
replace subj_priority = 2 if subject == "Math"
replace subj_priority = 3 if subject == "Science"
replace subj_priority = 4 if subject == "SocStud"
bysort school_distrct_cd instn_number: egen min_priority = min(subj_priority)

* Flag (before dropping rows) which schools are relying on the fallback, so this is visible in
* the output rather than a silent substitution.
gen byte used_fallback_subject = (min_priority > 1)
quietly levelsof instn_name if used_fallback_subject == 1 & subj_priority == min_priority, clean
display "Schools using a non-ELA fallback subject: `r(levels)'"

keep if subj_priority == min_priority

keep instn_name is_dli_school is_peer_school subject used_fallback_subject subgroup num_tested_cnt
reshape wide num_tested_cnt, i(instn_name is_dli_school is_peer_school subject used_fallback_subject) j(subgroup) string

gen total_n = num_tested_cntAll
foreach r in Asian Black Hisp Multi White {
    gen pct_`r' = round(100 * num_tested_cnt`r' / total_n, 0.1)
}

label variable subject "Subject used for this school's demographic composition"
label variable used_fallback_subject "Non-ELA subject used because ELA unavailable for this school"
label variable total_n "Number tested (denominator for the percentages below)"
label variable pct_Asian "Percent Asian"
label variable pct_Black "Percent Black"
label variable pct_Hisp  "Percent Hispanic"
label variable pct_Multi "Percent Multiracial"
label variable pct_White "Percent White"

gsort -is_peer_school -is_dli_school instn_name
list instn_name is_dli_school is_peer_school subject total_n pct_Black pct_Hisp pct_White pct_Asian pct_Multi, noobs

* Export for the user to review directly, alongside a plain-language read of it in chat.
export excel instn_name is_dli_school is_peer_school subject used_fallback_subject total_n ///
    pct_Black pct_Hisp pct_White pct_Asian pct_Multi ///
    using "$outputpath/Unformatted/globe_peer_demographic_check.xlsx", ///
    firstrow(varlabels) sheet("Peer demographic check") replace

log close
