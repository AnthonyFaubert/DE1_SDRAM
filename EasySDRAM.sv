
`timescale 1 ns / 1 ps

`include "SDRAM.svh"

// TODO send a readout whenever a write happens. Add a write readout fifo that will be read out whenever SafeSDRAM's readValid is false.

module EasySDRAM #(parameter CLOCK_PERIOD = 8) ( // period in nanoseconds, (default 125MHz) needed for refresh timing
	input logic clk, rst, // max clock: 133MHz, recommend 100 or 125 for nice multiple of 50MHz

        // FIFO interface
        input logic write, // write and full signals of the FIFO
        output logic full,
        output logic [8:0] fifoUsage, // how many commands are pending in the FIFO (256 will cause full)
        // FIFO write word (seperated into its parts)
        input logic isWrite, // 1'b0: read from address, 1'b1: write writeData with writeMask to address
        input logic [24:0] address, // [24:10] is the row address, [9:0] is the column address. It costs 4-6 cycles to switch rows.
        input logic [1:0] writeMask, // 2'b11: write data[15:0], 2'b10: write data[15:8], 2'b01: write data[7:0], 2'b00: invalid
        input logic [15:0] writeData,

        // Read port
	output logic readValid, // ignore raddr and rdata if this is false, otherwise they carry a readout
	output logic [24:0] raddr, // tells you the address the data was read from
	output logic [15:0] rdata, // tells you the data that was at the address

        // This signals to the controller to keep the row open for as long as possible instead of refreshing when the command FIFO becomes empty.
        // Refreshes can cost up to 1(close cmd) + 2(close delay) + 1(refresh cmd) + 8(refresh delay) + 1(open cmd) + 2(open delay) = 15 cycles! So don't keep this true unless you're sure you'll have data soon
	input logic keepOpen,

        // Status outputs. You can ignore them, but they might be useful for optimizing
	output logic busy, // tells you when the controller is busy with delays or refreshes, and isn't paying attention to the command fifo yet (doesn't look like it would actually be very useful)
	output logic rowOpen, // tells you if a row is still open (more useful than busy)
	output logic [9:0] refreshCountdown, // number of cycles before the controller drops what it's doing to save some data that's about to decay away. (currently will actually start a refresh procedure when this is about 15 or less, TODO: change)


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
   localparam integer REFRESH_TIME = (10**6 * 64 / 8192 / CLOCK_PERIOD) - 1; // # of clocks in between each refresh (125MHz: 976) (-1 for off-by-1 safety)

   logic commandReady, prechargeReady, writeReady; // rowOpen and readValid are output ports
   import CommandEnumPackage::*;
   CommandEnum command;
   logic [1:0] wMask, bankSel;
   logic [12:0] addr;
   logic [15:0] wdata;
   // raddr and rdata are output ports
   SafeSDRAM safeDRAM (.clk, .rst, .command, 
		       .commandReady, .prechargeReady, .writeReady, .rowOpen,
		       .addr, .bankSel, .writeMask(wMask), .wdata,
		       .readValid, .raddr, .rdata,
		       .DRAM_DQ, .DRAM_ADDR, .DRAM_BA, .DRAM_CAS_N, .DRAM_CKE,
		       .DRAM_CLK, .DRAM_CS_N, .DRAM_LDQM, .DRAM_RAS_N, .DRAM_UDQM, .DRAM_WE_N
		       );

   // 256x44 FIFO using 2 M10ks (2 M10ks = 64x256)
   logic empty, read;
   logic [43:0] wfifo, rfifo;
   logic 	cmdWrite;
   logic [14:0] cmdRow;
   logic [9:0] 	cmdCol;
   logic [7:0] 	usedw;
   // Must be FWFT
   EasySDRAM_CmdFIFO cmdFIFO (.clock(clk), .sclr(rst), .rdreq(read), .wrreq(write),
			      .empty, .full, .data(wfifo), .q(rfifo), .usedw); // usedwords
   assign fifoUsage = full ? 9'd256 : {1'b0, usedw}; // usedw becomes invalid while full is true
   assign wfifo = {isWrite, writeMask, address, writeData};
   assign {cmdWrite, wMask, cmdRow, cmdCol, wdata} = rfifo;

   logic [13:0] waitCtr, nwaitCtr; // can handle 2^14=16384 > 100us*133MHz = 13300 cycles
   logic [10:0] refreshTimer, nrefreshTimer; // 2048 > REFRESH_TIME
   // pretty sure the writeback timer is handled by prechargeReady in SafeSDRAM, TODO remove this?
   //logic [2:0] writebackTimer, nwritebackTimer; // 8 > tDPL=2, keeps track of writeback delay before precharges
   enum 	{RESET, BOOTA, BOOTB, BOOTC, BOOTD, WORK, WAIT} ps, ns, waitReturn, nwaitReturn;
   always_comb begin
      command = NOOP;
      nrefreshTimer = refreshTimer - 10'd1; // keep ticking down
      nwaitReturn = waitReturn;
      nwaitCtr = 'X;
      read = 0;
      busy = 1;
      addr[9:0] = cmdCol;
      addr[12:10] = 'X;
      bankSel = 'X;

      // TODO: improve this and then maybe use it for behavior decisions?
      refreshCountdown = refreshTimer;
      
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
	   nwaitReturn = BOOTA;
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
	      nrefreshTimer = REFRESH_TIME;
	      if (ps == BOOTC) ns = BOOTD;
	      else ns = WORK;
	   end else begin
	      ns = ps;
	   end
	end

