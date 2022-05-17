////////////////////////////////////////////////////////////////////////////////
// Filename    : sync_fifo.sv
// Description : 
//
// Author      : Phu Vuong
// History     : May, 2 2022 : Initial 	
//
////////////////////////////////////////////////////////////////////////////////
module sync_fifo
	(
	rst_n,
	// for write
	wclk,
	wenable,
	wdata,
	full,
	// for read
	rclk,
	renable,
	rdata,
	empty
	);
////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AW = 7;
parameter DW = 32;
parameter DEPTH = 128;
////////////////////////////////////////////////////////////////////////////////
// Port declarations
input logic 					rst_n;
// for write
input logic 					wclk;
input logic 					wenable;
input logic	[DW-1:0]			wdata;
output logic 					full;
// for read
input logic 					rclk;
input logic 					renable;
output logic	[DW-1:0]			rdata;
output logic 					empty;
////////////////////////////////////////////////////////////////////////////////
//internal signal
logic 					int_wclk;
logic 					int_wenable;
logic 	[DW-1:0]			int_wdata;
logic 	[AW-1:0]			int_waddr;
logic 					int_rclk;
logic 					int_renable;
logic 	[DW-1:0]			int_rdata;
logic 	[AW-1:0]			int_raddr;
////////////////////////////////////////////////////////////////////////////////
//interface
//------------------------------------------------------------------------------
//write control
sync_fifo_wrctrl
	#(
	.AW(AW),
	.DW(DW)
	) isync_fifo_wrctrl_00
	(
	.rst_n(rst_n),
	.wenable(wenable),
	// input interface
	.wclk_i(wclk),
	.wdata_i(wdata),
	.rpnt_i(int_raddr),
	// output interface
	.wenable_o(int_wenable),
	.wclk_o(int_wclk),
	.wdata_o(int_wdata),
	.wpnt_o(int_waddr),
	.full_o(full)
	);
//------------------------------------------------------------------------------
//read control
sync_fifo_rdctrl
	#(
	.AW(AW),
	.DW(DW)
	) isync_fifo_rdctrl_00
	(
	.rst_n(rst_n),
	.renable(renable),
	// input interface
	.rclk_i(rclk),
	.rdata_i(int_rdata),
	.wpnt_i(int_waddr),
	// output interface
	.renable_o(int_renable),
	.rclk_o(int_rclk),
	.rdata_o(rdata),
	.rpnt_o(int_raddr),
	.empty_o(empty)
	);
//------------------------------------------------------------------------------
//memory
sync_fifo_memory
	#(
	.AW(AW),
	.DW(DW),
	.DEPTH(DEPTH)
	) isync_fifo_memory_00
	(
	// for write
	.wclk_i(int_wclk),
	.wenable_i(int_wenable),
	.waddr_i(int_waddr),
	.wdata_i(int_wdata),
	// for read
	.rclk_i(int_rclk),
	.renable_i(int_renable),
	.raddr_i(int_raddr),
	.rdata_o(int_rdata)
	);

endmodule
