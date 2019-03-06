
`include "SDRAM.svh"

/*
 Provides a safe and slightly simplified interface to the SDRAM.
 Note: DQMin is an important port.
 (|DQMin) being true disables the SDRAM output 2 (or 3, depending on CAS latency) clocks later,
 otherwise the SDRAM output is enabled 2 (or 3) clocks later.
 The SDRAM output must be disabled the clock before and the clock during a write command. (see page 32)
 Reads are much easier, as the data and the DQM have the same latency. So DQMin must be 2'b00 during a read command.
 2 clocks after a read command, the data and address you requested will show up on rdata and raddr, and readValid will be true.
 */
module SDRAM_LowLevel (
	input logic clk, rst, allBanks,
	input logic [1:0] DQMin, // COMPLICATED
	input logic [1:0] bankSel, // bank selector (only used during ACTIVE or PRECHARGE_BANK commands)
	input logic [12:0] addr,
	input logic [15:0] wdata,
	input CommandEnum command,
	output logic [15:0] rdata,
	output logic [9:0] raddr,
	output logic readValid,
	output logic writeReady, // confirmation that you have correctly set DQMin in previous clocks and so a write during this clock will be valid
	output logic [1:0] writeMask, // the write mask for the current write (delayed DQMin). if writeMask=2'b11, then both bytes will be written
		       
	// SDRAM I/O, connect to top-level SDRAM I/O //
	inout [15:0] DRAM_DQ, // Data input/output port. Each data word is 16 bits = 2 bytes
	output logic [12:0] DRAM_ADDR, // row/column ADDRess, depending on command specified by row/column strobes
	output logic [1:0] DRAM_BA, // Bank Address. the SDRAM is split into 4 equal banks
	output logic DRAM_CAS_N, // ColumnAddressStrobe, active-low
	output logic DRAM_CKE, // ClocKEnable, active-high
	output logic DRAM_CLK, // CLocK
	output logic DRAM_CS_N, // ChipSelect, active-low
	output logic DRAM_LDQM, // Low DQ (data port) Mask, can be used to ignore the lower byte of the data port (DQ[7:0]) during a write operation
	output logic DRAM_RAS_N, // RowAddressStrobe, active-low
	output logic DRAM_UDQM, // Upper DQ Mask, same as LDQM, but for the upper byte (DQ[15:8]) instead of the lower one
	output logic DRAM_WE_N // WriteEnable, active-low
     );
   // Mode register settings
   parameter WRITE_BURST_MODE = 1'b1; // Single location access
   parameter LATENCY_MODE = 1'b0; // CAS latency = 2
   parameter BURST_TYPE = 1'b0; // sequential
   parameter BURST_LENGTH = 3'd0; // 1
   // {DRAM_BA, DRAM_ADDR} = MODE_REG_VAL;
   localparam MODE_REG_VAL = {5'd0, WRITE_BURST_MODE, 4'd0, LATENCY_MODE, BURST_TYPE, BURST_LENGTH};

   // CAS latency requires advance notice be given for writes.
   // In Fig RW2 on page 32, DQM3 holds value at clock T2, DQM2 holds val @T3, DQM1 holds val @T4,
   //  note that vals @T2 and @T3 are needed to determine a valid write command
   logic [1:0] DQM3, DQM2, DQM1;
   assign {DRAM_UDQM, DRAM_LDQM} = DQMin;

   enum        {WRITE_MODE, READ_MODE} ps, ns;
   always_comb begin
      if (DQM)
      if (ps == WRITE_MODE) begin
	 writeReady = 1;
	 
      end else begin
	 writeReady = 0;
      end
   end
   always_ff @(posedge clk) begin
      if (rst) ps <= READ_MODE;
      else ps <= ns;
   end
   assign writeReady = (

   // It's illegal to write while the SDRAM is driving the line.
   // You also have to warn it the clock cycle before a write for it to stop driving the line, and obviously the clock cycle that you're writing. UDQM and LDQM have the programmed CAS latency (2 clocks).
   // That warning consists of (UDQM | LDQM) being true
   always @(posedge clk) begin // see page 32
      // You can't have a write during a valid read
      if (readValid) assert((command != WRITE) && (command != WRITEA));
      // If the delayed warning failed to happen in the previous clock or the current one, then error
      if ((DQM3 == 2'b00) || (DQM2 == 2'b00)) assert((command != WRITE) && (command != WRITEA));

      // Check that DQMin doesn't cancel your reads, otherwise throw a warning
      if ((command == READ) || (command == READA)) assert(rvalid0);
   end

   // No reason to ever disable the clock, set it enabled
   assign DRAM_CLK = clk;
   assign DRAM_CKE = 1'b1;
   // No reason to deselect the chip, it doesn't share a bus with anything else
   assign DRAM_CS_N = ~1'b1;

   assign rdata = DRAM_DQ;
   // For synchronising with CAS latency of 2 (raddr0/rvalid0 are the combinational shift inputs)
   logic rvalid2, rvalid1, rvalid0;
   logic [9:0] raddr2, raddr1, raddr0;
   
   // For preventing misuse of bank address pins
   logic [1:0] currentBank, nextBank;


   always_ff @(posedge clk) begin
      // Simple registers
      currentBank <= nextBank;
      {raddr, raddr2, raddr1} <= {raddr2, raddr1, raddr0};
      {DQM3, DQM2, DQM1} <= {DQM2, DQM1, DRAM_DQM};

      // Resettable registers
      if (rst) begin
	 {readValid, rvalid2, rvalid1} <= '0;
      end else begin
	 {readValid, rvalid2, rvalid1} <= {rvalid2, rvalid1, rvalid0};
      end
   end

   
   // I hate active-low
   logic RAS, CAS, WE;
   assign {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = {RAS, CAS, WE};

   // Translate a command into the appropriate signals / behaviour
   always_comb begin
      // Default 
      {RAS, CAS, WE, rvalid0} = '0;
      DRAM_BA = currentBank;
      nextBank = currentBank;      
      DRAM_ADDR = 'X;
      DRAM_DQ = 'Z;
// DQM HIGH => Z, DQM LOW => write a byte
      case (command) // page 9 command truth table for RAS, CAS, WE, etc
	READ, READA, WRITE, WRITEA: begin
	   CAS = 1;
	   if (command == WRITE || command == WRITEA) begin // write
	      if ((&DQM3) & ~(&DQM2)) begin // If both contained a high value, then warning is proper
		 WE = 1;
		 DRAM_DQ = wdata;
		 {DRAM_UDQM, DRAM_LDQM} = ~writeMask; // DQM bits high = ignore bytes
	      end else begin
		 CAS = 0; // Improper write warning so write is invalid, NO-OP instead
	      end
	   end else begin // save read address and remind you of it later when the data comes out
	      rvalid0 = ~DRAM_UDQM & ~DRAM_LDQM; // otherwise DQ will be undriven
	      raddr0 = addr[9:0];
	   end
	   DRAM_ADDR[10] = (command == READA || command == WRITEA);
	   DRAM_ADDR[9:0] = addr[9:0];
	end
	ACTIVATE: begin // open a row in a bank for access
	   RAS = 1;
	   {DRAM_BA, nextBank} = {2{bankSel}}; // allow bank changing
	   DRAM_ADDR = addr;
	end
	PRECHARGE_BANK, PRECHARGE_ALL: begin // close a row in the bank(s), effectively refreshes the row
	   {RAS, WE} = 2'b11;
	   
	   DRAM_ADDR[10] = (command == PRECHARGE_ALL);
	   {DRAM_BA, nextBank} = {2{bankSel}}; // allow bank changing
	end
	SET_MODE_REG: begin
	   {RAS, CAS, WE} = 3'b111;
	   {DRAM_BA, DRAM_ADDR} = MODE_REG_VAL;
	end
	AREFRESH: {RAS, CAS} = 2'b11;
	
	default: {RAS, CAS, WE} = 3'b000; // NO-OP
      endcase
   end
endmodule


module SDRAM_LowLevel_tb ();
   logic clk, rst, allBanks, readValid;
   logic [1:0] writeMask, bankSel;
   input logic [12:0] addr;
   input logic [15:0] wdata, rdata;
   CommandEnum command;
   output logic [15:0] rdata;
   output logic [9:0] raddr;
   	       
   tri [15:0] DRAM_DQ;
   logic [12:0] DRAM_ADDR;
   logic [1:0] DRAM_BA;
   logic DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N;
   

   SDRAM_LowLevel dut (.*);

   // Set up the 133MHz clock
   parameter CLOCK_PERIOD=7.5;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end


   int i;
   initial begin
      // Test command table: (page 9)
      command = NOOP; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10111);
      command = READ; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101010);
      command = READA; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101011);
      command = WRITE; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101000);
      command = WRITEA; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101001);
      command = ACTIVE; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10011);
      command = PRECHARGE_BANK; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b100100);
      command = PRECHARGE_ALL; #10;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b100101);
      command = AREFRESH; #10; // current test assumes CKE never changes
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10001);

      // Reset
      rst = 1; @(negedge clk);
      rst = 0;
      assert(~readValid);
      // Activate a row
      command = ACTIVE;
      {bankSel, addr} = 15'd9999; @(negedge clk);
      command = NOOP; repeat (2) begin assert(~readValid); @(negedge clk); end
      assert(~readValid);
      // Start a read
      command = READ; DQMin = 2'b00;
      addr[9:0] = 10'd720;
      assert(~readValid); @(negedge clk);
      command = NOOP; DQMin = 2'b11;
      assert(~readValid); @(negedge clk);
      assert(readValid);
      assert(DRAM_DQ === 'Z);
      // Start a write
      DQMin = 2'b11;
      assert(~readValid); @(negedge clk);
      assert(~readValid); @(negedge clk);
      assert(~readValid); @(negedge clk);
      command = WRITE;
   end
endmodule

/*
 // Address Space Parameters

`define ROWSTART        8          
`define ROWSIZE         12
`define COLSTART        0
`define COLSIZE         8
`define BANKSTART       20
`define BANKSIZE        2

// Address and Data Bus Sizes

`define  ASIZE          23      // total address width of the SDRAM
`define  DSIZE          16      // Width of data bus to SDRAMS


//parameter	INIT_PER	=	100;		//	For Simulation

//	Controller Parameter
////////////	133 MHz	///////////////

//parameter	INIT_PER	   =	32000;
//parameter	REF_PER		=	1536;
//parameter	SC_CL		   =	3;
//parameter	SC_RCD		=	3;
//parameter	SC_RRD		=	7;
//parameter	SC_PM		   =	1;
//parameter	SC_BL		   =	1;

///////////////////////////////////////
////////////	100 MHz	///////////////

parameter	INIT_PER	   =	24000;
parameter	REF_PER		=	1024;
parameter	SC_CL		  =	3;
parameter	SC_RCD		=	3;
parameter	SC_RRD		=	7;
parameter	SC_PM		  =	1;
parameter	SC_BL		  =	1;

///////////////////////////////////////
////////////	50 MHz	///////////////
/*
parameter	INIT_PER	=	12000;
parameter	REF_PER		=	512;
parameter	SC_CL		  =	3;
parameter	SC_RCD		=	3;
parameter	SC_RRD		=	7;
parameter	SC_PM		  =	1;
parameter	SC_BL		  =	1;
//*endcomment
///////////////////////////////////////

//	SDRAM Parameter
parameter	SDR_BL		=	(SC_PM == 1) ? 3'b111	:
							        (SC_BL == 1) ? 3'b000	:
							        (SC_BL == 2) ? 3'b001 :
							        (SC_BL == 4) ? 3'b010 : 3'b011;
parameter	SDR_BT		=	1'b0;	//	1'b0 : Sequential  1'b1 :	Interteave
parameter	SDR_CL		=	(SC_CL == 2) ? 3'b10 : 3'b11;
 */

