
`timescale 1 ns / 1 ps

module TestRam (
	       input logic 	   CLOCK_50,
	       input logic [9:0]   SW,
	       output logic [9:0]  LEDR,
	       input logic [3:0]   KEY,
	       output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
		
		// SDRAM I/O //
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

   logic clk50, clk125, rst50, rst125;
   assign clk50 = CLOCK_50;
   // Generate 125MHz clock from 50MHz clock
   // I generated a PLL that auto-resets itself, so leave that unconnected
   PLLClock125 clk125gen (.refclk(CLOCK_50), .rst(1'b0), .outclk_0(clk125), .locked(LEDR[8]));


   // Metastability filters and debouncing
   logic [19:0] debounceCtr; // overflows @ 95.4Hz
   logic [9:0] swMS, sw;
   logic [3:0] key, keyMS;
   always_ff @(posedge clk125) begin
      if (IS_SIMULATION) begin // Simulation
	 // skip metastability protection and debouncing
	 sw <= SW;
	 key <= ~KEY;
	 {keyMS, swMS, debounceCtr} <= 'X;
      end else begin // Synthesis
	 swMS <= SW;
	 keyMS <= ~KEY;
	 debounceCtr <= debounceCtr + 20'd1;
	 if (debounceCtr == 20'd0) begin
	    sw <= swMS;
	    key <= keyMS;
	 end
      end
   end // always_ff @ (posedge clk125)
   /*
   logic rst125MS;
   always_ff @(posedge clk125) begin
      if (IS_SIMULATION) begin
	 rst125 <= SW[9];
      end else begin
	 rst125 <= rst125MS;
	 rst125MS <= SW[9];
      end
   end
   assign rst50 = sw[9];
    */
   assign rst125 = sw[9];
   assign LEDR[9] = rst125;

   // 8ns = 1/125MHz
   parameter KEEP_OPEN_THRESHOLD = 200;
   logic [9:0] refreshCountdown;
   // sendRead sends a read command, sendWrite sends a write command (write overrides read)
   logic       sendRead, sendWrite, full, readValid;
   logic [24:0] address, raddr;
   logic [15:0] writeData, rdata;
   logic [1:0] 	writeMask;
   EasySDRAM #(.CLOCK_PERIOD(8)) sdram (
	    .clk(clk125), .rst(rst125),
	    .write(sendRead | sendWrite), .full, .fifoUsage(),
	    .isWrite(sendWrite), .address, .writeMask, .writeData,
	    .readValid, .raddr, .rdata,
	    .keepOpen(refreshCountdown > KEEP_OPEN_THRESHOLD), .busy(), .rowOpen(), .refreshCountdown,
	    .DRAM_DQ, .DRAM_ADDR, .DRAM_BA, .DRAM_CAS_N, .DRAM_CKE,
	    .DRAM_CLK, .DRAM_CS_N, .DRAM_LDQM, .DRAM_RAS_N, .DRAM_UDQM, .DRAM_WE_N
          );

   logic [24:0] raddrLast;
   logic [15:0] rdataLast;
   always @(posedge clk125) begin
      if (readValid) begin
	 raddrLast <= raddr;
	 rdataLast <= rdata;
      end
   end

   // The hex value to display on all the 7-segs
   logic [23:0] hexVal;
   Hex7Seg hex0 (.in(hexVal[ 3:0 ]), .out(HEX0));
   Hex7Seg hex1 (.in(hexVal[ 7:4 ]), .out(HEX1));
   Hex7Seg hex2 (.in(hexVal[11:8 ]), .out(HEX2));
   Hex7Seg hex3 (.in(hexVal[15:12]), .out(HEX3));
   Hex7Seg hex4 (.in(hexVal[19:16]), .out(HEX4));
   Hex7Seg hex5 (.in(hexVal[23:20]), .out(HEX5));

   // sw8 on means address build mode where you can set sw[7:0] to the byte you want to write to the address register and then key0 through key1 says which part of the address register to write it to
   // during address build when you press key3, since it's only 1 bit left, the top 2 bits are what command to execute, if any (sw7=read, sw6=write)
   // sw8 off means data build mode, which is only used for writes. key0 sets the bottom byte of the write data to sw[7:0], key1 sets the top byte to sw[7:0], and key2 sets the write mask to sw[1:0]
   logic 	flag;
   always_ff @(posedge clk125) begin
      {sendRead, sendWrite} <= '0;

      if (rst125) begin
	 {address, writeData} <= '0;
	 writeMask <= 2'b11;
      end else begin
	 if (sw[8]) begin // address build mode
	    if (key[0]) address[ 7:0 ] <= sw[7:0];
	    if (key[1]) address[15:8 ] <= sw[7:0];
	    if (key[2]) address[24:16] <= sw[7:0];
	    if (key[3]) begin // executes the command
	       address[24] <= sw[0];
	       if (~flag) {sendRead, sendWrite} <= sw[7:6];
	       flag <= 1;
	    end else begin
	       flag <= 0;
	    end
	 end else begin // ~sw[8]
	    if (key[0]) writeData[ 7:0] <= sw[7:0];
	    if (key[1]) writeData[15:8] <= sw[7:0];
	    if (key[2]) begin
	       writeMask <= sw[1:0];
	    end
	 end
      end
   end
   
   always_comb begin
      if (sw[8]) begin // address build mode
	 hexVal = address[23:0];
	 LEDR[0] = address[24];
      end else begin
	 hexVal = {8'd0, writeData};
	 LEDR[0] = 0;
      end
   end
endmodule

// Take in a 4-bit number (in) and display it as a hexadecimal digit on a 7-segment display (out)
module Hex7Seg (in, out);
	input logic [3:0] in;
	output logic [6:0] out;
	always_comb begin
		case (in)
		4'h0: out = ~7'b0111111;
		4'h1: out = ~7'b0000110;
		4'h2: out = ~7'b1011011;
		4'h3: out = ~7'b1001111;
		4'h4: out = ~7'b1100110;
		4'h5: out = ~7'b1101101;
		4'h6: out = ~7'b1111101;
		4'h7: out = ~7'b0000111;
		4'h8: out = ~7'b1111111;
		4'h9: out = ~7'b1101111;
		4'hA: out = ~7'b1110111;
		4'hB: out = ~7'b1111100; // b
		4'hC: out = ~7'b0111001;
		4'hD: out = ~7'b1011110; // d
		4'hE: out = ~7'b1111001;
		4'hF: out = ~7'b1110001;
		endcase
	end
endmodule

module TestRam_tb ();
   logic CLOCK_50, DRAM_CAS_N, DRAM_CKE, DRAM_CLK, DRAM_CS_N, DRAM_LDQM, DRAM_RAS_N, DRAM_UDQM, DRAM_WE_N;
   logic [9:0] SW, LEDR;
   logic [3:0] KEY;
   tri [15:0] DRAM_DQ;
   logic [12:0] DRAM_ADDR;
   logic [1:0] 	DRAM_BA;
   logic [6:0] 	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

   TestRam dut (.*);
   defparam dut.IS_SIMULATION = 1;

   // Set up the 50MHz clock
   logic clk;
   assign CLOCK_50 = clk;
   parameter CLOCK_PERIOD=20;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end

   initial begin
      @(negedge clk);
      SW[9] = 1; @(negedge clk); // reset
      SW[9] = 0;
      repeat (70000) @(negedge clk);
      $stop;
   end
endmodule
