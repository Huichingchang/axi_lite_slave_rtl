`timescale 1ns/1ps
module top_axi_slave # (
	parameter ADDR_WIDTH = 4,
	parameter DATA_WIDTH = 32
)(
	input wire clk,
	input wire rst_n,
	
	// AXI Lite Write Address Channel
	input wire [ADDR_WIDTH-1:0] s_axi_awaddr,
	input wire s_axi_awvalid,
	output wire s_axi_awready,
	
	// AXI Lite Write Data Channel
	input wire [DATA_WIDTH-1:0] s_axi_wdata,
	input wire s_axi_wvalid,
	output wire s_axi_wready,
	
	// AXI Lite Write Response Channel
	output wire [1:0] s_axi_bresp,
	output wire s_axi_bvalid,
	input wire s_axi_bready,
	
	// Export internal FSM signals for observation
	output wire wr_en,
	output wire [ADDR_WIDTH-1:0] wr_addr,
	output wire [DATA_WIDTH-1:0] wr_data
	
);
	//-----------------------------------
	// Instance: AXI Write FSM
	//-----------------------------------
	axi_slave_write_fsm #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) u_axi_slave_fsm (
		.clk (clk),
		.rst_n (rst_n),
		.awaddr (s_axi_awaddr),
		.awvalid (s_axi_awvalid),
		.awready (s_axi_awready),
		.wdata (s_axi_wdata),
		.wvalid (s_axi_wvalid),
		.wready (s_axi_wready),
		.bresp (s_axi_bresp),
		.bvalid (s_axi_bvalid),
		.bready (s_axi_bready),
		.wr_en (wr_en),
		.wr_addr (wr_addr),
		.wr_data (wr_data)
	);
	
	//--------------------------------
	// Instance: Register Block
	//--------------------------------
	reg_block #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) u_reg_block (
		.clk (clk),
		.rst_n (rst_n),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.wr_data(wr_data)
	);
endmodule