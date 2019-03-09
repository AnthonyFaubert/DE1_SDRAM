set_global_assignment -entity "PLLClock125" -library "lib_PLLClock125" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLLClock125" -library "lib_PLLClock125" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "PLLClock125" -library "lib_PLLClock125" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLLClock125" -name SPD_FILE [file join $::quartus(sip_path) "PLLClock125.spd"]

set_global_assignment -library "lib_PLLClock125" -name MISC_FILE [file join $::quartus(sip_path) "PLLClock125_sim/PLLClock125.vo"]
