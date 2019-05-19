onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TestRam_tb/CLOCK_PERIOD
add wave -noupdate /TestRam_tb/CLOCK_50
add wave -noupdate /TestRam_tb/DRAM_CAS_N
add wave -noupdate /TestRam_tb/DRAM_CKE
add wave -noupdate /TestRam_tb/DRAM_CLK
add wave -noupdate /TestRam_tb/DRAM_CS_N
add wave -noupdate /TestRam_tb/DRAM_LDQM
add wave -noupdate /TestRam_tb/DRAM_RAS_N
add wave -noupdate /TestRam_tb/DRAM_UDQM
add wave -noupdate /TestRam_tb/DRAM_WE_N
add wave -noupdate /TestRam_tb/SW
add wave -noupdate /TestRam_tb/LEDR
add wave -noupdate /TestRam_tb/KEY
add wave -noupdate /TestRam_tb/DRAM_DQ
add wave -noupdate /TestRam_tb/DRAM_ADDR
add wave -noupdate /TestRam_tb/DRAM_BA
add wave -noupdate /TestRam_tb/HEX0
add wave -noupdate /TestRam_tb/HEX1
add wave -noupdate /TestRam_tb/HEX2
add wave -noupdate /TestRam_tb/HEX3
add wave -noupdate /TestRam_tb/HEX4
add wave -noupdate /TestRam_tb/HEX5
add wave -noupdate /TestRam_tb/clk
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /TestRam_tb/dut/IS_SIMULATION
add wave -noupdate /TestRam_tb/dut/KEEP_OPEN_THRESHOLD
add wave -noupdate /TestRam_tb/dut/CLOCK_50
add wave -noupdate /TestRam_tb/dut/SW
add wave -noupdate /TestRam_tb/dut/LEDR
add wave -noupdate /TestRam_tb/dut/KEY
add wave -noupdate /TestRam_tb/dut/HEX0
add wave -noupdate /TestRam_tb/dut/HEX1
add wave -noupdate /TestRam_tb/dut/HEX2
add wave -noupdate /TestRam_tb/dut/HEX3
add wave -noupdate /TestRam_tb/dut/HEX4
add wave -noupdate /TestRam_tb/dut/HEX5
add wave -noupdate /TestRam_tb/dut/DRAM_DQ
add wave -noupdate /TestRam_tb/dut/DRAM_ADDR
add wave -noupdate /TestRam_tb/dut/DRAM_BA
add wave -noupdate /TestRam_tb/dut/DRAM_CAS_N
add wave -noupdate /TestRam_tb/dut/DRAM_CKE
add wave -noupdate /TestRam_tb/dut/DRAM_CLK
add wave -noupdate /TestRam_tb/dut/DRAM_CS_N
add wave -noupdate /TestRam_tb/dut/DRAM_LDQM
add wave -noupdate /TestRam_tb/dut/DRAM_RAS_N
add wave -noupdate /TestRam_tb/dut/DRAM_UDQM
add wave -noupdate /TestRam_tb/dut/DRAM_WE_N
add wave -noupdate /TestRam_tb/dut/clk50
add wave -noupdate /TestRam_tb/dut/clk125
add wave -noupdate /TestRam_tb/dut/rst50
add wave -noupdate /TestRam_tb/dut/rst125
add wave -noupdate /TestRam_tb/dut/debounceCtr
add wave -noupdate /TestRam_tb/dut/swMS
add wave -noupdate /TestRam_tb/dut/sw
add wave -noupdate /TestRam_tb/dut/key
add wave -noupdate /TestRam_tb/dut/keyMS
add wave -noupdate /TestRam_tb/dut/refreshCountdown
add wave -noupdate /TestRam_tb/dut/sendRead
add wave -noupdate /TestRam_tb/dut/sendWrite
add wave -noupdate /TestRam_tb/dut/full
add wave -noupdate /TestRam_tb/dut/readValid
add wave -noupdate /TestRam_tb/dut/address
add wave -noupdate /TestRam_tb/dut/raddr
add wave -noupdate /TestRam_tb/dut/writeData
add wave -noupdate /TestRam_tb/dut/rdata
add wave -noupdate /TestRam_tb/dut/writeMask
add wave -noupdate /TestRam_tb/dut/raddrLast
add wave -noupdate /TestRam_tb/dut/rdataLast
add wave -noupdate /TestRam_tb/dut/hexVal
add wave -noupdate /TestRam_tb/dut/flag
add wave -noupdate -divider easyram
add wave -noupdate /TestRam_tb/dut/sdram/ps
add wave -noupdate /TestRam_tb/dut/sdram/ns
add wave -noupdate /TestRam_tb/dut/sdram/waitReturn
add wave -noupdate /TestRam_tb/dut/sdram/refreshTimer
add wave -noupdate -divider saferam
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/commandReady
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/prechargeReady
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/rowOpen
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/command
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/bankSel
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/writeReady
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/readValid
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/raddr
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/OE
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/DQ
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/timingCounter
add wave -noupdate /TestRam_tb/dut/sdram/safeDRAM/prechargeTimer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {104676 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {471040 ps}