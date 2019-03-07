onerror {resume}
quietly virtual function -install /TesterCAS3_tb -env /TesterCAS3_tb { &{/TesterCAS3_tb/DRAM_CS_N, /TesterCAS3_tb/DRAM_RAS_N, /TesterCAS3_tb/DRAM_CAS_N, /TesterCAS3_tb/DRAM_WE_N, /TesterCAS3_tb/DRAM_ADDR[10] }} command
quietly virtual function -install /TesterCAS3_tb -env /TesterCAS3_tb { &{/TesterCAS3_tb/DRAM_UDQM, /TesterCAS3_tb/DRAM_LDQM }} DQM
quietly virtual function -install /TesterCAS3_tb -env /TesterCAS3_tb/#INITIAL#289 { &{/TesterCAS3_tb/DRAM_ADDR[9], /TesterCAS3_tb/DRAM_ADDR[8], /TesterCAS3_tb/DRAM_ADDR[7], /TesterCAS3_tb/DRAM_ADDR[6], /TesterCAS3_tb/DRAM_ADDR[5], /TesterCAS3_tb/DRAM_ADDR[4], /TesterCAS3_tb/DRAM_ADDR[3], /TesterCAS3_tb/DRAM_ADDR[2], /TesterCAS3_tb/DRAM_ADDR[1], /TesterCAS3_tb/DRAM_ADDR[0] }} addr90
quietly WaveActivateNextPane {} 0
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/CLOCK_50
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_CLK
add wave -noupdate -radix binary -radixshowbase 0 /TesterCAS3_tb/command
add wave -noupdate -radix binary -radixshowbase 0 /TesterCAS3_tb/DQM
add wave -noupdate -radix hexadecimal -radixshowbase 0 /TesterCAS3_tb/DRAM_DQ
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/DRAM_BA
add wave -noupdate -label {addr[9:0]} -radix unsigned -radixshowbase 0 /TesterCAS3_tb/addr90
add wave -noupdate -radix unsigned -childformat {{{/TesterCAS3_tb/DRAM_ADDR[12]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[11]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[10]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[9]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[8]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[7]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[6]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[5]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[4]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[3]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[2]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[1]} -radix unsigned} {{/TesterCAS3_tb/DRAM_ADDR[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/TesterCAS3_tb/DRAM_ADDR[12]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[11]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[10]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[9]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[8]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[7]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[6]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[5]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[4]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[3]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[2]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[1]} {-height 17 -radix unsigned -radixshowbase 0} {/TesterCAS3_tb/DRAM_ADDR[0]} {-height 17 -radix unsigned -radixshowbase 0}} /TesterCAS3_tb/DRAM_ADDR
add wave -noupdate -radixshowbase 0 {/TesterCAS3_tb/SW[9]}
add wave -noupdate -radixshowbase 0 {/TesterCAS3_tb/LEDR[9]}
add wave -noupdate -radixshowbase 0 {/TesterCAS3_tb/LEDR[0]}
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_CKE
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_CS_N
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_RAS_N
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_CAS_N
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_WE_N
add wave -noupdate -radix unsigned -radixshowbase 0 {/TesterCAS3_tb/DRAM_ADDR[10]}
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_UDQM
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/DRAM_LDQM
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/SW
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/LEDR
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/clk
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/rst
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/ns
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/ps
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/triggerDebug
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/addr
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/bank
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/curBank
add wave -noupdate -radix binary -radixshowbase 0 /TesterCAS3_tb/dut/DQM
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/CAS
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/RAS
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/WE
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/OE
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/DQ
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/waitRet
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/nwaitRet
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/waitCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/nwaitCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/seqCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/nseqCtr
add wave -noupdate -radix binary -radixshowbase 0 /TesterCAS3_tb/dut/MODE_REG_VAL
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/SW
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/LEDR
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/CLOCK_50
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/swCtr
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/swMS
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/sw
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_DQ
add wave -noupdate -radix unsigned -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_ADDR
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_BA
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_CAS_N
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_CKE
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_CLK
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_CS_N
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_LDQM
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_RAS_N
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_UDQM
add wave -noupdate -radixshowbase 0 /TesterCAS3_tb/dut/DRAM_WE_N
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {837589674 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 130
configure wave -valuecolwidth 68
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
WaveRestoreZoom {837450609 ps} {837734750 ps}
