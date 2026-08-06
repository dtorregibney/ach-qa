* 07_data_dictionary.do
* Purpose: export a data dictionary for the final cleaned dataset, alongside it in Data/modified
* — one row per variable, with label, type, value label, missingness, and range — so anyone
* opening milestones_clean.dta later can understand it without re-reading the cleaning scripts.

cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"
do "00_paths.do"

capture log close
log using "$logpath/07_data_dictionary.log", replace

use "$datapath/modified/milestones_clean.dta", clear

tempname dict
postfile `dict' str32 varname str244 varlabel str20 vartype str64 valuelabel ///
    double n_obs double n_missing double n_unique double min_val double max_val ///
    using "$datapath/modified/milestones_clean_dictionary_temp", replace

foreach v of varlist _all {
    local lbl : variable label `v'
    local vtype : type `v'
    local vallbl : value label `v'
    quietly count
    local nobs = r(N)
    quietly count if missing(`v')
    local nmiss = r(N)
    quietly levelsof `v', missing
    local nuniq = r(r)
    capture confirm numeric variable `v'
    if !_rc {
        quietly summarize `v'
        post `dict' ("`v'") ("`lbl'") ("`vtype'") ("`vallbl'") (`nobs') (`nmiss') (`nuniq') (r(min)) (r(max))
    }
    else {
        post `dict' ("`v'") ("`lbl'") ("`vtype'") ("`vallbl'") (`nobs') (`nmiss') (`nuniq') (.) (.)
    }
}
postclose `dict'

preserve
use "$datapath/modified/milestones_clean_dictionary_temp", clear
export excel "$datapath/modified/milestones_clean_dictionary.xlsx", firstrow(variables) replace
list, noobs
restore

erase "$datapath/modified/milestones_clean_dictionary_temp.dta"   // intermediate file only, not a deliverable — the .xlsx is what matters

log close
