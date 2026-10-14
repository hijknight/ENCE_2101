
`default_nettype none

module show_ticks_cm_3hex 
# (
	parameter LEADING_BLANK =1
)
(
	input Clk,
	input rst_n,
	input sample,
	input [20: 0] ticks_20ns,
	
	output reg [6: 0] HEX2, // hundreds
	output reg [6: 0] HEX1, // tens 
	output reg [6: 0] HEX0 // ones
	
);

	reg [20: 0] ticks_q;
	
	always @ (posedge Clk or negedge rst_n) begin
		if (!rst_n) begin
			ticks_q <= 21'd0;
		end else if (sample) begin
			ticks_q <= ticks_20ns;
		end
	end
	
	function [9: 0] ticks_to_cm10;
		input [20: 0] t;
		reg [47:0] p;
		begin
			p = (t * 16'd46282) + 48'd67108864; // + 2 ^ 26
			ticks_to_cm10 = p [47:27];
		end
	endfunction
	
	wire [9:0] cm_raw = ticks_to_cm10(ticks_q);
	
	// clamp to claimed range
	wire [9:0] cm_clamped = (cm_raw > 10'd400) ? 10'd400 : cm_raw;
	
	
	// binary (0..999) to BCD (hund, tens, ones)
	wire [3:0] bcd_h, bcd_t, bcd_o;
	
	bin_to_bcd3 bcd_converter (
		.bin (cm_clamped),
		.h (bcd_h),
		.t (bcd_t),
		.o (bcd_o)
	);
	
	wire [6:0] seg_h = (LEADING_BLANK && (bcd_h == 4'd0)) ? 7'b1111111 : seg7(bcd_h);
	wire [6:0] seg_t = (LEADING_BLANK && (bcd_h == 4'd0) && (bcd_t == 4'd0)) ? 7'b1111111 : seg7(bcd_t);
	wire [6:0] seg_o = seg7(bcd_o);
	
	always @ (posedge Clk or negedge rst_n) begin
		if (!rst_n) begin
			HEX2 <= 7'b1111111;
			HEX1 <= 7'b1111111;
			HEX0 <= 7'b1111111;
		end else begin
			HEX2 <= seg_h;
			HEX1 <= seg_t;
			HEX0 <= seg_o;
		end
	end
	
	function [6:0] seg7;
		input [3:0] d;
		begin
			case(d)
				4'd0 : seg7 = 7'b1000000;
				4'd1 : seg7 = 7'b1111001;
				4'd2 : seg7 = 7'b0100100;
				4'd3 : seg7 = 7'b0110000;
				4'd4 : seg7 = 7'b0011001;
				4'd5 : seg7 = 7'b0010010;
				4'd6 : seg7 = 7'b0000010;
				4'd7 : seg7 = 7'b1111000;
				4'd8 : seg7 = 7'b0000000;
				4'd9 : seg7 = 7'b0010000;
				default : seg7 = 7'b1111111; // blank
			endcase
		end
	endfunction

endmodule


module bin_to_bcd3 (
		input [9:0] bin,
		output reg [3:0] h,
		output reg [3:0] t,
		output reg [3:0] o
);
	
	integer i;
	
	reg [21:0] shift;
	
	always @(*) begin
		shift = {12'd0, bin};
		
		for (i = 0; i < 10; i = i + 1) begin
			if (shift[21:18] >= 4'd5) shift[21:18] = shift[21:18] + 4'd3;
			if (shift[17:14] >= 4'd5) shift[17:14] = shift[17:14] + 4'd3;
			if (shift[13:10] >= 4'd5) shift[13:10] = shift[13:10] + 4'd3;
			shift = shift << 1;
		end
		h = shift [21:18];
		t = shift [17:14];
		o = shift [13:10];
	end
endmodule	