* 03_suppression_and_destring.do
* Purpose: preserve the "Too Few Students" (TFS) suppression signal before converting the count
* variables from string to numeric. Destringing naively (without flagging first) would silently
* turn "TFS" into the same missing value as a genuinely blank/not-applicable cell, losing the
* distinction between "suppressed for privacy" and "no data at all."

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"
do "00_master.do"

capture log close
log using "$logpath/03_suppression_and_destring.log", replace

use "$datapath/modified/milestones_long_raw.dta", clear

local cnt_vars num_tested_cnt begin_cnt developing_cnt proficient_cnt distinguished_cnt

* Flag TFS rows before the value is lost to destring — this is the record of what got suppressed.
foreach v of local cnt_vars {
    gen byte tfs_`v' = (`v' == "TFS")
}

* Report suppression rates up front, so the scale of what's about to become missing is visible
* now rather than discovered later downstream.
foreach v of local cnt_vars {
    quietly summarize tfs_`v'
    display "`v': " %4.1f 100*r(mean) "% suppressed (TFS)"
}

destring `cnt_vars', replace force   // force converts any remaining non-numeric text (TFS, blanks) to missing; TFS cases are already flagged above, so that signal survives

* Confirm every missing value after destring is accounted for as either TFS-suppressed or
* genuinely blank — i.e. destring didn't silently drop something unexpected (e.g. a typo/stray
* non-numeric value that wasn't "TFS" and wasn't blank).
foreach v of local cnt_vars {
    quietly count if missing(`v') & tfs_`v' == 0
    local n_blank = r(N)
    quietly count if missing(`v') & tfs_`v' == 1
    local n_tfs = r(N)
    quietly count if missing(`v')
    local n_miss = r(N)
    display "`v': `n_tfs' TFS-suppressed + `n_blank' blank/other = `n_miss' missing total"
    assert `n_tfs' + `n_blank' == `n_miss'
}

misstable summarize num_tested_cnt begin_cnt developing_cnt proficient_cnt distinguished_cnt

save "$datapath/modified/milestones_long_flagged.dta", replace

log close
