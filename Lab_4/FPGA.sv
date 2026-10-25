module clock_divider #(parameter DIV = 50_000_000)(
    input  logic clk_in,
    input  logic rstn,
    output logic clk_out
);
    logic [$clog2(DIV)-1:0] count;
    always_ff @(posedge clk_in or negedge rstn) begin
        if (!rstn) begin count <= 0; clk_out <= 0; end
        else if (count == DIV-1) begin count <= 0; clk_out <= ~clk_out; end
        else count <= count + 1;
    end
endmodule





module top_traffic_light(
    input  logic CLK100MHZ,  // board clock
    input  logic rstn_btn,   // push button, active low
    output logic LED_R,      // red LED pin
    output logic LED_G,      // green LED pin
    output logic LED_B       // blue LED pin (used as orange)
);

    logic slow_clk;

    // Instantiate clock divider
    clock_divider #(.DIV(50_000_000)) slowclk (
        .clk_in (CLK100MHZ),
        .rstn   (rstn_btn),
        .clk_out(slow_clk)
    );

    // Instantiate traffic light FSM
    traffic_light #(
        .RED_DELAY(2),
        .RED_ORANGE_DELAY(1),
        .GREEN_DELAY(2),
        .ORANGE_DELAY(1),
        .COUNTER_WIDTH(24)
    ) fsm (
        .clk   (slow_clk),
        .rstn  (rstn_btn),
        .red   (LED_R),
        .orange(LED_B), // blue used for orange
        .green (LED_G)
    );

endmodule
