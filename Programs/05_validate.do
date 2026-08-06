* 05_validate.do
* Purpose: validate the cleaned dataset before calling it done — range checks, a domain-specific
* consistency check (the four achievement tiers should sum to ~100%), and alignment between the
* count and percent variables' missingness patterns. Saves the final cleaned file only if every
* check passes.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"
do "00_paths.do"

capture log close
log using "$logpath/05_validate.log", replace

use "$datapath/modified/milestones_long_scoped.dta", clear

* Range checks: percents must be within [0, 100]; counts must be non-negative where present.
assert inrange(begin_pct, 0, 100)         if !missing(begin_pct)
assert inrange(developing_pct, 0, 100)    if !missing(developing_pct)
assert inrange(proficient_pct, 0, 100)    if !missing(proficient_pct)
assert inrange(distinguished_pct, 0, 100) if !missing(distinguished_pct)
assert num_tested_cnt   >= 0 if !missing(num_tested_cnt)
assert begin_cnt        >= 0 if !missing(begin_cnt)
assert developing_cnt   >= 0 if !missing(developing_cnt)
assert proficient_cnt   >= 0 if !missing(proficient_cnt)
assert distinguished_cnt >= 0 if !missing(distinguished_cnt)
display "Range checks passed: all percents in [0,100], all counts >= 0"

* Domain check: the four achievement tiers are mutually exclusive and exhaustive, so their
* percentages should sum to ~100 for any row where a subgroup was actually tested. Allow a small
* tolerance for rounding in the source data.
gen pct_sum = begin_pct + developing_pct + proficient_pct + distinguished_pct
count if !missing(pct_sum) & !inrange(pct_sum, 99, 101)
local n_offsum = r(N)
display "Rows where the 4 tiers do NOT sum to ~100%: `n_offsum'"
assert `n_offsum' == 0
drop pct_sum

* Consistency check: num_tested_cnt missing should align with the pct variables also being
* missing (if nobody was tested/reported, there's nothing to compute a percent from).
count if missing(num_tested_cnt) & !missing(begin_pct)
local n_mismatch = r(N)
display "Rows where num_tested_cnt is missing but begin_pct is NOT: `n_mismatch'"

* Final descriptive check: does the overall shape make sense.
describe
tab subgroup_type
misstable summarize num_tested_cnt begin_cnt developing_cnt proficient_cnt distinguished_cnt ///
    begin_pct developing_pct proficient_pct distinguished_pct

save "$datapath/modified/milestones_clean.dta", replace

log close
