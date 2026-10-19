module keypad_scanner (
	input Clk,
	input Resetn,
	input [3:0] cols,
	
	output reg [3:0] rows,
	output reg [3:0] raw_key,
	output reg raw_valid,
	
	output reg [3:0] key,
	output reg key_valid
);

	localparam CLK_DIVISOR = 50000;

	reg [1:0] scan_row;
	
	reg [15:0] counter; // 2^16 > 50000
	
	
	localparam IDLE     = 2'd0;
	localparam DEBOUNCE = 2'd1;
	localparam HELD     = 2'd2;
	localparam RELEASE  = 2'd3;

	reg [1:0] state;
	reg [2:0] debounce_count;

	reg [3:0] candidate_key;

	// Information collected during a complete scan
	reg [3:0] frame_key;
	reg frame_seen;
	reg frame_error;

	// Synchronize the physical column inputs
	reg [3:0] cols_meta;
	reg [3:0] cols_sync;

	always @(posedge Clk or negedge Resetn) begin
		 if (!Resetn) begin
			  cols_meta <= 4'b1111;
			  cols_sync <= 4'b1111;
		 end else begin
			  cols_meta <= cols;
			  cols_sync <= cols_meta;
		 end
	end

	always @(posedge Clk or negedge Resetn) begin
		if (!Resetn) begin
			scan_row <= 0;
			counter <= 0;
		end else begin
			if (counter == CLK_DIVISOR - 1) begin
				scan_row <= scan_row + 2'd1;
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end
		end
	end
	
	
	always @(*) begin
		case (scan_row)
			2'd0: rows = 4'b0111;
			2'd1: rows = 4'b1011;
			2'd2: rows = 4'b1101;
			2'd3: rows = 4'b1110;
			default: rows = 4'b1111;
		endcase
	end
	
	always @(*) begin
    raw_key = 4'b0000;
    raw_valid = 1'b0;

    case (scan_row)
        2'd0: begin
            case (cols_sync)
                4'b0111: begin raw_key = 4'd1;  raw_valid = 1; end
                4'b1011: begin raw_key = 4'd2;  raw_valid = 1; end
                4'b1101: begin raw_key = 4'd3;  raw_valid = 1; end
                4'b1110: begin raw_key = 4'd10; raw_valid = 1; end // A
            endcase
        end

        2'd1: begin
            case (cols_sync)
                4'b0111: begin raw_key = 4'd4;  raw_valid = 1; end
                4'b1011: begin raw_key = 4'd5;  raw_valid = 1; end
                4'b1101: begin raw_key = 4'd6;  raw_valid = 1; end
                4'b1110: begin raw_key = 4'd11; raw_valid = 1; end // B
            endcase
        end

        2'd2: begin
            case (cols_sync)
                4'b0111: begin raw_key = 4'd7;  raw_valid = 1; end
                4'b1011: begin raw_key = 4'd8;  raw_valid = 1; end
                4'b1101: begin raw_key = 4'd9;  raw_valid = 1; end
                4'b1110: begin raw_key = 4'd12; raw_valid = 1; end// C
            endcase
        end

        2'd3: begin
            case (cols_sync)
                4'b0111: begin raw_key = 4'd14; raw_valid = 1; end // *
                4'b1011: begin raw_key = 4'd0;  raw_valid = 1; end
                4'b1101: begin raw_key = 4'd15; raw_valid = 1; end // #
                4'b1110: begin raw_key = 4'd13; raw_valid = 1; end // D
            endcase
			end
		endcase
	end
	
	
	wire scan_conflict =
    frame_error ||
    (frame_seen && raw_valid && frame_key != raw_key);

	wire scan_valid =
		 (frame_seen || raw_valid) && !scan_conflict;

	wire [3:0] scan_key =
		 raw_valid ? raw_key : frame_key;

	always @(posedge Clk or negedge Resetn) begin
		 if (!Resetn) begin
			  frame_key   <= 0;
			  frame_seen  <= 0;
			  frame_error <= 0;
		 end else if (counter == CLK_DIVISOR - 1) begin

			  if (scan_row == 2'd3) begin
					// Completed all four rows
					frame_seen  <= 0;
					frame_error <= 0;
					frame_key   <= 0;
			  end else if (raw_valid) begin

					if (frame_seen && frame_key != raw_key)
						 frame_error <= 1;

					frame_key  <= raw_key;
					frame_seen <= 1;
			  end
		 end
	end
		
	always @(posedge Clk or negedge Resetn) begin
		 if (!Resetn) begin
			  state          <= IDLE;
			  debounce_count <= 0;
			  candidate_key  <= 0;
			  key            <= 0;
			  key_valid      <= 0;
		 end else begin

			  // Default: no new keypress
			  key_valid <= 0;

			  // Update FSM once every complete 4-row scan
			  if (counter == CLK_DIVISOR - 1 &&
					scan_row == 2'd3) begin

					case (state)

						 IDLE: begin
							  if (scan_valid) begin
									candidate_key  <= scan_key;
									debounce_count <= 3'd1;
									state          <= DEBOUNCE;
							  end
						 end

						 DEBOUNCE: begin
							  if (!scan_valid ||
									scan_key != candidate_key) begin

									// Press disappeared or changed
									state <= IDLE;

							  end else if (debounce_count == 3'd4) begin

									// Fifth consecutive scan
									key       <= candidate_key;
									key_valid <= 1'b1;
									state     <= HELD;

							  end else begin
									debounce_count <= debounce_count + 1'b1;
							  end
						 end

						 HELD: begin
							  if (!scan_valid) begin
									debounce_count <= 3'd1;
									state <= RELEASE;
							  end
						 end

						 RELEASE: begin
							  if (scan_valid) begin
									// Key is still pressed
									state <= HELD;

							  end else if (debounce_count == 3'd4) begin
									// Released for five scans
									state <= IDLE;

							  end else begin
									debounce_count <= debounce_count + 1'b1;
							  end
						 end

						 default: state <= IDLE;

					endcase
			  end
		 end
	end
		
	
endmodule