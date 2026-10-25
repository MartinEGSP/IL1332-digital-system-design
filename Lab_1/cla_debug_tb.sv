`timescale 1ns / 1ps

module cla_debug_tb;
    logic signed [7:0] a, b; 
    logic signed [7:0] sum;
    logic ovf, uvf;

    // DUT = your CLA with OVF/UVF
    cla_8bit_ovf_uvf dut (
        .a(a),
        .b(b),
        .sum(sum), 
        .ovf(ovf),
        .uvf(uvf)
    ); 
    

    initial begin
        $display("=== CLA Debug Testbench ===");

         // VCD dump for GTKWave
    $dumpfile("cla_debug.vcd");
    $dumpvars(0, cla_debug_tb);
        
        // Overflow test
        a = 127; #20ns;
        b = 1; #20ns;
        $display("\nOverflow test:"); 
        $display(" a=%0d b=%0d", a, b); 
        $display(" CLA result  = %0d (bin=%b)", sum, sum); 
        $display(" ovf=%b uvf=%b", ovf, uvf);

        // Underflow test
        a = -128; #20ns;
        b = -1; #20ns;
        $display("\nUnderflow test:"); 
        $display(" a=%0d b=%0d", a, b); 
        $display(" CLA result  = %0d (bin=%b)", sum, sum); 
        $display(" ovf=%b uvf=%b", ovf, uvf); 

        // Random checks
        $display("\nRandom value comparison:"); 
        a = 36; #20ns;
        b = -127; #20ns;
        $display(" a=%4d b=%4d | CLA=%4d (bin=%b) | ovf=%b uvf=%b", 
                 a, b, sum, sum, ovf, uvf); 

        a = 9; #20ns;
        b = 99; #20ns;
        $display(" a=%4d b=%4d | CLA=%4d (bin=%b) | ovf=%b uvf=%b", 
                 a, b, sum, sum, ovf, uvf); 

        a = 101; #20ns;
        b = 18; #20ns;
        $display(" a=%4d b=%4d | CLA=%4d (bin=%b) | ovf=%b uvf=%b", 
                 a, b, sum, sum, ovf, uvf);
        

        $display("\n=== Debug test completed ===");
        $finish;
    end
endmodule
