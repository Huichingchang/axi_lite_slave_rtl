`timescale 1ns/1ps
module axi_slave_write_fsm #(
	parameter ADDR_WIDTH = 4,
	parameter DATA_WIDTH = 32
)(
	input wire clk,
	input wire rst_n,
	 
	// AXI wRITE aDDRESS
	input wire [ADDR_WIDTH-1:0] awaddr,
	input wire awvalid,
	output reg awready,
	
	// AXI Write Data
	input wire [DATA_WIDTH-1:0] wdata,
	input wire wvalid,
	output reg wready,
	
	// AXI Write Response
	output reg [1:0] bresp,
	output reg bvalid,
	input wire bready,
	
	// Register Write Output
	output reg wr_en,
	output reg [ADDR_WIDTH-1:0] wr_addr,
	output reg [DATA_WIDTH-1:0] wr_data
);

	localparam IDLE = 2'b00;
	localparam WRITE = 2'b01;
	localparam RESP = 2'b10;
	
	reg [1:0] state, next_state;
	
	
	// FSM State Transition
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			state <= IDLE;
		else
			state <= next_state;
	end
	
	// FSM Next State Logic
	always @(*) begin
		next_state = state;
		case (state)
			IDLE: begin
			   if (awvalid && wvalid) 
					next_state = WRITE;
			end
			
			WRITE: begin
			   next_state = RESP;
			end
			RESP: begin
				if (bready) 
					next_state = IDLE;
			end
		endcase
	end
	
	// Output Logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			awready <= 0;
			wready <= 0;
			bvalid <= 0;
			bresp <= 2'b00;
			wr_en <= 0;
			wr_addr <= 0;
			wr_data <= 0;
		end else begin
			// default
			awready <= 0;
			wready <= 0;
			bvalid <= 0;
			wr_en <= 0;
			
			case (state)
				IDLE: begin
					awready <= 1;
					wready <= 1;
					if (awvalid && wvalid) begin
						wr_en <= 1;
						wr_addr <= awaddr;
						wr_data <= wdata;
					end
				end
				WRITE: begin
					bvalid <= 1;
					bresp <= 2'b00;  //OKAY response
				end		
			endcase
		end
	end
endmodule