* 00_paths.do
* Purpose: defines this project's data/output/log path globals — nothing else. Sourced by every
* other script, including 00_master.do itself, so there's exactly one place a Drive path is
* hardcoded. Deliberately does NOT call any other script, so it can be safely sourced from
* anywhere without creating a call cycle.

global datapath   "/Users/danielatorregibney/Library/CloudStorage/GoogleDrive-daniela.torregibney@bellwether.org/My Drive/ACH - Eval/Data"
global outputpath "/Users/danielatorregibney/Library/CloudStorage/GoogleDrive-daniela.torregibney@bellwether.org/My Drive/ACH - Eval/Output"
global logpath    "/Users/danielatorregibney/Library/CloudStorage/GoogleDrive-daniela.torregibney@bellwether.org/My Drive/ACH - Eval/Logs"
