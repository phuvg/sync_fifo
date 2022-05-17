////////////////////////////////////////////////////////////////////////////////
// Filename    : tb_sync_fifo.sv
// Description : 
//
// Author      : Phu Vuong
// History     : May, 2 2022 : Initial 	
//
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module tb_sync_fifo ();
////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AW = 7;
parameter DW = 32;
parameter DEPTH = 128;
parameter CLK_PERIOD = 1;
parameter CHECK_SIZE = 140;
//------------------------------------------------------------------------------
//internal signal
logic 			rst_n;
logic 			wclk;
logic 			wenable;
logic [DW-1:0]		wdata;
logic 			full;
logic 			rclk;
logic 			renable;
logic [DW-1:0]		rdata;
logic 			empty;
//loop
integer i;
logic [DW-1:0]initdata;
logic [DW-1:0]datastep;
logic read_only_check_flag;
logic [AW:0]read_only_check_counter;
logic wenable_gen_enable;
logic wdata_gen_enable;
logic [AW:0]write_read_parallel_check_counter;
logic renable_gen_enable;
logic rdata_gen_check;
////////////////////////////////////////////////////////////////////////////////
// DUT
sync_fifo
	#(
	.AW(AW),
	.DW(DW),
	.DEPTH(DEPTH)
	) isync_fifo_00
	(
	.rst_n(rst_n),
	// for write
	.wclk(wclk),
	.wenable(wenable),
	.wdata(wdata),
	.full(full),
	// for read
	.rclk(rclk),
	.renable(renable),
	.rdata(rdata),
	.empty(empty)
	);
////////////////////////////////////////////////////////////////////////////////
// testbench
//------------------------------------------------------------------------------
// testcase
initial begin
	//init
	rst_n = 1'b0;
	wenable = 1'b0;
	initdata = $urandom_range(1000, 10000); datastep = $urandom_range(1, 500);
	wdata = initdata;
	renable = 1'b0;
	wclk = 1'b0;
	rclk = 1'b0;
	read_only_check_flag = 1'b0;
	wenable_gen_enable = 1'b0;
	wdata_gen_enable = 1'b0;
	renable_gen_enable = 1'b0;
	rdata_gen_check = 1'b0;
	write_read_parallel_check_counter = {(AW+1){1'b0}};
	$display("----------START SIM----------");
	$display(">> initial write data = %d; step size = %d", wdata, datastep);
	//check write function and full signal
	$display("-----WRITE CHECK-----");
	#(2.5*CLK_PERIOD)	rst_n = 1'b1;
	#(10*CLK_PERIOD)	wenable = 1'b1;
	for(i=0; i<(CHECK_SIZE);i=i+1) begin
		#(CLK_PERIOD) wdata = wdata + datastep;
		$display(">> step %d: wdata = %d; full = %b; write_enable = %b", i, isync_fifo_00.int_wdata, full, isync_fifo_00.int_wenable);
	end
	//check read function and empty signal
	$display("-----READ CHECK-----");
	#(CLK_PERIOD)		wenable = 1'b0;
	#(10*CLK_PERIOD)	renable = 1'b1; read_only_check_flag = 1'b1;
	#((CHECK_SIZE)*CLK_PERIOD) read_only_check_flag = 1'b0;
	//check reset function
	rst_n = 1'b0; renable = 1'b0;
	#(20*CLK_PERIOD) rst_n = 1'b1;
	#(20*CLK_PERIOD);
	//parallel write and read	
	$display("-----WRITE READ PARALLEL CHECK-----");
	initdata = $urandom_range(2000, 20000); datastep = $urandom_range(2, 200);
	wenable_gen_enable = 1'b1;
	#(CLK_PERIOD) wdata = initdata; renable_gen_enable = 1'b1; wdata_gen_enable = 1'b1;
	#(CLK_PERIOD) rdata_gen_check = 1'b1;
	#(CHECK_SIZE*CLK_PERIOD);
	$finish;
	
end
//------------------------------------------------------------------------------
// clock
always begin
	#(0.5*CLK_PERIOD) wclk <= ~wclk;
end
always begin
	#(0.5*CLK_PERIOD) rclk <= ~rclk;
end
//------------------------------------------------------------------------------
// Dump waveform
initial
	begin
	$dumpfile("wf_sync_fifo.vcd");
	//$dumpvars(0, isync_fifo_00);
	$dumpvars;
	end
//------------------------------------------------------------------------------
// for read check only
always @(posedge rclk) begin
	if(!read_only_check_flag) begin
		read_only_check_counter <= {(AW+1){1'b1}};
	end else begin
		if(read_only_check_counter != {(AW+1){1'b1}}) begin
			if((rdata - (read_only_check_counter * datastep)) == initdata) begin
				$display(">> step = %d: rdata = wdata = %d, empty = %b -> PASS", read_only_check_counter, rdata, empty);
			end else begin
				$display(">> step = %d: rdata != wdata; rdata = %d, empty = %b -> FAIL", read_only_check_counter, rdata, empty);
			end
		end
		if(!empty) begin
			read_only_check_counter <= read_only_check_counter + {{(AW){1'b0}}, 1'b1};
		end
	end
end
// for write read parallel
//generate wenable
always @(posedge wclk) begin
	if(wenable_gen_enable) begin
		#(CLK_PERIOD);
		wenable <= ~wenable;
	end
end
//generate wdata
always @(posedge wclk) begin
	if(wdata_gen_enable) begin
		#(2*CLK_PERIOD);
		wdata <= wdata + datastep;
		write_read_parallel_check_counter <= write_read_parallel_check_counter + {{(AW){1'b0}}, 1'b1};
	end
end
//generate renable
always @(posedge rclk) begin
	if(renable_gen_enable) begin
		#(CLK_PERIOD) renable <= ~renable;
	end
end
//self-test
always @(negedge rclk) begin
	if(rdata_gen_check && renable) begin
		if(write_read_parallel_check_counter == {(AW+1){1'b0}}) begin
			if(rdata == initdata) begin
				$display(">> rdata == wdata == %d; full = %b; empty = %b --> PASS", rdata, full, empty);
			end else begin
				$display(">> rdata != wdata; rdata == %d; full = %b; empty = %b --> FAIL", rdata, full, empty);
			end
		end else begin
			if(((rdata - initdata) / write_read_parallel_check_counter) == datastep) begin
				$display(">> rdata == wdata == %d; full = %b; empty = %b --> PASS", rdata, full, empty);
			end else begin
				$display(">> rdata != wdata; rdata == %d; full = %b; empty = %b --> FAIL", rdata, full, empty);
			end
		end
	end
end

endmodule
