//------------ 7. Add saturation mechanism----------
`timescale 1ns / 1ps // interpret time units

module cla_8bit_sat_out_tb;
logic signed [7:0] a;
logic signed [7:0] b;
logic signed [7:0] sum;
logic ovf, uvf;

// Instantiate the Device Under Test (DUT)
cla_8bit_sat_out dut_cla(
    .a(a),
    .b(b),
    .sum(sum),
    .ovf(ovf),
    .uvf(uvf)
);


    initial begin
        // VCD dump for GTKWave
        $dumpfile("cla_8bit_sat_out.vcd");
        $dumpvars(0, cla_8bit_sat_out_tb);

        $display("=== CLA 8-bit Saturation Testbench ===");
        $display("   a     b   |   sum | ovf uvf");
        $display("-------------------------------------");
        #30ns;
        // Overflow test
        a = 127; b = 1; #30ns;
        $display("%5d %6d | %5d |  %b   %b", a, b, sum, ovf, uvf);

        // Underflow test
        a = -128; b = -1; #30ns;
        $display("%5d %6d | %5d |  %b   %b", a, b, sum, ovf, uvf);

        // Normal values
        a = 50; b = 25; #30ns;
        $display("%5d %6d | %5d |  %b   %b", a, b, sum, ovf, uvf);

        a = -40; b = 15; #30ns;
        $display("%5d %6d | %5d |  %b   %b", a, b, sum, ovf, uvf);

        $display("=== Test completed ===");
        $finish;
    end
endmodule
