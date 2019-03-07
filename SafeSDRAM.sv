
`include "SDRAM.svh"


/* UPDATED USAGE GUIDE:
 WARNING: this module doesn't protect you from boot-up misuse, you must observe the boot-up procedure:
 input NOOPs for at least 100us, then input a PRECHARGE_ALL command, then input at least 2 AUTO_REFRESH commands, then a SET_MODE_REG command, and then you're ready to open rows and things.
 
 Optimisation tips:
 READ results show up 2 clock cycles later (CAS latency).
 you need 2 NOOP commands in-between a READ and a write, but no delay from a WRITE to a READ.
 There have to be 2 clock cycles after a WRITE command before the row can be closed (aka precharged. even with WRITEA), so you might as well always end your row access with 2 read commands.
 
 NOTE: the SDRAM chip supports having at least two rows open (each on different banks) at once, but this module simplifies delay checks by only allowing a single row to be open at once.
 */

/* OUTDATED USAGE GUIDE (OBSOLETE, ignore until this is deleted)
 Provides a safe and slightly simplified interface to the SDRAM.
 Note: DQMin is an important port.
 (|DQMin) being true disables the SDRAM output 2 (or 3, depending on CAS latency) clocks later,
 otherwise the SDRAM output is enabled 2 (or 3) clocks later.
 The SDRAM output must be disabled the clock before and the clock during a write command. (see page 32)
 Reads are much easier, as the data and the DQM have the same latency. So DQMin must be 2'b00 during a read command.
 2 clocks after a read command, the data and address you requested will show up on rdata and raddr, and readValid will be true.
 */

module SafeSDRAM (
	input logic clk, rst,

	output logic commandReady, // send a command and then this will go back to true once the appropriate delay has occurred
	output logic prechargeReady, // not allowed to send a precharge command (PRECHARGE_* or WRITEA or READA) unless this is true
	output logic rowOpen, // precharges, reads, and writes are only allowed when this is true. activates and refreshes are only allowed when it's false.
	input CommandEnum command,

        // bank selector (only used during ACTIVATE or PRECHARGE_BANK commands)
	input logic [1:0] bankSel,
        // row (13-bit) or column (10-bit) address (row during ACTIVATE, col during reads/writes)
	input logic [12:0] addr,

	output logic writeReady, // ready to accept a write commmand (commandReady must also be true)
	input logic [1:0] writeMask, // the write mask for the current write, if any. if writeMask=2'b11, then both bytes will be written (2'b10=>wdata[15:8] written)
	input logic [15:0] wdata,

        // Delayed read output results. When readValid is true, rdata is the data that was stored at address raddr. (raddr={2'bank,13'row,10'col})
	output logic readValid,
	output logic [24:0] raddr,
	output logic [15:0] rdata,
		       
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
/* little self-reminder to stop my text editor from being annoying, ignore this
(setq verilog-auto-newline nil)
(setq verilog-auto-indent-on-newline nil)
*/

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
   logic [1:0] DQM3, DQM2, DQM1, DRAM_DQM; // DRAM_DQM is a proxy output port
   assign {DRAM_UDQM, DRAM_LDQM} = DRAM_DQM;

   // flip-flop holding whether or the previous clock was a valid write command, or something else
   logic lastCmdWasValidWrite, nlastCmdWasValidWrite;
   // if prev cmd was a valid write we can continue writing.
   // if DQM stopped the SDRAM from driving DQ then we can write. (DQM3=11 & DQM2=11)
   assign writeReady = (lastCmdWasValidWrite | &{DQM3, DQM2});


   logic OE;
   logic [15:0] DQ;
   assign DRAM_DQ = OE ? DQ : 'Z;

   // It's illegal to write while the SDRAM is driving the line.
   // You also have to warn it the clock cycle before a write for it to stop driving the line, and obviously the clock cycle that you're writing. UDQM and LDQM have the programmed CAS latency (2 clocks).
   // That warning consists of (UDQM | LDQM) being true
   logic error; // true if you gave an invalid command (didn't observe proper ready signals). used for testbenches. Generated by the case(command) in always_comb
   always @(posedge clk) begin // see page 32
      assert(~(writeReady & readValid)); // if they are both true at once then that would allow you to have contention on the DQ bus
      // Warning: don't write when you're not ready
      if ((command == WRITE) | (command == WRITEA)) assert(writeReady);
      assert(~error);
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
   // Remember row for raddr output
   logic [12:0] currentRow, nextRow;
   logic 	nrowOpen; // rowOpen is a output reg
   assign raddr[24:10] = {currentBank, currentRow};

   // keep track of required delays between various commands
   // prechargeTimer is for ensuring your row access isn't too short
   logic [3:0] timingCounter, ntimingCounter, prechargeTimer, nprechargeTimer;

   always_ff @(posedge clk) begin
      // Simple registers
      lastCmdWasValidWrite <= nlastCmdWasValidWrite;
      currentBank <= nextBank;
      currentRow <= nextRow;
      {raddr[9:0], raddr2, raddr1} <= {raddr2, raddr1, raddr0};
      {DQM3, DQM2, DQM1} <= {DQM2, DQM1, DRAM_DQM};

      // Resettable registers
      if (rst) begin
	 {timingCounter, prechargeTimer, rowOpen} <= '0;
	 {readValid, rvalid2, rvalid1} <= '0;
      end else begin
	 timingCounter <= ntimingCounter;
	 prechargeTimer <= nprechargeTimer;
	 rowOpen <= nrowOpen;
	 {readValid, rvalid2, rvalid1} <= {rvalid2, rvalid1, rvalid0};
      end
   end

   
   // I hate active-low
   logic RAS, CAS, WE;
   assign {DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} = ~{RAS, CAS, WE};
   
   // Translate a command into the appropriate signals / behaviour
   always_comb begin
      // Default 
      {RAS, CAS, WE, rvalid0, nlastCmdWasValidWrite} = '0;
      DRAM_BA = currentBank;
      nextBank = currentBank;
      nextRow = currentRow;
      nrowOpen = rowOpen;
      DRAM_ADDR = 'X;
      DQ = 'X;
      OE = 0;
      DRAM_DQM = 2'b11; // force the idle (SDRAM output disabled) state unless specifically required otherwise (read or write command)
      error = 0;

      // Default timingCounter behavior
      if (|timingCounter) begin // != 0
	 commandReady = 0;
	 ntimingCounter = timingCounter - 4'd1;
      end else begin // == 0
	 commandReady = 1;
	 ntimingCounter = timingCounter; // keep 0 instead of overflowing
      end

      // Default prechargeTimer behavior
      if (|prechargeTimer) begin // != 0
	 prechargeReady = 0;
	 nprechargeTimer = prechargeTimer - 4'd1;
      end else begin // == 0
	 prechargeReady = rowOpen; // can't close a not-open row
	 nprechargeTimer = prechargeTimer; // keep 0 instead of overflowing
      end
      
// DQM HIGH => Z, DQM LOW => write a byte
      if (commandReady) begin
	 case (command) // page 9 command truth table for RAS, CAS, WE, etc
	   
	   READ, READA, WRITE, WRITEA: begin
	      if (rowOpen) begin
		 CAS = 1;
		 if (command == WRITE || command == WRITEA) begin // write
			if (writeReady) begin // it is now safe to write (DQ won't be dual-driven)
			   WE = 1;
			   OE = 1; DQ = wdata; // the only spot where our output is driven
			   DRAM_DQM = ~writeMask; // DQM bits high = ignore bytes
			   nlastCmdWasValidWrite = 1; // you can always string together writes
			   if (prechargeTimer <= `tDPL) nprechargeTimer = `tDPL; // WRITE->PRE, change the minimum delay only
			end else begin
			   CAS = 0; // disable the write
			   assert(0); // you tried to dual-drive the DQ bus
			end	      
		 end else begin // must be a READ or READA, so save read address and remind you of it later when the data comes out
		    rvalid0 = 1;
		    DRAM_DQM = 2'b00; // enable reading both bytes
		    raddr0 = addr[9:0];
		 end
		 DRAM_ADDR[10] = (command == READA || command == WRITEA);
		 DRAM_ADDR[9:0] = addr[9:0];
		 if (command == READA) begin
		    if (prechargeReady) begin
		       ntimingCounter = `tRP; // PRE->ACT
		       nrowOpen = 0;
		    end else begin
		       error = 1;
		    end
		 end else if (command == WRITEA) begin // this technically can be sent tDPL cycles before prechargeReady=1, but that's too complicated for now
		    if (prechargeReady) begin
		       ntimingCounter = `tDPL + `tRP; // WRITE->PRE + PRE->ACT
		       nrowOpen = 0;
		    end else begin
		       error = 1;
		    end
		 end // READA/WRITEA
	      end else begin // if (rowOpen) else
		 error = 1;
	      end
	   end // READ/READA/WRITE/WRITEA
	   
	   ACTIVATE: begin // open a row in a bank for access
	      if (~rowOpen) begin
		 RAS = 1;
		 nrowOpen = 1;
		 {DRAM_BA, nextBank} = {2{bankSel}}; // allow bank changing
		 DRAM_ADDR = addr;
		 nextRow = addr; // we're changing rows
		 ntimingCounter = `tRCD; // ACT->READ
		 nprechargeTimer = `tRAS; // ACT->PRE
	      end else begin
		 error = 1;
	      end
	   end
	   PRECHARGE_BANK, PRECHARGE_ALL: begin // close a row in the bank(s), effectively refreshes the row
	      if (prechargeReady & rowOpen) begin
		 nrowOpen = 0;
		 {RAS, WE} = 2'b11;
		 
		 DRAM_ADDR[10] = (command == PRECHARGE_ALL);
		 {DRAM_BA, nextBank} = {2{bankSel}}; // allow bank changing
		 ntimingCounter = `tRP; // PRE->ACT
	      end else begin
		 error = 1;
	      end
	   end
	   SET_MODE_REG: begin
	      {RAS, CAS, WE} = 3'b111;
	      {DRAM_BA, DRAM_ADDR} = MODE_REG_VAL;
	      ntimingCounter = `tMRD; // SetMode->cmd
	   end
	   AREFRESH: begin
	      if (~rowOpen) begin
		 {RAS, CAS} = 2'b11;
		 ntimingCounter = `tRC; // REF->REF
	      end else begin
		 error = 1;
	      end
	   end
	   
	   default: {RAS, CAS, WE} = 3'b000; // NO-OP, these are default values so this case doesn't even need to be here
	 endcase // case (command)
      end // if (commandReady)
      // else NO-OP, which is default
   end
endmodule


module SafeSDRAM_tb ();
   logic clk, rst, commandReady, prechargeReady, writeReady, readValid, rowOpen;
   CommandEnum command;
   logic [1:0] writeMask, bankSel;
   logic [12:0] addr;
   logic [15:0] wdata, rdata;
   logic [24:0] raddr;
   	       
   tri [15:0] DRAM_DQ;
   logic [12:0] DRAM_ADDR;
   logic [1:0] DRAM_BA;
   logic DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N;

   SafeSDRAM dut (.*);

   // Set up the 133MHz clock
   parameter CLOCK_PERIOD=7.5;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end


   int i;
   initial begin
      rst = 1; @(negedge clk); @(negedge clk);
      rst = 0;
      assert(commandReady & ~rowOpen & ~prechargeReady);

      // Test command table: (page 9) //
      command = NOOP;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10111);
      @(negedge clk);
     
      
      command = ACTIVATE;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10011);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);
      
      command = WRITE;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101000);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);
      
      command = READ;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101010);
      @(negedge clk);
      command = NOOP; while (~(commandReady & prechargeReady)) @(negedge clk);
      
      command = READA;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101011);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);

      
      command = ACTIVATE; @(negedge clk);
      command = NOOP; while (~(commandReady & prechargeReady)) @(negedge clk);
      
      command = WRITEA;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101001);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);


      command = AREFRESH; // current test assumes CKE never changes
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10001);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);


      command = ACTIVATE; @(negedge clk);
      command = NOOP; while (~(commandReady & prechargeReady)) @(negedge clk);

      command = PRECHARGE_BANK;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b100100);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);


      command = ACTIVATE; @(negedge clk);
      command = NOOP; while (~(commandReady & prechargeReady)) @(negedge clk);

      command = PRECHARGE_ALL;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b100101);
      @(negedge clk);
      command = NOOP; while (~commandReady) @(negedge clk);

      // Reset
      rst = 1; @(negedge clk);
      rst = 0;
      assert(~readValid);
      // Activate a row
      command = ACTIVATE;
      {bankSel, addr} = 15'd9999; @(negedge clk);
      command = NOOP;
      repeat (2) begin assert(~readValid & ~commandReady); @(negedge clk); end
      assert(~readValid & commandReady & rowOpen);

      // Start a read
      command = READ;
      addr[9:0] = 10'd720;
      assert(~readValid); @(negedge clk);
      command = NOOP;
      assert(~readValid & ~writeReady); @(negedge clk);
      assert(readValid & ~writeReady); @(negedge clk);
      assert(~readValid & ~writeReady); @(negedge clk);
      
      // Start a write
      assert(writeReady);
      command = WRITE;
      writeMask = 2'b11;
      wdata = 16'hDEAD;
      addr[9:0] = 10'd299;
      assert(DRAM_DQ == 10'd299);
      @(negedge clk);
      command = NOOP;
      repeat (`tDPL) assert(~prechargeReady); @(negedge clk);
      assert(prechargeReady & rowOpen);

      // Precharge
      command = READA;
      addr[9:0] = 10'd185;
      @(negedge clk);
      repeat (`tRP) assert(~commandReady); @(negedge clk);
      assert(commandReady & ~rowOpen);

      repeat (20) @(negedge clk);
      $stop;
   end
endmodule
