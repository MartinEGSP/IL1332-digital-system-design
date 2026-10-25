// === Built-in versions of CLA blocks (no NANDs) ===

// Propagate: p = a OR b
module propagate_logic_builtin (
    input  logic a, b,
    output logic p
);
    assign p = a | b;
endmodule

// Generate: g = a AND b
module generate_logic_builtin (
    input  logic a, b,
    output logic g
);
    assign g = a & b;
endmodule

// Sum: sum = a XOR b XOR cin
module sum_logic_builtin (
    input  logic a, b,
    input  logic cin,
    output logic sum
);
    assign sum = a ^ b ^ cin;
endmodule


// --- Carry logic slices ---
// c1 = g0 + p0·c0
module CLA_carry_logic_0_builtin (
    input  logic p0, g0, ci0,
    output logic co
);
    assign co = g0 | (p0 & ci0);
endmodule



















`timescale 1ns / 1ps // interpret time units

//2-input NAND-gate
module nand2_delay (
    input logic a, b,
    output logic y
);
assign #1 y = ~(a & b); //#1 = 1T delay
endmodule

//3-input NAND-gate
module nand3_delay (
    input logic a, b,
    input logic c,
    output logic y
);
assign #1.25 y = ~(a & b & c); //#1.25 = 1.25T delay
endmodule

//4-input NAND-gate
module nand4_delay (
    input logic a, b,
    input logic c, d,
    output logic y
);
assign #1.5 y = ~(a & b & c & d); //#1.5 = 1.5T delay
endmodule

//2-input XOR-gate
module xor2_delay (
    input logic a, b,
    output logic y
);
logic nand1_out, nand2_out;
logic nand3_out;

nand2_delay u1 (
    .a(a), .b(b),
    .y(nand1_out) // A nand B = y1
); 
nand2_delay u2 (
    .a(a), 
    .b(nand1_out),
    .y(nand2_out) // A nand y1 = y2
); 
nand2_delay u3 (
    .a(b), 
    .b(nand1_out), 
    .y(nand3_out) // B nand y1 = y3
); 
nand2_delay u4 (
    .a(nand2_out), 
    .b(nand3_out), 
    .y(y) // y2 nand y3 = XOR
); 
endmodule

//------1. Design and Simulate the Following Modules--------
module propagate_logic (
    input logic a, b,
    output logic p //A or B
);
logic nand1_out;
logic nand2_out;

nand2_delay u1 (
    .a(a), .b(a), 
    .y(nand1_out)
); 
nand2_delay u2 (
    .a(b), .b(b), 
    .y(nand2_out)
); 
nand2_delay u3 (
    .a(nand1_out), 
    .b(nand2_out), 
    .y(p)
    );
endmodule

module generate_logic (
    input logic a, b,
    output logic g //A and B
);
logic nand_out;

nand2_delay u1 (
    .a(a), .b(b),
    .y(nand_out)
); 
nand2_delay u2 (
    .a(nand_out), 
    .b(nand_out), 
    .y(g)
); 
endmodule



// /*
module sum_logic (
    input logic a, b,
    input logic cin,
    output logic sum
);
logic xor1_out;

xor2_delay u1 (
    .a(a), .b(b), 
    .y(xor1_out)
); 
xor2_delay u2 (
    .a(xor1_out), .b(cin), 
    .y(sum)
); 
endmodule/*/

module sum_logic (
    input  logic a, b,
    input  logic cin,
    output logic sum
);
    assign sum = a ^ b ^ cin;
endmodule*/








module CLA_carry_logic_0 ( // c1 = g0 + p0c0
input logic p0, g0,
input logic ci0,
output logic co
);
logic nand1_out, nand2_out;

nand2_delay u1 (
    .a(p0), .b(ci0),         
    .y(nand1_out)
);
nand2_delay u2 (
    .a(g0), .b(g0), 
    .y(nand2_out)
);
nand2_delay u3 (
    .a(nand1_out), 
    .b(nand2_out), 
    .y(co)
);
endmodule








// c2 = g1 + p1·g0 + p1·p0·c0
module CLA_carry_logic_1 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic ci0,
    output logic co
);
    assign co = g1 | (p1 & g0) | (p1 & p0 & ci0);
endmodule

// c3 = g2 + p2·g1 + p2·p1·g0 + p2·p1·p0·c0
module CLA_carry_logic_2 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic p2, g2,
    input  logic ci0,
    output logic co
);
    assign co = g2 
              | (p2 & g1) 
              | (p2 & p1 & g0) 
              | (p2 & p1 & p0 & ci0);
endmodule

// c4 = g3 + p3·g2 + p3·p2·g1 + p3·p2·p1·g0 + p3·p2·p1·p0·c0
module CLA_carry_logic_3 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic p2, g2,
    input  logic p3, g3,
    input  logic ci0,
    output logic co
);
    assign co = g3
              | (p3 & g2)
              | (p3 & p2 & g1)
              | (p3 & p2 & p1 & g0)
              | (p3 & p2 & p1 & p0 & ci0);
endmodule

// c5 = g4 + p4·g3 + p4·p3·g2 + p4·p3·p2·g1 + p4·p3·p2·p1·g0 + p4·p3·p2·p1·p0·c0
module CLA_carry_logic_4 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic p2, g2,
    input  logic p3, g3,
    input  logic p4, g4,
    input  logic ci0,
    output logic co
);
    assign co = g4
              | (p4 & g3)
              | (p4 & p3 & g2)
              | (p4 & p3 & p2 & g1)
              | (p4 & p3 & p2 & p1 & g0)
              | (p4 & p3 & p2 & p1 & p0 & ci0);
endmodule

// c6 = g5 + p5·g4 + p5·p4·g3 + p5·p4·p3·g2 + p5·p4·p3·p2·g1 + p5·p4·p3·p2·p1·g0 + p5·p4·p3·p2·p1·p0·c0
module CLA_carry_logic_5 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic p2, g2,
    input  logic p3, g3,
    input  logic p4, g4,
    input  logic p5, g5,
    input  logic ci0,
    output logic co
);
    assign co = g5
              | (p5 & g4)
              | (p5 & p4 & g3)
              | (p5 & p4 & p3 & g2)
              | (p5 & p4 & p3 & p2 & g1)
              | (p5 & p4 & p3 & p2 & p1 & g0)
              | (p5 & p4 & p3 & p2 & p1 & p0 & ci0);
endmodule

// c7 = g6 + p6·g5 + p6·p5·g4 + ... + p6·p5·p4·p3·p2·p1·p0·c0
module CLA_carry_logic_6 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic p2, g2,
    input  logic p3, g3,
    input  logic p4, g4,
    input  logic p5, g5,
    input  logic p6, g6,
    input  logic ci0,
    output logic co
);
    assign co = g6
              | (p6 & g5)
              | (p6 & p5 & g4)
              | (p6 & p5 & p4 & g3)
              | (p6 & p5 & p4 & p3 & g2)
              | (p6 & p5 & p4 & p3 & p2 & g1)
              | (p6 & p5 & p4 & p3 & p2 & p1 & g0)
              | (p6 & p5 & p4 & p3 & p2 & p1 & p0 & ci0);
endmodule

// c8 = g7 + p7·g6 + p7·p6·g5 + ... + p7·p6·p5·p4·p3·p2·p1·p0·c0
module CLA_carry_logic_7 (
    input  logic p0, g0,
    input  logic p1, g1,
    input  logic p2, g2,
    input  logic p3, g3,
    input  logic p4, g4,
    input  logic p5, g5,
    input  logic p6, g6,
    input  logic p7, g7,
    input  logic ci0,
    output logic co
);
    assign co = g7
              | (p7 & g6)
              | (p7 & p6 & g5)
              | (p7 & p6 & p5 & g4)
              | (p7 & p6 & p5 & p4 & g3)
              | (p7 & p6 & p5 & p4 & p3 & g2)
              | (p7 & p6 & p5 & p4 & p3 & p2 & g1)
              | (p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0)
              | (p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & ci0);
endmodule


module cla_8bit (
    input logic signed [7:0] a,
    input logic signed [7:0] b,
    output logic signed [8:0] sum
);
logic [7:0] p, g; //propagate and generate
logic [8:0] c;  //carry

// Initial carry-in
    assign c[0] = 1'b0;

// Propagate Logic
genvar i;
generate
    for (i = 0; i < 8; i++) 
        begin : generate_PL
            propagate_logic pl (
                .a(a[i]),
                .b(b[i]),
                .p(p[i])
            );
        end
endgenerate
// Generate Logic
genvar j;
generate
    for (j = 0; j < 8; j++) 
        begin : generate_GL 
            generate_logic gl (
                .a(a[j]), 
                .b(b[j]), 
                .g(g[j])
            );
        end
endgenerate



// Slice 0
CLA_carry_logic_0 cl0 (
    .p0(p[0]), 
    .g0(g[0]), 
    .ci0(c[0]),   // external carry-in is 0
    .co(c[1])
);
// Slice 1
CLA_carry_logic_1 cl1 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .ci0(c[0]),   // carry from cl0
    .co(c[2])
);
// Slice 2
CLA_carry_logic_2 cl2 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .p2(p[2]), .g2(g[2]),
    .ci0(c[0]),   // carry from cl1
    .co(c[3])
);
// Slice 3
CLA_carry_logic_3 cl3 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .p2(p[2]), .g2(g[2]), 
    .p3(p[3]), .g3(g[3]), 
    .ci0(c[0]),   // carry from cl2
    .co(c[4])
);
// Slice 4
CLA_carry_logic_4 cl4 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .p2(p[2]), .g2(g[2]), 
    .p3(p[3]), .g3(g[3]),
    .p4(p[4]), .g4(g[4]), 
    .ci0(c[0]),   // carry from cl3
    .co(c[5])
);
// Slice 5
CLA_carry_logic_5 cl5 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .p2(p[2]), .g2(g[2]), 
    .p3(p[3]), .g3(g[3]),
    .p4(p[4]), .g4(g[4]),
    .p5(p[5]), .g5(g[5]), 
    .ci0(c[0]),   // carry from cl4 
    .co(c[6])
);
// Slice 6
CLA_carry_logic_6 cl6 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .p2(p[2]), .g2(g[2]), 
    .p3(p[3]), .g3(g[3]),
    .p4(p[4]), .g4(g[4]),
    .p5(p[5]), .g5(g[5]),
    .p6(p[6]), .g6(g[6]), 
    .ci0(c[0]),   // carry from cl5
    .co(c[7])
);
// Slice 7
CLA_carry_logic_7 cl7 (
    .p0(p[0]), .g0(g[0]), 
    .p1(p[1]), .g1(g[1]), 
    .p2(p[2]), .g2(g[2]), 
    .p3(p[3]), .g3(g[3]),
    .p4(p[4]), .g4(g[4]),
    .p5(p[5]), .g5(g[5]),
    .p6(p[6]), .g6(g[6]),
    .p7(p[7]), .g7(g[7]), 
    .ci0(c[0]),   // carry from cl6
    .co(c[8])
);




// Sum Logic
genvar k;
generate
    for (k = 0; k < 8; k++) begin : SUM_BLOCK
        sum_logic sl (
            .a(a[k]),
            .b(b[k]),
            .cin(c[k]),
            .sum(sum[k])
        );
    end
endgenerate
assign sum[8] = c[8]; // The final MSB sum bit (sign extension)


endmodule


// 8-bit CLA with OVF and UVF detection (no built-in reference)
module cla_8bit_ovf_uvf (
input logic [7:0] a,
input logic [7:0] b,
output logic [7:0] sum,
output logic ovf, uvf
);
logic [8:0] cla_sum; //from cla_8-bit tb

cla_8bit dut (
    .a(a),
    .b(b),
    .sum(cla_sum)
);
assign sum = cla_sum[7:0]; 
assign ovf = (~a[7] & ~b[7] &  cla_sum[7]); //if both inputs are positive but result = negative then ovf
assign uvf = ( a[7] &  b[7] & ~cla_sum[7]); ///if both inputs are negative but result = positive then uvf
endmodule
