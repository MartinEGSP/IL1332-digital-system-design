//------- 6. Modify 8-bit CLA to 8-bit CLA with OVF and UVF detection------
`timescale 1ns / 1ps

module cla_8bit_ovf_uvf_tb;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic signed [7:0] sum;
    logic ovf, uvf;

    // DUT
    cla_8bit_ovf_uvf dut_cla (
        .a(a),
        .b(b),
        .sum(sum),
        .ovf(ovf),
        .uvf(uvf)
    );
   
    initial begin
        // VCD dump for GTKWave
        $dumpfile("cla_8bit_ovf_uvf.vcd");
        $dumpvars(0, cla_8bit_ovf_uvf_tb);
        #40ns;
        $display("  a     b     sum  ovf    uvf"); 
        // Overflow test
        a = 8'sd127;  
        b = 8'sd1; 
        #40ns;
        $display("%4d  %3d  %3d  %4b  %4b", a, b, sum, ovf, uvf);

        // Underflow test
        a = -8'sd128;  
        b = -8'sd1; 
        #40ns;
        $display("%3d  %3d  %4d  %4b  %4b", a, b, sum, ovf, uvf);
     
        $finish;
    end
endmodule
