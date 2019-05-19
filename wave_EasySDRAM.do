onerror {resume}
quietly virtual function -install /EasySDRAM_tb -env /EasySDRAM_tb { &{/EasySDRAM_tb/DRAM_ADDR[9], /EasySDRAM_tb/DRAM_ADDR[8], /EasySDRAM_tb/DRAM_ADDR[7], /EasySDRAM_tb/DRAM_ADDR[6], /EasySDRAM_tb/DRAM_ADDR[5], /EasySDRAM_tb/DRAM_ADDR[4], /EasySDRAM_tb/DRAM_ADDR[3], /EasySDRAM_tb/DRAM_ADDR[2], /EasySDRAM_tb/DRAM_ADDR[1], /EasySDRAM_tb/DRAM_ADDR[0] }} DADDR90
quietly WaveActivateNextPane {} 0
add wave -noupdate /EasySDRAM_tb/CLOCK_PERIOD
add wave -noupdate /EasySDRAM_tb/Tdiv4
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/clk
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/rst
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/clkCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/lastRefresh
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/write
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/full
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/isWrite
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/keepOpen
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/busy
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/rowOpen
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/refreshCountdown
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/fifoUsage
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/readValid
add wave -noupdate /EasySDRAM_tb/raddr
add wave -noupdate -radix hexadecimal -radixshowbase 0 /EasySDRAM_tb/rdata
add wave -noupdate /EasySDRAM_tb/rtag
add wave -noupdate /EasySDRAM_tb/address
add wave -noupdate /EasySDRAM_tb/tag
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/writeMask
add wave -noupdate -radix hexadecimal -radixshowbase 0 /EasySDRAM_tb/writeData
add wave -noupdate -radix hexadecimal -radixshowbase 0 /EasySDRAM_tb/DRAM_DQ
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/DRAM_BA
add wave -noupdate {/EasySDRAM_tb/DRAM_ADDR[12]}
add wave -noupdate {/EasySDRAM_tb/DRAM_ADDR[11]}
add wave -noupdate {/EasySDRAM_tb/DRAM_ADDR[10]}
add wave -noupdate -label {DRAM_ADDR[9:0]} -radix hexadecimal -radixshowbase 0 /EasySDRAM_tb/DADDR90
add wave -noupdate /EasySDRAM_tb/DRAM_ADDR
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_CAS_N
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_CKE
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_CLK
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_CS_N
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_LDQM
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_RAS_N
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_UDQM
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/DRAM_WE_N
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/rst
add wave -noupdate /EasySDRAM_tb/dut/ps
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/clk
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/waitCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/refreshTimer
add wave -noupdate /EasySDRAM_tb/dut/waitReturn
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/rowOpen
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/commandReady
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/prechargeReady
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/writeReady
add wave -noupdate /EasySDRAM_tb/dut/command
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/keepOpen
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/full
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/write
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/empty
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/read
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/busy
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/cmdWrite
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/wMask
add wave -noupdate /EasySDRAM_tb/dut/wdata
add wave -noupdate /EasySDRAM_tb/dut/cmdRow
add wave -noupdate /EasySDRAM_tb/dut/cmdCol
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/bankSel
add wave -noupdate /EasySDRAM_tb/dut/addr
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/fifoUsage
add wave -noupdate /EasySDRAM_tb/dut/address
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/writeMask
add wave -noupdate -radix hexadecimal -radixshowbase 0 /EasySDRAM_tb/dut/writeData
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/isWrite
add wave -noupdate -radix binary -radixshowbase 0 /EasySDRAM_tb/dut/readValid
add wave -noupdate /EasySDRAM_tb/dut/raddr
add wave -noupdate -radix hexadecimal -radixshowbase 0 /EasySDRAM_tb/dut/rdata
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/refreshCountdown
add wave -noupdate /EasySDRAM_tb/dut/wfifo
add wave -noupdate /EasySDRAM_tb/dut/rfifo
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/nwaitCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /EasySDRAM_tb/dut/nrefreshTimer
add wave -noupdate /EasySDRAM_tb/dut/ns
add wave -noupdate /EasySDRAM_tb/dut/nwaitReturn
add wave -noupdate /EasySDRAM_tb/dut/REFRESH_TIME
add wave -noupdate /EasySDRAM_tb/dut/CLOCK_PERIOD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {123894852 ps} 0}
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
WaveRestoreZoom {123823490 ps} {124059010 ps}
