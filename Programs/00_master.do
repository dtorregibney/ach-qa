* 00_master.do
* Purpose: defines this project's data/output/log paths once, then runs the pipeline in order.
* This is the only file where a Drive path should be hardcoded — every other .do file references
* the globals below instead of hardcoding its own path, so moving the Drive folder only requires
* updating one file.

clear all                                  // start from a clean Stata session
set more off                                // don't pause output waiting on --more--

* --- Project paths ---
global datapath   "/Users/danielatorregibney/Library/CloudStorage/GoogleDrive-daniela.torregibney@bellwether.org/My Drive/ACH - Eval/Data"
global outputpath "/Users/danielatorregibney/Library/CloudStorage/GoogleDrive-daniela.torregibney@bellwether.org/My Drive/ACH - Eval/Output"
global logpath    "/Users/danielatorregibney/Library/CloudStorage/GoogleDrive-daniela.torregibney@bellwether.org/My Drive/ACH - Eval/Logs"

* --- Pipeline scripts, run in order ---
* do "Programs/01_explore_raw.do"
