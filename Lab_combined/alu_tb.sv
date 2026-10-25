`timescale 1ns / 1ps

module alu_tb;

    // DUT inputs
    logic [7:0] x, y;
    logic [1:0] s, m;

    // DUT output
    logic [15:0] z;

    // Instantiate DUT
    alu dut (
        .x(x),
        .y(y),
        .s(s),
        .m(m),
        .z(z)
    );

    // VCD dump for GTKWave
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

    // Task to apply and display one test
    task run_test(input [7:0] a, input [7:0] b, input [1:0] sel, input [1:0] mode);
        begin
            x = a; y = b; s = sel; m = mode;
            #5; // wait for signals to propagate
            $display("t=%0t | s=%b m=%b | x=%0d y=%0d | z=%0d (bin=%b)",
                      $time, s, m, x, y, z, z);
        end
    endtask

    // Main test process
    initial begin
        $display("===== ALU Testbench =====");

        // 1. Deterministic tests (cover every function at least once)
        run_test(8'd5,  8'd3, 2'b00, 2'b00); // ADD
        run_test(8'd5,  8'd3, 2'b00, 2'b01); // SUB
        run_test(8'd5,  8'd3, 2'b00, 2'b10); // MULT

        run_test(8'b10110010, 8'd1, 2'b01, 2'b00); // ROTATE RIGHT
        run_test(8'b10110010, 8'd2, 2'b01, 2'b01); // ROTATE LEFT
        run_test(8'b10110010, 8'd3, 2'b01, 2'b10); // SHIFT RIGHT
        run_test(8'b10110010, 8'd4, 2'b01, 2'b11); // SHIFT LEFT

        run_test(8'd7, 8'd5, 2'b10, 2'b00); // GREATER
        run_test(8'd2, 8'd9, 2'b10, 2'b01); // LESS
        run_test(8'd6, 8'd6, 2'b10, 2'b10); // EQUAL
        run_test(8'd4, 8'd7, 2'b10, 2'b11); // NOT EQUAL

        run_test(8'b1100, 8'b1010, 2'b11, 2'b00); // AND
        run_test(8'b1100, 8'b1010, 2'b11, 2'b01); // OR
        run_test(8'b1100, 8'b1010, 2'b11, 2'b10); // NOT
        run_test(8'b1100, 8'b1010, 2'b11, 2'b11); // XOR

        // 2. Randomized tests
        for (int i = 0; i < 20; i++) begin
            run_test($urandom_range(0,255), $urandom_range(0,255),
                     $urandom_range(0,3), $urandom_range(0,3));
        end

        $display("===== Test Completed =====");
        $finish;
    end

endmodule
