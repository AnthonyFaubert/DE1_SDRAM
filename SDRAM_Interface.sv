
module SDRAM_LowLevel (
	// SDRAM I/O, connect to top-level SDRAM I/O //
	output logic [12:0] DRAM_ADDR, // row/column address, depending on command specified by row/column strobes
	output logic [1:0] DRAM_BA, // bank address. the SDRAM is split into 4 equal banks
	output logic DRAM_CAS_N, // ColumnAddressStrobe, active-low
	output logic DRAM_CKE, // ClocKEnable
	output logic DRAM_CLK, // CLocK
	output logic DRAM_CS_N, // ChipSelect, active-low
	inout [15:0] DRAM_DQ, // Data input/output port. Each data word is 16 bits = 2 bytes
	output logic DRAM_LDQM, // Low DQ (data port) Mask, can be used to ignore the lower byte of the data port (DQ[7:0]) during a write operation
	output logic DRAM_RAS_N, // RowAddressStrobe, active-low
	output logic DRAM_UDQM, // Upper DQ Mask, same as LDQM, but for the upper byte (DQ[15:8]) instead of the lower one
	output logic DRAM_WE_N, // WriteEnable, active-low
     );

   logic [1:0] writeDataMask; // determines which bytes of a write are written, top, bottom, or both
   assign {DRAM_UDQM, DRAM_LDQM} = ~writeDataMask; // mask bits are active-low

   // No reason to ever disable the clock, set it enabled
   assign DRAM_CKE = 1'b1;
   // No reason to deselect the chip, it doesn't share a bus with anything else
   assign DRAM_CS_N = ~1'b1;

   // determines what operation the SDRAM will perform (read, write, refresh, etc)
   logic [1:0] command;
   assign {DRAM_CAS_N, DRAM_RAS_N} = ~command;

   // I hate active-low signals
   logic writeEnable;
   assign DRAM_WE_N = ~writeEnable;

   // Commands (datasheet page 9)       {RAS, CAS, WE}
   parameter NOOP                     = 3'b000;
   parameter BURST_STOP               = 3'b001;
   parameter READ                     = 3'b010; // A10 low
   parameter READ_WITH_AUTOPRECHARGE  = 3'b010; // A10 high
   parameter WRITE                    = 3'b011; // A10 low
   parameter WRITE_WITH_AUTOPRECHARGE = 3'b011; // A10 high
   parameter BANK_ACTIVATE            = 3'b100;
   parameter PRECHARGE_SELECT_BANK    = 3'b101; // A10 low
   parameter PRECHARGE_ALL_BANKS      = 3'b101; // A10 high
   parameter CBR_AUTO_REFRESH         = 3'b110; // see datasheet page 9, clock enable
   parameter SELF_REFRESH             = 3'b110; // see datasheet page 9, clock enable
   parameter MODE_REGISTER_SET        = 3'b111; // {A10, BA1, BA0} low
   
   
   always_ff @(posedge DRAM_CLK) begin
      
   end

endmodule // SDRAM_Interface
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

