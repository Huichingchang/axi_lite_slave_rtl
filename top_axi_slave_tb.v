`timescale 1ns/1ps
module top_axi_slave_tb;
	parameter ADDR_WIDTH = 4;
	parameter DATA_WIDTH = 32;
	
	reg clk;
	reg rst_n;
	
	// AXI Write Address Channel
	reg [ADDR_WIDTH-1:0] s_axi_awaddr;
	reg s_axi_awvalid;
	wire s_axi_awready;
	
	// AXI Write Data Channel
	reg [DATA_WIDTH-1:0] s_axi_wdata;
	reg s_axi_wvalid;
	wire s_axi_wready;
	
	// AXI Write Response Channel
	wire [1:0] s_axi_bresp;
	wire s_axi_bvalid;
	reg s_axi_bready;
	
	//DUT
	top_axi_slave #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) dut (
		.clk(clk),
		.rst_n(rst_n),
		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),
		.s_axi_wdata(s_axi_wdata),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),
		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready)
	);
	
	// Clock generation: 100MHz
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	// Reset and test process
	initial begin
		/*$dumpfile("top_axi_slave_tb.vcd");
		$dumpvars(0,top_axi_slave_tb);*/
		
		// Default values
		s_axi_awaddr = 0;
		s_axi_awvalid = 0;
		s_axi_wdata = 0;
		s_axi_wvalid = 0;
		s_axi_bready = 0;
		
		rst_n = 0;
		#20;
		rst_n = 1;
		#10;
		
		// Test 1: Write 0XDEADBEEF to address 0X0
		axi_write(4'h0, 32'hDEADBEEF);
		
		// Test 2: Write 0x12345678 to address 0x4
		axi_write(4'h4, 32'h12345678);
		
		#100;
		$finish;
	end
	
	// Task: AXI-lite write
	task axi_write;
		input [ADDR_WIDTH-1:0] awaddr;
		input [DATA_WIDTH-1:0] wdata;
	   begin
			@(posedge clk);
			s_axi_awaddr <= awaddr;
			s_axi_awvalid <= 1;
			s_axi_wdata <= wdata;
			s_axi_wvalid <= 1;
			s_axi_bready <= 1;
			
			wait (s_axi_awready && s_axi_wready);
			@(posedge clk);
			s_axi_awvalid <= 0;
			s_axi_wvalid <= 0;
			
			wait (s_axi_bvalid);
			@(posedge clk);
			s_axi_bready <= 0;
			$display("AXI Write Done: Addr = 0x%0h, Data = 0x%0h", awaddr, wdata);
	   end
	endtask
endmodule