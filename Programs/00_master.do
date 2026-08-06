* 00_master.do
* Purpose: runs the full cleaning pipeline in order, from the raw file to the validated output.
* Path globals live in 00_paths.do, not here — that avoids a call cycle, since every individual
* script also sources 00_paths.do (not this file) to bootstrap standalone runs.

clear all                                  // start from a clean Stata session
set more off                                // don't pause output waiting on --more--
cd "/Users/danielatorregibney/Quantitative Analysis/ACH QA/Programs"   // so relative do-calls below resolve regardless of Stata's launch-time cwd

do "00_paths.do"                            // load $datapath/$outputpath/$logpath

* --- Pipeline scripts, run in order ---
do "01_explore_raw.do"                     // first look at raw data: describe/codebook/duplicates/missing, read-only
do "02_reshape_long.do"                    // reshape wide (subgroup-in-varname) to long (subgroup as a variable) + subgroup_type
do "03_suppression_and_destring.do"        // flag TFS-suppressed cells, then destring the count variables
do "04_scope_and_missing_flags.do"         // drop ALL aggregate rollup rows; resolves is_peer_school/is_dli_school missingness
do "05_validate.do"                        // range checks, tier-sum check, count/percent alignment; writes milestones_clean.dta
