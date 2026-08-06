* 04_scope_and_missing_flags.do
* Purpose: drop the "ALL" aggregate/rollup rows (not individual schools, so out of scope for a
* school-level analysis), and check whether that also resolves the missingness on the two
* binary school-characteristic flags (is_peer_school, is_dli_school).
*
* ASSUMPTION being made here: the unit of analysis is individual schools, so instn_name=="ALL"
* rows (district/state-level rollups) are out of scope. Flagging this explicitly since it's a
* judgment call, not a fact derivable from the data itself.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"
do "00_master.do"

capture log close
log using "$logpath/04_scope_and_missing_flags.log", replace

use "$datapath/modified/milestones_long_flagged.dta", clear

* Diagnostic: are the missing is_peer_school/is_dli_school rows the same rows as instn_name==
* "ALL"? If so, dropping ALL resolves both issues at once rather than needing two fixes.
count if missing(is_peer_school) & instn_name == "ALL"
count if missing(is_peer_school) & instn_name != "ALL"
count if missing(is_dli_school) & instn_name == "ALL"
count if missing(is_dli_school) & instn_name != "ALL"

local n_before = _N
count if instn_name == "ALL"
local n_all = r(N)
display "Dropping `n_all' aggregate/rollup rows (instn_name == ALL) out of `n_before' total"

drop if instn_name == "ALL"

local n_after = _N
assert `n_after' == `n_before' - `n_all'   // confirms exactly the intended rows were dropped, nothing else

* Re-check the binary flags now that ALL rows are gone.
misstable summarize is_peer_school is_dli_school

save "$datapath/modified/milestones_long_scoped.dta", replace

log close
