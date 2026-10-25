`timescale 1ns/1ps

// =====================================================
// Common NAND modules for all labs
// Implemented using assign statements with delay
// =====================================================

// 2-input NAND
module nand2_delay (
    input  logic a, b,
    output logic y
);
    assign #1 y = ~(a & b);
endmodule

// 3-input NAND
module nand3_delay (
    input  logic a, b, c,
    output logic y
);
    assign #1.25 y = ~(a & b & c);
endmodule

// 4-input NAND
module nand4_delay (
    input  logic a, b, c, d,
    output logic y
);
    assign #1.5 y = ~(a & b & c & d);
endmodule

// 5-input NAND
module nand5_delay (
    input  logic a, b, c, d, e,
    output logic y
);
    assign #1.75 y = ~(a & b & c & d & e);
endmodule

// 6-input NAND
module nand6_delay (
    input  logic a, b, c, d, e, f,
    output logic y
);
    assign #2 y = ~(a & b & c & d & e & f);
endmodule

// 7-input NAND
module nand7_delay (
    input  logic a, b, c, d, e, f, g,
    output logic y
);
    assign #2.25 y = ~(a & b & c & d & e & f & g);
endmodule

// 8-input NAND
module nand8_delay (
    input  logic a, b, c, d, e, f, g, h,
    output logic y
);
    assign #2.5 y = ~(a & b & c & d & e & f & g & h);
endmodule

// 9-input NAND
module nand9_delay (
    input  logic a, b, c, d, e, f, g, h, i,
    output logic y
);
    assign #2.75 y = ~(a & b & c & d & e & f & g & h & i);
endmodule
