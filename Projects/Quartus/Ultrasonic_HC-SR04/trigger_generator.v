
`default_nettype none

module trigger_generator(
	input Clock,
	input Resetn,
	output cycle_out,
	output trig_out
);


	localparam DIVISOR_TRIG = 500; // 20ns * 500 = 10 micro s
	localparam DIVISOR_CYCLE = 3000000; // 20ns * 3,000,000 = 60 ms
	
	reg [21: 0] counter_cycle; // 2^22 = 4.2mil > 3mil
	
	reg led_out; // monitor 60 ms cycle
	
	always @ (posedge Clock, negedge Resetn) begin
		if (!Resetn) begin
			counter_cycle <= 0;
			led_out <= 0;
		end else begin
			if (counter_cycle == DIVISOR_CYCLE - 1) begin
				counter_cycle <= 0;
				led_out <= ~led_out;
			end else begin
				counter_cycle <= counter_cycle + 1;
			end
		end
	end
	
	
	assign cycle_out = led_out;
	
	reg trig_out_q;
	
	always @ (posedge Clock) begin
		if (!Resetn) begin
			trig_out_q <= 0;
		end else begin
			trig_out_q <= (counter_cycle < DIVISOR_TRIG);
		end
	end
	
	
	assign trig_out = trig_out_q;
	
endmodule