# Create work library
vlib work

# List of additional files required to simulate this one. Ex:
# set ADDITIONAL_FILES {"rom32x8.v" "submodule.sv"} # NEVER ADD BB FILE FOR RAM/ROM!
 set ADDITIONAL_FILES ""
#set ADDITIONAL_FILES {"clock100pll.v" "clock100pll/clock100pll_0002.v"}
# "" or "-Lf altera_mf_ver"
set EXTRA_LIBS ""

# Set MOD_NAME to do_THISSTUFF.do
variable hist [history]
variable doi [string last ".do" $hist] # doi = last index of ".do"
variable begini [string last "do_" $hist $doi] # begini = last index of "do_" befor doi
# MOD_NAME = the asterisk stuff of the last "do_*.do" found in the history
set MOD_NAME [string range $hist $begini+3 $doi-1]

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./${MOD_NAME}.sv"
if {$ADDITIONAL_FILES ne ""} {
   vlog {*}$ADDITIONAL_FILES
}

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
#vsim -novopt -t 1ps -lib work {*}[split $EXTRA_LIBS " "] ${MOD_NAME}_tb
vsim -voptargs="+acc" -t 1ps -lib work {*}[split $EXTRA_LIBS " "] ${MOD_NAME}_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do wave_${MOD_NAME}.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
