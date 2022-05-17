////////////////////////////////////////////////////////////////////////////////
// Filename    : sync_fifo_rdctrl.sv
// Description : 
//
// Author      : Phu Vuong
// History     : May, 2 2022 : Initial 	
//
////////////////////////////////////////////////////////////////////////////////
module sync_fifo_rdctrl
	(
	rst_n,
	renable,
	// input interface
	rclk_i,
	rdata_i,
	wpnt_i,
	// output interface
	renable_o,
	rclk_o,
	rdata_o,
	rpnt_o,
	empty_o
	);
	
////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AW = 7;
parameter DW = 32;
	
////////////////////////////////////////////////////////////////////////////////
// Port declarations
input logic 					rst_n;
input logic 					renable;
// input interface
input logic 					rclk_i;
input logic	[DW-1:0]			rdata_i;
input logic 	[AW-1:0]			wpnt_i;
// output interface
output logic					renable_o;
output logic 					rclk_o;
output logic 	[DW-1:0]			rdata_o;
output logic 	[AW-1:0]			rpnt_o;
output logic 					empty_o;
////////////////////////////////////////////////////////////////////////////////
//internal signal
logic int_clk;
logic int_enable;
logic [AW-1:0]cnt_wpnt;
logic [AW-1:0]plus_wpnt;
logic cmp_empty;
////////////////////////////////////////////////////////////////////////////////
//enable
assign int_enable = rst_n & renable & ~empty_o;
assign int_clk = int_enable & rclk_i;
//counter
always_ff @ (posedge int_clk or negedge rst_n)
begin
	if(!rst_n) begin
		cnt_wpnt <= 1'b0;
	end else begin
		if(!cmp_empty && int_enable) begin
			cnt_wpnt <= cnt_wpnt + {{(AW-1){1'b0}}, 1'b1};
		end else begin
			cnt_wpnt <= cnt_wpnt;
		end
	end
end
//empty
always_ff @(posedge int_clk or negedge rst_n)
begin
	if(!rst_n) begin
		empty_o <= 1'b0;
	end else begin
		empty_o <= cmp_empty;
	end
end
//compare =
assign cmp_empty = (cnt_wpnt == wpnt_i) ? 1'b1 : 1'b0;
//output
assign renable_o = int_enable;
assign rclk_o = int_clk;
assign rdata_o = rdata_i;
assign rpnt_o = cnt_wpnt;

endmodule
