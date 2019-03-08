
`ifndef __SDRAM_SVH__
`define __SDRAM_SVH__

// AREFRESH = auto refresh
/*
typedef logic [3:0] CommandEnum;
parameter NOOP           = 4'd0;
parameter ACTIVATE       = 4'd1;
parameter READ           = 4'd2;
parameter READA          = 4'd3;
parameter WRITE          = 4'd4;
parameter WRITEA         = 4'd5;
parameter PRECHARGE_BANK = 4'd6;
parameter PRECHARGE_ALL  = 4'd7;
parameter AREFRESH       = 4'd8;
parameter SET_MODE_REG   = 4'd9;
 */
package CommandEnumPackage;
  typedef enum {NOOP, ACTIVATE, READ, READA, WRITE, WRITEA, PRECHARGE_BANK, PRECHARGE_ALL, AREFRESH, SET_MODE_REG} CommandEnum;
endpackage
// Used to be this, but it doesn't work between modules:
//typedef enum {NOOP, ACTIVATE, READ, READA, WRITE, WRITEA, PRECHARGE_BANK, PRECHARGE_ALL, AREFRESH, SET_MODE_REG} CommandEnum;

// PRECHARGE_BANK, PRECHARGE_ALL, WRITEA, and READA are all "precharge" commands, however WRITEA delays before precharging
// row open = activate, row close = precharge
// All of these assume CAS latency = 2 (-7 speed grade)
// Values from page 20
`define tRC  4'd8 // delay from a refresh to another refresh (also the minimum delay between activates)
`define tRCD 4'd2 // delay from activate to reading/writing
`define tMRD 4'd2 // delay after mode register write command
`define tRP  4'd2 // delay from precharge to activate
`define tDPL 4'd2 // delay from write to precharge
`define tRAS 4'd5 // delay from a activate to a precharge
`define tDAL 4'd4 // delay from WRITEA to ACTIVATE/REFRESH

`endif
