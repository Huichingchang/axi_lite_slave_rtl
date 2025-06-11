`timescale 1ns/1ps
module reg_block #(
	parameter ADDR_WIDTH = 4,
	parameter DATA_WIDTH = 32,
	parameter REG_NUM = 4
)(
	input wire clk,
	input wire rst_n,
	input wire wr_en,
	input wire [ADDR_WIDTH-1:0] wr_addr,
	input wire [DATA_WIDTH-1:0] wr_data

);

	// 寄存器陣列
	reg [DATA_WIDTH-1:0] reg_array [0: REG_NUM-1];
	
	integer i;
	
	//初始化 + 寫入邏輯
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// 全部寄存器初始化為0
			for (i = 0; i < REG_NUM; i = i + 1) begin
				reg_array[i] <= {DATA_WIDTH{1'b0}};
			end
		end else if (wr_en) begin
			//地址範圍檢查
			if (wr_addr[ADDR_WIDTH-1:2] < REG_NUM) begin
				reg_array[wr_addr[ADDR_WIDTH-1:2]] <= wr_data;
			end
		end
	end
endmodule