onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/clk
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/rst
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/commandReady
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/prechargeReady
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/writeReady
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/readValid
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/rowOpen
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/command
add wave -noupdate -radix binary -radixshowbase 0 /SafeSDRAM_tb/writeMask
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/bankSel
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/addr
add wave -noupdate -radix hexadecimal -radixshowbase 0 /SafeSDRAM_tb/wdata
add wave -noupdate -radix hexadecimal -radixshowbase 0 /SafeSDRAM_tb/rdata
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/raddr
add wave -noupdate -radix hexadecimal -radixshowbase 0 /SafeSDRAM_tb/DRAM_DQ
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_ADDR
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_BA
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_CAS_N
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_CKE
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_CLK
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_CS_N
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_LDQM
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_RAS_N
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_UDQM
add wave -noupdate -radix unsigned -radixshowbase 0 /SafeSDRAM_tb/DRAM_WE_N
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate /SafeSDRAM_tb/dut/clk
add wave -noupdate /SafeSDRAM_tb/dut/rst
add wave -noupdate /SafeSDRAM_tb/dut/commandReady
add wave -noupdate /SafeSDRAM_tb/dut/prechargeReady
add wave -noupdate /SafeSDRAM_tb/dut/rowOpen
add wave -noupdate /SafeSDRAM_tb/dut/command
add wave -noupdate /SafeSDRAM_tb/dut/bankSel
add wave -noupdate /SafeSDRAM_tb/dut/addr
add wave -noupdate /SafeSDRAM_tb/dut/writeReady
add wave -noupdate /SafeSDRAM_tb/dut/writeMask
add wave -noupdate /SafeSDRAM_tb/dut/wdata
add wave -noupdate /SafeSDRAM_tb/dut/readValid
add wave -noupdate /SafeSDRAM_tb/dut/raddr
add wave -noupdate /SafeSDRAM_tb/dut/rdata
add wave -noupdate /SafeSDRAM_tb/dut/DQM3
add wave -noupdate /SafeSDRAM_tb/dut/DQM2
add wave -noupdate /SafeSDRAM_tb/dut/DQM1
add wave -noupdate /SafeSDRAM_tb/dut/DRAM_DQM
add wave -noupdate /SafeSDRAM_tb/dut/lastCmdWasValidWrite
add wave -noupdate /SafeSDRAM_tb/dut/nlastCmdWasValidWrite
add wave -noupdate /SafeSDRAM_tb/dut/OE
add wave -noupdate /SafeSDRAM_tb/dut/DQ
add wave -noupdate /SafeSDRAM_tb/dut/error
add wave -noupdate /SafeSDRAM_tb/dut/rvalid2
add wave -noupdate /SafeSDRAM_tb/dut/rvalid1
add wave -noupdate /SafeSDRAM_tb/dut/rvalid0
add wave -noupdate /SafeSDRAM_tb/dut/raddr2
add wave -noupdate /SafeSDRAM_tb/dut/raddr1
add wave -noupdate /SafeSDRAM_tb/dut/raddr0
add wave -noupdate /SafeSDRAM_tb/dut/currentBank
add wave -noupdate /SafeSDRAM_tb/dut/nextBank
add wave -noupdate /SafeSDRAM_tb/dut/currentRow
add wave -noupdate /SafeSDRAM_tb/dut/nextRow
add wave -noupdate /SafeSDRAM_tb/dut/nrowOpen
add wave -noupdate /SafeSDRAM_tb/dut/timingCounter
add wave -noupdate /SafeSDRAM_tb/dut/ntimingCounter
add wave -noupdate /SafeSDRAM_tb/dut/prechargeTimer
add wave -noupdate /SafeSDRAM_tb/dut/nprechargeTimer
add wave -noupdate /SafeSDRAM_tb/dut/RAS
add wave -noupdate /SafeSDRAM_tb/dut/CAS
add wave -noupdate /SafeSDRAM_tb/dut/WE
add wave -noupdate /SafeSDRAM_tb/dut/MODE_REG_VAL
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {389 ps} 0}
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
WaveRestoreZoom {362 ps} {478 ps}
