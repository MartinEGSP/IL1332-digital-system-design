`timescale 1ns/1ps

// =======================================================
// Carry Lookahead Adder (CLA) modules - Clean version
// =======================================================

// Propagate logic: p = a OR b
module propagate_logic (
    input  logic a, b,
    output logic p
);
    assign p = a | b;
endmodule

// Generate logic: g = a AND b
module generate_logic (
    input  logic a, b,
    output logic g
);
    assign g = a & b;
endmodule

// Sum logic: sum = a XOR b XOR cin
module sum_logic (
    input  logic a, b, cin,
    output logic sum
);
    assign sum = a ^ b ^ cin;
endmodule

// 8-bit CLA
module cla_8bit (
    input  logic [7:0] a, b,
    output logic [8:0] sum  // 9 bits because of carry out
);
    logic [7:0] p, g; // propagate, generate
    logic [8:0] c;    // carry

    // propagate and generate bits
    assign p = a | b;
    assign g = a & b;

    // carry[0] = 0 (no input carry)
    assign c[0] = 1'b0;

    // carry equations (carry lookahead)
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[5] = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & g[0]) | (p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[6] = g[5] | (p[5] & g[4]) | (p[5] & p[4] & g[3]) | (p[5] & p[4] & p[3] & g[2]) | (p[5] & p[4] & p[3] & p[2] & g[1]) | (p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[7] = g[6] | (p[6] & g[5]) | (p[6] & p[5] & g[4]) | (p[6] & p[5] & p[4] & g[3]) | (p[6] & p[5] & p[4] & p[3] & g[2]) | (p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) | (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[8] = g[7] | (p[7] & g[6]) | (p[7] & p[6] & g[5]) | (p[7] & p[6] & p[5] & g[4]) | (p[7] & p[6] & p[5] & p[4] & g[3]) | (p[7] & p[6] & p[5] & p[4] & p[3] & g[2]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);

    // sum bits
    assign sum[7:0] = a ^ b ^ c[7:0];
    assign sum[8]   = c[8];  // carry-out
endmodule

// 8-bit CLA with overflow/underflow detection
module cla_8bit_ovf_uvf (
    input  logic signed [7:0] a, b,
    output logic signed [7:0] sum,
    output logic ovf, uvf
);
    logic [8:0] cla_sum;
    cla_8bit dut (.a(a), .b(b), .sum(cla_sum));

    assign sum = cla_sum[7:0];
    assign ovf = (~a[7] & ~b[7] & cla_sum[7]); // pos+pos -> neg
    assign uvf = ( a[7] &  b[7] & ~cla_sum[7]); // neg+neg -> pos
endmodule

// 8-bit CLA with saturation
module cla_8bit_sat_out (
    input  logic signed [7:0] a, b,
    output logic signed [7:0] sum,
    output logic ovf, uvf
);
    logic [8:0] cla_sum;
    cla_8bit dut (.a(a), .b(b), .sum(cla_sum));

    assign ovf = (~a[7] & ~b[7] & cla_sum[7]);
    assign uvf = ( a[7] &  b[7] & ~cla_sum[7]);

    assign sum = ovf ?  8'sd127 :
                 uvf ? -8'sd128 :
                        cla_sum[7:0];
endmodule
