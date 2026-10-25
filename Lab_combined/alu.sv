`timescale 1ns / 1ps // interpret time units


//-------------------- TASK B -------------------------
// Top-level ALU integration
module alu(
    input  logic [7:0] x, y,    // 8-bit input
    input  logic [1:0] m, s,           // 2-bit input (switch case)
    output logic [15:0] z       // 16-bit output
);
    logic [15:0] z_arith, z_shift, z_comp, z_logic; // output values from the modules

    // Instantiate submodules
    arithmetic        U1 (.x(x), .y(y), .m(m), .z(z_arith)); //gives the values
    shifter_rotator   U2 (.x(x), .y(y), .m(m), .z(z_shift));
    comparator        U3 (.x(x), .y(y), .m(m), .z(z_comp));
    logic_unit        U4 (.x(x), .y(y), .m(m), .z(z_logic));

    // Select which module output to use
    always_comb begin
        case(s) //(if 2 = 2'b00)
            2'b00: z = z_arith; // 00 = Arithmetic unit
            2'b01: z = z_shift; // 01 = Shifter/Rotator unit
            2'b10: z = z_comp;  // 10 = Comparator unit
            2'b11: z = z_logic; // 11 = Logic unit
            default: z = 16'd0;
        endcase
    end
endmodule



//-------------------- Arithmetic unit -------------------------
// Uses cla_8bit from Lab 1 and mult_mnbit from Lab 2
module arithmetic(
    input  logic signed [7:0] x, y, // 8-bit input
    input  logic [1:0] m,           // 2-bit input (switch case)
    output logic signed [15:0] z    // 16-bit output
);
    logic [8:0] cla_sum;   // 9-bit output from CLA
    logic [15:0] mult_out; // multiplier output

    // Instantiate CLA (Lab 1)
    cla_8bit cla_add (
        .a(x),
        .b(y),
        .sum(cla_sum)
    );

    // Instantiate multiplier (Lab 2)
    mult_mnbit #(8,8) mult_unit (
        .a(x),
        .b(y),
        .product(mult_out)
    );

    logic signed [15:0] cla_extended; // declares sign-extended CLA output
    assign cla_extended = {{7{cla_sum[8]}}, cla_sum}; //program didnt like constant in alway_comb

    always_comb begin
        case(m) // (if m = 2'b00)
            //2'b00: z = {{7{cla_sum[8]}}, cla_sum}; // ADD using CLA, sign-extended to 16 bits
            2'b00: z = cla_extended; 
            2'b01: z = x - y;                      // SUB still behavioral (CLA is only addition)
            2'b10: z = mult_out;                   // MULT using mult_mnbit
            default: z = 16'b0;                    // if no case matches then (0000 0000 0000 0000)
        endcase
    end
endmodule



//-------------------- Shifter / Rotator -------------------------
//New shifter/rotater since the one from Lab 2 is only one input
module shifter_rotator(
   input  logic signed [7:0] x, y, // 8-bit input
   input  logic [1:0] m,           // 2-bit input (switch case)
   output logic signed [15:0] z    // 16-bit output
);
    always_comb begin
        case(m) // case switch (if m = 2'b00)
            2'b00: z = {8'b0, (x >> y) | (x << (8 - y))}; // Rotate right, shift x right by y then shift x left by whats left then combined with or
            2'b01: z = {8'b0, (x << y) | (x >> (8 - y))}; // Rotate left, shift x left by y then shift x right by whats left then combined with or
            2'b10: z = {8'b0, (x >> y)};                  // Shift right by y                 (m=10)
            2'b11: z = {8'b0, (x << y)};                  // Shift left by y                  (m=11)
            default: z = 16'd0;
        endcase
    end
endmodule

//-------------------- Comparator -------------------------
module comparator(
    input  logic signed [7:0] x, y, // 8-bit input
    input  logic [1:0] m,           // 2-bit input (switch case)
    output logic signed [15:0] z    // 16-bit output
);
    always_comb begin
        case(m) // case switch (if m = 2'b00)
            2'b00: z = (x > y)  ? 16'd1 : 16'd0;      // if x > y then 16'd1 else 16'd0    (m=00)
            2'b01: z = (x < y)  ? 16'd1 : 16'd0;      // if x < y then 16'd1 else 16'd0    (m=01)
            2'b10: z = (x == y) ? 16'd1 : 16'd0;      // if x = y then 16'd1 else 16'd0    (m=10)
            2'b11: z = (x != y) ? 16'd1 : 16'd0;      // if x != y then 16'd1 else 16'd0   (m=11)
            default: z = 16'd0;
        endcase
    end
endmodule

//-------------------- Logic unit -------------------------
module logic_unit(
    input  logic signed [7:0] x, y, // 8-bit input
    input  logic [1:0] m,           // 2-bit input (switch case)
    output logic signed [15:0] z    // 16-bit output
);
    always_comb begin
        case(m) // case switch (if m = 2'b00)
            2'b00: z = {8'b0, (x & y)};  // AND (m=00)
            2'b01: z = {8'b0, (x | y)};  // OR  (m=01)
            2'b10: z = {~x, ~y};         // NOT (m=10)  up=~x, lo=~y
            2'b11: z = {8'b0, (x ^ y)};  // XOR (m=11)
            default: z = 16'd0;
        endcase
    end
endmodule

//-------------------- TASK C -------------------------
module alu4 ( //small version
    input  logic [3:0] x, y,
    input  logic [1:0] s, m,
    output logic [7:0] z
);
    // instantiate smaller modules 
    always_comb begin
        case (s)
            2'b00: case (m) //Arithmetic unit
                2'b00: z = x + y;      // add
                2'b01: z = x - y;      // sub
                2'b10: z = x * y;      // mult
                default: z = 8'd0;
            endcase
            2'b01: case (m) //Shifter / Rotator
                2'b00: z = {4'b0, (x >> y) | (x << (4 - y))}; // Rotate right
                2'b01: z = {4'b0, (x << y) | (x >> (4 - y))}; // Rotate left
                2'b10: z = {4'b0, (x >> y)};                  // Shift right
                2'b11: z = {4'b0, (x << y)};                  // Shift left
                default: z = 8'd0;
            endcase
            2'b10: case (m) //Comparator
                2'b00: z = (x > y)  ? 8'd1 : 8'd0;
                2'b01: z = (x < y)  ? 8'd1 : 8'd0;
                2'b10: z = (x == y) ? 8'd1 : 8'd0;
                2'b11: z = (x != y) ? 8'd1 : 8'd0;
                default: z = 8'd0;
            endcase
            2'b11: case (m) //Logic unit
                2'b00: z = {4'b0, (x & y)};
                2'b01: z = {4'b0, (x | y)};
                2'b10: z = {~x, ~y}; //not x, not y
                2'b11: z = {4'b0, (x ^ y)};
                default: z = 8'd0;
            endcase
        endcase
    end
endmodule
