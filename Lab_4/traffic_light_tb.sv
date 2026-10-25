`timescale 1ns / 1ps
//TASK 1
module traffic_light_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic red, orange, green;

    // Instantiate DUT (Device Under Test)
    traffic_light #(
        .RED_DELAY(5),
        .RED_ORANGE_DELAY(3),
        .GREEN_DELAY(4),
        .ORANGE_DELAY(2),
        .COUNTER_WIDTH(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .red(red),
        .orange(orange),
        .green(green)
    );

    // Clock generation (period = 10 ns)
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        #15 rst_n = 1;  // release reset after 15 ns

        // Run simulation long enough to see several full cycles
        #200 $finish;
    end

    // Monitor output
    initial begin
        $display("Time\tState\tRed Orange Green");
        $monitor("%0t\t%b%b%b", $time, red, orange, green);
    end

    // Optional waveform dump (for GTKWave)
    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, traffic_light_tb);
    end

endmodule
