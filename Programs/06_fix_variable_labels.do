* 06_fix_variable_labels.do
* Purpose: every variable gets a label, and every label is sentence case. The raw file's labels
* (where they existed at all) were ALL_CAPS straight from the source export (e.g. INSTN_NUMBER,
* SCHOOL_DSTRCT_NM); the two binary flags and everything we derived during cleaning had no label
* at all. Fixes milestones_clean.dta in place — this is a refinement of the "final" cleaned file,
* not a new pipeline stage.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"
do "00_paths.do"

capture log close
log using "$logpath/06_fix_variable_labels.log", replace

use "$datapath/modified/milestones_clean.dta", clear

* --- Identifiers, straight from the raw source (previously ALL_CAPS) ---
label variable instn_number    "Institution number"
label variable instn_name      "Institution name"
label variable school_distrct_cd "School district code"
label variable school_dstrct_nm  "School district name"
label variable subject         "Subject tested"

* --- Binary school-characteristic flags (previously unlabeled) ---
label variable is_peer_school  "Peer-comparison school (1 = yes)"
label variable is_dli_school   "Dual Language Immersion (DLI) school (1 = yes)"

* --- Derived during cleaning (previously unlabeled) ---
label variable subgroup        "Reporting subgroup (race, sex, or All)"
label variable subgroup_type   "Subgroup category: race, gender, or total"

* --- Achievement tier counts and percents (previously mixed-case, subgroup-specific labels) ---
label variable num_tested_cnt      "Number of students tested"
label variable begin_cnt           "Number scoring Beginning Learner"
label variable developing_cnt      "Number scoring Developing Learner"
label variable proficient_cnt      "Number scoring Proficient Learner"
label variable distinguished_cnt   "Number scoring Distinguished Learner"
label variable begin_pct           "Percent scoring Beginning Learner"
label variable developing_pct      "Percent scoring Developing Learner"
label variable proficient_pct      "Percent scoring Proficient Learner"
label variable distinguished_pct   "Percent scoring Distinguished Learner"

* --- Suppression flags (previously unlabeled) ---
label variable tfs_num_tested_cnt    "Number-tested count was suppressed (Too Few Students)"
label variable tfs_begin_cnt         "Beginning Learner count was suppressed (Too Few Students)"
label variable tfs_developing_cnt    "Developing Learner count was suppressed (Too Few Students)"
label variable tfs_proficient_cnt    "Proficient Learner count was suppressed (Too Few Students)"
label variable tfs_distinguished_cnt "Distinguished Learner count was suppressed (Too Few Students)"

* Verify nothing was missed: every variable in the file should have a non-empty label now.
local n_unlabeled = 0
foreach v of varlist _all {
    local lbl : variable label `v'
    if "`lbl'" == "" {
        display "UNLABELED: `v'"
        local n_unlabeled = `n_unlabeled' + 1
    }
}
display "Variables still unlabeled: `n_unlabeled'"
assert `n_unlabeled' == 0

save "$datapath/modified/milestones_clean.dta", replace

log close
