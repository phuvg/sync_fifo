////////////////////////////////////////////////////////////////////////////////
// Filename    : sync_fifo_wrctrl.sv
// Description : 
//
// Author      : Phu Vuong
// History     : May, 2 2022 : Initial 	
//
////////////////////////////////////////////////////////////////////////////////
module sync_fifo_wrctrl
	(
	rst_n,
	wenable,
	// input interface
	wclk_i,
	wdata_i,
	rpnt_i,
	// output interface
	wenable_o,
	wclk_o,
	wdata_o,
	wpnt_o,
	full_o
	);
	
////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AW = 7;
parameter DW = 32;
	
////////////////////////////////////////////////////////////////////////////////
// Port declarations
input logic 					rst_n;
input logic 					wenable;
// input interface
input logic 					wclk_i;
input logic	[DW-1:0]			wdata_i;
input logic 	[AW-1:0]			rpnt_i;
// output interface
output logic 					wenable_o;
output logic 					wclk_o;
output logic 	[DW-1:0]			wdata_o;
output logic 	[AW-1:0]			wpnt_o;
output logic 					full_o;
////////////////////////////////////////////////////////////////////////////////
//internal signal
logic int_clk;
//logic [DW-1:0]int_data;
logic int_enable;
logic [AW-1:0]cnt_wpnt;
logic [AW-1:0]plus_wpnt;
logic cmp_full;
logic int_full_enable_clk;
////////////////////////////////////////////////////////////////////////////////
//enable
assign int_enable = rst_n & wenable & ~full_o;
assign int_clk = int_enable & wclk_i;
//assign int_data = {(DW){int_enable}} & wdata_i;
//counter
always_ff @ (posedge int_clk or negedge rst_n)
begin
	if(!rst_n) begin
		cnt_wpnt <= 1'b0;
	end else begin
		if(!cmp_full && int_enable) begin
			cnt_wpnt <= cnt_wpnt + {{(AW-1){1'b0}}, 1'b1};
		end else begin
			cnt_wpnt <= cnt_wpnt;
		end
	end
end
//full
always_ff @(posedge wclk_i or negedge rst_n)
begin
	if(!rst_n) begin
		full_o <= 1'b0;
	end else begin
		full_o <= cmp_full;
	end
end
//plus 1
assign plus_wpnt = cnt_wpnt + {{(AW){1'b0}}, 1'b1};
//compare =
assign cmp_full = (plus_wpnt == rpnt_i) ? 1'b1 : 1'b0;
//output
assign wenable_o = int_enable;
assign wclk_o = int_clk;
assign wdata_o = wdata_i;
assign wpnt_o = cnt_wpnt;

endmodule
