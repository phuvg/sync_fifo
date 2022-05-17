////////////////////////////////////////////////////////////////////////////////
// Filename    : sync_fifo_memory.sv
// Description : 
//
// Author      : Phu Vuong
// History     : May, 2 2022 : Initial 	
//
////////////////////////////////////////////////////////////////////////////////
module sync_fifo_memory
	(
	// for write
	wclk_i,
	wenable_i,
	waddr_i,
	wdata_i,
	// for read
	rclk_i,
	renable_i,
	raddr_i,
	rdata_o
	);
////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AW = 7;
parameter DW = 32;
parameter DEPTH = 128;
////////////////////////////////////////////////////////////////////////////////
// Port declarations
// for write
input logic 					wclk_i;
input logic 					wenable_i;
input logic	[AW-1:0]			waddr_i;
input logic	[DW-1:0]			wdata_i;
// for read
input logic 					rclk_i;
input logic 					renable_i;
input logic	[AW-1:0]			raddr_i;
output logic	[DW-1:0] 			rdata_o;
////////////////////////////////////////////////////////////////////////////////
//internal signal
logic	[DW-1:0]				ram[DEPTH-1:0];
////////////////////////////////////////////////////////////////////////////////
//write memory
always_ff @(posedge wclk_i)
	begin
	if(wenable_i) begin
		ram[waddr_i] <= wdata_i;
	end
	end
//read memory
always_ff @(posedge rclk_i)
	begin
	if(renable_i) begin
		rdata_o <= ram[raddr_i];
	end
	end
endmodule
