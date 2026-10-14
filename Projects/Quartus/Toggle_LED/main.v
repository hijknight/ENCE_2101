module main(

	input   [0:9]   SW,
	output  [0:9]   LEDR

);

	assign LEDR[0:9] = SW[0:9];
	
endmodule