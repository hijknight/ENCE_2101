module main (
    input MAX10_CLK1_50,
    input [9:0] SW,
    output [9:0] LEDR

);

    wire Clock;
    wire Resetn;

    assign Clock = MAX10_CLK1_50;
    assign Resetn = SW[0];

	 // counter
	 parameter DIVISOR = 25000000;
    reg [24:0] counter;
	 reg led_out;
	 
	 

    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn) begin
            counter <= 0;
				led_out <= 0;
        end
        else begin
				if (counter == DIVISOR - 1) begin
					counter <= 0;
					led_out <= ~led_out;
				end
				else begin
					counter = counter + 1;
				end
        end
    end

    assign LEDR[0] = led_out;
    
endmodule






