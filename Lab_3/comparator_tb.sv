`timescale 1ns/1ps

module comparator_tb;
    logic [3:0] a, b;
    logic gt, lt, eq;

    comparator4 dut(.a(a), .b(b), .gt(gt), .lt(lt), .eq(eq));

    initial begin
        $dumpfile("comparator_tb.vcd");
        $dumpvars(0, comparator_tb);

        $display(" a   b  | gt lt eq");

        // exhaustive test
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                a = i; b = j; #1;
                $display("%2d  %2d |  %b  %b  %b", a, b, gt, lt, eq);
            end
        end

        $finish;
    end
endmodule
