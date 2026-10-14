module main(
	input [9:0]  SW,
	output [9:0] LEDR
	

);

	assign LEDR[9:7] = {3{SW[9] & SW[8] & SW[7]}};
	assign LEDR[6:0] = SW[6:0];

endmodule