/*
	INIT_FIFO: begin // read the first command from the FIFO (refresh until command available)
	   busy = 0;
	   if (empty & commandReady) begin // refresh until we have a command
	      commmand = AREFRESH;
	      nrefreshTimer = REFRESH_TIME;
	      ns = INIT_FIFO;
	   end else if (~empty) begin
	      read = 1; // read the command
	      ns = WORK;
	   end
	end
*/
	// Normal operation
	WORK: begin
	   ns = WORK; // stay here forever (until reset)
	   // Can't do anything if we're not ready
	   if (commandReady) begin
	      busy = 0;
	      if (empty & ~keepOpen) begin
		 // Nothing to do, refresh rows
		 if (~rowOpen) begin
		    command = AREFRESH; // refresh
		    nrefreshTimer = REFRESH_TIME;
		 end else if (rowOpen & prechargeReady) begin
		    command = PRECHARGE_ALL; // close the row so we can start refreshing
		 end
	      end else if (~empty) begin // stuff to do
		 if ((cmdRow == raddr[24:10]) & rowOpen) begin
		    // On the right row
		    if (cmdWrite) begin // write requested
		       if (writeReady) begin
			  if (refreshTimer > (4'd2 + `tDPL + `tRP)) begin
			     // There's enough time to write(1) + WRITE->PRE(tDPL) + close(1) + PRE->REF(tRP)
			     command = WRITE;
			     read = 1; // next command
			  end else if ((refreshTimer > (4'd1 + `tDPL + `tRP)) & prechargeReady) begin
			     // There's enough time to writea(1) + WRITE->PRE(tDPL) + PRE->REF(tRP)
			     command = WRITEA;
			     read = 1; // next command
			     busy = 1;
			  end else begin
			     // no time, refresh ASAP
			     if (prechargeReady) command = PRECHARGE_ALL;
			     busy = 1;
			  end
		       end else if (refreshTimer > (4'd2 + `tDAL)) begin // ~writeReady
			  // There's enough time to wait4writeRdy(1) + writea(1) + WRITEA->REF(tDAL)
			  command = NOOP;
		       end else begin
			  // Not ready to write and not enough time to wait to be ready.
			  if (prechargeReady) command = PRECHARGE_ALL;
		       end
		    end else begin // read requested
		       if (refreshTimer <= (4'd2 + `tRP)) begin
			  // Not enough time to read(1) + close(1) + PRE->REF(tRP), so we need to refresh ASAP
			  command = READA; // we can read and close at the same time
			  busy = 1;
		       end else begin
			  command = READ;
		       end
		       read = 1; // we've completed the command. get a new one
		    end
		 end else if (rowOpen) begin
		    // On the wrong row, close it and open the right one
		    // Even if we're running out of time and have to refresh, we still have to close the row
		    if (prechargeReady) command = PRECHARGE_ALL;
		 end else begin
		    // No row currently open, open the row
		    if (refreshTimer > (4'd2 + `tRAS + `tRP)) begin
		       // We have time to open(1) + ACT->PRE(tRAS) + close(1) + PRE->REF(tRP), so go for it
		       command = ACTIVATE;
		       {bankSel, addr} = cmdRow;
		    end else begin
		       // Not enough time to open and close a row, refresh instead
		       command = AREFRESH; // refresh
		       nrefreshTimer = REFRESH_TIME;
		       busy = 1;
		    end
		 end // else: !if(rowOpen)

		 /*
		 if (rowOpen && ()) begin
		    // Minimum write access is write(1) WRITE->PRE(tDPL) + close(1) + PRE->REF(tRP)
		    if (refreshTimer > (4'd2 + `tDPL + `tRP)) begin
		       command = WRITE; if (fifoOut[command] = write); // TODO
		    // Minimum writea access is writea(1) WRITE->PRE(tDPL) + PRE->REF(tRP)
		    end else if (refreshTimer > (4'd1 + `tDPL + `tRP)) begin
		       command = WRITEA; // don't have to issue a close command TODO
		    // Minimum read access is read(1) + close(1) + PRE->REF(tRP)
		    end else if (refreshTimer > (4'd2 + `tRP)) begin
		       command = READ; // TODO
		    end else begin // time to close the row
		       command = READA; or; // TODO
		       command = PRECHARGE_ALL;
		    end
		 end else begin // ~rowOpen
		    // Minimum read access is read(1) + close(1) + PRE->REF(tRP)
		    if (refreshTimer > (4'd2 + `tRP)) begin
		       command = READ;
		    end else if (refreshTimer > (4'd1 + `tDPL + `tRP)) begin
		       command = WRITEA; // don't have to issue a close command
		    end else begin // too late to do a write, even with auto-precharge
		       command = PRECHARGE_ALL;
		    end
		    
		    // Minimum access is close(1) + PRE->REF(tRP) = 1+2=3
		    if (refreshTimer > (4'd1 + `tRP)) begin // TODO Write tDPL
		    end else begin // too late to do anymore read/writes
		       command = PRECHARGE_ALL;
		    end
		 end else begin // ~rowOpen
		    // Minimum row access is open(1) + ACT->PRE(tRAS) + close(1) + PRE->REF(tRP) = 2+5+2=9
		    if (refreshTimer > (4'd2 + `tRAS + `tRP)) begin // there's time to open and close a row
		       // TODO: do stuff
		    end else begin // too late to open a row
		       command = AREFRESH;
		       nrefreshTimer = REFRESH_TIME;
		    end
		    // ACT->REF
		 end // else: !if(rowOpen)
		  */
	      end else begin // empty & keepOpen
		 // Nothing to do, but we were told to be ready, so only refresh if we have to
		 if (rowOpen) begin
		    if (refreshTimer <= (4'd2 + `tRP)) begin
		       // Not enough time to wait4cmd(1) + close(1) + PRE->REF(tRP)
		       command = PRECHARGE_ALL;
		       busy = 1;
		    end
		 end else begin // no row open
		    if (refreshTimer <= (4'd3 + `tRAS + `tRP)) begin
		       // Not enough time to wait4cmd(1) + open(1) + ACT->PRE(tRAS) + close(1) + PRE->REF(tRP)
		       command = AREFRESH; // refresh
		       nrefreshTimer = REFRESH_TIME;
		       busy = 1;
		    end
		 end
	      end
	   end // implies if (~commandReady) command = NOOP
	end
      endcase
   end
   always_ff @(posedge clk) begin
      waitCtr <= nwaitCtr;
      waitReturn <= nwaitReturn;
      refreshTimer <= nrefreshTimer;
      // TODO REMOVE? writebackTimer <= nwritebackTimer;

      if (rst) begin
	 ps <= RESET;
      end else begin
	 ps <= ns;
      end
   end
endmodule // EasySDRAM

module EasySDRAM_tb ();
   logic clk, rst, write, full, isWrite, readValid, keepOpen, busy, rowOpen;
   logic [9:0] refreshCountdown;
   logic [8:0] fifoUsage;
   logic [24:0] raddr, address;
   logic [1:0] 	writeMask;
   logic [15:0] writeData, rdata;

   tri [15:0] DRAM_DQ;
   logic [12:0] DRAM_ADDR;
   logic [1:0] DRAM_BA;
   logic DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N;

   // Set up the 133MHz clock and a number that counts clock posedges
   parameter CLOCK_PERIOD=7.5;
   int 	 clkCtr, lastRefresh;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
      clkCtr = 0;
      lastRefresh = 0;
   end
   always @(posedge clk) clkCtr++;
   localparam Tdiv4 = CLOCK_PERIOD / 4;

   // DUT
   EasySDRAM #(CLOCK_PERIOD) dut (.*);
   import CommandEnumPackage::*; // so we can use the enum values

   // Check refresh timing
   always @(posedge clk) begin
      if (dut.commandReady && !dut.rowOpen && (dut.command == AREFRESH)) begin
	 // Valid refresh command
	 if (lastRefresh == 0) begin
	    // We were waiting for the first refresh
	    lastRefresh = clkCtr;
	 end else begin
	    // Check timing: assert (now - lastRefresh) < (refresh period)
	    assert( (clkCtr - lastRefresh) < (10**6 * 64 / 8192 / CLOCK_PERIOD) );
	    lastRefresh = clkCtr;
	 end
      end
   end


   int i;
   initial begin
      {write, keepOpen} = '0;
      rst = 1; @(posedge clk); @(posedge clk); #Tdiv4; // for clarity of reading the waveform, don't change signals at the clock edge
      rst = 0; #Tdiv4;
      assert(busy & ~full & ~readValid);
      while (busy) begin
	 assert(~full & ~readValid);
	 @(posedge clk); #Tdiv4;
      end
      assert(~busy & ~full & ~readValid);

      // Watch some auto-refreshing
      repeat (10) @(posedge clk);
      #Tdiv4;

      // send some writes
      {write, isWrite, address} = {2'b11, 25'd0};
      {writeMask, writeData} = {2'b11, 16'hDEAD};
      @(posedge clk); #Tdiv4;
      
      {write, isWrite, address} = {2'b11, 25'd1};
      {writeMask, writeData} = {2'b11, 16'hBEEF};
      @(posedge clk); #Tdiv4;

      // Write 2 rows
      i = 2;
      write = 1; isWrite = 1;
      for (i = 2; i < 2048; i++) begin
	 address = i[24:0];
	 {writeMask, writeData} = {2'b11, i[16:1]};
	 @(posedge clk); #Tdiv4;
	 while (full) @(posedge clk); #Tdiv4;
      end
      write = 0;

      // Wait for it to finish
      keepOpen = 1;
      while (fifoUsage != 9'd0) @(posedge clk);
      // Watch it try to stay open
      repeat (dut.REFRESH_TIME + 20) @(posedge clk);
      #Tdiv4;

      // Alternate reads and writes across rows (horrendously inefficient)
      write = 1;
      for (i = 0; i < 500; i++) begin
	 isWrite = i[0];
	 address = (i >> 1)*200; // change that to left-shift and boy-oh-boy the controller gets thrashed
	 {writeMask, writeData} = {2'b11, i[15:0]};
	 @(posedge clk); #Tdiv4;
	 while (full) @(posedge clk); #Tdiv4;
      end
      write = 0;

      repeat (20) @(posedge clk);
      $stop;
   end
endmodule
