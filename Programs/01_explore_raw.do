* 01_explore_raw.do
* Purpose: first look at the raw ACH milestones data before proposing any cleaning steps.
* Read-only step — never modifies or resaves the raw file itself.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"   // ensure relative paths below resolve regardless of Stata's launch-time cwd
do "00_paths.do"                                                      // load $datapath/$outputpath/$logpath globals

capture log close                                                      // close any log left open from a prior run
log using "$logpath/01_explore_raw.log", replace                       // fresh log for this exploration pass

use "$datapath/raw/milestones_wide.dta", clear                         // load raw data; read-only, never resaved

describe                                                               // variable names, types, formats, labels
codebook, compact                                                      // range/#missing/#unique for every variable at a glance

count                                                                  // total observation count
duplicates report                                                      // check whether duplication exists at all, and its shape

misstable summarize                                                    // which variables have missing values, and how much

* Eyeball spelling/capitalization consistency in every string variable — inconsistent
* capitalization (e.g. "Male" vs "male") won't show up in codebook's numeric summary.
foreach v of varlist _all {
    local vtype : type `v'
    if strpos("`vtype'", "str") {
        display "---- `v' ----"
        tab `v', missing
    }
}

log close
