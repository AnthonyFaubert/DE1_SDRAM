set_global_assignment -entity "clock100pll" -library "lib_clock100pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock100pll" -library "lib_clock100pll" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "clock100pll" -library "lib_clock100pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock100pll" -name SPD_FILE [file join $::quartus(sip_path) "clock100pll.spd"]

set_global_assignment -library "lib_clock100pll" -name MISC_FILE [file join $::quartus(sip_path) "clock100pll_sim/clock100pll.vo"]
