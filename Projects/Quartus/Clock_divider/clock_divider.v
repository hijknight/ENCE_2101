module clock_divider (
	input MAX10_CLK1_50,
	input KEY0,
	
	output reg [3: 0] LEDR
);

	parameter CLK_DIVIDER = 50000000; // 25,000,000 is the clock divider value for one count every half second
	reg [25: 0] count; // 2^26 > 50000000
	
	wire Reset = ~KEY0;
	wire Clk = MAX10_CLK1_50;
	
	
	always @ (posedge Clk or posedge Reset) begin
		if (Reset) begin
			count <= 0;
			LEDR <= 0;
		end else begin
			if (count == CLK_DIVIDER - 1) begin
				LEDR <= LEDR + 1;
				count <= 0;
			end else begin
				count <= count + 1;
			end
		end
	end
	
endmodule