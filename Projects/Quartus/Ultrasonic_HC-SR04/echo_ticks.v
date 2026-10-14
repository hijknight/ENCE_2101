
`default_nettype none

module echo_ticks (
	input clk,
	input rst_n,
	input echo_in,
	
	output reg [20: 0] width_ticks,
	output reg valid,
	output reg timeout,
	output wire busy
);

	localparam CLK_HZ        = 50000000; // MAX_10 clock runs at 50,000,000 Hz
	localparam TIMEOUT_TICKS = 2000000; // stop after this time, (40 ms)
	
	// 2FF (Synchronize async input)
	reg echo_meta, echo_sync, echo_prev;
	
	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			echo_meta <= 1'b0;
			echo_sync <= 1'b0;
			echo_prev <= 1'b0;
		end else begin
			echo_meta <= echo_in;
			echo_sync <= echo_meta;
			echo_prev <= echo_sync;
		end
	end
	
	wire rising = echo_sync & ~echo_prev;
	wire falling = ~echo_sync & echo_prev;
	
	
	// measurement style
	
	reg counting;
	reg [20:0] count;
	
	assign busy = counting;
	
	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			counting <= 1'b0;
			count <= 21'd0;
			width_ticks <= 21'd0;
			valid <= 1'b0;
			timeout <= 1'b0;
		end else begin
			valid <= 1'b0;
			timeout <= 1'b0;
			
			if (!counting) begin
				if (rising) begin
					counting <= 1'b1;
					count <= 21'd0;
				end
			end else begin
				count <= count + 21'd1;
				
				if (falling) begin
					counting <= 1'b0;
					width_ticks <= count + 21'd1;
					valid <= 1'b1;
				end else if (count >= (TIMEOUT_TICKS - 1)) begin
					counting <= 1'b0;
					width_ticks <= TIMEOUT_TICKS;
					timeout <= 1'b1;
				end
			end
		end
	end
	
endmodule