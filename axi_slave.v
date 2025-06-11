`timescale 1ns/1ps
module axi_slave #(
	parameter ADDR_WIDTH = 4,
	parameter DATA_WIDTH = 32
)(
	input wire clk,
	input wire rst_n,
	
	// Write Address Channel
	input wire [ADDR_WIDTH-1:0] awaddr,
	input wire awvalid,
	output reg awready,
	
	// Write Data Channel
	input wire [DATA_WIDTH-1:0] wdata,
	input wire wvalid,
	output reg wready,
	
	// Write Response Channel
	output reg bvalid,
	input wire bready,
	
	//寫入控制暫存器
	output reg write_en,
	output reg [ADDR_WIDTH-1:0] write_addr,
	output reg [DATA_WIDTH-1:0] write_data
);

	//狀態暫存器
	reg aw_hs, w_hs;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			awready <= 1'b0;
			wready <= 1'b0;
			bvalid <= 1'b0;
			write_en <= 1'b0;
			write_addr <= 'b0;
			write_data <= 'b0;
			aw_hs <= 1'b0;
			w_hs <= 1'b0;
		end else begin
			// Address ready handshake
			if (awvalid && !awready) begin
				awready <= 1'b1;
			end else begin
				awready <= 1'b0;
			end
			
			// Data ready handshake
			if (wvalid && !wready) begin
				wready <= 1'b1;
			end else begin
				wready <= 1'b0;
			end
			
			// Both handshakes complete
			aw_hs <= awvalid && awready;
			w_hs <= wvalid && wready;
			
			if (aw_hs && w_hs) begin
				write_en <= 1'b1;
				write_addr <= awaddr;
				write_data <= wdata;
				bvalid <= 1'b1;
			end else begin
				write_en <= 1'b0;
			end
			
			// Response accepted
			if (bvalid && bready) begin
				bvalid <= 1'b0;
			end
		end
	end
endmodule
