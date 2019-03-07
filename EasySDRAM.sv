
`include "SDRAM.svh"

module EasySDRAM #(parameter CLOCK_PERIOD = 8) ( // period in nanoseconds, (default 125MHz) needed for refresh timing
	input logic clk, rst, // max clock: 133MHz, recommend 100 or 125 for nice multiple of 50MHz

        // FIFO interface
        input logic write, full, // write and full signals of the FIFO
        // FIFO write word (seperated into its parts)
        input logic isWrite, // 1'b0: read from address, 1'b1: write writeData with writeMask to address
        input logic [24:0] address, // [24:10] is the row address, [9:0] is the column address. It costs 4-6 cycles to switch rows.
        input logic [1:0] writeMask, // 2'b11: write data[15:0], 2'b10: write data[15:8], 2'b01: write data[7:0], 2'b00: invalid
        input logic [15:0] writeData,


        // This signals to the controller to keep the row open for as long as possible instead of refreshing when the command FIFO becomes empty.
        // Refreshes can cost up to 1(close cmd) + 2(close delay) + 1(refresh cmd) + 8(refresh delay) + 1(open cmd) + 2(open delay) = 15 cycles! So don't keep this true unless you're sure you'll have data soon
	input logic keepOpen,

        // Status outputs. You can ignore them, but they might be useful for optimizing
	output logic busy, // tells you when the controller is busy with delays or refreshes, and isn't paying attention to the command fifo yet
	output logic rowOpen, // tells you if a row is still open
	output logic [:0] refreshCountdown, // number of cycles before the controller drops what it's doing to save some data that's about to decay away.


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
   localparam REFRESH_TIME = 10**6 * 64 / 8192 / CLOCK_PERIOD; // # of clocks in between each refresh (125MHz: 976)

   logic commandReady, prechargeReady, writeReady, readValid; // rowOpen is an output port
   CommandEnum command;
   logic [1:0] wMask, bankSel;
   logic [12:0] addr;
   logic [15:0] wdata, rdata;
   logic [24:0] raddr;
   SafeSDRAM safeDRAM (.clk, .rst, .command, 
		       .commandReady, .prechargeReady, .writeReady, .rowOpen,
		       .addr, .bankSel, .writeMask(wMask), .wdata,
		       .readValid, .raddr, .rdata,
		       .DRAM_DQ, .DRAM_ADDR, .DRAM_BA, .DRAM_CAS_N, .DRAM_CKE,
		       .DRAM_CLK, .DRAM_CS_N, .DRAM_LDQM, .DRAM_RAS_N, .DRAM_UDQM, .DRAM_WE_N
		       );

   logic [13:0] waitCtr, nwaitCtr; // can handle 2^14=16384 > 100us*133MHz = 13300 cycles
   enum 	{RESET, BOOTA, BOOTB, BOOTC, BOOTD, IDLE} ps, ns, waitReturn, nwaitReturn;
   always_comb begin
      command = NOOP;
      
      case (ps)
	// Utility
	WAIT: begin
	   nwaitCtr = waitCtr - 14'd1;
	   if (waitCtr == 14'd1) ns = waitReturn;
	   else ns = WAIT;
	end

	// SDRAM boot sequence
	RESET: begin // start waiting 100us
	   nwaitCtr = 100 * 1000/CLOCK_PERIOD + 10; // 100us in clocks (+ 10 clocks because why not / peace of mind)
	   nwaitReturn = TODO;
	   ns = WAIT;
	end
	BOOTA: begin // close any banks that booted open, I assume
	   command = PRECHARGE_ALL;
	   ns = BOOTB;
	end
	BOOTB: begin // mode register
	   if (commandReady) begin
	      command = SET_MODE_REG; // set the CAS latency and other stuff
	      ns = BOOTC;
	   end else begin
	      ns = ps;
	   end
	end
	BOOTC, BOOTD: begin
	   if (commandReady) begin
	      command = AREFRESH; // auto refresh
	      if (ps == BOOTC) ns = BOOTD;
	      else ns = IDLE
	   end else begin
	      ns = ps;
	   end
	end

	// Normal operation
	IDLE: begin
	   
	end
      endcase
   end
   always_ff @(posedge clk) begin
      if (rst) begin
	 ps <= RESET;
      end else begin
	 ps <= ns;
      end
   end
endmodule // EasySDRAM

module EasySDRAM_tb ();
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
   localparam Tdiv4 = CLOCK_PERIOD / 4;


   int i;
   initial begin
      writeMask = 2'b11; // needs to have a value for write commands
      rst = 1; @(posedge clk); @(posedge clk); #Tdiv4; // for clarity of reading the waveform, don't change signals at the clock edge
      rst = 0; #Tdiv4;
      assert(commandReady & ~rowOpen & ~prechargeReady);

      // Test command table: (page 9) //
      command = NOOP; #Tdiv4; // give time for logic to change before checking assertions
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10111);
      @(posedge clk); #Tdiv4;
     
      
      command = ACTIVATE; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10011);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;
      
      command = WRITE; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101000);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;
      
      command = READ; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101010);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~(commandReady & prechargeReady)) @(posedge clk); #Tdiv4;
      
      command = READA; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101011);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;

      
      command = ACTIVATE; @(posedge clk); #Tdiv4;
      command = NOOP; while (~(commandReady & prechargeReady)) @(posedge clk); #Tdiv4;
      
      command = WRITEA; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b101001);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;


      command = AREFRESH; #Tdiv4; // current test assumes CKE never changes
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N} == 5'b10001);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;


      command = ACTIVATE; @(posedge clk); #Tdiv4;
      command = NOOP; while (~(commandReady & prechargeReady)) @(posedge clk); #Tdiv4;

      command = PRECHARGE_BANK; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b100100);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;


      command = ACTIVATE; @(posedge clk); #Tdiv4;
      command = NOOP; while (~(commandReady & prechargeReady)) @(posedge clk); #Tdiv4;

      command = PRECHARGE_ALL; #Tdiv4;
      assert({DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N, DRAM_ADDR[10]} == 6'b100101);
      @(posedge clk); #Tdiv4;
      command = NOOP; while (~commandReady) @(posedge clk); #Tdiv4;

      // Check Timings //
      // Reset
      rst = 1; @(posedge clk); #Tdiv4;
      rst = 0; #Tdiv4;
      assert(~readValid);
      // Activate a row
      command = ACTIVATE;
      {bankSel, addr} = 15'd9999; @(posedge clk); #Tdiv4;
      command = NOOP; #Tdiv4;
      repeat (2) begin assert(~readValid & ~commandReady); @(posedge clk); #Tdiv4; end
      assert(~readValid & commandReady & rowOpen);

      // Start a read
      command = READ;
      addr[9:0] = 10'd720; #Tdiv4;
      assert(~readValid); @(posedge clk); #Tdiv4;
      command = NOOP; #Tdiv4;
      // CAS latency
      repeat (2) begin assert(~readValid & ~writeReady); @(posedge clk); #Tdiv4; end
      assert(readValid & ~writeReady); @(posedge clk); #Tdiv4;
      assert(~readValid & ~writeReady); @(posedge clk); #Tdiv4;
      
      // Start a write
      assert(writeReady);
      command = WRITE;
      writeMask = 2'b11;
      wdata = 16'hDEAD;
      addr[9:0] = 10'd299; #Tdiv4;
      assert(DRAM_DQ == 16'hDEAD);
      @(posedge clk); #Tdiv4;
      command = NOOP;
      repeat (`tDPL) begin assert(~prechargeReady); @(posedge clk); #Tdiv4; end
      assert(prechargeReady & rowOpen);

      // Precharge
      command = READA;
      addr[9:0] = 10'd185;
      @(posedge clk); #Tdiv4;
      command = NOOP;
      repeat (`tRP) begin assert(~commandReady); @(posedge clk); #Tdiv4; end
      assert(commandReady & ~rowOpen & readValid);


      // Check row->row timing
      // Activate a row
      command = ACTIVATE;
      {bankSel, addr} = 15'd4444; @(posedge clk); #Tdiv4;
      command = NOOP; #Tdiv4;
      repeat (2) begin assert(~readValid & ~commandReady); @(posedge clk); #Tdiv4; end
      assert(~readValid & commandReady & rowOpen);

      repeat (`tRAS - 2) begin assert(~prechargeReady & ~readValid & commandReady); @(posedge clk); #Tdiv4; end
      
      // Start a write with precharge
      assert(writeReady);
      command = WRITEA;
      writeMask = 2'b11;
      wdata = 16'hBEEF;
      addr[9:0] = 10'd333; #Tdiv4;
      assert(DRAM_DQ == 16'hBEEF);
      @(posedge clk); #Tdiv4;
      command = NOOP;
      repeat (`tDPL) begin assert(~prechargeReady & ~commandReady); @(posedge clk); #Tdiv4; end
      repeat (`tRP) begin assert(~prechargeReady & ~commandReady & ~rowOpen); @(posedge clk); #Tdiv4; end
      assert(~rowOpen & ~prechargeReady & commandReady);

      repeat (20) @(posedge clk);
      $stop;
   end
endmodule
