* 02_reshape_long.do
* Purpose: reshape the raw wide-format milestones file (subgroup embedded in variable names,
* e.g. num_tested_cntAsian, begin_pctBlack) into long format — one row per school x subject x
* subgroup. Every later cleaning step (suppression flag, destring, missing-data handling)
* becomes a single operation instead of one repeated per subgroup. Raw file is never touched;
* this writes a new file to Data/modified.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"   // ensure relative paths below resolve regardless of Stata's launch-time cwd
do "00_paths.do"                                                      // load $datapath/$outputpath/$logpath globals

capture log close
log using "$logpath/02_reshape_long.log", replace

use "$datapath/raw/milestones_wide.dta", clear      // start from the untouched raw file

* instn_number alone is NOT globally unique — it's only unique within a district (e.g.
* institution "101" exists as a different school in district 608 and in district 615) —
* confirmed via a duplicates check. school_distrct_cd must be part of the identifier.
isid school_distrct_cd instn_number subject          // confirm each district-school-subject triple is unique in the wide file — reshape relies on this as the row identifier

local n_wide = _N
display "Wide-format row count: `n_wide'"

* Each stub below repeats across 8 subgroup suffixes (All/Asian/Black/Female/Hisp/Male/Multi/
* White) in the wide file; j(subgroup) captures which suffix each new long row came from.
reshape long num_tested_cnt begin_cnt developing_cnt proficient_cnt distinguished_cnt ///
    begin_pct developing_pct proficient_pct distinguished_pct, ///
    i(school_distrct_cd instn_number subject) j(subgroup) string

local n_long = _N
local expected = `n_wide' * 8
display "Long-format row count: `n_long' (expected `n_wide' wide rows x 8 subgroups = `expected')"
assert `n_long' == `expected'                        // catches a reshape mistake immediately instead of silently continuing with the wrong shape

* "subgroup" mixes two different reporting dimensions (race/ethnicity and sex) plus the "All"
* total — flag which kind each row is, so later analysis can filter/group correctly instead of
* re-deriving this every time.
gen subgroup_type = "race"   if inlist(subgroup, "Asian", "Black", "Hisp", "Multi", "White")
replace subgroup_type = "gender" if inlist(subgroup, "Male", "Female")
replace subgroup_type = "total"  if subgroup == "All"
assert !missing(subgroup_type)                       // catches any subgroup value this classification didn't anticipate

describe
tab subgroup_type
tab subgroup

save "$datapath/modified/milestones_long_raw.dta", replace   // "_raw" tag: reshaped only, no other cleaning applied yet

log close
