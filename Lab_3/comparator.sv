module comparator4 (
    input  logic [3:0] a, b,
    output logic gt, lt, eq //gt = greater then, lt = lower then, eq = equal
);
    // slice outputs
    logic g_up, l_up, e_up; //g_up = greater upper-bits, l_up = less upper-bits, e_up = equal upper-bits
    logic g_lo, l_lo, e_lo; //g_lo = greater lower-bits, l_lo = less lower-bits, e_lo = equal lower-bits

    // upper 2 bits
    comparator_slice hi ( 
        .a(a[3:2]), .b(b[3:2]), //upper
        .g(g_up), .l(l_up), .e(e_up)
    );

    // lower 2 bits
    comparator_slice lo ( 
        .a(a[1:0]), .b(b[1:0]), //lower
        .g(g_lo), .l(l_lo), .e(e_lo)
    );

    // combine results 
    assign gt = g_up | (e_up & g_lo);   // a > b if (upper bits say a > b) OR (upper bits are equal AND lower bits say a > b)
    assign lt = l_up | (e_up & l_lo);   // a < b if (upper bits say a < b) OR (upper bits are equal AND lower bits say a < b)
    assign eq = e_up & e_lo;            // equal only if both slices are equal
endmodule


module comparator_slice (
    input  logic [1:0] a, b,
    output logic g,  // a > b
    output logic l,  // a < b
    output logic e   // a == b
);
    always_comb begin //compare input of a and b, both upper and lower
        if (a > b) begin
            g = 1; l = 0; e = 0;
        end else if (a < b) begin
            g = 0; l = 1; e = 0;
        end else begin
            g = 0; l = 0; e = 1;
        end
    end
endmodule
