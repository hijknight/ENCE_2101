
module main (
    input MAX10_CLK1_50,
    input KEY0,

    inout wire [15:0] ARDUINO_IO,

    output wire [9:0] LEDR,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2
);

    wire cycle_out;
    wire trig_out;
    wire echo_in;

    wire [20:0] width_ticks;
    wire sample;
    wire timeout;
    wire busy;

    // Arduino GPIO connections
    assign ARDUINO_IO[11] = trig_out;
    assign echo_in = ARDUINO_IO[10];

    // Status LEDs
    assign LEDR = {7'b0, cycle_out, timeout, busy};

    // Trigger Generator
    trigger_generator triggers (
        .Clock (MAX10_CLK1_50),
        .Resetn (KEY0),
        .cycle_out (cycle_out),
        .trig_out (trig_out)
    );

    // Echo Pulse Counter
    echo_ticks echoes (
        .clk (MAX10_CLK1_50),
        .rst_n (KEY0),
        .echo_in (echo_in),

        .width_ticks (width_ticks),
        .valid (sample),
        .timeout (timeout),
        .busy (busy)
    );

    // Distance Display
    show_ticks_cm_3hex ticks_to_hex (
        .Clk (MAX10_CLK1_50),
        .rst_n (KEY0),
        .sample (sample),
        .ticks_20ns (width_ticks),

        .HEX2 (HEX2),
        .HEX1 (HEX1),
        .HEX0 (HEX0)
    );

endmodule
