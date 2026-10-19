module main (
	input MAX10_CLK1_50,
	input KEY0,
	
	inout [7:0] ARDUINO_IO,
	
	output reg [9:0] LEDR,
	output wire [6:0] HEX0
);

	wire key_valid;
	wire [3:0] key;
	
	wire [3:0] raw_key;
	wire raw_valid;
	
	wire [3:0] cols;
	wire [3:0] rows;
	
	assign cols = ARDUINO_IO[3:0];

	genvar i;
	generate
		 for (i = 0; i < 4; i = i + 1) begin : row_drivers
			  assign ARDUINO_IO[i+4] =
					(rows[i] == 1'b0) ? 1'b0 : 1'bz;
		 end
	endgenerate
	
	keypad_scanner scanner (
		.Clk       (MAX10_CLK1_50),
		.Resetn    (KEY0),
		.cols      (cols),
		
		.rows      (rows),
		.raw_key   (raw_key),
		.raw_valid (raw_valid),
		
		.key      (key),
		.key_valid(key_valid)
	);
	
	key_to_7seg converter (
		.key (key),
		.HEX0 (HEX0)
	);
	
	
	always @(posedge MAX10_CLK1_50 or negedge KEY0) begin
		if (!KEY0) begin
			LEDR <= 10'd0;
		end else if (key_valid) begin
			LEDR <= LEDR + 10'd1;
		end
	end
	
//	
//	assign LEDR[3:0] = cols;
//	assign LEDR[7:4] = rows;
//	assign LEDR[8] = raw_valid;
//	assign LEDR[9] = key_valid;
	
endmodule


module key_to_7seg (
	input [3:0] key,
	
	output reg [6:0] HEX0
);


	always @ (*) begin
		case (key)
			4'd0 : HEX0 = 7'b1000000;
			4'd1 : HEX0 = 7'b1111001;
			4'd2 : HEX0 = 7'b0100100;
			4'd3 : HEX0 = 7'b0110000;
			4'd4 : HEX0 = 7'b0011001;		// 0 - 9
			4'd5 : HEX0 = 7'b0010010;
			4'd6 : HEX0 = 7'b0000010;
			4'd7 : HEX0 = 7'b1111000;
			4'd8 : HEX0 = 7'b0000000;
			4'd9 : HEX0 = 7'b0010000;
			
			4'd10: HEX0 = 7'b0001000; // A
			4'd11: HEX0 = 7'b0000011; // b
			4'd12: HEX0 = 7'b1000110; // C
			4'd13: HEX0 = 7'b0100001;
			
			4'd14: HEX0 = 7'b0110110; // "*"
			4'd15: HEX0 = 7'b0001001; // H for "#"
			default: HEX0=7'b1111111;
		endcase
	end
endmodule



//module main (
//    input MAX10_CLK1_50,
//    input KEY0,
//
//    inout [7:0] ARDUINO_IO,
//
//    output [9:0] LEDR,
//    output [6:0] HEX0
//);
//
//    // R2 = ARDUINO_IO[6]
//    // Hold R2 LOW, disconnect the other rows
//	 
//	 reg [3:0] key;
//
//    assign ARDUINO_IO[7] = 1'bz; // R1
//    assign ARDUINO_IO[6] = 1'b0; // R2
//    assign ARDUINO_IO[5] = 1'bz; // R3
//    assign ARDUINO_IO[4] = 1'bz; // R4
//
//    // Leave columns as inputs
//    assign ARDUINO_IO[3:0] = 4'bzzzz;
//
//    // Show active-low column inputs on LEDs
//    assign LEDR[3:0] = ~ARDUINO_IO[3:0];
//    assign LEDR[9:4] = 6'b000000;
//
//    // Blank the seven-segment display
//    always @(posedge MAX10_CLK1_50 or negedge KEY0) begin
//		if (!KEY0) begin
//			key <= 4'd0;
//		end else begin
//		
//			case (ARDUINO_IO [3:0])
//				4'b0111 : key <= 4'd4;
//				4'b1011 : key <= 4'd5;
//				4'b1101 : key <= 4'd6;
//				4'b1110 : key <= 4'd11;
//			endcase
//		end
//	end
//	
//	key_to_7seg converter (
//		.key (key),
//		.HEX0 (HEX0)
//	);
//			
//			
//			
// endmodule

//module main (
//    input [7:0] ARDUINO_IO,
//    output [9:0] LEDR
//);
//
//    assign ARDUINO_IO[7:0] = 8'bzzzz;
//
//    assign LEDR[0] = ~ARDUINO_IO[0];
//    assign LEDR[9:1] = 9'b0;
//
//endmodule
