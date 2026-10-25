`timescale 1ns / 1ps // interpret time units


//-------------------- TASK B -------------------------
module alu( //(Top-level integration)
    input  logic signed [7:0] x, y,//8-bit input
    input  logic [1:0] m, s,        //2-bit input (switch case)
    output logic signed [15:0] z //16-bit output
);
    logic [15:0] z_arith, z_shift, z_comp, z_logic; //output value for the modules

    // Instantiate submodules
    arithmetic        U1 (.x(x), .y(y), .m(m), .z(z_arith));
    shifter_rotator   U2 (.x(x), .y(y), .m(m), .z(z_shift));
    comparator        U3 (.x(x), .y(y), .m(m), .z(z_comp));
    logic_unit        U4 (.x(x), .y(y), .m(m), .z(z_logic));

    // Select which module output to use
    always_comb begin
        case(s) //(if 2 = 2'b00)
            2'b00: z = z_arith; // 00
            2'b01: z = z_shift; // 01
            2'b10: z = z_comp;  // 10
            2'b11: z = z_logic; // 11
        endcase
    end
endmodule


module arithmetic(
    input  logic signed [7:0] x, y, //8-bit input
    input  logic [1:0] m,  //2-bit input (switch case)
    output logic signed [15:0] z    //16-bit output
);
    always_comb begin
         case(m) // (if m = 2'b00)
            2'b00: z = x + y;       // add  (m=00)
            2'b01: z = x - y;       // sub  (m=01)
            2'b10: z = x * y;       // mult (m=10)
            default: z = 16'b0;     // if case = false/ (11) then (0000 0000 0000 0000)
        endcase
    end
endmodule


module shifter_rotator(
   input  logic signed [7:0] x, y, //8-bit input
   input  logic [1:0] m,        //2-bit input (switch case)
   output logic signed [15:0] z //16-bit output
);
    always_comb begin
        case(m) //case switch (if m = 2'b00)
            2'b00: z = {8'b0, (x >> y) | (x << (8 - y))};//Rotate right, shift x right by y then shift x left by whats left then combined with or
            2'b01: z = {8'b0, (x << y) | (x >> (8 - y))};//Rotate left, shift x left by y then shift x right by whats left then combined with or
            2'b10: z = {8'b0, (x >> y)};          // Shift right by y                 (m=10)
            2'b11: z = {8'b0, (x << y)};          // Shift left by y                  (m=11)
        endcase
    end
endmodule


module comparator(
    input  logic signed [7:0] x, y, //8-bit input
    input  logic [1:0] m,         //2-bit input (switch case)
    output logic signed [15:0] z //16-bit output
);
    always_comb begin
        case(m) //case switch (if m = 2'b00)
            2'b00: z = (x > y)  ? 16'd1 : 16'd0;      // if x > y then 16'd1 else 16'd0,    (m=00)
            2'b00: z = (x < y)  ? 16'd1 : 16'd0;      // if x < y then 16'd1 else 16'd0,    (m=01)
            2'b10: z = (x == y) ? 16'd1 : 16'd0;      // if x = y then 16'd1 else 16'd0     (m=10)
            2'b11: z = (x != y) ? 16'd1 : 16'd0;      // if x != y then 16'd1 else 16'd0    (m=11)
        endcase
    end
endmodule


module logic_unit(
    input  logic signed [7:0] x, y, //8-bit input
    input  logic [1:0] m,      //2-bit input (switch case)
    output logic signed [15:0] z //16-bit output
);
    always_comb begin
        case(m) //case switch (if m = 2'b00)
            2'b00: z = {8'b0, (x & y)};  // AND (m=00)
            2'b00: z = {8'b0, (x | y)};  // OR  (m=01)
            2'b10: z = {8'b0, (~x)};     // NOT (m=10)
            2'b11: z = {8'b0, (x ^ y)};  // XOR (m=11)
        endcase
    end
endmodule


