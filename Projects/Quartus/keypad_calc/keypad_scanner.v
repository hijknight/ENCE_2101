module keypad_scanner (
	input Clk,
	input Resetn,
	input [3:0] cols,
	
	output reg [3:0] rows,
	output reg [3:0] key,
	output reg key_valid
);

	parameter CLK_DIVISOR = 50000;

	reg [1:0] scan_row;
	
	reg [15:0] counter; // 2^16 > 50000

	always @(posedge Clk or negedge Resetn) begin
		if (!Resetn) begin
			scan_row <= 0;
			counter <= 0;
		end else begin
			if (counter == CLK_DIVISOR - 1) begin
				scan_row <= scan_row + 1;
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end
		end
	end
	
	always @(*) begin
    key = 4'b0000;
    key_valid = 1'b0;

    case (scan_row)
        2'd0: begin
            case (cols)
                4'b1110: begin key = 4'd1;  key_valid = 1; end
                4'b1101: begin key = 4'd2;  key_valid = 1; end
                4'b1011: begin key = 4'd3;  key_valid = 1; end
                4'b0111: begin key = 4'd10; key_valid = 1; end // A
            endcase
        end

        2'd1: begin
            case (cols)
                4'b1110: begin key = 4'd4;  key_valid = 1; end
                4'b1101: begin key = 4'd5;  key_valid = 1; end
                4'b1011: begin key = 4'd6;  key_valid = 1; end
                4'b0111: begin key = 4'd11; key_valid = 1; end // B
            endcase
        end

        2'd2: begin
            case (cols)
                4'b1110: begin key = 4'd7;  key_valid = 1; end
                4'b1101: begin key = 4'd8;  key_valid = 1; end
                4'b1011: begin key = 4'd9;  key_valid = 1; end
                4'b0111: begin key = 4'd12; key_valid = 1; end // C
            endcase
        end

        2'd3: begin
            case (cols)
                4'b1110: begin key = 4'd14; key_valid = 1; end // *
                4'b1101: begin key = 4'd0;  key_valid = 1; end
                4'b1011: begin key = 4'd15; key_valid = 1; end // #
                4'b0111: begin key = 4'd13; key_valid = 1; end // D
            endcase
			end
		endcase
	end
	
	
endmodule