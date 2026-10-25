//------------ 5. Simulate and verify your 8-bit CLA-----------
`timescale 1ns / 1ps // interpret time units

module cla_8bit_tb;
logic [7:0] a; 
logic [7:0] b;
logic [8:0] sum;

// Instantiate the Device Under Test (DUT)
cla_8bit dut_cla(
    .a(a),
    .b(b),
    .sum(sum)
);
initial begin
    $display("Starting Testbench step 5");
    
    // VCD dump for GTKWave
    $dumpfile("cla_8bit.vcd");
    $dumpvars(0, cla_8bit_tb);
    
    // Print table header
    $display(" a   b   sum   sum(bin)");
    $display("---------------------------");

    // Apply test vectors
    for (int x = 0; x < 7; x += 1) begin
        for (int y = 0; y < 7; y += 1) begin
            a = x; 
            b = y; #30
            $display("%2d  %2d  %3d   %09b", a, b, sum, sum);
        end
    end
    $display("Test completed");
    $finish;
end

endmodule
