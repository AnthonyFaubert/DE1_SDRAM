
`timescale 1 ns / 1 ps

module Tester (
	       input logic 	   CLOCK_50,
	       input logic [9:0]   SW,
	       output logic [9:0]  LEDR,
//	       input logic [3:0] KEY,
	       inout [15:0] 	   DRAM_DQ, // Data input/output port. Each data word is 16 bits = 2 bytes
	       output logic [12:0] DRAM_ADDR, // row/column ADDRess, depending on command specified by row/column strobes
	       output logic [1:0]  DRAM_BA, // Bank Address. the SDRAM is split into 4 equal banks
	       output logic 	   DRAM_CAS_N, // ColumnAddressStrobe, active-low
	       output logic 	   DRAM_CKE, // ClocKEnable, active-high
	       output logic 	   DRAM_CLK, // CLocK
	       output logic 	   DRAM_CS_N, // ChipSelect, active-low
	       output logic 	   DRAM_LDQM, // Low DQ (data port) Mask, can be used to ignore the lower byte of the data port (DQ[7:0]) during a write operation
	       output logic 	   DRAM_RAS_N, // RowAddressStrobe, active-low
	       output logic 	   DRAM_UDQM, // Upper DQ Mask, same as LDQM, but for the upper byte (DQ[15:8]) instead of the lower one
	       output logic 	   DRAM_WE_N // WriteEnable, active-low
	       );
   parameter IS_SIMULATION = 0;
/*Emacs text editor settings
(setq verilog-auto-newline nil)
(setq verilog-auto-indent-on-newline nil)
 */

   logic clk, rst;
   // Generate 100MHz clock from 50MHz clock, TODO: what to do about reset? seems it can be left 0 as I turned on auto-reset
   clock100pll clk100gen (.refclk(CLOCK_50), .rst(1'b0), .outclk_0(clk), .locked(LEDR[0]));
   
   logic [19:0] swCtr; // overflows @ 95.4Hz
   logic [9:0] swMS, sw;
   always_ff @(posedge clk) begin
      if (IS_SIMULATION) begin // Simulation
	 // skip metastability protection and debouncing
	 sw <= SW;
	 {swMS, swCtr} <= 'X;
      end else begin // Synthesis
	 swMS <= SW;
	 swCtr <= swCtr + 20'd1;
	 if (swCtr == 20'd0) sw <= swMS;
	 else sw <= sw;
      end
   end
   assign rst = sw[9];
   assign LEDR[9] = rst;


   logic [12:0] addr;
   logic [1:0] 	bank, curBank, DQM;
   logic 	CAS, RAS, WE;
   assign DRAM_BA = bank;
   assign DRAM_CKE = 1;
   assign DRAM_CLK = clk;
   assign DRAM_CS_N = 0;
   assign DRAM_ADDR = addr;
   assign DRAM_CAS_N = ~CAS;
   assign DRAM_RAS_N = ~RAS;
   assign DRAM_WE_N = ~WE;
   assign {DRAM_UDQM, DRAM_LDQM} = DQM;
   logic 	OE; // OutputEnable
   logic [15:0] DQ;
   assign DRAM_DQ = OE ? DQ : 'Z;

   parameter WRITE_BURST_MODE = 1'b1; // Single location access
   parameter LATENCY_MODE = 1'b0; // CAS latency = 2
   parameter BURST_TYPE = 1'b0; // sequential
   parameter BURST_LENGTH = 3'd0; // 1
   // {DRAM_BA, DRAM_ADDR} = MODE_REG_VAL;
   localparam MODE_REG_VAL = {5'd0, WRITE_BURST_MODE, 4'd0, LATENCY_MODE, BURST_TYPE, BURST_LENGTH};

   // keep (wires), preserve (regs), noprune (unused aka no fanout)
   // https://forums.intel.com/s/question/0D50P00003yyHTBSA2/how-to-preserve-nets-during-quartus-analysissynthesis?language=en_US
   logic 	triggerDebug; /* synthesis noprune */
	assign LEDR[1] = triggerDebug;

   enum {WAIT,
	 RESET, BOOTA, BOOTB, BOOTC,
	 OPEN1, WRITE1, WRITE2, WRITE3, READ1, READ2, WRITE4,
	 OPEN2, CLOSE2,
	 OPEN3, READ31, READ32, READ33, READ34,
	 DONE} ps, ns, waitRet, nwaitRet;
   logic [$clog2(10000)-1:0] waitCtr, nwaitCtr;
   logic [13:0] 	     seqCtr, nseqCtr;
   always_comb begin
      addr = '0;
      // Default request SDRAM to not drive DQ
      DQM = 2'b11;
      OE = 0;
      DQ = 'X;
      // NO-OP
      {CAS, RAS, WE} = '0;
      //
      bank = curBank;
      nwaitRet = waitRet;
      nseqCtr = seqCtr;
      nwaitCtr = 'X;
      triggerDebug = 0;

      if (rst) begin
	 ns = RESET;
      end else begin
	 case (ps)
	   // Utility
	   WAIT: begin
	      nwaitCtr = waitCtr - 1;
	      if (waitCtr == 1) ns = waitRet;
	      else ns = WAIT;
	   end

	   RESET: begin
	      nwaitRet = BOOTA;
	      nwaitCtr = 10010; // >100us
	      ns = WAIT;
	   end
	   BOOTA: begin
	      {RAS, CAS, WE, addr[10]} = 4'b1011; // precharge all
	      nwaitRet = BOOTB;
	      nwaitCtr = 2; // tRP=2
	      ns = WAIT;

	      nseqCtr = 14'd8191; // auto-refresh all rows
	   end

	   BOOTB: begin // runs 8192 times
	      {RAS, CAS, WE} = 3'b110; // auto refresh
	      nseqCtr = seqCtr - 14'd1;
	      if (seqCtr == 14'd0) nwaitRet = BOOTC;
	      else nwaitRet = BOOTB;
	      nwaitCtr = 8; // tRC=8
	      ns = WAIT;	      
	   end
	   
	   BOOTC: begin
	      {RAS, CAS, WE} = 3'b111; // set mode reg
	      {bank, addr} = MODE_REG_VAL;// mode reg value
	      nwaitRet = OPEN1;
	      nwaitCtr = 2; // tMRD=2
	      ns = WAIT;
	   end


	   OPEN1: begin // activate bank0 row6000
	      triggerDebug = 1;
	      {RAS, CAS, WE} = 3'b100; // activate row
	      bank = 2'd0;
	      addr = 13'd6000;
	      nwaitRet = WRITE1;
	      nwaitCtr = 2; // tRCD=2
	      ns = WAIT;
	   end
	   WRITE1: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0110; // write
	      addr[9:0] = 10'd100;
	      OE = 1;
	      DQM = 2'b00; // enable both bytes
	      DQ = 16'hDEAD;
	      ns = WRITE2;
	   end
	   WRITE2: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0110; // write
	      addr[9:0] = 10'd101;
	      OE = 1;
	      DQM = 2'b00; // enable both bytes
	      DQ = 16'hBEEF;
	      ns = WRITE3;
	   end
	   WRITE3: begin // in theory, should be able to get one write in before the DQM from the read kicks in
	      {RAS, CAS, WE, addr[10]} = 4'b0110; // write
	      addr[9:0] = 10'd110;
	      OE = 1;
	      DQM = 2'b00; // enable both bytes
	      DQ = 16'hF00D;
	      ns = READ1;
	   end
	   READ1: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0100; // read
	      addr[9:0] = 10'd100;
	      DQM = 2'b00; // enable both bytes
	      ns = READ2;
	   end
	   READ2: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0100; // read
	      addr[9:0] = 10'd101;
	      DQM = 2'b00; // enable both bytes

	      // Switch to writing by NO-OPing for 3 cycles with DQM=2'b11
	      nwaitCtr = 3;
	      nwaitRet = WRITE4;
	      ns = WAIT;
	   end
	   WRITE4: begin // do a final write and close
	      {RAS, CAS, WE, addr[10]} = 4'b0111; // write with auto-precharge
	      addr[9:0] = 10'd99;
	      OE = 1;
	      DQM = 2'b00; // enable both bytes
	      DQ = 16'hFACE;

	      nwaitCtr = 4; // tRP=2 + tDPL=2 (tDPL because there's a "writeback" period)
	      nwaitRet = OPEN2;
	      ns = WAIT;
	   end
	   
	   OPEN2: begin // activate bank1 row2000
	      {RAS, CAS, WE} = 3'b100; // activate row
	      bank = 2'd1;
	      addr = 13'd2000;
	      nwaitRet = CLOSE2;
	      nwaitCtr = 5; // tRAS=5, (tRAS + 1 (sending precharge command) + tRP = tRC) (ACT->PRE + cmdPRE + PRE->ACT = ACT->ACT)
	      ns = WAIT;
	   end
	   CLOSE2: begin
	      {RAS, CAS, WE, addr[10]} = 4'b1011; // precharge all
	      nwaitRet = OPEN3;
	      nwaitCtr = 2; // tRP=2
	      ns = WAIT;
	   end

	   // ram[bank][row][col], row = ram[0][6000]
	   // row[100]=1234, row[101]=2345, row[99]=4444
	   OPEN3: begin // activate bank0 row6000
	      {RAS, CAS, WE} = 3'b100; // activate row
	      bank = 2'd0;
	      addr = 13'd6000;
	      nwaitRet = READ31;
	      nwaitCtr = 2; // tRCD=2
	      ns = WAIT;
	   end
	   READ31: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0100; // read
	      addr[9:0] = 10'd100;
	      DQM = 2'b00; // enable both bytes
	      ns = READ32;
	   end
	   READ32: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0100; // read
	      addr[9:0] = 10'd101;
	      DQM = 2'b00; // enable both bytes
	      ns = READ33;
	   end
	   READ33: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0100; // read
	      addr[9:0] = 10'd110;
	      DQM = 2'b00; // enable both bytes
	      ns = READ34;
	   end
	   READ34: begin
	      {RAS, CAS, WE, addr[10]} = 4'b0101; // read with auto-precharge
	      addr[9:0] = 10'd99;
	      DQM = 2'b00; // enable both bytes
	      ns = DONE;
	   end

	   DONE: begin
	      ns = DONE;
	   end
	 endcase
      end // if (rst) else begin
   end // always_comb

   always_ff @(posedge clk) begin
      waitRet <= nwaitRet;
      waitCtr <= nwaitCtr;
      seqCtr <= nseqCtr;
      curBank <= bank;
      ps <= ns; // reset handled in always_comb
   end
endmodule

module Tester_tb ();
   logic CLOCK_50, DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N;
   logic [9:0] SW, LEDR;
   tri [15:0] DRAM_DQ;
   logic [12:0] DRAM_ADDR;
   logic [1:0] 	DRAM_BA;

   Tester dut (.*);
   defparam dut.IS_SIMULATION = 1;

   // Set up the 50MHz clock
   logic 	clk;
   assign CLOCK_50 = clk;
   parameter CLOCK_PERIOD=20;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end

   initial begin
      @(negedge DRAM_CLK);
      SW[9] = 1; @(negedge DRAM_CLK); // reset
      SW[9] = 0;
      repeat (100*100 + 9*8192 + 5000) @(negedge DRAM_CLK);
      $stop;
   end
endmodule
