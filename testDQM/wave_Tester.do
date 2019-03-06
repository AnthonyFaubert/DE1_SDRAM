onerror {resume}
quietly virtual function -install /Tester_tb -env /Tester_tb/#INITIAL#272 { &{/Tester_tb/DRAM_CS_N, /Tester_tb/DRAM_RAS_N, /Tester_tb/DRAM_CAS_N, /Tester_tb/DRAM_WE_N, /Tester_tb/DRAM_ADDR[10] }} command
quietly virtual function -install /Tester_tb -env /Tester_tb/#INITIAL#272 { &{/Tester_tb/DRAM_UDQM, /Tester_tb/DRAM_LDQM }} DQM
quietly WaveActivateNextPane {} 0
add wave -noupdate -radixshowbase 0 /Tester_tb/CLOCK_50
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_CLK
add wave -noupdate -radix binary -radixshowbase 0 /Tester_tb/command
add wave -noupdate -radix binary -radixshowbase 0 /Tester_tb/DQM
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/DRAM_DQ
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/DRAM_BA
add wave -noupdate -radix unsigned -childformat {{{/Tester_tb/DRAM_ADDR[12]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[11]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[10]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[9]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[8]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[7]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[6]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[5]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[4]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[3]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[2]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[1]} -radix unsigned} {{/Tester_tb/DRAM_ADDR[0]} -radix unsigned}} -radixshowbase 0 -subitemconfig {{/Tester_tb/DRAM_ADDR[12]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[11]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[10]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[9]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[8]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[7]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[6]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[5]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[4]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[3]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[2]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[1]} {-height 17 -radix unsigned -radixshowbase 0} {/Tester_tb/DRAM_ADDR[0]} {-height 17 -radix unsigned -radixshowbase 0}} /Tester_tb/DRAM_ADDR
add wave -noupdate -radixshowbase 0 {/Tester_tb/SW[9]}
add wave -noupdate -radixshowbase 0 {/Tester_tb/LEDR[9]}
add wave -noupdate -radixshowbase 0 {/Tester_tb/LEDR[0]}
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_CKE
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_CS_N
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_RAS_N
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_CAS_N
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_WE_N
add wave -noupdate -radix unsigned -radixshowbase 0 {/Tester_tb/DRAM_ADDR[10]}
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_UDQM
add wave -noupdate -radixshowbase 0 /Tester_tb/DRAM_LDQM
add wave -noupdate -radixshowbase 0 /Tester_tb/SW
add wave -noupdate -radixshowbase 0 /Tester_tb/LEDR
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/clk
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/rst
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/ns
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/ps
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/triggerDebug
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/addr
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/bank
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/curBank
add wave -noupdate -radix binary -radixshowbase 0 /Tester_tb/dut/DQM
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/CAS
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/RAS
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/WE
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/OE
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/DQ
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/waitRet
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/nwaitRet
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/waitCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/nwaitCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/seqCtr
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/nseqCtr
add wave -noupdate -radix binary -radixshowbase 0 /Tester_tb/dut/MODE_REG_VAL
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/SW
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/LEDR
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/CLOCK_50
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/swCtr
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/swMS
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/sw
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/DRAM_DQ
add wave -noupdate -radix unsigned -radixshowbase 0 /Tester_tb/dut/DRAM_ADDR
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_BA
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_CAS_N
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_CKE
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_CLK
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_CS_N
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_LDQM
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_RAS_N
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_UDQM
add wave -noupdate -radixshowbase 0 /Tester_tb/dut/DRAM_WE_N
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {837462344 ps} 0}
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
WaveRestoreZoom {837417058 ps} {837681762 ps}
