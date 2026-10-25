`timescale 1ns / 1ps
//TASK 2
module digital_lock_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic [3:0] key;
    logic valid_key;
    logic state;

    // Instantiate DUT (Device Under Test)
    digital_lock dut (
        .clk(clk),
        .rst_n(rst_n),
        .key(key),
        .valid_key(valid_key),
        .state(state)
    );

    // Clock generation (period = 10 ns)
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize
        clk = 0;
       rst_n = 0;
        key = 0;
        valid_key = 0;
        #20rst_n = 1;  // release reset

        // Step 1: Lock the system by pressing B (hex B)
        press_key(4'hB);

        // Step 2: Enter correct code 1, 2, 3, 4
        press_key(4'd1);
        press_key(4'd2);
        press_key(4'd3);
        press_key(4'd4);

        // Step 3: Press C to confirm unlock
        press_key(4'hC);

        #50 $finish;
    end

    // Task for simulating a key press (1-cycle pulse)
    task press_key(input [3:0] k);
        begin
            key = k;
            valid_key = 1;
            #10;
            valid_key = 0;
            #20; // wait between presses
        end
    endtask

    // Display status
    initial begin
        $display("Time\tLocked\tKey");
        $monitor("%0t\t%b\t%h", $time, state, key);
    end

    // Waveform dump (optional)
    initial begin
        $dumpfile("digital_lock.vcd");
        $dumpvars(0, digital_lock_tb);
    end

endmodule
